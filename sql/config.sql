
conn / as sysdba

Show parameter service_name
alter system set service_names = 'SIT08001,XE' scope = both;
alter system register;
--@/u01/app/oracle/product/11.2.0/xe/apex/apxremov.sql;
--drop package HTMLDB_SYSTEM;
/

SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER SYSTEM ENABLE RESTRICTED SESSION;
ALTER SYSTEM SET JOB_QUEUE_PROCESSES=0;
ALTER SYSTEM SET AQ_TM_PROCESSES=0;
ALTER DATABASE OPEN;
ALTER DATABASE CHARACTER SET INTERNAL_USE UTF8;
SHUTDOWN;
STARTUP;
ALTER SYSTEM SET SEC_CASE_SENSITIVE_LOGON=FALSE;

ALTER DATABASE 
  DATAFILE '/u01/app/oracle/oradata/XE/system.dbf'
  AUTOEXTEND ON
  NEXT 10M
  MAXSIZE UNLIMITED;   
ALTER DATABASE 
  DATAFILE '/u01/app/oracle/oradata/XE/users.dbf'
  AUTOEXTEND ON
  NEXT 10M
  MAXSIZE UNLIMITED;
  
CREATE TEMPORARY TABLESPACE TEMP_SIT TEMPFILE 
  '/u01/app/oracle/oradata/XE/TEMP_SIT.DBF' SIZE 256M AUTOEXTEND ON NEXT 640K MAXSIZE 32767M
TABLESPACE GROUP ''
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M
FLASHBACK ON;

CREATE TABLESPACE INDX_SIT DATAFILE 
  '/u01/app/oracle/oradata/XE/INDX_SIT.DBF' SIZE 256M AUTOEXTEND ON NEXT 1280K MAXSIZE 32767M
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

GRANT SELECT ON v_$session TO tw08;
GRANT SELECT ON dba_role_privs TO tw08;

alter session set current_schema=TW08;

CREATE OR REPLACE
PROCEDURE kill_other_sessions
AS
  pragma autonomous_transaction;
  v_username VARCHAR2(30);
  v_sid      NUMBER;
BEGIN
  v_username := SYS_CONTEXT('USERENV', 'SESSION_USER');
  v_sid      := SYS_CONTEXT('USERENV','SID');
  FOR sess IN (
    SELECT, sid, serial# FROM v$session 
        WHERE EXISTS
          (SELECT 1 FROM utilisateur_app WHERE nom_utilis=v_username)
        AND NOT EXISTS
          (SELECT 1 FROM dba_role_privs WHERE granted_role='DBA' 
                AND grantee=v_username)
        AND username=v_username AND sid<>v_sid
    )
  LOOP
    EXECUTE IMMEDIATE 'ALTER SYSTEM DISCONNECT SESSION '''||
        sess.sid||','||sess.serial#|| ''' IMMEDIATE';
  END
  LOOP;
END
kill_other_sessions;
/
CREATE OR REPLACE PUBLIC SYNONYM kill_other_sessions FOR kill_other_sessions;
grant execute on kill_other_sessions to public;
/
CREATE OR REPLACE
FUNCTION kos(placeholder IN VARCHAR2)
RETURN INT
AS
BEGIN
  kill_other_sessions;
  RETURN 0;
END
kos;
/
CREATE OR REPLACE PUBLIC SYNONYM kos FOR kos;
grant execute on kos to public;
/
alter session set current_schema=SYS;
Exec UTL_RECOMP.RECOMP_SERIAL ();
/
exit