/* 

QUERY STORE XE

*/


SELECT name, type_desc FROM sys.all_objects 
WHERE name LIKE '%uery_stor%' or name= 'query_context_settings'


/*

CREATE DB2
*/


CREATE DATABASE DB2;
GO

USE DB2;

CREATE TABLE T1
(ID INT
,T VARCHAR(10)
)

INSERT into T1(ID,T)
SELECT 
	number AS ID
	,'lalal' AS t
FROM
	master..spt_values
WHERE
	type = 'P'
GO 10

ALTER DATABASE [DB2] SET QUERY_STORE = ON;
GO


SELECT * FROM db2.dbo.t1;
GO 10


-- PUT DB2 into Read-only mode

ALTER DATABASE DB2 SET READ_ONLY;
GO 


SELECT * FROM sys.database_query_store_options

-- RUN QUERY; no recordings to query store
SELECT * FROM db2.dbo.t1;
GO 20


-- READONLY_REASON
/*

1 – database is in read-only mode
2 – database is in single-user mode
3 – database is in read-only / single-user mode
5 – database is in emergency mode
8 – database is in log accept mode
*/

USE MASTER;
GO

ALTER DATABASE DB2 SET SINGLE_USER;
GO

USE DB2;
GO

SELECT * FROM sys.database_query_store_options

USE MASTER;
GO

ALTER DATABASE DB2 SET MULTI_USER;
GO

USE DB2;
GO

SELECT * FROM sys.database_query_store_options


-- put it to emergency mode



ALTER DATABASE [db2] SET EMERGENCY;
GO

SELECT * FROM sys.database_query_store_options

/*
DBCC CHECKDB (N'db2', REPAIR_ALLOW_DATA_LOSS) WITH ALL_ERRORMSGS, NO_INFOMSGS;
GO
*/

ALTER DATABASE [db2] SET ONLINE;
GO

SELECT * FROM sys.database_query_store_options




/*

sys.query_store_query_text

sys.query_store_query

*/

SELECT * FROM sys.query_store_query

SELECT * FROM sys.query_store_query_text

-- SELECT * FROM sys.query_context_settings

SELECT * FROM sys.query_store_plan



/*

sys.query_store_runtime_stats


sys.query_store_runtime_stats_interval


*/


SELECT * FROM sys.query_store_runtime_stats


SELECT * FROM sys.query_store_runtime_stats_interval




/*

INTERNALS!
INTERNAL TABLES
*/



SELECT DB_ID() 

DBCC FLUSHPROCINDB (16)




select * from sys.internal_tables

sp_spaceused 'sys.plan_persist_query'; 
GO
sp_spaceused 'plan_persist_query_text'; 
GO
sp_spaceused 'plan_persist_query'; 
GO
sp_spaceused 'plan_persist_plan'; 
GO
sp_spaceused 'plan_persist_runtime_stats'; 
GO
sp_spaceused 'plan_persist_runtime_stats_interval'; 
GO
sp_spaceused 'plan_persist_context_settings'; 
GO


-- structure of internal table

SELECT SCHEMA_NAME(itab.schema_id) AS schema_name
    ,itab.name AS internal_table_name
    ,typ.name AS column_data_type 
    ,col.*
FROM sys.internal_tables AS itab
JOIN sys.columns AS col ON itab.object_id = col.object_id
JOIN sys.types AS typ ON typ.user_type_id = col.user_type_id
ORDER BY itab.name, col.column_id;



-- index statistics on internal tables
SELECT SCHEMA_NAME(itab.schema_id) AS schema_name
    ,itab.name AS internal_table_name
    , s.*
FROM sys.internal_tables AS itab
JOIN sys.stats AS s ON itab.object_id = s.object_id
ORDER BY itab.name, s.stats_id;





SELECT SCHEMA_NAME(itab.schema_id) AS schema_name
    ,itab.name AS internal_table_name
    ,idx.name AS heap_or_index_name
    ,p.*
    ,au.*
FROM sys.internal_tables AS itab
JOIN sys.indexes AS idx
--     JOIN to the heap or the clustered index
    ON itab.object_id = idx.object_id AND idx.index_id IN (0,1)
JOIN   sys.partitions AS p 
    ON p.object_id = idx.object_id AND p.index_id = idx.index_id
JOIN   sys.allocation_units AS au
--     IN_ROW_DATA (type 1) and ROW_OVERFLOW_DATA (type 3) => JOIN to partition's Hobt
--     else LOB_DATA (type 2) => JOIN to the partition ID itself.
ON au.container_id =  
    CASE au.type 
        WHEN 2 THEN p.partition_id 
        ELSE p.hobt_id 
    END
ORDER BY itab.name, idx.index_id;


/*

RECOMPILE OPTION

*/


select * from [dbo].[butromogothurt];
go

select * from [dbo].[dezhastostepupnextyear]
option (recompile);
go

select * from  sys.query_store_query_text
select * from  sys.query_store_query
order by query_id
select * from  sys.query_store_plan


-- recompile 
-- it means plan is not cached!

select * FROM sys.dm_exec_cached_plans AS CP WITH(NOLOCK)
    CROSS APPLY sys.dm_exec_sql_text(CP.plan_handle) AS T



ALTER DATABASE [whatanotsogoodyearforthedallascowboys] SET QUERY_STORE CLEAR;