#!/bin/sh

docker exec TW08 bash -c "sqlplus -s / as sysdba <<< 'delete SYS.aud$;'"
