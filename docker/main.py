# pip install cx_Oracle
# pip install sqlparse
# yay -S oracle-instantclient-basic

import cx_Oracle
import sqlparse
# from pygments import highlight
# from pygments.formatters import Terminal256Formatter, NullFormatter
# from pygments import lexers
import re
import datetime

# lex = lexers.get_lexer_by_name("sql")
# formatter = NullFormatter(style='monokai')

def print_data(cur):
    data = cur.fetchall()
    cols = [row[0] for row in cur.description]
    # print(tabulate(data, headers=cols))
    for n, row in enumerate(data):
        print('--#output {} : '.format(n+1))
        for i, col in enumerate(cols):
            print('--    {} = {}'.format(col,row[i]))

def clean_sql(sql):
    for i, t in enumerate(re.findall(':\s*\w+', sql)):
        sql = sql.replace(t,':{}'.format(i+1))
    return sql

connection = cx_Oracle.connect("system/becora@localhost:1527/XE", encoding="UTF-8")

cursor = connection.cursor()
cursor.execute("""
SELECT sql_text,sql_bind
FROM   dba_audit_trail
WHERE username = 'TW08' and obj_name in (
  select table_name from all_tables where owner='TW08'
) ORDER BY extended_timestamp asc""")
selcur = connection.cursor()
prev_sql = None
for call in cursor.fetchall():
    sql = call[0]
    sql = clean_sql(sql)
    bind = call[1]
    if(bind is not None):
        args = bind.split(' #')[1:]
        for i, arg in reversed(list(enumerate(args))):
            arg = arg.split(':',maxsplit=1)[1]
            arg = "TO_DATE('{}')".format(datetime.datetime.strptime(arg.replace(' 0:0:0',''), '%m/%d/%Y') \
                .strftime('%d-%b-%Y')) \
                if arg.endswith(" 0:0:0") else "'{}'".format(arg)
            sql = re.sub(':{}'.format(i+1), arg, sql)
            # sql = sql.replace(':b{}'.format(i+1), arg)
    sql = sqlparse.format(sql, reindent=True, keyword_case='upper')

    # sql = highlight(sql, lex, formatter)
    if sql != prev_sql:
        prev_sql = sql
        print(sql+"\n;")
        # if sql.startswith('SELECT'):
        #     selcur.execute(sql)
        #     print_data(selcur)
    print('-------------------------------------------------------------------')
