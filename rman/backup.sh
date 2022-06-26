#!/bin/sh

backupdir='/tmp/rmanbackup'
rm -rf $backupdir
mkdir -p $backupdir

rman target / << EOF
    shutdown immediate;
    startup mount;
    crosscheck backup;
    delete noprompt backup;

    set nocfau;
    BACKUP as compressed BACKUPSET SPFILE FORMAT '$backupdir/spf';
    BACKUP as compressed BACKUPSET CURRENT CONTROLFILE FORMAT '$backupdir/ctl';
    backup full as compressed BACKUPSET database FORMAT '$backupdir/bkp';
    alter database open;
EOF

today=`date +"%Y-%m-%d"`
tar -czvf backup_$today.rman.gz -C $backupdir .
rm -rf $backupdir