#!/bin/sh

while getopts ":nc" option; do
   case $option in
      n) # clear audit.sql file
         echo -n > audit.sql
         echo "audit file cleared"
         exit;;
      c) # clear audit in db
         docker exec TW08 bash -c "sqlplus -s / as sysdba <<< 'delete SYS.aud$;'"
         echo "audit in db cleared"
         exit;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done
echo '--------------------' `date +'%d/%m/%y %H:%M:%S'` '--------------------' >> audit.sql 
python main.py >> audit.sql 
echo -e '--------------------------- END ---------------------------\n\n' >> audit.sql 
docker exec TW08 bash -c "sqlplus -s / as sysdba <<< 'delete SYS.aud$;'"
echo "audit aquired"
