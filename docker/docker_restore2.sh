#!/bin/sh

backupfile=$1
dockercontainer=${2:-TW08}
port=${3:-1521}

docker stop $dockercontainer && docker rm $dockercontainer
docker run --name $dockercontainer -d -p $port:1521 \
    -e ORACLE_PASSWORD=password -v $HOME/docker-share:/docker-share \
    --shm-size=1G gvenzl/oracle-xe:11-full

echo "Waiting for Oracle "
until docker logs $dockercontainer | rg 'DATABASE IS READY TO USE!' &> /dev/null
do
    printf "."
    sleep 1
done
echo -e "\nOracle is running."
docker exec $dockercontainer sed -i 's/<< EOF/ as sysdba << EOF/' healthcheck.sh
backup_to="$HOME/docker-share/rmanbackup"
rm -rf $backup_to
mkdir -p $backup_to
tar -xzvf $backupfile -C $backup_to

echo db_name=XE > $backup_to/pfile_dummy.ora
echo sga_target=500M >> $backup_to/pfile_dummy.ora

backup_from="/docker-share/rmanbackup"

docker exec $dockercontainer bash -c "
#rm -rf /u01/app/oracle/fast_recovery_area/XE
rman target / << EOF
    #startup force nomount pfile=$backup_from/pfile_dummy.ora;
    SHUTDOWN IMMEDIATE;
    STARTUP NOMOUNT; 
EOF

rman auxiliary / << EOF
    DUPLICATE DATABASE TO XE
    BACKUP LOCATION '$backup_from/'
    NOFILENAMECHECK;
EOF
sqlplus -s / as sysdba <<EOF
    NOAUDIT INSERT ON PERSONNE;
    NOAUDIT UPDATE ON PERSONNE;
    NOAUDIT DELETE ON PERSONNE;
    AUDIT SELECT table , INSERT table , UPDATE table , DELETE table  by TW08 BY ACCESS;
    delete SYS.aud$;
    alter user system identified by password;
    alter user TW08 identified by password;
    /
    BEGIN
        FOR username IN (
            SELECT
                nom_utilis
            FROM
                utilisateur_app
            WHERE
                nom_utilis IN (
                    SELECT
                        username
                    FROM
                        all_users
                )
        ) LOOP
            EXECUTE IMMEDIATE 'alter user '
                              || username.nom_utilis
                              || ' identified by password';
        END LOOP;
    END;
    /
EOF
"
rm -rf $backup_to