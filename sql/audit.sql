alter system set AUDIT_TRAIL=db, extended scope=spfile; 

ALTER DATABASE TEMPFILE '/u01/app/oracle/oradata/XE/temp.dbf' DROP;
alter tablespace TEMP add tempfile '/u01/app/oracle/oradata/XE/temp.dbf' REUSE;

SELECT username, obj_name, extended_timestamp, sql_text, sql_bind
FROM   dba_audit_trail 
WHERE username = 'TW08' and obj_name in (
  select table_name from all_tables where owner='TW08'
) ORDER BY extended_timestamp asc;

SELECT distinct obj_name
FROM   dba_audit_trail;

SELECT count(*)
FROM   dba_audit_trail
;

select distinct obj$name
FROM   sys.AUD$
;

delete
FROM   sys.AUD$
where obj$name='PERSONNE'
and userid<>'TW08';


SELECT *
FROM   dba_audit_trail
WHERE username <> 'TW08' and obj_name='MANDAT' ORDER BY extended_timestamp DESC;

NOAUDIT ALL;
NOAUDIT DELETE TABLE;

select * from DBA_STMT_AUDIT_OPTS;
select * from DBA_OBJ_AUDIT_OPTS;
select * from dba_priv_audit_opts;


select name || '=' || value PARAMETER from sys.v_$parameter where name like '%audit%';


Noaudit All;
Noaudit All Privileges;
Noaudit All On Default;
Noaudit Table;

NOAUDIT INSERT ON PERSONNE;
NOAUDIT UPDATE ON PERSONNE;
NOAUDIT DELETE ON PERSONNE;

NOAUDIT INSERT ON MANDAT;
NOAUDIT UPDATE ON MANDAT;
NOAUDIT DELETE ON MANDAT;

select * from all_def_audit_opts;

select (owner ||'.'|| object_name) object_name,
alt, aud, com, del, gra, ind, ins, loc, ren, sel, upd, ref, exe
from dba_obj_audit_opts
where alt != '-/-' or aud != '-/-'
or com != '-/-' or del != '-/-'
or gra != '-/-' or ind != '-/-'
or ins != '-/-' or loc != '-/-'
or ren != '-/-' or sel != '-/-'
or upd != '-/-' or ref != '-/-'
or exe != '-/-';

DELETE FROM sys.AUD$;
truncate table sys.aud$;

AUDIT INSERT ON PERSONNE BY ACCESS;
AUDIT UPDATE ON PERSONNE BY ACCESS;
AUDIT DELETE ON PERSONNE BY ACCESS;


NOAUDIT CREATE SESSION;
noaudit connect;
COMMIT;

AUDIT SELECT table , INSERT table , UPDATE table , DELETE table  by TW08 BY ACCESS;
NOAUDIT SELECT table , INSERT table , UPDATE table , DELETE table by TW08;

AUDIT SELECT ON PERSONNE BY ACCESS;

SELECT * FROM V$OPTION WHERE VALUE = 'TRUE';

select 'AUDIT SELECT ON '||table_name||' by ACCESS;' from all_tables where owner='TW08' union
select 'AUDIT INSERT ON '||table_name||' by ACCESS;' from all_tables where owner='TW08' union
select 'AUDIT UPDATE ON '||table_name||' by ACCESS;' from all_tables where owner='TW08' union
select 'AUDIT DELETE ON '||table_name||' by ACCESS;' from all_tables where owner='TW08';

select 'NOAUDIT SELECT ON '||table_name||';' from all_tables where owner='TW08' union
select 'NOAUDIT INSERT ON '||table_name||';' from all_tables where owner='TW08' union
select 'NOAUDIT UPDATE ON '||table_name||';' from all_tables where owner='TW08' union
select 'NOAUDIT DELETE ON '||table_name||';' from all_tables where owner='TW08';
