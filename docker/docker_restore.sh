#!/bin/sh

backupdir='/tmp/rmanbackup'
rm -rf $backupdir
mkdir -p $backupdir

tar -xzvf $1 -C $backupdir

echo db_name=XE > ${backupdir}/pfile_dummy.ora
echo sga_target=270M >> ${backupdir}/pfile_dummy.ora

docker cp ${backupdir}/. TW08D:/u01/app/oracle/backup
rm -rf $backupdir

docker exec TW08D bash -c "
mkdir -p /u01/app/oracle/fast_recovery_area
rman target / << EOF
    startup force nomount pfile=/u01/app/oracle/backup/pfile_dummy.ora;
EOF
rman target / << EOF
    restore spfile from '/u01/app/oracle/backup/spf';
    startup force nomount;
    restore controlfile from '/u01/app/oracle/backup/ctl';
    alter database mount;
    catalog start with '/u01/app/oracle/backup/' noprompt;
    restore database;
    recover database;
    alter database open resetlogs;

    HOST 'rm -rf /u01/app/oracle/backup';
    crosscheck backup;
    DELETE noprompt EXPIRED BACKUP;
EOF
sqlplus -s / as sysdba <<EOF
    ALTER DATABASE TEMPFILE '/u01/app/oracle/oradata/XE/temp.dbf' DROP;
    alter tablespace TEMP add tempfile '/u01/app/oracle/oradata/XE/temp.dbf' REUSE;
    
    NOAUDIT INSERT ON PERSONNE;
    NOAUDIT UPDATE ON PERSONNE;
    NOAUDIT DELETE ON PERSONNE;
    AUDIT SELECT table , INSERT table , UPDATE table , DELETE table  by TW08 BY ACCESS;
    delete SYS.aud$;
EOF
"