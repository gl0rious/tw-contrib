#!/bin/sh

docker exec TW08D bash -c "sqlplus -s / as sysdba <<EOF
    alter system set AUDIT_TRAIL=db, extended scope=spfile;
    ALTER DATABASE TEMPFILE '/u01/app/oracle/oradata/XE/temp.dbf' DROP;
    alter tablespace TEMP add tempfile '/u01/app/oracle/oradata/XE/temp.dbf' REUSE;
    delete SYS.aud$;
    AUDIT SELECT table , INSERT table , UPDATE table , DELETE table  by TW08 BY ACCESS;
EOF"