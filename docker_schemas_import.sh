#!/bin/sh

docker stop tw08test && docker rm tw08test

docker run --name tw08test -d -p 1522:1521 -e ORACLE_PASSWORD=password -v $HOME/docker-share:/docker-share --shm-size=1G gvenzl/oracle-xe:11-full

echo "Waiting for Oracle "
until docker logs tw08test | rg 'DATABASE IS READY TO USE!' &> /dev/null
do
    printf "."
    sleep 1
done
echo -e "\nOracle is running."
docker exec tw08test sed -i 's/<< EOF/ as sysdba << EOF/' healthcheck.sh

docker exec tw08test bash -c "
sqlplus -s / as sysdba <<EOF
    create or replace directory sharedir as '/docker-share';
    --CREATE USER tw99 IDENTIFIED BY password;
    --GRANT DBA TO tw99;
EOF
#impdp system/password DIRECTORY=sharedir SCHEMAS=tw08 REMAP_SCHEMA=tw08:tw99 DUMPFILE=backup.dmp
#impdp system/password DIRECTORY=sharedir FULL=YES REMAP_SCHEMA=tw08:tw99 CONTENT=METADATA_ONLY DUMPFILE=backup.dmp
impdp system/password DIRECTORY=sharedir SCHEMAS=tw08 REMAP_SCHEMA=tw08:tw99 CONTENT=METADATA_ONLY DUMPFILE=backup.dmp
"




