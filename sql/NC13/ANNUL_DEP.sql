WITH stored as (
    select CODE_ORD ord, CODE_CHAP chap, gestion, MOIS mois, nvl(ANNUL_DEP,0) annul
    FROM TAB_CREDIT
    WHERE TYPE_NOMENC = 'BF'
),
computed AS (
    SELECT c.CODE_ORD ord, lc.CHAPITRE chap, c.GESTION gestion, to_char(c.DT_REF,'MM') mois, sum(nvl(lc.MT_CREDIT,0)) annul
    FROM CREDIT c,
    LIGNE_CREDIT lc 
    WHERE lc.CODE_CREDIT = c.CODE_CREDIT
    AND c.TYPE_NOMENC = 'GF'
    AND c.TYPE_CREDIT = 'ANDP'
    AND c.DT_ANNUL IS null
    GROUP BY c.CODE_ORD , lc.CHAPITRE, c.GESTION, to_char(c.DT_REF,'MM')
)
SELECT st.ord, st.chap, st.GESTION, st.mois, st.annul, cm.annul
FROM stored st, computed cm
WHERE st.ord = cm.ord
    AND st.chap = cm.chap
    AND st.GESTION = cm.gestion
    AND st.mois = cm.mois
    AND st.annul <> cm.annul
ORDER BY 1,2,3,4
;

WITH stored as (
select CODE_ORD ord, CODE_CHAP chap, CODE_ART art, gestion, MOIS mois, nvl(ANNUL_DEP,0) annul
FROM TAB_CREDIT
WHERE TYPE_NOMENC = 'GF'
--  AND GESTION = '2022'
--  AND CODE_ORD = '12500801'
--  AND CODE_CHAP = '3111'
--  AND MOIS='07'
),
computed AS (
SELECT c.CODE_ORD ord, lc.CHAPITRE chap, lc.ARTICLE art, c.GESTION, to_char(c.DT_REF,'MM') mois, sum(nvl(lc.MT_CREDIT,0)) annul
FROM CREDIT c,
LIGNE_CREDIT lc 
WHERE lc.CODE_CREDIT = c.CODE_CREDIT
AND c.TYPE_NOMENC = 'GF'
AND c.TYPE_CREDIT = 'ANDP'
AND c.DT_ANNUL IS null
GROUP BY c.CODE_ORD , lc.CHAPITRE, lc.ARTICLE, c.GESTION, to_char(c.DT_REF,'MM')
)
SELECT cr.ord, cr.chap, cr.art, cr.GESTION, cr.mois, max(cr.annul), sum(m.annul)
FROM stored cr, computed m
WHERE cr.ord = m.ord
AND cr.chap = m.chap
AND cr.art = m.art
AND cr.GESTION = m.gestion
AND cr.mois >= m.mois
GROUP BY cr.ord, cr.chap, cr.art, cr.GESTION, cr.mois
HAVING max(cr.annul) <> sum(m.annul)
;


SELECT DISTINCT TYPE_NOMENC
FROM TAB_CREDIT tc 
ORDER BY 1;