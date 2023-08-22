GRANT SELECT ON v_$session TO tw08;
GRANT SELECT ON dba_role_privs TO tw08;
grant alter system to tw08;
/
--revoke select on v_$session from tw08;
/
CREATE OR REPLACE
PROCEDURE kill_other_sessions
AS
  pragma autonomous_transaction;
  v_username VARCHAR2(30);
  v_sid      NUMBER;
BEGIN
  v_username := SYS_CONTEXT('USERENV', 'SESSION_USER');
  v_sid      := SYS_CONTEXT('USERENV','SID');
  FOR sess   IN
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
          nom_utilis=v_username
      )
    AND NOT EXISTS
      (
        SELECT
          1
        FROM
          dba_role_privs
        WHERE
          granted_role='DBA'
        AND grantee   =v_username
      )
    AND username=v_username
    AND sid    <>v_sid
  )
  LOOP
    EXECUTE IMMEDIATE 'ALTER SYSTEM DISCONNECT SESSION '''||sess.sid||','
    ||sess.serial#|| ''' IMMEDIATE';
  END
  LOOP;
END
kill_other_sessions;
/
CREATE OR REPLACE PUBLIC SYNONYM kill_other_sessions FOR
tw08.kill_other_sessions;
/
--DROP PUBLIC SYNONYM kill_other_sessions;
/
--grant execute on kill_other_sessions to public;
/
--revoke execute on kill_other_sessions from public;
/
EXEC kill_other_sessions;
/
CREATE OR REPLACE
FUNCTION kos(num IN VARCHAR2)
RETURN INT
AS
BEGIN
  kill_other_sessions;
  RETURN 0;
END
kos;
/
CREATE OR REPLACE PUBLIC SYNONYM kos FOR tw08.kos;
/
SELECT
  kos(:b1)
FROM
  dual;
/
SELECT
  klses(SUM(1))
FROM
  V$SESSION
WHERE
  USERNAME=:b1
/
revoke DBA from SALAH;