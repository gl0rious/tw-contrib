#!/bin/sh

docker exec TW08-ALGER bash -c 'sqlplus -s / as sysdba <<< "startup force;"'
