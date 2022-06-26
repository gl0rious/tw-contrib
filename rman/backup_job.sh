su - oracle -c "/backup/rman_backup.sh"

echo "################ Backup to NAS ################"
if ! lsscsi | grep QNAP > /dev/null; then
        echo "QNAP NAS was not connected"
        /etc/init.d/iscsi restart > /dev/null
        sleep 1
fi
if ! mountpoint /diskserv2 > /dev/null; then
        echo "NAS parent directory was not mounted"
        mount -a
fi
if [ -d "/diskserv2/oracle" ]; then
        echo "Copying Oracle backups to NAS"
    cp -vu /backup/backup_* /diskserv2/rman_backups
    find /backup/backup_* -type f -mtime +14 -delete
else
        echo "Oracle backup NAS directory does not exist"
fi
