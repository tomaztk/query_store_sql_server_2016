USE NQS;
GO

select * from sys.dm_exec_query_stats



/* CATALOG VIEWS */

-- Run-time execution statistics for queries.
select * from sys.query_store_runtime_stats 

-- Start and end times for the intervals over which run-time execution statistics are collected.
select * from  sys.query_store_runtime_stats_interval 

-- Execution plan information for queries.
select * from sys.query_store_plan

-- Query information and its overall aggregated run-time execution statistics.
select *fROM sys.query_store_query 

-- Query text as entered by the user, including white space, hints, and comments.
select * FROM sys.query_store_query_text 



--- finding top 10 queries that perform poorly

SELECT TOP 10 
	 rs.avg_duration
	,qt.query_sql_text
	,q.query_id
	,qt.query_text_id
	,p.plan_id
	,GETUTCDATE() AS CurrentUTCTime
	,rs.last_execution_time 

FROM sys.query_store_query_text AS qt 
JOIN sys.query_store_query AS q 
ON qt.query_text_id = q.query_text_id 
JOIN sys.query_store_plan AS p 
ON q.query_id = p.query_id 
JOIN sys.query_store_runtime_stats AS rs 
ON p.plan_id = rs.plan_id 

WHERE rs.last_execution_time > DATEADD(hour, -1, GETUTCDATE()) 
ORDER BY rs.avg_duration DESC;

