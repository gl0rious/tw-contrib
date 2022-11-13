select * from v$nls_parameters where parameter='NLS_CHARACTERSET';

select userenv('language') from dual;

select TO_CHAR(TO_DATE(rownum, 'fmMM'),'fmMONTH','NLS_DATE_LANGUAGE = FRENCH') nn, 
    to_char(rownum,'fm00') ii from dual connect by rownum <=12;
    
select value from NLS_DATABASE_PARAMETERS where parameter='NLS_CHARACTERSET';