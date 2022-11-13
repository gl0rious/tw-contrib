SELECT ALL ORDONNATEUR.CODE_ORD,
           ORDONNATEUR.LIBELLE_ORD
FROM ORDONNATEUR
WHERE nvl(TYPE_SERVICE, 'BF') IN ('BF',
                                  'RC')
  AND SUBSTR(ORDONNATEUR.CODE_ORD, 1, 1)!='2'
ORDER BY 1
;
-------------------------------------------------------------------
SELECT DISTINCT NOMENC_BUD.chapitre
FROM NOMENC_BUD
WHERE TYPE_NOMENC='BF'
  AND SUBSTR(NOMENC_BUD.CODE_CPT, 1, 6) = SUBSTR('202001031', 1, 6)
  AND NOMENC_BUD.CODE_ORD = '110308'
  AND ARTICLE IS NULL
  AND NOMENC_BUD.GESTION = '2022'
ORDER BY 1
;
-------------------------------------------------------------------
SELECT LIBELLE
FROM ARTICLE
WHERE CODE_CHAP = '3111'
;
-------------------------------------------------------------------
SELECT ALL ARTICLE CODE_ART,
           libelle LIB_ART,
           chapitre CODE_CHAP
FROM NOMENC_BUD
WHERE TYPE_NOMENC='BF'
  AND CHAPITRE='3111'
  AND ARTICLE IS NOT NULL
  AND SUBSTR(NOMENC_BUD.CODE_CPT, 1, 6) = SUBSTR('202001031', 1, 6)
  AND NOMENC_BUD.CODE_ORD = '110308'
  AND NOMENC_BUD.GESTION = '2022'
ORDER BY 1
;
-------------------------------------------------------------------
SELECT 1
FROM CREDIT,
     LIGNE_CREDIT
WHERE CREDIT.CODE_CREDIT = LIGNE_CREDIT.CODE_CREDIT
  AND CREDIT.CODE_CPT = '202001031'
  AND CREDIT.CODE_ORD = '110308'
  AND CREDIT.TYPE_NOMENC IN ('GF')
  AND LIGNE_CREDIT.CHAPITRE = '3111'
  AND LIGNE_CREDIT.ARTICLE = '00'
  AND CREDIT.GESTION = '2022'
  AND CREDIT.DT_REF > TO_DATE('31-Oct-2022')
  AND DT_ANNUL IS NULL
;
-------------------------------------------------------------------
-------------------------------------------------------------------
SELECT SOLDE
FROM TAB_CREDIT
WHERE CODE_CPT = '202001031'
  AND CODE_ORD = '110308'
  AND TYPE_NOMENC = 'RF'
  AND CODE_CHAP = '3111'
  AND CODE_ART = '00'
  AND (GESTION = '2022'
       AND MOIS <= TO_CHAR(TO_DATE('31-Oct-2022'), 'MM'))
ORDER BY GESTION DESC,
         MOIS DESC
;
-------------------------------------------------------------------
SELECT SOLDE
FROM TAB_CREDIT
WHERE CODE_CPT = '202001031'
  AND CODE_ORD = '110308'
  AND TYPE_NOMENC = 'GF'
  AND CODE_CHAP = '3111'
  AND CODE_ART = '00'
  AND GESTION = '2022'
  AND MOIS <= TO_CHAR(TO_DATE('31-Oct-2022'), 'MM')
ORDER BY GESTION DESC,
         MOIS DESC
;
-------------------------------------------------------------------
SELECT NVL(MAX(NUM_BORDEREAU), 0) + 1
FROM CREDIT
WHERE CREDIT.GESTION = '2022'
  AND TYPE_NOMENC = 'GF'
  AND CREDIT.CODE_ORD = '110308'
  AND DT_ANNUL IS NULL
  AND EXISTS
    (SELECT 1
     FROM LIGNE_CREDIT
     WHERE LIGNE_CREDIT.CODE_CREDIT = CREDIT.CODE_CREDIT
       AND LIGNE_CREDIT.CHAPITRE = '3111'
       AND LIGNE_CREDIT.ARTICLE = '00' )
;
-------------------------------------------------------------------
-------------------------------------------------------------------
