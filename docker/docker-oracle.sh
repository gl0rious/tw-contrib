#!/bin/sh

docker rm -f tw08
docker volume rm oracle-volume

docker run --name tw08 -d -p 1521:1521 -e ORACLE_SID=XE -e ORACLE_PASSWORD=max --shm-size=1G \
-v /home/majid/fast:/u01/app/oracle/fast_recovery_area/XE \
-v /home/majid:/workdir \
-v oracle-volume:/u01/app/oracle/oradata gvenzl/oracle-xe:11-full

# docker cp sauvegardeDu_210824.dmp tw08:/u01/app/oracle/dump.dmp
# docker cp config.sql tw08:/u01/app/oracle/config.sql

while true; do
  if docker exec tw08 bash -c "sqlplus -s system/max <<< 'SELECT INSTANCE_NAME, STATUS, DATABASE_STATUS FROM V\$INSTANCE;'" | grep -E '^XE.*OPEN.*ACTIVE' >/dev/null 2>&1; then
    # docker exec -it tw08 bash -c "source /u01/app/oracle/.bash_profile; lsnrctl status"
    # docker exec -it tw08 tnsping XE 
    docker exec tw08 imp system/max file=/workdir/sauvegardeDu_210824.dmp full=y buffer=1000 
    break
  fi
  sleep 3s
done

# docker exec -it tw08 imp system/max file=sauvegardeDu_210824.dmp full=y buffer=1000 
# docker exec -it tw08 bash -c "source /u01/app/oracle/.bash_profile; lsnrctl status"
# docker exec tw08 imp system/max file=/workdir/sauvegardeDu_210824.dmp full=y
docker exec tw08 sqlplus /nolog @/workdir/config.sql
# docker exec -it tw08 bash /workdir/imp.sh
