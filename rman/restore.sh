#!/bin/sh

backupdir='/tmp/rmanbackup'
rm -rf $backupdir
mkdir -p $backupdir

tar -xzvf $1 -C $backupdir

echo db_name=XE > ${backupdir}/pfile_dummy.ora
echo sga_target=270M >> ${backupdir}/pfile_dummy.ora
rman target / << EOF
   startup force nomount pfile=${backupdir}/pfile_dummy.ora
EOF
rm -f ${backupdir}/pfile_dummy.ora
mkdir -p /u01/app/oracle/fast_recovery_area

rman target / << EOF
    restore spfile from '${backupdir}/spf';
    startup force nomount;
    restore controlfile from '${backupdir}/ctl';
    alter database mount;
    catalog start with '${backupdir}/' noprompt;
    restore database;
    recover database;
    alter database open resetlogs;

    HOST 'rm -rf $backupdir';
    crosscheck backup;
    DELETE noprompt EXPIRED BACKUP;
EOF
