USE NQS;
GO


IF OBJECT_ID(N'dbo.MyCursor', N'U') IS NOT NULL
BEGIN
	DROP TABLE dbo.MyCursor
END



SELECT 
	s1.name 
INTO dbo.MyCursor

FROM
	sys.all_columns AS s1
CROSS JOIN (SELECT n FROM (VALUES (1),(2),(3),(4)) AS s(n)) AS n1
CROSS JOIN (SELECT n FROM (VALUES (1),(2),(3),(4)) AS s(n)) AS n2
CROSS JOIN (SELECT n FROM (VALUES (1),(2),(3),(4)) AS s(n)) AS n3;
GO
-- (604224 row(s) affected)
-- Duration 00:00:01

CREATE CLUSTERED INDEX x ON dbo.MyCursor(name);
GO
-- Duration 00:00:02


DECLARE @name SYSNAME, @i INT = 0

DECLARE c CURSOR LOCAL FAST_FORWARD
FOR
	SELECT * FROM dbo.MyCursor

OPEN c;

FETCH c INTO @name;

WHILE (@@FETCH_STATUS <> -1)
BEGIN
	SET @i += 1;
	FETCH c INTO @name;
END

CLOSE c;
DEALLOCATE c;

-- Duration 00:00:13 // without LOCAL FAST_FORWARD
-- Duration 00:00:06 // with    LOCAL FAST_FORWARD


-- https://youtu.be/XUCxQkFoqpw?t=1842
