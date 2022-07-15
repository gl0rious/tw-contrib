#!/bin/sh

docker stop TW08D && docker rm TW08D
docker run --name TW08D -d -p 1527:1521 -e ORACLE_PASSWORD=max \
    --shm-size=2G gvenzl/oracle-xe:11-full

docker exec TW08D sed -i 's/<< EOF/ as sysdba << EOF/' healthcheck.sh

while ! docker exec TW08D lsnrctl status | grep 'Instance "XE", status READY'; do
    sleep 2;
done

./docker_restore.sh $1
