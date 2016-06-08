USE AdventureWorks;
GO

/*
USE [master]
GO
ALTER DATABASE [AdventureWorks] SET QUERY_STORE = ON
GO
ALTER DATABASE [AdventureWorks] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, INTERVAL_LENGTH_MINUTES = 1)
GO
*/


-- QUERY 1

SELECT  StoreID ,  
        Name ,
        CustomerID
FROM    Sales.Customer AS c  
        INNER JOIN Sales.Store AS s ON c.StoreID = s.BusinessEntityID
WHERE   StoreID IS NOT NULL

/*

USE AdventureWorks;
GO

-- QUERY 2

SELECT  PersonID ,  
        Title ,
        FirstName ,
        LastName
FROM    Sales.Customer AS c  
        INNER JOIN Person.Person AS p ON p.BusinessEntityID = c.PersonID
WHERE   PersonID IS NOT NULL  




-- QUERY 3

SELECT  bea.BusinessEntityID ,  
        bea.AddressID ,
        bea.AddressTypeID ,
        FirstName ,
        LastName ,
        a.AddressLine1 ,
        a.City ,
        at.Name AS AddressType
FROM    Person.Person AS p  
        INNER JOIN Person.BusinessEntityAddress AS bea ON bea.BusinessEntityID = p.BusinessEntityID
        INNER JOIN Person.Address AS a ON a.AddressID = bea.AddressID
        INNER JOIN Person.AddressType AS at ON at.AddressTypeID = bea.AddressTypeID
WHERE   p.BusinessEntityID = 2996 --Amanda Cook  


*/