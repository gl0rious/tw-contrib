#!/bin/sh

docker exec TW08E bash -c 'sqlplus -s / as sysdba <<< "delete SYS.aud$;"'