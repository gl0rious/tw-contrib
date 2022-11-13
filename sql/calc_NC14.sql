DROP TYPE t_nc14_tab;
DROP TYPE t_nc14_row;
DROP FUNCTION calc_NC14;

CREATE OR REPLACE TYPE t_nc14_row AS OBJECT (
    code_cpt VARCHAR2(20), 
    credit NUMBER,
    blocage NUMBER,
    dep_anter NUMBER,
    dep_mois NUMBER,
    reimput NUMBER,
    dep_annul NUMBER,
    dep_total NUMBER,
    solde NUMBER
);

CREATE OR REPLACE TYPE t_nc14_tab IS TABLE OF t_nc14_row;



CREATE OR REPLACE FUNCTION calc_NC14 (
    p_gestion IN VARCHAR2, p_mois IN VARCHAR2
) RETURN t_nc14_tab IS 
  nc14_tab t_nc14_tab;
BEGIN    
SELECT  t_nc14_row(code_cpt,
credit_total,
    blocage,
    dep_anter,
    dep_mois,
    reimput,
    dep_annul,
    dep_total,
    solde)   BULK COLLECT INTO nc14_tab
FROM (
        SELECT
            '2020010' || chaps.sec CODE_CPT,
            sum(nvl(cred.credit, 0)) credit_total,
            sum(nvl(bloc.mt, 0)) blocage,
            sum(nvl(depense.dep_anter, 0)+ nvl(reimput.reimput_anter, 0)- nvl(annul_dep.annul_anter, 0)) dep_anter,
            sum(nvl(depense.dep_mois, 0)) dep_mois,
            sum(nvl(reimput.reimput_mois, 0)) reimput,
            sum(nvl(annul_dep.annul_mois, 0)) dep_annul,
            sum((
        nvl(depense.dep_anter, 0)+ nvl(depense.dep_mois, 0)+
            nvl(reimput.reimput_mois, 0)+ nvl(reimput.reimput_anter, 0)-
            nvl(annul_dep.annul_mois, 0)-nvl(annul_dep.annul_anter, 0)
    )) dep_total,
            sum(nvl(cred.credit, 0) - nvl(bloc.mt, 0) - (
        nvl(depense.dep_anter, 0)+ nvl(depense.dep_mois, 0)+ 
        nvl(reimput.reimput_mois, 0)+ nvl(reimput.reimput_anter, 0)
        - nvl(annul_dep.annul_mois, 0)- nvl(annul_dep.annul_anter, 0)
    ))solde
        FROM
            (
                SELECT
                    CODE_ORD ord,
                    CHAPITRE chap,
                    SECTION sec
                FROM
                    NOMENC_BUD
                WHERE
                    TYPE_NOMENC = 'BF'
                    AND SUBSTR(CODE_CPT, 1, 6) = '202001'
                    AND GESTION = p_gestion
            UNION
                SELECT
                    m.CODE_ORD,
                    mc.CODE_CHAPITRE,
                    SUBSTR(mc.CODE_CHAPITRE, 1, 2)
                FROM
                    MANDAT m,
                    MANDAT_CHAPITRE mc
                WHERE
                    m.TYPE_SERVICE = 'BF'
                    AND m.NUM_MANDAT = mc.NUM_MANDAT
                    AND m.GESTION = p_gestion
                    AND m.STATUT NOT IN (
                        'EMIS', 'ADMIS'
                    )
            ) chaps
        LEFT JOIN (
                SELECT
                    ord,
                    chap,
                    sum(mt) credit
                FROM
                    (
                        SELECT
                            c.CODE_ORD ord,
                            lc.CHAPITRE chap,
                            CASE
                                WHEN c.TYPE_CREDIT = 'TRSF'
                                    AND lc.NAT_CRE = 1 THEN -lc.MT_CREDIT
                                    ELSE lc.MT_CREDIT
                                END mt
                            FROM
                                CREDIT c,
                                LIGNE_CREDIT lc
                            WHERE
                                c.CODE_CREDIT = lc.CODE_CREDIT
                                AND c.TYPE_NOMENC = 'BF'
                                AND c.GESTION = p_gestion
                                AND to_char(c.DT_REF, 'MM')<=p_mois
                                    AND c.TYPE_CREDIT IN (
                                        'RATT', 'TRSF'
                                    )
                                        AND c.DT_ANNUL IS NULL
                                UNION ALL
                                    SELECT
                                        ord,
                                        chap,
                                        mt
                                    FROM
                                        (
                                            SELECT
                                                ROW_NUMBER() OVER (
                                                    PARTITION BY c.CODE_ORD,
                                                    lc.CHAPITRE
                                                ORDER BY
                                                    DT_REF DESC
                                                ) rn,
                                                c.CODE_ORD ord,
                                                lc.CHAPITRE chap,
                                                c.TYPE_CREDIT typec,
                                                lc.MT_CREDIT mt
                                            FROM
                                                CREDIT c,
                                                LIGNE_CREDIT lc
                                            WHERE
                                                c.CODE_CREDIT = lc.CODE_CREDIT
                                                AND c.TYPE_NOMENC = 'BF'
                                                AND c.TYPE_CREDIT IN (
                                                    'INIT', 'LFCO'
                                                )
                                                    AND c.GESTION = p_gestion
                                                    AND to_char(c.DT_REF, 'MM')<=p_mois
                                                        AND c.DT_ANNUL IS NULL
                                        )
                                    WHERE
                                        rn = 1
                    )
                GROUP BY
                    ord,
                    chap
            ) cred ON
            chaps.ord = cred.ord
            AND chaps.ord = cred.ord
            AND chaps.chap = cred.chap
        LEFT JOIN (
                SELECT
                    c.CODE_ORD ord,
                    lc.CHAPITRE chap,
                    sum(
CASE WHEN c.TYPE_CREDIT = 'DEBL' THEN -lc.MT_CREDIT
ELSE lc.MT_CREDIT
END 
) mt
                FROM
                    CREDIT c,
                    LIGNE_CREDIT lc
                WHERE
                    c.CODE_CREDIT = lc.CODE_CREDIT
                    AND c.TYPE_NOMENC = 'BF'
                    AND c.GESTION = p_gestion
                    AND to_char(c.DT_REF, 'MM')<=p_mois
                        AND c.TYPE_CREDIT IN (
                            'BLOC', 'DEBL'
                        )
                            AND c.DT_ANNUL IS NULL
                        GROUP BY
                            c.CODE_ORD,
                            lc.CHAPITRE
            ) bloc ON
            chaps.ord = bloc.ord
            AND chaps.ord = bloc.ord
            AND chaps.chap = bloc.chap
        LEFT JOIN (
                SELECT
                    ord ,
                    chap,
                    sum(dep_mois) dep_mois,
                    sum(dep_anter) dep_anter
                FROM
                    (
                        SELECT
                            m.CODE_ORD ord,
                            ma.CODE_CHAPITRE chap ,
                            sum(
CASE WHEN m.MOIS =p_mois THEN ma.mt_net
ELSE 0
END) dep_mois,
                            sum(
CASE WHEN m.MOIS<p_mois THEN ma.mt_net
ELSE 0
END) dep_anter
                        FROM
                            mandat m,
                            mandat_article ma
                        WHERE
                            m.NUM_MANDAT = ma.NUM_MANDAT
                            AND m.mois <=p_mois
                            AND m.gestion =p_gestion
                            AND m.type_service ='BF'
                            AND m.STATUT NOT IN (
                                'EMIS', 'ADMIS'
                            )
                        GROUP BY
                            m.CODE_ORD,
                            ma.CODE_CHAPITRE
                    UNION
                        SELECT
                            c.CODE_ORD ord,
                            lc.CHAPITRE chap,
                            sum(
CASE WHEN to_char(c.DT_REF, 'MM')=p_mois THEN lc.MT_CREDIT
ELSE 0
END) debit_mois,
                            sum(
CASE WHEN to_char(c.DT_REF, 'MM')<p_mois THEN lc.MT_CREDIT
ELSE 0
END) debit_anter
                        FROM
                            CREDIT c,
                            LIGNE_CREDIT lc
                        WHERE
                            c.CODE_CREDIT = lc.CODE_CREDIT
                            AND c.TYPE_NOMENC = 'BF'
                            AND c.GESTION = p_gestion
                            AND to_char(c.DT_REF, 'MM')<=p_mois
                                AND c.TYPE_CREDIT = 'DEBI'
                                AND c.DT_ANNUL IS NULL
                            GROUP BY
                                c.CODE_ORD,
                                lc.CHAPITRE
                    )
                GROUP BY
                    ord,
                    chap
            ) depense ON
            chaps.ord = depense.ord
            AND chaps.ord = depense.ord
            AND chaps.chap = depense.chap
        LEFT JOIN (
                SELECT
                    lc.CODE_ORD ord,
                    lc.CHAPITRE chap,
                    sum(
CASE WHEN to_char(c.DT_REF, 'MM')=p_mois AND lc.NAT_CRE = 1 THEN -lc.MT_CREDIT
WHEN to_char(c.DT_REF, 'MM')=p_mois AND lc.NAT_CRE = 2 THEN lc.MT_CREDIT
ELSE 0
END) reimput_mois,
                    sum(
CASE WHEN to_char(c.DT_REF, 'MM')<p_mois AND lc.NAT_CRE = 1 THEN -lc.MT_CREDIT
WHEN to_char(c.DT_REF, 'MM')<p_mois AND lc.NAT_CRE = 2 THEN lc.MT_CREDIT
ELSE 0
END 
) reimput_anter
                FROM
                    CREDIT c,
                    LIGNE_CREDIT lc
                WHERE
                    c.CODE_CREDIT = lc.CODE_CREDIT
                    AND c.TYPE_NOMENC = 'BF'
                    AND c.GESTION = p_gestion
                    AND to_char(c.DT_REF, 'MM')<=p_mois
                        AND c.TYPE_CREDIT IN (
                            'REMP', 'REMS'
                        )
                            AND c.DT_ANNUL IS NULL
                        GROUP BY
                            lc.CODE_ORD,
                            lc.CHAPITRE
            ) reimput ON
            chaps.ord = reimput.ord
            AND chaps.ord = reimput.ord
            AND chaps.chap = reimput.chap
        LEFT JOIN (
                SELECT
                    c.CODE_ORD ord,
                    lc.CHAPITRE chap,
                    sum(CASE WHEN to_char(c.DT_REF, 'MM')=p_mois THEN lc.MT_CREDIT ELSE 0 END) annul_mois,
                    sum(CASE WHEN to_char(c.DT_REF, 'MM')<p_mois THEN lc.MT_CREDIT ELSE 0 END) annul_anter
                FROM
                    CREDIT c,
                    LIGNE_CREDIT lc
                WHERE
                    c.CODE_CREDIT = lc.CODE_CREDIT
                    AND c.TYPE_NOMENC = 'GF'
                    AND c.GESTION = p_gestion
                    AND to_char(c.DT_REF, 'MM')<=p_mois
                        AND c.TYPE_CREDIT = 'ANDP'
                        AND c.DT_ANNUL IS NULL
                    GROUP BY
                        c.CODE_ORD,
                        lc.CHAPITRE
            ) annul_dep ON
            chaps.ord = annul_dep.ord
            AND chaps.ord = annul_dep.ord
            AND chaps.chap = annul_dep.chap
        WHERE
            chaps.sec IS NOT NULL
        GROUP BY
            chaps.sec
ORDER BY
    1
    )
WHERE
    credit_total <> 0
    OR   
blocage <> 0
    OR  
dep_anter <> 0
    OR
dep_mois <> 0
    OR
reimput <> 0
    OR  
dep_annul <> 0
    OR  
dep_total <> 0
    OR  
solde <> 0
;
RETURN nc14_tab;
END;



SELECT *
FROM   TABLE(calc_NC14('2022','04'))
;