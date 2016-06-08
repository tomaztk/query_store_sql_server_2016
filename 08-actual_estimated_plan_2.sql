USE NQS;
GO

-- Estimated Plan
-- No Actual plan!
/*
EXAMPLE 1
*/

DECLARE @Var AS INTEGER
SET @Var = 10

IF @Var > 5 BEGIN
    SELECT @Var
END ELSE BEGIN
    SELECT 0
END


WHILE @Var > 10 BEGIN
    SET @Var = @Var - 1
END



/*
EXAMPLE 2
*/
-- difference between estimated and actual
-- with actual it solves the logical IF and executes
-- just a block of T-SQL within IF Statement

DECLARE @Var AS INTEGER = 10

IF @Var > 5 BEGIN
    SELECT * FROM AdventureWorks.Person.Person
WHERE BusinessEntityID = @Var
END ELSE BEGIN
    SELECT TOP(1) * FROM AdventureWorks.Person.Person
WHERE BusinessEntityID < @Var
END


/*
EXAMPLE 3
*/
-- 
-- same exeuction plan reused 

DECLARE @Var AS INTEGER = 3
WHILE @Var > 0 BEGIN
    SELECT * FROM AdventureWorks.Person.Person WHERE BusinessEntityID = @Var
    SET @Var = @Var - 1
END



/*
EXAMPLE 4

*/

-- UPDAting statistics on table

--Creating table
CREATE TABLE V_stat_test (
    ID BIGINT PRIMARY KEY IDENTITY,
    v_text VARCHAR(100),
    c_int INT
)

-- GETTING SOME MOCK DATA
INSERT V_stat_test
SELECT
    LEFT([Text],100) AS ID
    ,severity  AS v_text
FROM sys.messages
-- (278674 row(s) affected)
-- Duration: 00:00:08


CREATE NONCLUSTERED INDEX NCI_Age ON V_stat_test(c_int)

-- check estim/actu plan
SELECT v_text FROM V_stat_test WHERE c_int = 21
-- estimated plan
-- estimated number of rows: 1738
-- estimated row size: 65 B
-- estimated data size: 110 KB


-- ### Run Query: 
-- actual plan
-- Actual number of rows: 1738
-- estimated number of rows: 1738
-- estimated row size: 65 B
-- estimated data size: 110 KB

-- (1738 row(s) affected)


DELETE FROM V_stat_test WHERE c_int = 21

-- (1738 row(s) affected)


-- check estim/actu plan
SELECT v_text FROM V_stat_test WHERE c_int = 21
-- estimated plan
-- estimated number of rows: 1738
-- estimated row size: 65 B
-- estimated data size: 110 KB

-- ### Run Query: 
-- actual plan
-- Actual number of rows: 0
-- estimated number of rows: 1738
-- estimated row size: 65 B
-- estimated data size: 110 KB


UPDATE STATISTICS V_stat_test
-- Duration: 00:00:01


-- check only estimated execution plan
SELECT v_text FROM V_stat_test WHERE c_int = 21
-- estimated plan
-- estimated number of rows: 1
-- estimated row size: 65 B
-- estimated data size: 65 B

-- ### Run Query: 
-- actual plan
-- Actual number of rows: 0
-- estimated number of rows: 1
-- estimated row size: 65 B
-- estimated data size: 65 B
