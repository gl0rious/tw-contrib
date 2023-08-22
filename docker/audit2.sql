SELECT lib_banque,
       code_banque
FROM banque
ORDER BY 1
;
-------------------------------------------------------------------
SELECT libELLE,
       code_MODE
FROM MODE_PAIE
ORDER BY POSITION
;
-------------------------------------------------------------------
SELECT libELLE,
       code_OBJET
FROM OBJET_PAIE
ORDER BY 2
;
-------------------------------------------------------------------
SELECT ROWID,GESTION,
             NUM_CPT_G,
             CODE_ORD,
             CODE_MANDAT,
             JOURNEE,
             MOIS,
             DT_REGLEMENT,
             dt_admission,
             NUM_MANDAT,
             CPT_CREDIT,
             DT_EMISSION,
             MT_BRUT,
             NUM_ANAL,
             MT_rejete,
             NAT_REF,
             REFERENCE,
             AGENT_EMIS,
             AGENT_ADMIS,
             AGENT_DISPO,
             AGENT_OPPOS,
             AGENT_REG,
             STATUT,
             TYPE_SERVICE,
             MT_NET,
             SI_REGLE,
             MOTIF_REJET,
             NOTE_VERIF,
             DT_DISPO,
             DT_OPPOS,
             objet_pay,
             MOD_PAY,
             PST_COMPTA
FROM MANDAT
WHERE NUM_MANDAT='87229'
;
-------------------------------------------------------------------
SELECT MAX(LIB_CPT_G)
FROM NOMENC
WHERE NUM_CPT_G = '402001011'
;
-------------------------------------------------------------------
SELECT MAX(LIBELLE_ORD)
FROM ORDONNATEUR
WHERE CODE_ORD = '00107008'
  AND TYPE_SERVICE = 'WL'
;
-------------------------------------------------------------------
SELECT MAX(UTILIS)
FROM UTILISATEUR_APP
WHERE NOM_UTILIS = 'AHMEDA'
;
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
SELECT MAX(UTILIS)
FROM UTILISATEUR_APP
WHERE NOM_UTILIS = ' '
;
-------------------------------------------------------------------
-------------------------------------------------------------------
SELECT ROWID,CPT_CREDIT,
             PST_TRSF,
             CODE_REC,
             CODE_PRECPT,
             RIB_LIGNE,
             CREDIT_LIGNE,
             MT_REJET,
             NUM_MANDAT,
             si_cloture
FROM LIGNE_mandat
WHERE (NUM_MANDAT='87229')
;
-------------------------------------------------------------------
SELECT ROWID,NUM_RECEP,
             NUM_MANDAT,
             NUM_OPPOSIT,
             DT_OPER,
             CPT_CREDITER,
             MT_PAYE
FROM PAIEMENT_OPPOS
WHERE (NUM_MANDAT='87229')
;
-------------------------------------------------------------------
SELECT ROWID,CODE_SEC,
             NAT_CRE,
             NUM_MANDAT,
             CODE_CHAPITRE
FROM MANDAT_CHAPITRE
WHERE nat_cre='C'
  AND (NUM_MANDAT='87229')
ORDER BY CODE_CHAPITRE DESC
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
SELECT ROWID,NUM_MANDAT,
             CODE_CHAPITRE,
             CODE_CHAP_SAISI,
             CODE_ARTICLE,
             MT_OPER,
             MT_REJETE
FROM MANDAT_ARTICLE
WHERE nat_cre='C'
  AND (NUM_MANDAT='87229')
  AND (CODE_CHAPITRE='9500')
;
-------------------------------------------------------------------
SELECT LIB_ART
FROM ARTICLE
WHERE CODE_ART = '231'
  AND CODE_CHAP = '9500'
;
-------------------------------------------------------------------
SELECT ROWID,NUM_MANDAT,
             CODE_PERS,
             NUM_COMPTE_S,
             BANQUE,
             MT_BENIF,
             si_cloture
FROM BENIF_MANDAT
WHERE (NUM_MANDAT='87229')
;
-------------------------------------------------------------------
SELECT NOM,
       PRENOM
FROM PERSONNE
WHERE CODE_PERS = '9130'
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
;
-------------------------------------------------------------------
SELECT LIB_OPER
FROM LIGNE_CREDIT
WHERE PROGRAM = '19022'
  AND LIB_OPER IS NOT NULL
;
-------------------------------------------------------------------
SELECT CPT_CREDITER,
       SUM(MT_PAYE)
FROM PAIEMENT_OPPOS
WHERE NUM_MANDAT = '87229'
GROUP BY CPT_CREDITER
;
-------------------------------------------------------------------
