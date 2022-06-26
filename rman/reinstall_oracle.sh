#!/bin/sh


rpm -e oracle-xe-11.2.0-1.0.x86_64
rm -rf /u01
rpm -ivh ~/oracle-xe-11.2.0-1.0.x86_64.rpm
/etc/init.d/oracle-xe configure << EOF
8080
1521
password
password
y
EOF

cp ~/.bash_profile /u01/app/oracle/