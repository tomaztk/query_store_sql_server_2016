/*

SELECT
   qp.query_id
  ,qp.query_plan
  ,qt.query_sql_text
  ,qp.last_execution_time
  ,qp.initial_compile_start_time
  ,CAST(query_plan AS XML) AS 'Execution Plan'
  ,rs.avg_duration
  ,rs.min_duration
  ,rs.max_duration
  ,rs.stdev_duration
  ,rs.avg_logical_io_reads
  ,rs.avg_physical_io_reads
  ,rs.last_dop
  ,is_forced_plan

into SQLR.dbo.QS_TEST

FROM sys.query_store_plan qp
INNER JOIN sys.query_store_query q
  ON qp.query_id = q.query_id
INNER JOIN sys.query_store_query_text qt
  ON q.query_text_id = qt.query_text_id
INNER JOIN sys.query_store_runtime_stats rs
  ON qp.plan_id = rs.plan_id

WHERE
	(qt.query_sql_text LIKE '%MyTableAP%'
AND qt.query_sql_text NOT LIKE '%sys.query_store_runtime_stats%')

-- (21 row(s) affected)


*/


--- MY DATASET
SELECT
   ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS rn 
  ,query_id
  ,CAST(avg_duration AS INT) AS avg_duration
  ,min_duration
  ,max_duration
  ,CAST(stdev_duration AS INT) AS stdev_duration
  ,avg_logical_io_reads
  ,avg_physical_io_reads
  ,last_dop
  ,is_forced_plan
FROM dbo.QS_TEST



-- MY R PROCEDURE for clustering
ALTER PROCEDURE [dbo].[SQLR_QS_Clusters]
AS

DECLARE @RScript nvarchar(max)
SET @RScript = N'
				 library(cluster)	
				 image_file <- tempfile()
				 jpeg(filename = image_file, width = 500, height = 500)
				 mydata <- InputDataSet
				 d <- dist(mydata, method = "euclidean") 
				 fit <- hclust(d, method="ward.D")
				 plot(fit)
				 dev.off() 
				 OutputDataSet <- data.frame(data=readBin(file(image_file, "rb"), what=raw(), n=1e6))'

DECLARE @SQLScript nvarchar(max)
SET @SQLScript = N'select 
				  -- query_id
				  --,
				   avg_duration
				  ,min_duration
				  ,max_duration
				  ,stdev_duration
				  ,avg_logical_io_reads
				  ,avg_physical_io_reads
				  ,last_dop
				  ,is_forced_plan
				from dbo.QS_TEST'

EXECUTE sp_execute_external_script
	 @language = N'R'
	,@script = @RScript
	,@input_data_1 = @SQLScript
WITH RESULT SETS (
					(Hierarchical varbinary(max))
				 )


-- cor(mtcars, use="complete.obs", method="kendall") 

-- R PROCEDURE FOR statistical test for performance in FORCED PLAN!
ALTER PROCEDURE [dbo].[SQLR_QS_Pearson]
AS
DECLARE @RScript nvarchar(max)
SET @RScript = N' 
	             mydata <- InputDataSet
				 df <- data.frame(cor(mydata, use="complete.obs", method="pearson") )
				 OutputDataSet <- df'

DECLARE @SQLScript nvarchar(max)
SET @SQLScript = N'select 
				   avg_duration
				  ,is_forced_plan
				from dbo.QS_TEST'

EXECUTE sp_execute_external_script
	 @language = N'R'
	,@script = @RScript
	,@input_data_1 = @SQLScript
WITH RESULT SETS (
					(avg_duration DECIMAL(10,4)
					,is_forced_plan DECIMAL(10,4))
				 )


execute [dbo].[SQLR_QS_Pearson]