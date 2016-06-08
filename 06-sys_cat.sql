USE NQS;
GO
/*
-- http://slavasql.blogspot.si/2014/11/newest-sql-server-feature-query-store.html
*/

SELECT * FROM  sys.query_store_runtime_stats 

-- force plan for particular query
EXEC sp_query_store_force_plan 1, 1; 


SELECT * FROM sys.query_store_plan

-- unforce plan for particular query
EXEC sp_query_store_unforce_plan 1, 1; 



SELECT * FROM sys.query_store_query_text
WHERE 
	query_text_id = 270

SELECT * FROM sys.query_store_query
where query_text_id = 270


SELECT * FROM sys.query_store_plan
WHERE query_id = 277
-- plan_id		query_id
-- 290			277


-- force plan for particular query
EXEC sp_query_store_force_plan 277, 290; 

-- unforce plan for particular query
EXEC sp_query_store_unforce_plan 277, 290; 
