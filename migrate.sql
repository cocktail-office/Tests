set head off pagesize 0 linesize 1000 feedback off  verify off termout off  pages 0 echo off ver off feedb off head off emb on showmode off autotrace off trimspool on;

spool prepare.sql




-- Profiles
select 'create profile "'||profile||'" limit '||resource_name||' '||limit ||' ;'from dba_profiles where profile not in ('DEFAULT');

-- tablespaces 
select 'create tablespace ' || nvl(b.tablespace_name, nvl(a.tablespace_name,'UNKOWN')) || ' datafile  ''/u00/databases/$ORACLE_SID/oradata/'|| lower(nvl(b.tablespace_name, nvl(a.tablespace_name,'UNKOWN'))) || '01.dbf'' size '|| ceil((kbytes_alloc-nvl(kbytes_free,0))/64)*64  ||'M AUTOEXTEND ON NEXT 8M MAXSIZE '|| ceil((kbytes_alloc-nvl(kbytes_free,0))/32*1.2+1)*32 ||'M EXTENT MANAGEMENT LOCAL AUTOALLOCATE SEGMENT SPACE MANAGEMENT  AUTO;' from
( select sum(bytes)/1024/1024 Kbytes_free,
              tablespace_name
       from  sys.dba_free_space
       group by tablespace_name ) a,
     ( select sum(bytes)/1024/1024 Kbytes_alloc,
              tablespace_name
       from sys.dba_data_files
       group by tablespace_name  )b
where a.tablespace_name = b.tablespace_name and b.tablespace_name not in ('PERFSTAT','RBS','ROLLBACKS','SYSAUD','SYSAUX','SYSTEM','TEMP','TOOLS', 'UNDOTBS1','UNDO','UNDO01','UNDO1','USERS','XDB');



-- public synonyms
select 'create public synonym "'||synonym_name||'" for '|| decode(TABLE_OWNER,null,null,'"'||TABLE_OWNER||'".')||'"'||TABLE_NAME||'"'|| decode(DB_LINK,null,null,'@"'||DB_LINK||'"') ||';' text from dba_synonyms where OWNER='PUBLIC' and ( table_owner not in ('ADAMS','ANONYMOUS','BLAKE','CLARK','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','HR','JONES','MDDATA','MDSYS','MGMT_VIEW','ODM','ODM_MTR','OE','OLAPSYS','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','QS','QS_ADM','QS_CB','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SCOTT','SH','SI_INFORMTN_SCHEMA','SYS','SYSTEM','TRACESVR','TSMSYS', 'WKPROXY','WKSYS','WK_TEST','WMSYS','XDB','SYSMAN','ORACLE_OCM','REPOSITORY','TOAD','SQLNAV') or db_link is not null ) ;


-- roles
select  'create role "'||name||'"'|| decode(PASSWORD, 'EXTERNAL',' identified externally',null,null,' identified by values '''||PASSWORD||''' ')||';' text from sys.user$, dba_roles where name=role and name not in ('AQ_ADMINISTRATOR_ROLE','AQ_USER_ROLE','AUTHENTICATEDUSER','CONNECT','CTXAPP','DBA','DELETE_CATALOG_ROLE','EJBCLIENT','EXECUTE_CATALOG_ROLE','EXP_FULL_DATABASE','GATHER_SYSTEM_STATISTICS','GLOBAL_AQ_USER_ROLE','HS_ADMIN_ROLE','IMP_FULL_DATABASE','JAVADEBUGPRIV','JAVAIDPRIV','JAVASYSPRIV','JAVAUSERPRIV','JAVA_ADMIN','JAVA_DEPLOY','LOGSTDBY_ADMINISTRATOR','OEM_MONITOR','PLUSTRACE','RECOVERY_CATALOG_OWNER','RESOURCE','SCHEDULER_ADMIN','SELECT_CATALOG_ROLE','SNMPAGENT','TKPROFER','WKUSER','WM_ADMIN_ROLE','XDBADMIN') and name not like 'OEM_%' and name not like 'MGMT_%';




-- users
select 'create user "'||username||'" identified '|| decode(PASSWORD, 'EXTERNAL','externally ','by values '''||PASSWORD||''' ')|| decode(DEFAULT_TABLESPACE,'SYSTEM',null,' default tablespace "'||DEFAULT_TABLESPACE||'" ')|| decode(TEMPORARY_TABLESPACE,'SYSTEM',null,' temporary tablespace "'||TEMPORARY_TABLESPACE||'" ')|| decode(profile,'DEFAULT', null, ' profile "'||PROFILE||'" ')||';' text from dba_users where username in ('SCOLARITE','SOUTE','STOCK');


-- Privs  X_x

-- system privilege
select 'grant '||privilege||' to "'||grantee||'"'|| decode(ADMIN_OPTION,'YES', ' WITH ADMIN OPTION')||';' from dba_sys_privs  where grantee in ('APOGEE');

-- role privilege
select 'grant '||granted_role||' to "'||grantee||'"'|| decode(ADMIN_OPTION,'YES', ' WITH ADMIN OPTION')||';' from dba_role_privs  where grantee in ('APOGEE');

-- tablespace quota
select 'alter user "'||username||'" quota '|| decode(MAX_BYTES,-1, 'unlimited', (MAX_BYTES/1024)||'K ')|| ' on "'||TABLESPACE_NAME||'";' from dba_ts_quotas  where  username   in ('APOGEE');


spool off
