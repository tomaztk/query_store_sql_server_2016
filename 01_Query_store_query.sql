USE [master];
GO

-- IF Exists: DROP DATABASE NQS; GO

CREATE DATABASE [NQS] CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'NQS', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLSERVER2016RC3\MSSQL\DATA\NQS.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'NQS_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLSERVER2016RC3\MSSQL\DATA\NQS_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO

ALTER DATABASE [NQS] SET QUERY_STORE = OFF
GO
ALTER DATABASE [NQS] SET RECOVERY SIMPLE 
GO

USE NQS;
GO

ALTER DATABASE CURRENT SET QUERY_STORE (interval_length_minutes = 1)
ALTER DATABASE CURRENT SET QUERY_STORE=ON

CREATE TABLE MyTable 
(
	 col1 INT
	,col2 INT
	,col3 BINARY(2000)
);
GO

-- ROLLBACK TRANSACTION
SET NOCOUNT ON

BEGIN TRANSACTION
	DECLARE @i INT=0
		WHILE @i < 10000
			BEGIN
				INSERT INTO MyTable(col1,col2) VALUES (@i,@i)
				SET @i += 1
			END
COMMIT TRANSACTION;
GO

INSERT INTO MyTable (col1, col2) VALUES (1,1);
GO 10000

-- Beginning execution loop
-- Batch execution completed 10000 times.
-- Duration Time (00:00:11)


CREATE INDEX i1 ON MyTable(col1)
CREATE INDEX i2 ON MyTable(col2)




select @@servername


Select * from NQS.dbo.MyTable


---- Another parameter sniffing
USE NQS;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'U' AND [name] = 'MyTable1')
DROP TABLE dbo.MyTable1;
GO


CREATE TABLE MyTable1 
	(ID TINYINT NOT NULL
	,VAL TINYINT NOT NULL)

INSERT INTO MyTable1 (ID,VAL)
		  SELECT  1,1
UNION ALL SELECT  1,2
UNION ALL SELECT  1,3
UNION ALL SELECT  1,4
UNION ALL SELECT  1,5
UNION ALL SELECT  1,6
UNION ALL SELECT  1,7
UNION ALL SELECT  1,8
UNION ALL SELECT  1,9
UNION ALL SELECT  2,9
-- (10 row(s) affected)


IF EXISTS (SELECT * FROM sys.objects WHERE type = 'U' AND [name] = 'MyTable2')
DROP TABLE dbo.MyTable2;
GO


CREATE TABLE MyTable2
	(ID TINYINT NOT NULL
	,VAL TINYINT NOT NULL)

INSERT INTO MyTable2 (ID,VAL)
		  SELECT  3,1
UNION ALL SELECT  3,2
UNION ALL SELECT  3,3
UNION ALL SELECT  3,4
UNION ALL SELECT  3,5
UNION ALL SELECT  3,6
UNION ALL SELECT  3,7
UNION ALL SELECT  3,8
UNION ALL SELECT  3,9
UNION ALL SELECT  4,9
-- (10 row(s) affected)

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'U' AND [name] = 'MyTable3')
DROP TABLE dbo.MyTable3;
GO


CREATE TABLE MyTable3
	(ID TINYINT NOT NULL
	,VAL TINYINT NOT NULL)

INSERT INTO MyTable3 (ID,VAL)
		  SELECT  5,1
UNION ALL SELECT  5,2
UNION ALL SELECT  5,3
UNION ALL SELECT  5,4
UNION ALL SELECT  5,5
UNION ALL SELECT  5,6
UNION ALL SELECT  5,7
UNION ALL SELECT  5,8
UNION ALL SELECT  5,9
UNION ALL SELECT  6,9
-- (10 row(s) affected)





DECLARE @i AS INT = 0
DECLARE @r AS DECIMAL(10,4)

WHILE (100 >= @i)
BEGIN
SET @r = RAND()
	IF @r < 0.310
		BEGIN
			--SELECT * FROM MyTable1  WHERE ID = 1
			PRINT CAST(@i AS VARCHAR(10))+ ' | ' + 'Table1' + ' | ' + CAST(@r AS VARCHAR(20))
			SET @i = @i +1
		END

	IF @r >= 0.310 AND @r < 0.330
		BEGIN
			--SELECT * FROM MyTable1  WHERE ID = 2
			PRINT CAST(@i AS VARCHAR(10))+ ' | ' + 'Table1 - Spike' + ' | ' + CAST(@r AS VARCHAR(20))
			SET @i = @i +1
		END

	IF @r >= 0.330 AND @r <= 0.630
		BEGIN
			--SELECT * FROM MyTable2  WHERE ID = 3
			PRINT CAST(@i AS VARCHAR(10))+ ' | '  + 'Table2' + ' | ' + CAST(@r AS VARCHAR(20))
			SET @i = @i +1
		END

	IF @r > 0.630 AND @r <= 0.660
		BEGIN
			--SELECT * FROM MyTable2  WHERE ID = 4
			PRINT CAST(@i AS VARCHAR(10))+ ' | '  + 'Table2  - Spike' + ' | ' + CAST(@r AS VARCHAR(20))
			SET @i = @i +1
		END

	IF @r > 0.660 AND @r <= 0.970
		BEGIN
			--SELECT * FROM MyTable3 WHERE ID = 5
			PRINT CAST(@i AS VARCHAR(10))+ ' | '  + 'Table3' + ' | ' + CAST(@r AS VARCHAR(20))
			SET @i = @i +1
		END
    /* "% Probability of spike of */
	IF @r > 0.970
		BEGIN
			--SELECT * FROM MyTable3 WHERE ID = 6
			PRINT CAST(@i AS VARCHAR(10)) + ' | ' + 'Table3 - Spike' + ' | ' + CAST(@r AS VARCHAR(20))
			SET @i = @i +1
		END
END;
GO