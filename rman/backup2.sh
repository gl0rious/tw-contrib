#!/bin/sh

backupdir='/tmp/rmanbackup'
rm -rf $backupdir
mkdir -p $backupdir

rman target / << EOF
run
{
    crosscheck backup;
    delete noprompt backup;
    
    DELETE ARCHIVELOG ALL COMPLETED BEFORE 'sysdate-1';
    CROSSCHECK ARCHIVELOG ALL;
    DELETE EXPIRED ARCHIVELOG ALL;

    CONFIGURE DEVICE TYPE DISK BACKUP TYPE TO COMPRESSED BACKUPSET PARALLELISM 8;

    configure controlfile autobackup format for device type disk to '$backupdir/%F';

    allocate channel c1 type disk format '$backupdir/%I-%Y%M%D-%U';
    backup  as compressed backupset database plus archivelog delete all input;
    release channel c1 ;
}
EOF

today=`date +"%Y-%m-%d"`
tar -czvf backup_$today.rman.gz -C $backupdir .
rm -rf $backupdir