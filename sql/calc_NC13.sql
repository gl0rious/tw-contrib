DROP INDEX CREDIT_DT_REF_IDX;
DROP INDEX LIGNE_CREDIT_CODE_CREDIT_IDX;
DROP INDEX NOMENC_BUD_CODE_ORD_IDX;

CREATE INDEX CREDIT_DT_REF_IDX ON CREDIT (GESTION, TYPE_NOMENC, TYPE_CREDIT, to_char(DT_REF, 'MM'));
CREATE INDEX LIGNE_CREDIT_CODE_CREDIT_IDX ON LIGNE_CREDIT (CODE_CREDIT);
CREATE INDEX NOMENC_BUD_CODE_ORD_IDX ON NOMENC_BUD (GESTION, TYPE_NOMENC, CODE_ORD);
/
DROP FUNCTION NC13BF;
DROP TYPE t_nc13_tab;
DROP TYPE t_nc13_row;

CREATE OR REPLACE TYPE t_nc13_row AS OBJECT (
    cpt VARCHAR2(20), 
    ord VARCHAR2(10), 
    chap VARCHAR2(10), 
    sec VARCHAR2(10), 
    credit NUMBER,
    blocage NUMBER,
    dep_anter NUMBER,
    dep_mois NUMBER,
    reimput NUMBER,
    dep_annul NUMBER,
    dep_total NUMBER,
    solde NUMBER
);
/
CREATE OR REPLACE TYPE t_nc13_tab IS TABLE OF t_nc13_row;
/
create or replace FUNCTION NC13BF (p_cpt IN VARCHAR2,
    p_gestion IN VARCHAR2, p_mois IN VARCHAR2, p_ord IN VARCHAR2 DEFAULT NULL 
) RETURN t_nc13_tab IS 
  nc13_tab t_nc13_tab;
BEGIN
    SELECT
    t_nc13_row(
        p_cpt,
        ord,
        chap,
        sec,
        credit,
        blocage,
        dep_anter,
        dep_mois,
        reimput,
        dep_annul,
        dep_total,
        solde
    ) BULK COLLECT
INTO
    nc13_tab
FROM
    (
        WITH chaps AS (
            SELECT
                CODE_ORD ord,
                CHAPITRE chap,
                SECTION sec
            FROM
                NOMENC_BUD
            WHERE
                TYPE_NOMENC = 'BF'
                AND SUBSTR(CODE_CPT, 1, 6) = SUBSTR(p_cpt, 1, 6)
                AND GESTION = p_gestion
                AND CODE_ORD = nvl(p_ord,CODE_ORD)
                AND ARTICLE IS NULL
        UNION
            SELECT
                m.CODE_ORD,
                mc.CODE_CHAPITRE,
                mc.CODE_SEC
            FROM
                MANDAT m
                JOIN MANDAT_CHAPITRE mc USING(NUM_MANDAT)
            WHERE
                m.TYPE_SERVICE = 'BF'
                AND m.GESTION = p_gestion
                AND m.CODE_ORD = nvl(p_ord,m.CODE_ORD)
                AND m.STATUT NOT IN (
                    'EMIS', 'ADMIS'
                )
                AND mc.CODE_CHAPITRE NOT IN (
                    SELECT
                        b.CHAPITRE
                    FROM
                        NOMENC_BUD b
                    WHERE
                        b.TYPE_NOMENC = 'BF'
                        AND SUBSTR(b.CODE_CPT, 1, 6) = SUBSTR(p_cpt, 1, 6)
                            AND b.GESTION = p_gestion
                            AND b.CODE_ORD = m.CODE_ORD
                )
        ),
        cred AS (
            SELECT
                ord,
                chap,
                sum(mt) AS mt
            FROM
                (
                    SELECT
                        c.CODE_ORD ord,
                        lc.CHAPITRE chap,
                        CASE
                            WHEN c.TYPE_CREDIT = 'TRSF'
                                AND lc.NAT_CRE = 1 THEN -lc.MT_CREDIT
                            WHEN c.TYPE_CREDIT = 'RETR'
                                THEN -lc.MT_CREDIT
                            ELSE lc.MT_CREDIT
                            END mt
                        FROM
                            CREDIT c
                            JOIN LIGNE_CREDIT lc USING(CODE_CREDIT)
                        WHERE
                            c.CODE_ORD = nvl(p_ord,c.CODE_ORD)
                            AND c.TYPE_NOMENC = 'BF'
                            AND c.GESTION = p_gestion
                            AND to_char(c.DT_REF, 'MM')<= p_mois
                                AND c.TYPE_CREDIT IN (
                                    'RATT', 'TRSF','RETR'
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
                                            CREDIT c
                                            JOIN LIGNE_CREDIT lc USING(CODE_CREDIT)
                                        WHERE
                                            c.CODE_ORD = nvl(p_ord,c.CODE_ORD)
                                            AND c.TYPE_NOMENC = 'BF'
                                            AND c.TYPE_CREDIT IN (
                                                'INIT', 'LFCO'
                                            )
                                                AND c.GESTION = p_gestion
                                                AND to_char(c.DT_REF, 'MM')<= p_mois
                                                    AND c.DT_ANNUL IS NULL
                                    )
                                WHERE
                                    rn = 1
                )
            GROUP BY
                ord,
                chap
            ORDER BY
                1,
                2
        ),
        bloc AS (
            SELECT
                c.CODE_ORD ord,
                lc.CHAPITRE chap,
                sum(
CASE WHEN c.TYPE_CREDIT = 'DEBL' THEN -lc.MT_CREDIT
ELSE lc.MT_CREDIT
END 
) mt
            FROM
                CREDIT c
                JOIN LIGNE_CREDIT lc USING(CODE_CREDIT)
            WHERE
                c.CODE_ORD = nvl(p_ord,c.CODE_ORD)
                AND c.TYPE_NOMENC = 'BF'
                AND c.GESTION = p_gestion
                AND to_char(c.DT_REF, 'MM')<= p_mois
                    AND c.TYPE_CREDIT IN (
                        'BLOC', 'DEBL'--, 'RETR'
                    )
                        AND c.DT_ANNUL IS NULL
                    GROUP BY
                        c.CODE_ORD,
                        lc.CHAPITRE
        ),
        depense AS (
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
CASE WHEN m.MOIS = p_mois THEN ma.mt_net
END) dep_mois,
                        sum(
CASE WHEN m.MOIS<p_mois THEN ma.mt_net
END) dep_anter
                    FROM
                        mandat m
                        JOIN mandat_article ma USING(NUM_MANDAT)
                    WHERE
                        m.CODE_ORD = nvl(p_ord,m.CODE_ORD)
                        AND m.mois <= p_mois
                        AND m.gestion = p_gestion
                        AND m.type_service = 'BF'
                        AND m.SI_DISPO = '1'
                        AND m.MOD_PAY<>'DEBIT'
--                      AND m.SI_DEBIT is null
--                        AND m.STATUT NOT IN (
--                            'EMIS', 'ADMIS'
--                        )
                    GROUP BY
                        m.CODE_ORD,
                        ma.CODE_CHAPITRE
                UNION ALL
                    SELECT
                        c.CODE_ORD ord,
                        lc.CHAPITRE chap,
                        sum(
CASE WHEN to_char(c.DT_REF, 'MM')= p_mois THEN lc.MT_CREDIT
END) debit_mois,
                        sum(
CASE WHEN to_char(c.DT_REF, 'MM')<p_mois THEN lc.MT_CREDIT
END) debit_anter
                    FROM
                        CREDIT c
                        JOIN LIGNE_CREDIT lc USING(CODE_CREDIT)
                    WHERE
                        c.CODE_ORD = nvl(p_ord,c.CODE_ORD)
                        AND c.TYPE_NOMENC = 'BF'
                        AND c.GESTION = p_gestion
                        AND to_char(c.DT_REF, 'MM')<= p_mois
                            AND c.TYPE_CREDIT = 'DEBI'
                            AND c.DT_ANNUL IS NULL
                        GROUP BY
                            c.CODE_ORD,
                            lc.CHAPITRE
                )
            GROUP BY
                ord,
                chap
        ),
        reimput AS (
            SELECT
                lc.CODE_ORD ord,
                lc.CHAPITRE chap,
                sum(
CASE WHEN to_char(c.DT_REF, 'MM')= p_mois AND lc.NAT_CRE = 1 THEN -lc.MT_CREDIT
WHEN to_char(c.DT_REF, 'MM')= p_mois AND lc.NAT_CRE = 2 THEN lc.MT_CREDIT
END) reimput_mois,
                sum(
CASE WHEN to_char(c.DT_REF, 'MM')<p_mois AND lc.NAT_CRE = 1 THEN -lc.MT_CREDIT
WHEN to_char(c.DT_REF, 'MM')<p_mois AND lc.NAT_CRE = 2 THEN lc.MT_CREDIT
END 
) reimput_anter
            FROM
                CREDIT c
                JOIN LIGNE_CREDIT lc USING(CODE_CREDIT)
            WHERE
                lc.CODE_ORD = nvl(p_ord,lc.CODE_ORD)
                AND c.TYPE_NOMENC = 'BF'
                AND c.GESTION = p_gestion
                AND to_char(c.DT_REF, 'MM')<= p_mois
                    AND c.TYPE_CREDIT IN (
                        'REMP', 'REMS'
                    )
                        AND c.DT_ANNUL IS NULL
                    GROUP BY
                        lc.CODE_ORD,
                        lc.CHAPITRE
        ),
        annul_dep AS (
            SELECT
                c.CODE_ORD ord,
                lc.CHAPITRE chap,
                sum(CASE WHEN to_char(c.DT_REF, 'MM')= p_mois THEN lc.MT_CREDIT ELSE 0 END) annul_mois,
                sum(CASE WHEN to_char(c.DT_REF, 'MM')<p_mois THEN lc.MT_CREDIT ELSE 0 END) annul_anter
            FROM
                CREDIT c
                JOIN LIGNE_CREDIT lc using(CODE_CREDIT)
            WHERE
                c.TYPE_NOMENC = 'GF'
                AND c.GESTION = p_gestion
                AND to_char(c.DT_REF, 'MM')<= p_mois
                AND c.TYPE_CREDIT = 'ANDP'
                AND c.DT_ANNUL IS NULL
            GROUP BY
                c.CODE_ORD,
                lc.CHAPITRE
        )
        SELECT
            ord,
            chap,
            chaps.sec,
            nvl(cred.mt, 0) credit,
            nvl(bloc.mt, 0) blocage,
            nvl(depense.dep_anter, 0)+ nvl(reimput.reimput_anter, 0)- nvl(annul_dep.annul_anter, 0) dep_anter,
            nvl(depense.dep_mois, 0) dep_mois,
            nvl(reimput.reimput_mois, 0) reimput,
            nvl(annul_dep.annul_mois, 0) dep_annul,
            (
                nvl(depense.dep_anter, 0)+ nvl(depense.dep_mois, 0)+
                nvl(reimput.reimput_anter, 0)+nvl(reimput.reimput_mois, 0)-
                nvl(annul_dep.annul_anter, 0)-nvl(annul_dep.annul_mois, 0)
            ) dep_total,
            nvl(cred.mt, 0) - nvl(bloc.mt, 0) - (
                nvl(depense.dep_anter, 0)+ nvl(depense.dep_mois, 0)+
                nvl(reimput.reimput_anter, 0)+nvl(reimput.reimput_mois, 0)-
                nvl(annul_dep.annul_anter, 0)-nvl(annul_dep.annul_mois, 0)
            ) solde
        FROM
            chaps
        LEFT JOIN cred using(ord,chap)
        LEFT JOIN bloc using(ord,chap)
        LEFT JOIN depense using(ord,chap)
        LEFT JOIN reimput using(ord,chap)
        LEFT JOIN annul_dep using(ord,chap)
        ORDER BY
            1,
            2
    )
    WHERE
    credit <> 0
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

RETURN nc13_tab;
END;
/


SELECT *
FROM   TABLE(NC13BF('202001000','2022','07','12500801'))
;