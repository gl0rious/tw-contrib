#!/bin/sh

docker exec TW08 bash -c "
sqlplus -s / as sysdba <<EOF
    create or replace directory sharedir as '/docker-share';
EOF
expdp system/password DIRECTORY=sharedir FULL=YES CONTENT=METADATA_ONLY DUMPFILE=backup.dmp REUSE_DUMPFILES=YES NOLOGFILE=YES
"
