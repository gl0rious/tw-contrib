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

sqls = (('INSERT INTO CREDIT(CODE_CREDIT,TYPE_NOMENC,GESTION,DT_CREAT,CODE_CPT,CODE_ORD,TYPE_CREDIT,NAT_REF,REFERENCE,DT_REF) VALUES (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10)'
,' #1(10):22RSBF0006 #2(2):BF #3(4):2022 #4(14):7/8/2022 0:0:0 #5(9):202001031 #6(8):12500801 #7(4):REMS #8(6):Autres #9(10):22RSBF0006 #10(14):7/8/2022 0:0:0'),
('SELECT CHAPITRE   FROM LIGNE_CREDIT  WHERE CHAPITRE = :b1  AND CODE_CPT = :b2  AND CODE_ORD = :b3  AND TYPE_NOMENC = :b4  AND CODE_CREDIT = :b5',' #1(4):3111 #2(9):202001031 #3(8):12500801 #4(2):BF #5(10):22RSBF0006'),)
prev_sql = None
for sql, bind in sqls:
    if(bind is not None):
        args = bind.split(' #')[1:]
        for i, arg in enumerate(args):
            arg = arg.split(':',maxsplit=1)[1]
            arg = "TO_DATE('{}')".format(datetime.datetime.strptime(arg.replace(' 0:0:0',''), '%m/%d/%Y') \
                .strftime('%d-%b-%Y')) \
                if arg.endswith(" 0:0:0") else "'{}'".format(arg)
            sql = re.sub('(:[a-z]*{})([^\d]?)'.format(i+1), arg+'\\2', sql)
            # sql = sql.replace(':b{}'.format(i+1), arg)
    sql = sqlparse.format(sql, reindent=True, keyword_case='upper')
    sql = highlight(sql, lex, formatter)
    if sql != prev_sql:
        prev_sql = sql
        print(sql+";")
    print('-------------------------------------------------------------------')
