SELECT MAX(NUM_MANDAT)
FROM MANDAT
WHERE GESTION = '2022'
  AND CODE_ORD = '00107008'
  AND NUM_CPT_G = '402001011'
  AND CODE_MANDAT = '1125'
  AND TYPE_SERVICE = 'WL'
;
-------------------------------------------------------------------
SELECT COUNT(CODE_PERS)
FROM BENIF_MANDAT
WHERE BENIF_MANDAT.NUM_MANDAT = NVL('87229', 'VIDE')
;
-------------------------------------------------------------------
SELECT COUNT(CODE_PERS)
FROM BENIF_MANDAT
WHERE BENIF_MANDAT.NUM_MANDAT = '87229'
  AND CODE_PERS = '000'
;
-------------------------------------------------------------------
SELECT ROWID,GESTION,
             NUM_CPT_G,
             CODE_ORD,
             CODE_MANDAT,
             dt_admission,
             NUM_MANDAT,
             objet_pay,
             MOD_PAY,
             banque,
             CPT_CREDIT,
             PST_COMPTA,
             DT_EMISSION,
             MT_BRUT,
             NAT_REF,
             REFERENCE,
             NUM_REJET,
             MOTIF_REJET,
             NOTE_VERIF,
             STATUT,
             TYPE_SERVICE,
             SI_ADMIS,
             SI_ADMIS_DEC,
             AGENT_ADMIS,
             MT_NET
FROM MANDAT
WHERE STATUT IN ('ADMIS',
                 'EMIS')
  AND TYPE_SERVICE='WL'
  AND (GESTION='2022')
  AND (NUM_CPT_G='402001011')
  AND (CODE_ORD='00107008')
  AND (CODE_MANDAT='1125')
  AND (NUM_MANDAT='87229')
;
-------------------------------------------------------------------
SELECT NUM_MANDAT
FROM MANDAT
WHERE NUM_MANDAT = '87229'
  FOR
  UPDATE NOWAIT
;
-------------------------------------------------------------------
SELECT LIB_CPT_G
FROM NOMENC
WHERE NUM_CPT_G = '402001011'
;
-------------------------------------------------------------------
SELECT LIBELLE_ORD
FROM ORDONNATEUR
WHERE CODE_ORD = '00107008'
;
-------------------------------------------------------------------
SELECT ROWID,NAT_CRE,
             CODE_SEC,
             NUM_MANDAT,
             CODE_CHAPITRE
FROM MANDAT_CHAPITRE
WHERE (NUM_MANDAT='87229')
ORDER BY CODE_SEC,
         CODE_CHAPITRE
;
-------------------------------------------------------------------
SELECT LIBELLE
FROM ARTICLE
WHERE CODE_CHAP = '9500'
  AND CODE_SECT = '2'
  AND TYPE_CREDIT = 'WL'
  AND CODE_ART = '00'
;
-------------------------------------------------------------------
SELECT LIB_SEC
FROM SECTION
WHERE CODE_SEC = '2'
  AND TYPE_CREDIT = 'WL'
;
-------------------------------------------------------------------
SELECT SUM(NVL(MANDAT_ARTICLE.MT_OPER, 0) - NVL(MANDAT_ARTICLE.MT_REJETE, 0))
FROM MANDAT_ARTICLE
WHERE MANDAT_ARTICLE.NUM_MANDAT = '87229'
  AND MANDAT_ARTICLE.CODE_SEC = '2'
  AND MANDAT_ARTICLE.CODE_CHAP_SAISI = '9500'
;
-------------------------------------------------------------------
SELECT SUM(NVL(MANDAT_ARTICLE.MT_OPER, 0))
FROM MANDAT_ARTICLE
WHERE MANDAT_ARTICLE.NUM_MANDAT = '87229'
  AND MANDAT_ARTICLE.CODE_SEC = '2'
  AND MANDAT_ARTICLE.CODE_CHAP_SAISI = '9500'
;
-------------------------------------------------------------------
SELECT ROWID,NUM_MANDAT,
             NAT_CRE,
             CODE_SEC,
             CODE_CHAPITRE,
             CODE_CHAP_SAISI,
             CODE_ARTICLE,
             MT_OPER,
             MT_REJETE
FROM MANDAT_ARTICLE
WHERE (NUM_MANDAT='87229')
  AND (CODE_SEC='2')
  AND (CODE_CHAP_SAISI='9500')
ORDER BY CODE_ARTICLE
;
-------------------------------------------------------------------
SELECT LIB_ART
FROM ARTICLE
WHERE CODE_ART = '231'
  AND CODE_CHAP = '9500'
;
-------------------------------------------------------------------
SELECT ROWID,NUM_MANDAT,
             CODE_ARTICLE,
             CODE_CHAPITRE,
             CODE_SEC,
             PROGRAM,
             MT_OPER,
             MT_REJETE
FROM MANDAT_PROGRAM
WHERE (NUM_MANDAT='87229')
  AND (CODE_ARTICLE='231')
  AND (CODE_CHAPITRE='9500')
  AND (CODE_SEC='2')
;
-------------------------------------------------------------------
SELECT LIB_OPER
FROM LIGNE_CREDIT
WHERE PROGRAM = '19022'
  AND SECTION = '2'
  AND CHAPITRE = '9500'
  AND ARTICLE = '231'
  AND CODE_CPT = '402001011'
  AND CODE_ORD = '00107008'
  AND TYPE_NOMENC = 'WL'
  AND GESTION = '2022'
  AND LIB_OPER IS NOT NULL
;
-------------------------------------------------------------------
SELECT ROWID,NUM_LIGNE_C,
             MT_NET,
             CPT_CREDIT,
             CODE_PRECPT,
             RIB_LIGNE,
             CREDIT_LIGNE,
             MT_REJET,
             NUM_MANDAT,
             CODE_OPER
FROM LIGNE_mandat
WHERE (NUM_MANDAT='87229')
;
-------------------------------------------------------------------
SELECT lib_banque,
       code_banque
FROM banque
ORDER BY 1
;
-------------------------------------------------------------------
SELECT ROWID,NUM_LIGNE,
             NUM_MANDAT,
             CODE_PERS,
             NUM_COMPTE_S,
             BANQUE,
             MT_INIT,
             MT_REJET,
             MT_BENIF,
             NUM_COMPTE,
             NOM_CHARGE
FROM BENIF_MANDAT
WHERE (NUM_MANDAT='87229')
;
-------------------------------------------------------------------
SELECT NOM
FROM PERSONNE
WHERE CODE_PERS = '9130'
;
-------------------------------------------------------------------
SELECT ROWID,NUM_MANDAT,
             CODE_CHAPITRE
FROM MANDAT_CHAP_EMIS
WHERE (NUM_MANDAT='87229')
;
-------------------------------------------------------------------
SELECT MANDAT_BANQ
FROM PARAM_APP
;
-------------------------------------------------------------------
