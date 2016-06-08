USE NQS;
GO

-- CASE OF ACTUAL vs. ESTIMATED EXECTION PLAN
-- AND DIFFERENCES

/*
-- http://sqlperformance.com/2012/11/t-sql-queries/ten-common-threats-to-execution-plan-quality
*/

IF EXISTS ( SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[NewOrders]') AND type in ( N'U' ) )
	DROP TABLE [NewOrders];
GO



SELECT 
	*
	INTO NewOrders
FROM 
	AdventureWorks.Sales.SalesOrderDetail;
GO
-- (121317 row(s) affected)
-- Duration 00:00:00


CREATE INDEX IX_NO_ProductID on NewOrders(ProductID);
GO







SET SHOWPLAN_XML ON
-- Estimated Plan
GO

SELECT 
	 OrderQty
	,CarrierTrackingNumber
FROM 
	NewOrders
WHERE 
	ProductID = 897

GO

SET SHOWPLAN_XML OFF
GO



BEGIN TRAN
	UPDATE NewOrders
		SET [ProductID] = 897
		WHERE 
			[ProductID] between 800 and 900;
GO
-- (40058 row(s) affected)

SET STATISTICS XML ON
-- Actual Plan
GO

SELECT 
	 OrderQty
	,CarrierTrackingNumber
FROM 
	NewOrders
WHERE 
	ProductID = 897
	
ROLLBACK TRAN
GO
SET STATISTICS XML OFF