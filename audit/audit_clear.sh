#!/bin/sh

docker exec TW08D bash -c 'sqlplus -s / as sysdba <<< "delete SYS.aud$;"'
