# export LD_LIBRARY_PATH=/home/majid/Desktop/pop/instantclient_21_1/:$LD_LIBRARY_PATH
import cx_Oracle
import sqlparse
from pygments import highlight
from pygments.formatters import Terminal256Formatter, NullFormatter
from pygments import lexers
import re
import datetime

lex = lexers.get_lexer_by_name("sql")
formatter = NullFormatter(style='monokai')

connection = cx_Oracle.connect("tw08/twroot02@localhost:1527/XE", encoding="UTF-8")

cursor = connection.cursor()
res = cursor.execute("""
SELECT sql_text,sql_bind
FROM   dba_audit_trail
WHERE userhost<>'tk' and username = :usr and obj_name in (
  select table_name from all_tables where owner=:usr
) ORDER BY extended_timestamp asc""",
                     usr='TW08')
# datere = re.compile("^(\d{1,2}/\d{1,2}/\d{4}) 0:0:0$")
prev_sql = None
for call in cursor.fetchall():
    sql = call[0]
    bind = call[1]
    if(bind is not None):
        args = bind.split(' #')[1:]
        for i, arg in reversed(list(enumerate(args))):
            arg = arg.split(':',maxsplit=1)[1]
            arg = "TO_DATE('{}')".format(datetime.datetime.strptime(arg.replace(' 0:0:0',''), '%m/%d/%Y') \
                .strftime('%d-%b-%Y')) \
                if arg.endswith(" 0:0:0") else "'{}'".format(arg)
            sql = re.sub(':b?{}'.format(i+1), arg, sql)
            # sql = sql.replace(':b{}'.format(i+1), arg)
    sql = sqlparse.format(sql, reindent=True, keyword_case='upper')
    sql = highlight(sql, lex, formatter)
    if sql != prev_sql:
        prev_sql = sql
        print(sql+";")
    print('-------------------------------------------------------------------')