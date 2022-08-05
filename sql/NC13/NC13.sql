
with deps_mois as (
select m.CODE_ORD ord, ma.CODE_CHAPITRE chap, sum(ma.mt_net) dep
from mandat m, mandat_article ma
where m.NUM_MANDAT=ma.NUM_MANDAT
--and m.CODE_ORD='103301'
--and ma.CODE_CHAPITRE = '3122'
and m.gestion='2022'
and m.type_service='BF'
and m.mois='05'
group by m.CODE_ORD, ma.CODE_CHAPITRE, m.mois
order by ord, chap, mois desc
),
deps_ant as (
select m.CODE_ORD ord, ma.CODE_CHAPITRE chap, sum(ma.mt_net) dep
from mandat m, mandat_article ma
where m.NUM_MANDAT=ma.NUM_MANDAT
--and m.CODE_ORD='103301'
--and ma.CODE_CHAPITRE = '3122'
and m.gestion='2022'
and m.type_service='BF'
and m.mois<'05'
group by m.CODE_ORD, ma.CODE_CHAPITRE
order by ord, chap desc
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
),
credit as (
select CODE_ORD ord, CODE_CHAP chap, TOT_CREDIT, REIMPUT from (
SELECT ROW_NUMBER() OVER (PARTITION BY CODE_ORD, CODE_CHAP ORDER BY MOIS desc) rn,
CODE_ORD, CODE_CHAP, MOIS, TOT_CREDIT,
       (NVL(REIMPUT_PLUS, 0) - NVL(REIMPUT_MOINS, 0)) REIMPUT
FROM TAB_CREDIT
WHERE TYPE_NOMENC = 'BF'
  AND GESTION = '2022'
  AND MOIS <= '05' )
  where rn = 1
  order by 1,2
)
select ordchap.ord ord, ordchap.chap chap, credit.tot_credit, nvl(deps_ant.dep,0) dep_ant, nvl(deps_mois.dep,0) dep_mois, credit.reimput,
        (nvl(deps_mois.dep,0) + nvl(deps_ant.dep,0)) dep_tot, (credit.tot_credit - (nvl(deps_mois.dep,0) + nvl(deps_ant.dep,0))) solde
from ordchap 
left join deps_mois on ordchap.ord=deps_mois.ord and ordchap.chap=deps_mois.chap
left join deps_ant on ordchap.ord=deps_ant.ord and ordchap.chap=deps_ant.chap
join credit on ordchap.ord=credit.ord and ordchap.chap=credit.chap
order by ord, chap;