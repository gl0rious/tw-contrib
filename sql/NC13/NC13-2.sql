
WITH deps_mois AS
(
  SELECT m.CODE_ORD ORD,
         ma.CODE_CHAPITRE chap,
         SUM(ma.mt_net) dep
  FROM mandat m,
       mandat_article ma
  WHERE m.NUM_MANDAT = ma.NUM_MANDAT --
  AND   m.CODE_ORD = '103301' --
  AND   ma.CODE_CHAPITRE = '3122'
  AND   m.gestion = '2022'
  AND   m.type_service = 'BF'
  AND   m.mois = '05'
  GROUP BY m.CODE_ORD,
           ma.CODE_CHAPITRE,
           m.mois
  ORDER BY ORD,
           chap,
           mois DESC
),
deps_ant AS
(
  SELECT m.CODE_ORD ORD,
         ma.CODE_CHAPITRE chap,
         SUM(ma.mt_net) dep
  FROM mandat m,
       mandat_article ma
  WHERE m.NUM_MANDAT = ma.NUM_MANDAT --
  AND   m.CODE_ORD = '103301' --
  AND   ma.CODE_CHAPITRE = '3122'
  AND   m.gestion = '2022'
  AND   m.type_service = 'BF'
  AND   m.mois < '05'
  GROUP BY m.CODE_ORD,
           ma.CODE_CHAPITRE
  ORDER BY ORD,
           chap DESC
),
credit AS
(
  SELECT CODE_ORD ORD,
         CODE_CHAP chap,
         TOT_CREDIT,
         REIMPUT
  FROM (SELECT ROW_NUMBER() OVER (PARTITION BY CODE_ORD,CODE_CHAP ORDER BY MOIS DESC) rn,
               CODE_ORD,
               CODE_CHAP,
               MOIS,
               TOT_CREDIT,
               (NVL(REIMPUT_PLUS,0) - NVL(REIMPUT_MOINS,0)) REIMPUT
        FROM TAB_CREDIT
        WHERE TYPE_NOMENC = 'BF'
        AND   GESTION = '2022'
        AND   MOIS <= '05')
  WHERE rn = 1
  ORDER BY 1,
           2
),
ordchap as (
SELECT N.CODE_ORD ord, N.CHAPITRE chap       
FROM NOMENC_BUD N
WHERE N.TYPE_NOMENC = 'BF'
  AND SUBSTR(N.CODE_CPT, 1, 6) = SUBSTR('202001000', 1, 6)
  AND GESTION = '2022'
UNION
SELECT MANDAT.CODE_ORD, CODE_CHAPITRE       
FROM MANDAT,
     MANDAT_CHAPITRE
WHERE MANDAT.TYPE_SERVICE = 'BF'
  AND MANDAT.NUM_MANDAT = MANDAT_CHAPITRE.NUM_MANDAT
  AND GESTION = '2022'
  AND STATUT NOT IN ('EMIS',
                     'ADMIS')
ORDER BY 2,1
)
SELECT ordchap.ord ORD,
       ordchap.chap chap,
       credit.tot_credit,
       nvl(deps_ant.dep,0) dep_ant,
       nvl(deps_mois.dep,0) dep_mois,
       credit.reimput,
       (nvl(deps_mois.dep,0) + nvl(deps_ant.dep,0)) dep_tot,
       (credit.tot_credit -(nvl (deps_mois.dep,0) + nvl (deps_ant.dep,0))) solde
FROM ordchap
  LEFT JOIN deps_mois
         ON ordchap.ord = deps_mois.ord
        AND ordchap.chap = deps_mois.chap
  LEFT JOIN deps_ant
         ON ordchap.ord = deps_ant.ord
        AND ordchap.chap = deps_ant.chap
  JOIN credit
    ON ordchap.ord = credit.ord
   AND ordchap.chap = credit.chap
ORDER BY ORD,
         chap