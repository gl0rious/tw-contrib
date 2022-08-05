show parameter service;

SELECT *
FROM   dba_services

exec dbms_service.create_service('SIT08001','SIT08001');
exec dbms_service.start_service('SIT08001');

SELECT name,
       network_name
FROM   v$active_services
ORDER BY 1;


alter system set service_names = 'XE,SIT08001' scope = both;
alter system register;