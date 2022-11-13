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

rman auxiliary / << EOF
    DUPLICATE DATABASE TO XE
    BACKUP LOCATION '/workdir/ppp/rman/'
    NOFILENAMECHECK;
    HOST 'rm -rf $backupdir';
EOF
