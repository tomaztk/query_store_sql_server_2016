USE NQS;
GO

-- GET ALL THE VIEWS

DECLARE @table AS TABLE(
			 table_qualifies VARCHAR(1000)
			,table_owner VARCHAR(1000)
			,table_name VARCHAR(1000)
			,table_type VARCHAR(10)
			,remark VARCHAR(50)
			)

INSERT INTO @table
--EXECUTE SP_TABLES @Table_Type = '''VIEW'''
EXECUTE SP_TABLES

SELECT * FROM @table 
	WHERE 
		table_name like '%uery_stor%'





DECLARE @cmd varchar(8000)
SELECT @cmd = 'USE ? SELECT ''?'', object_id, definition, is_recompiled FROM sys.sql_modules'
EXEC sp_MSforeachdb @cmd



-- Query Store options
SELECT 
	 actual_state
	,actual_state_desc
	,readonly_reason
	,current_storage_size_mb
	,max_storage_size_mb
FROM 
	sys.database_query_store_options;


-- Last n queries executed on the database?
SELECT  TOP 10 
	 qt.query_sql_text
	,q.query_id
	,qt.query_text_id
	,p.plan_id
	,rs.last_execution_time
FROM 
	 sys.query_store_query_text AS qt 
	JOIN sys.query_store_query AS q 
    ON qt.query_text_id = q.query_text_id 
	JOIN sys.query_store_plan AS p 
    ON q.query_id = p.query_id 
	JOIN sys.query_store_runtime_stats AS rs 
    ON p.plan_id = rs.plan_id

ORDER BY 
	rs.last_execution_time DESC;
GO


-- Query for showing total execution time count over 
-- time available (data being stored) in Query Store

SELECT 
	 q.query_id
	,qt.query_text_id
	,qt.query_sql_text
	,SUM(rs.count_executions) AS total_execution_count

FROM 
	sys.query_store_query_text AS qt 
	JOIN sys.query_store_query AS q 
    ON qt.query_text_id = q.query_text_id 
	JOIN sys.query_store_plan AS p 
    ON q.query_id = p.query_id 
	JOIN sys.query_store_runtime_stats AS rs 
    ON p.plan_id = rs.plan_id

GROUP BY 
		 q.query_id
		,qt.query_text_id
		,qt.query_sql_text

ORDER BY 
	total_execution_count DESC;
GO



-- The number of queries with the longest average execution time within last hour?
SELECT 
	TOP 10 
    rs.avg_duration
   ,qt.query_sql_text
   ,q.query_id
   ,qt.query_text_id
   ,p.plan_id
   ,GETUTCDATE() AS CurrentUTCTime
   ,rs.last_execution_time 
FROM 
	sys.query_store_query_text AS qt 
	JOIN sys.query_store_query AS q 
    ON qt.query_text_id = q.query_text_id 
	JOIN sys.query_store_plan AS p 
    ON q.query_id = p.query_id 
	JOIN sys.query_store_runtime_stats AS rs 
    ON p.plan_id = rs.plan_id
WHERE 
	rs.last_execution_time > DATEADD(hour, -1, GETDATE())
	 
ORDER BY 
	rs.avg_duration DESC;
GO

-- The number of queries that had the biggest average physical IO reads in last 24 hours, with corresponding average row count and execution count?
SELECT TOP 10 
	 rs.avg_physical_io_reads
	,qt.query_sql_text
	,q.query_id
	,qt.query_text_id
	,p.plan_id
	,rs.runtime_stats_id
	,rsi.start_time
	,rsi.end_time
	,rs.avg_rowcount
	,rs.count_executions

FROM 
	sys.query_store_query_text AS qt 
	JOIN sys.query_store_query AS q 
    ON qt.query_text_id = q.query_text_id 
	JOIN sys.query_store_plan AS p 
    ON q.query_id = p.query_id 
	JOIN sys.query_store_runtime_stats AS rs 
    ON p.plan_id = rs.plan_id 
	JOIN sys.query_store_runtime_stats_interval AS rsi 
    ON rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
WHERE 
	rsi.start_time >= DATEADD(hour, -24, GETDATE()) 
ORDER BY 
	rs.avg_physical_io_reads DESC;
GO

-- Queries with multiple plans available
;WITH Query_MultPlans
AS
(
SELECT 
	 COUNT(*) AS cnt
	,q.query_id 
FROM 
	sys.query_store_query_text AS qt
	JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id
	JOIN sys.query_store_plan AS p
    ON p.query_id = q.query_id
GROUP 
	BY q.query_id
HAVING 
	COUNT(distinct plan_id) > 1
)

SELECT 
	 q.query_id
	,object_name(object_id) AS ContainingObject
	,query_sql_text
	,plan_id
	,p.query_plan AS plan_xml
	,p.last_compile_start_time
	,p.last_execution_time

FROM 
	Query_MultPlans AS qm
	JOIN sys.query_store_query AS q
    ON qm.query_id = q.query_id
	JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id
	JOIN sys.query_store_query_text qt 
    ON qt.query_text_id = q.query_text_id

ORDER BY 
	query_id, plan_id;



--- Queries that recently regressed in comparison in one time in history
SELECT 
     qt.query_sql_text
	,q.query_id
    ,qt.query_text_id
    ,rs1.runtime_stats_id AS runtime_stats_id_1
    ,rsi1.start_time AS interval_1
    ,p1.plan_id AS plan_1
    ,rs1.avg_duration AS avg_duration_1
    ,rs2.avg_duration AS avg_duration_2
    ,p2.plan_id AS plan_2
    ,rsi2.start_time AS interval_2
    ,rs2.runtime_stats_id AS runtime_stats_id_2
FROM 
	sys.query_store_query_text AS qt 
	JOIN sys.query_store_query AS q 
    ON qt.query_text_id = q.query_text_id 
	JOIN sys.query_store_plan AS p1 
    ON q.query_id = p1.query_id 
	JOIN sys.query_store_runtime_stats AS rs1 
    ON p1.plan_id = rs1.plan_id 
	JOIN sys.query_store_runtime_stats_interval AS rsi1 
    ON rsi1.runtime_stats_interval_id = rs1.runtime_stats_interval_id 
	JOIN sys.query_store_plan AS p2 
    ON q.query_id = p2.query_id 
	JOIN sys.query_store_runtime_stats AS rs2 
    ON p2.plan_id = rs2.plan_id 
	JOIN sys.query_store_runtime_stats_interval AS rsi2 
    ON rsi2.runtime_stats_interval_id = rs2.runtime_stats_interval_id
WHERE 
		rsi1.start_time > DATEADD(hour, -48, GETUTCDATE()) 
    AND rsi2.start_time > rsi1.start_time 
    AND p1.plan_id <> p2.plan_id
    AND rs2.avg_duration > 2*rs1.avg_duration
ORDER BY 
	 q.query_id
	,rsi1.start_time
	,rsi2.start_time;
go




-- Queries that recently regressed in performance (comparing recent vs. history execution)?


--- "Recent" workload - last 1 minute
DECLARE @recent_start_time datetimeoffset;
DECLARE @recent_end_time datetimeoffset;
SET @recent_start_time = DATEADD(hour, -10, GETDATE());
SET @recent_end_time = GEtDATE();

--- "History" workload - from 10 minutes ago
DECLARE @history_start_time datetimeoffset;
DECLARE @history_end_time datetimeoffset;
SET @history_start_time = DATEADD(day, -10, GETDATE());
SET @history_end_time = GETDATE();

WITH
hist AS
(
    SELECT 
        p.query_id query_id, 
        CONVERT(float, SUM(rs.avg_duration*rs.count_executions)) total_duration, 
        SUM(rs.count_executions) count_executions,
        COUNT(distinct p.plan_id) num_plans 
     FROM sys.query_store_runtime_stats AS rs
        JOIN sys.query_store_plan p ON p.plan_id = rs.plan_id
    WHERE  (rs.first_execution_time >= @history_start_time 
               AND rs.last_execution_time < @history_end_time)
        OR (rs.first_execution_time <= @history_start_time 
               AND rs.last_execution_time > @history_start_time)
        OR (rs.first_execution_time <= @history_end_time 
               AND rs.last_execution_time > @history_end_time)
    GROUP BY p.query_id
),
recent AS
(
    SELECT 
        p.query_id query_id, 
        CONVERT(float, SUM(rs.avg_duration*rs.count_executions)) total_duration, 
        SUM(rs.count_executions) count_executions,
        COUNT(distinct p.plan_id) num_plans 
    FROM sys.query_store_runtime_stats AS rs
        JOIN sys.query_store_plan p ON p.plan_id = rs.plan_id
    WHERE  (rs.first_execution_time >= @recent_start_time 
               AND rs.last_execution_time < @recent_end_time)
        OR (rs.first_execution_time <= @recent_start_time 
               AND rs.last_execution_time > @recent_start_time)
        OR (rs.first_execution_time <= @recent_end_time 
               AND rs.last_execution_time > @recent_end_time)
    GROUP BY p.query_id
)
SELECT 
    results.query_id query_id,
    results.query_text query_text,
    results.additional_duration_workload additional_duration_workload,
    results.total_duration_recent total_duration_recent,
    results.total_duration_hist total_duration_hist,
    ISNULL(results.count_executions_recent, 0) count_executions_recent,
    ISNULL(results.count_executions_hist, 0) count_executions_hist 
FROM
(
    SELECT
        hist.query_id query_id,
        qt.query_sql_text query_text,
        ROUND(CONVERT(float, recent.total_duration/
                   recent.count_executions-hist.total_duration/hist.count_executions)
               *(recent.count_executions), 2) AS additional_duration_workload,
        ROUND(recent.total_duration, 2) total_duration_recent, 
        ROUND(hist.total_duration, 2) total_duration_hist,
        recent.count_executions count_executions_recent,
        hist.count_executions count_executions_hist   
    FROM hist 
        JOIN recent 
            ON hist.query_id = recent.query_id 
        JOIN sys.query_store_query AS q 
            ON q.query_id = hist.query_id
        JOIN sys.query_store_query_text AS qt 
            ON q.query_text_id = qt.query_text_id    
) AS results
WHERE additional_duration_workload > 0
ORDER BY additional_duration_workload DESC
OPTION (MERGE JOIN);




SELECT * FROM sys.query_store_runtime_stats