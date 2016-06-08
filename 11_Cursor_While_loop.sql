CREATE PROCEDURE dbo.while_cursor
AS

DECLARE
     @schema_name SYSNAME,
     @object_name SYSNAME,
     @index_name  SYSNAME,
     @s NVARCHAR(MAX) = N'';

DECLARE indexes CURSOR
  LOCAL STATIC FORWARD_ONLY READ_ONLY
     FOR
         SELECT s = OBJECT_SCHEMA_NAME(o.[object_id]), o = o.name, i = i.name
            FROM sys.objects AS o
            INNER JOIN sys.indexes AS i
            ON o.[object_id] = i.[object_id]
            INNER JOIN
            (
               SELECT [object_id], index_id, row_count = SUM(row_count)
                  FROM sys.dm_db_partition_stats
                  GROUP BY [object_id], index_id
             ) AS s
             ON o.[object_id] = s.[object_id]
             AND i.index_id = s.index_id
             WHERE o.is_ms_shipped = 0
             AND i.index_id >= 1
             ORDER BY s.row_count DESC, s, o, i;

OPEN indexes;

FETCH NEXT FROM indexes INTO @schema_name, @object_name, @index_name;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- we're just concatenating here, but pretend we needed to, 
    -- say, call a stored procedure for each row in the cursor:

     SET @s += CHAR(13) + CHAR(10) + N'ALTER INDEX '
             + QUOTENAME(@index_name)  + ' ON '
             + QUOTENAME(@schema_name) + '.'
             + QUOTENAME(@object_name) + ' REORGANIZE;';

     FETCH NEXT FROM indexes INTO @schema_name, @object_name, @index_name;
END

CLOSE indexes;
DEALLOCATE indexes;





/*
faster
*/

CREATE PROCEDURE dbo.while_xmlconcat
AS

DECLARE @s NVARCHAR(MAX);

SELECT @s = 
(
    SELECT CHAR(13) + CHAR(10) + 'ALTER INDEX ' 
       + QUOTENAME(i) + ' ON ' 
       + QUOTENAME(s) + '.' 
       + QUOTENAME(o) + ' REORGANIZE;'
       FROM 
       (
           SELECT TOP (1000000)
               s = OBJECT_SCHEMA_NAME(o.[object_id]), 
               o = o.name, 
               i = i.name
           FROM sys.objects AS o
           INNER JOIN sys.indexes AS i
           ON o.[object_id] = i.[object_id]
           INNER JOIN 
           (
               SELECT [object_id], index_id, row_count = SUM(row_count)
                   FROM sys.dm_db_partition_stats
                   GROUP BY [object_id], index_id
           ) AS s
           ON o.[object_id] = s.[object_id]
           AND i.index_id = s.index_id
           WHERE o.is_ms_shipped = 0
           AND i.index_id >= 1
           ORDER BY s.row_count DESC, s, o, i
       ) AS x
        FOR XML PATH(''), TYPE
).value('.[1]', 'NVARCHAR(MAX)');



/*
even faster
*/

CREATE PROCEDURE dbo.while_simpleconcat
AS

DECLARE @s NVARCHAR(MAX) = N'';

SELECT @s += CHAR(13) + CHAR(10) + 'ALTER INDEX ' 
       + QUOTENAME(i) + ' ON ' 
       + QUOTENAME(s) + '.' 
       + QUOTENAME(o) + ' REORGANIZE;'
        FROM 
       (
           SELECT TOP (1000000)
               s = OBJECT_SCHEMA_NAME(o.[object_id]), 
               o = o.name, 
               i = i.name
           FROM sys.objects AS o
           INNER JOIN sys.indexes AS i
           ON o.[object_id] = i.[object_id]
           INNER JOIN 
           (
               SELECT [object_id], index_id, row_count = SUM(row_count)
                   FROM sys.dm_db_partition_stats
                   GROUP BY [object_id], index_id
           ) AS s
           ON o.[object_id] = s.[object_id]
           AND i.index_id = s.index_id
           WHERE o.is_ms_shipped = 0
           AND i.index_id >= 1
           ORDER BY s.row_count DESC, s, o, i
       ) AS x;



CREATE PROCEDURE dbo.while_colleague1
AS
SELECT
    RowID = ROW_NUMBER() OVER (ORDER BY s.row_count DESC,
      OBJECT_SCHEMA_NAME(o.[object_id]), o.name, i.name),
    s = OBJECT_SCHEMA_NAME(o.[object_id]),
    o = o.name,
    i = i.name
  INTO #Temp
  FROM sys.objects AS o
  INNER JOIN sys.indexes AS i
  ON o.[object_id] = i.[object_id]
  INNER JOIN
  (
    SELECT [object_id], index_id, row_count = SUM(row_count)
    FROM sys.dm_db_partition_stats
    GROUP BY [object_id], index_id
  ) AS s
  ON o.[object_id] = s.[object_id]
  AND i.index_id = s.index_id
  WHERE o.is_ms_shipped = 0
  AND i.index_id >= 1
  ORDER BY s.row_count DESC, s, o, i;

DECLARE @CurrentRowID INT,
        @s NVARCHAR(MAX) = N'';

SELECT @CurrentRowID = MIN(RowID)
  FROM #Temp;

WHILE @CurrentRowID IS NOT NULL
BEGIN
  SELECT @s += CHAR(13) + CHAR(10) + N'ALTER INDEX '
    + QUOTENAME(i)  + ' ON '
    + QUOTENAME(s) + '.'
    + QUOTENAME(o) + ' REORGANIZE;'
  FROM #Temp
  WHERE RowID = @CurrentRowID;

  SELECT @CurrentRowID = MIN(RowID)
    FROM #Temp
    WHERE RowID > @CurrentRowID;
END

DROP TABLE #Temp;



SET NOCOUNT ON;
GO
CREATE TABLE #stats
(
    rownum   INT IDENTITY(1,1),
    procname SYSNAME,
    dt       DATETIME2
);
GO

INSERT #stats(procname,dt) SELECT '-', SYSDATETIME();
GO
EXEC dbo.while_cursor;
GO 1000
INSERT #stats(procname,dt) SELECT 'cursor', SYSDATETIME();
GO
EXEC dbo.while_xmlconcat;
GO 1000
INSERT #stats(procname,dt) SELECT 'xml concat', SYSDATETIME();
GO
EXEC dbo.while_simpleconcat;
GO 1000
INSERT #stats(procname,dt) SELECT 'simple concat', SYSDATETIME();
GO
EXEC dbo.while_colleague1;
GO 1000
INSERT #stats(procname,dt) SELECT 'colleague 1 while', SYSDATETIME();
GO

-- using the new LAG functionality in SQL Server 2012:

SELECT
    procname,
    duration = DATEDIFF(MILLISECOND, LAG(dt, 1, NULL) OVER (ORDER BY rownum), dt)
  FROM #stats
  ORDER BY rownum;
GO

DROP TABLE #stats;
GO
