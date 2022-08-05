SELECT c.CODE_ORD ord, lc.CHAPITRE chap, c.GESTION, to_char(c.DT_REF,'MM') mois, lc.ARTICLE art, c.DT_ANNUL, c.CODE_CREDIT, lc.MT_CREDIT
FROM CREDIT c,
LIGNE_CREDIT lc 
WHERE lc.CODE_CREDIT = c.CODE_CREDIT
AND c.TYPE_NOMENC = 'GF'
AND c.TYPE_CREDIT = 'ANDP'
AND c.DT_ANNUL IS null
AND c.CODE_ORD ='110308' AND lc.CHAPITRE = '3112' AND c.GESTION ='2021' AND to_char(c.DT_REF,'MM')<='12' AND lc.ARTICLE ='1'
--GROUP BY c.CODE_ORD ord, lc.CHAPITRE chap, c.GESTION, to_char(c.DT_REF,'MM') mois, lc.ARTICLE art, c.DT_ANNUL, c.CODE_CREDIT,
;


select m.CODE_ORD ord, ma.CODE_CHAPITRE chap, m.MOIS , sum(ma.mt_net) dep_mois, 
sum(sum(ma.mt_net)) OVER (PARTITION BY m.CODE_ORD, ma.CODE_CHAPITRE order by m.mois ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) dep_anter_mois,
sum(sum(ma.mt_net)) OVER (PARTITION BY m.CODE_ORD, ma.CODE_CHAPITRE order by m.mois ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) dep_total_mois
from mandat m, mandat_article ma
where m.NUM_MANDAT=ma.NUM_MANDAT
and m.CODE_ORD='103301'
and ma.CODE_CHAPITRE = '3122'
and m.gestion='2021'
and m.type_service='BF'
group by m.CODE_ORD, ma.CODE_CHAPITRE, m.mois
order by ord, chap, mois asc
;