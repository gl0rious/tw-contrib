#!/usr/bin/expect -f

set year [lindex $argv 0];
set month [lindex $argv 1];

set timeout 3

spawn su relance -c "cd /application/relance/rcrpcsc/rcrpcsc$year; ./prelance.4ge;"
expect "MOT DE PASSE"
send "rh|469\r"
expect "MENU GENERAL"
send "4\r"
expect "GESTION DE COMPTES"
send "4\r"
expect "MENU      DIVERS"
send "7\r"
expect "Mois"
send "$month\r"
expect "Continuer O/N"
send "O\r"
expect "Avec controle O/N"
send "N\r"
expect "(D)isquette ou (C)artouche (M)odem"
send "M\r"
expect "Taper < RC > pour commencer l'envoi"
send "\r"
expect "bash: envacct.bat: command not found"
send "\r"
close

spawn su relance -c "cd /application/relance/rfsdrss/rfsdrss$year; ./prelance.4ge;"
expect "MOT DE PASSE"
send "rh|469\r"
expect "MENU GENERAL"
send "4\r"
expect "GESTION DE COMPTES"
send "4\r"
expect "MENU      DIVERS"
send "7\r"
expect "Mois"
send "$month\r"
expect "Continuer O/N"
send "O\r"
expect "Avec controle O/N"
send "N\r"
expect "(D)isquette ou (C)artouche (M)odem"
send "M\r"
expect "Taper < RC > pour commencer l'envoi"
send "\r"
expect "bash: envacct.bat: command not found"
send "\r"
close

spawn su relop -c "cd /application/relop/rpcsc/rpcsc$year; ./prelop.4ge;"
expect "MOT DE PASSE"
send "rh|469\r"
expect "MENU GENERAL"
send "4\r"
expect "GESTION DE COMPTES"
send "4\r"
expect "MENU      DIVERS"
send "6\r"
expect "Mois"
send "$month\r"
expect "(D)isquette ou (C)artouche (M)odem"
send "M\r"
expect "Attente d'envoi    , appuyez sur < RC > "
send "\r"
close

spawn su relop -c "cd /application/relop/fsdrs/fsdrs$year; ./prelop.4ge;"
expect "MOT DE PASSE"
send "rh|469\r"
expect "MENU GENERAL"
send "4\r"
expect "GESTION DE COMPTES"
send "4\r"
expect "MENU      DIVERS"
send "6\r"
expect "Mois"
send "$month\r"
expect "(D)isquette ou (C)artouche (M)odem"
send "M\r"
expect "Attente d'envoi    , appuyez sur < RC > "
send "\r"
close

exit
expect eof
