/*

TEST for C# Win APP

*/

USE [NQS]
GO

IF OBJECT_ID(N'dbo.MyTableAP', N'U') IS NOT NULL
BEGIN
	DROP TABLE dbo.MyTableAP
END

CREATE TABLE [dbo].[MyTableAP](
	[ID] [tinyint] NOT NULL,
	[VAL] [smallint] NOT NULL
) ON [PRIMARY]

GO

INSERT INTO dbo.MyTableAP (id, val)
SELECT 
	1 AS id
	,number AS val
FROM 
	master..spt_values
WHERE TYPE = 'P'
UNION ALL
SELECT 2 AS id, 2048 AS val
-- (2049 row(s) affected)


/*
--OPTION FORCED PLAN
*/


DECLARE @i AS SMALLINT = 1
WHILE @i < 200

BEGIN
	DECLARE @id AS TINYINT = 1
	DECLARE @val AS SMALLINT = 0
	SET @VAL = @i

			SELECT * 
				FROM MyTableAP
			WHERE
				id = @id
			AND val = @val
	SET @i += 1
END



DECLARE @ide AS TINYINT = 1
--DECLARE @val AS SMALLINT = 2048 

SELECT * 
	FROM MyTableAP
WHERE
	id = @ide
--AND val = @val

-- OPTION (USE PLAN N'')



-- Option and plan reuse
-- Same query with different parameter

-- query with param = 1
SELECT * 
FROM AdventureWorks.Production.Product 
WHERE ProductSubcategoryID = 1;


-- query with param = 4
SELECT * 
FROM AdventureWorks.Production.Product 
WHERE ProductSubcategoryID = 4;


 -- gimnastika15
-- query with dynamic param = 1
DECLARE @MyIntParm INT
SET @MyIntParm = 1
EXEC sp_executesql
				  N'SELECT * 
				  FROM AdventureWorks.Production.Product 
				  WHERE ProductSubcategoryID = @Parm',
				  N'@Parm INT',
				 @MyIntParm
