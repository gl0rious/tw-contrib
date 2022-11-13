GRANT SELECT ON v_$session TO tw08;
GRANT SELECT ON dba_role_privs TO tw08;
/
create or replace TRIGGER tw08.session_cleanup
AFTER LOGON ON
DATABASE
DECLARE
  v_username VARCHAR2(30);
  v_sid NUMBER;
BEGIN
    v_username := SYS_CONTEXT('USERENV', 'SESSION_USER');
    v_sid := SYS_CONTEXT('USERENV', 'SID');
    FOR sess IN
      (
        SELECT
            sid,
            serial#
        FROM
            v$session
        WHERE
            EXISTS
          (
                SELECT
                    1
                FROM
                    utilisateur_app
                WHERE
                    nom_utilis = v_username
            )
            AND NOT EXISTS
          (
                SELECT
                    1
                FROM
                    DBA_ROLE_PRIVS
                WHERE
                    granted_role = 'DBA'
                    AND grantee = v_username
            )
            AND username = v_username
            AND sid <> v_sid
    )
      LOOP
        EXECUTE IMMEDIATE 'ALTER SYSTEM DISCONNECT SESSION ''' || sess.sid || ','
        || sess.serial#|| ''' IMMEDIATE';
    END
  LOOP;
END session_cleanup;
/
--select * from dba_triggers where triggering_event like '%LOGON%';