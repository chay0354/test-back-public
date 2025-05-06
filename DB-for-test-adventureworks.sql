USE AdventureWorks2019;
GO
DROP TABLE IF EXISTS [dbo].[SalesOrderHeader];
DROP TABLE IF EXISTS [dbo].[Customer];
DROP TABLE IF EXISTS [dbo].[Product];
DROP TABLE IF EXISTS [dbo].[ProductCategory];
DROP TABLE IF EXISTS [dbo].[Employee];
GO

CREATE TABLE [dbo].[Customer](
    [CustomerID] [int] NOT NULL PRIMARY KEY,
    [PersonID] [int] NULL,
    [StoreID] [int] NULL,
    [TerritoryID] [int] NULL
);

GO

CREATE TABLE [dbo].[SalesOrderHeader](
    [SalesOrderID] [int] NOT NULL PRIMARY KEY,
    [CustomerID] [int] NOT NULL,
    [OrderDate] [datetime] NOT NULL,
    [TotalDue] [decimal](10, 2) NOT NULL
);

GO

CREATE TABLE [dbo].[Product](
    [ProductID] [int] NOT NULL PRIMARY KEY,
    [Name] [nvarchar](100) NOT NULL,
    [ProductNumber] [nvarchar](25) NOT NULL,
    [ListPrice] [decimal](10, 2) NOT NULL
);

GO

CREATE TABLE [dbo].[ProductCategory](
    [ProductCategoryID] [int] NOT NULL PRIMARY KEY,
    [Name] [nvarchar](50) NOT NULL
);

GO

CREATE TABLE [dbo].[Employee](
    [EmployeeID] [int] NOT NULL PRIMARY KEY,
    [FirstName] [nvarchar](50) NOT NULL,
    [LastName] [nvarchar](50) NOT NULL,
    [HireDate] [datetime] NOT NULL,
    [Salary] [decimal](10,2) NOT NULL
);

GO