USE NQS;
GO

-- Purge data in query store
ALTER DATABASE NQS 
	SET QUERY_STORE CLEAR;


DBCC FREEPROCCACHE;
GO

-- ALL PLANS
SELECT * FROM sys.dm_exec_cached_plans


-- REUSED PLANS

SELECT 
	 usecounts
	,cacheobjtype
	,objtype
	,text 
FROM 
	sys.dm_exec_cached_plans 
	CROSS APPLY sys.dm_exec_sql_text(plan_handle) 
WHERE 
	usecounts > 1 
ORDER BY 
	usecounts DESC;
GO


-- SHOW PLANS for Prepared Execution plans
SELECT 
	plan_handle
	,query_plan
	,objtype 
FROM	
	sys.dm_exec_cached_plans 
	CROSS APPLY sys.dm_exec_query_plan(plan_handle) 
WHERE 
	objtype ='Prepared';
GO


-- MEMORY BREAKDOWN FOR ALL CACHED PLANS

SELECT 
	 plan_handle
	,ecp.memory_object_address AS CompiledPlan_MemoryObject
	,omo.memory_object_address
	,type
	,page_size_in_bytes 

FROM
	sys.dm_exec_cached_plans AS ecp 
	JOIN sys.dm_os_memory_objects AS omo 
    ON ecp.memory_object_address = omo.memory_object_address 
    OR ecp.memory_object_address = omo.parent_address

WHERE 
	cacheobjtype = 'Compiled Plan';
GO

-- GEtting single plan

SELECT * FROM sys.dm_exec_query_plan(0x06000C003FDB7722002D13DA7200000001000000000000000000000000000000000000000000000000000000)


-- #######################
-- QUERY PLANS
-- #######################

SELECT * FROM sys.dm_exec_query_plan


USE master;
GO
	EXEC sp_who;
GO

USE master;
GO

SELECT * 
	FROM sys.dm_exec_requests
	WHERE session_id = 53;
GO


-- GETTING A SINGLE QUERY PLAN

SELECT * FROM sys.dm_exec_query_plan(0x06000C003FDB7722002D13DA7200000001000000000000000000000000000000000000000000000000000000)


-- RETRIEVE EVERY QUERY PLAN FROM THE PLAN CACHE

USE master;
GO
	SELECT * FROM sys.dm_exec_cached_plans AS cp 
	CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle)

WHERE
	DB_NAME() = 'NQS';
GO


-- Retrieve top 5 queries by average CPU time

USE NQS; 
GO

SELECT TOP 5 
	 total_worker_time/execution_count AS [Avg CPU Time]
	,Plan_handle
	,query_plan 
FROM 
	sys.dm_exec_query_stats AS qs
	CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle)

ORDER BY 
	total_worker_time/execution_count DESC;
GO