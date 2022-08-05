-- APEX cleanup
@?/apex/apxremov.sql
drop package HTMLDB_SYSTEM;

-- Oracle Spatial (SDO) Clean Up
drop user MDSYS cascade;

set pagesize 0 
set feed off 
spool dropsyn.sql 
select 'drop public synonym "' || synonym_name || '";' from dba_synonyms where table_owner='MDSYS'; 
spool off;
@dropsyn.sql


drop user mddata cascade;
drop user spatial_csw_admin_usr cascade;

@?/md/admin/mddins.sql

-- Oracle Text (CONTEXT) Clean Up
@?/ctx/admin/catnoctx.sql
drop procedure sys.validate_context;
drop package XDB.dbms_xdbt;
drop procedure xdb.xdb_datastore_proc;
start ?/rdbms/admin/utlrp.sql


-- XOQ – OLAP API
@?/olap/admin/olapidrp.plb
@?/olap/admin/catnoxoq.sql
@?/rdbms/admin/utlrp.sql

-- Expression Filter and Rules Manager (EXF, RUL) Clean Up
@?/rdbms/admin/catnoexf.sql


-- JAVAVM and XML Clean Up
@?/rdbms/admin/catnojav.sql
@?/xdk/admin/rmxml.sql
@?/javavm/install/rmjvm.sql
@?/rdbms/admin/utlrp.sql
delete from registry$ where status='99' and cid in ('XML','JAVAVM','CATJAVA');
commit;

-- XDB Clean Up
shutdown immediate
startup upgrade
@?/rdbms/admin/catnoqm.sql


start ?/rdbms/admin/catxdbdv.sql

start ?/rdbms/admin/dbmsmeta.sql
start ?/rdbms/admin/dbmsmeti.sql
start ?/rdbms/admin/dbmsmetu.sql
start ?/rdbms/admin/dbmsmetb.sql
start ?/rdbms/admin/dbmsmetd.sql
start ?/rdbms/admin/dbmsmet2.sql
start ?/rdbms/admin/catmeta.sql
start ?/rdbms/admin/prvtmeta.plb
start ?/rdbms/admin/prvtmeti.plb
start ?/rdbms/admin/prvtmetu.plb
start ?/rdbms/admin/prvtmetb.plb
start ?/rdbms/admin/prvtmetd.plb
start ?/rdbms/admin/prvtmet2.plb
start ?/rdbms/admin/catmet2.sql