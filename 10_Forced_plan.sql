-- FORCED PLAN
-- OLD WAY / NEW WAY



-- Query 1
DBCC FREEPROCCACHE
EXEC sp_executesql
@stmt = N'SELECT
  p.name,
  tha.TransactionDate,
  tha.TransactionType,
  tha.Quantity,
  tha.ActualCost
FROM Production.TransactionHistoryArchive tha
JOIN Production.Product p
ON tha.ProductID = p.ProductID
WHERE p.ProductID = @productID', 
@params = N'@productID INT',
@productID = 461



-- Query 2
DBCC FREEPROCCACHE
EXEC sp_executesql
@stmt = N'SELECT
  p.name,
  tha.TransactionDate,
  tha.TransactionType,
  tha.Quantity,
  tha.ActualCost
FROM Production.TransactionHistoryArchive tha
JOIN Production.Product p
ON tha.ProductID = p.ProductID
WHERE p.ProductID = @productID', 
@params = N'@productID INT',
@productID = 712 




EXEC sp_create_plan_guide
@name = N'ForcePlan',
@stmt = N'SELECT
 p.name,
 tha.TransactionDate,
 tha.TransactionType,
 tha.Quantity,
 tha.ActualCost
FROM Production.TransactionHistoryArchive tha
JOIN Production.Product p
ON tha.ProductID = p.ProductID
WHERE p.ProductID = @productID', 
@type = N'SQL',
@module_or_batch = NULL,
@params = N'@productID INT',
@hints = '<ShowPlanXML xmlns="http://schemas.microsoft.com/sqlserver/2004/07/showplan" Version="1.4" Summary……….’