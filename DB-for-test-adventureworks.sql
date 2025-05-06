USE AdventureWorks2019;
GO

--------------------------------------------------------------------------------
-- Step 0: Drop all existing tables
--------------------------------------------------------------------------------
EXEC sp_MSforeachtable 'DROP TABLE IF EXISTS ?';
GO

--------------------------------------------------------------------------------
-- Step 1: Create 15 AdventureWorks2022 tables in dbo schema
--------------------------------------------------------------------------------
CREATE TABLE dbo.EmployeeDepartmentHistory (
  EmployeeID     INT       NOT NULL,
  DepartmentID   SMALLINT  NOT NULL,
  ShiftID        TINYINT   NOT NULL,
  StartDate      DATE      NOT NULL,
  EndDate        DATE      NULL,
  ModifiedDate   DATETIME  NOT NULL DEFAULT GETDATE(),
  CONSTRAINT PK_EDH PRIMARY KEY CLUSTERED(EmployeeID, StartDate)
);
GO

CREATE TABLE dbo.EmployeePayHistory (
  EmployeeID     INT        NOT NULL,
  RateChangeDate DATETIME   NOT NULL,
  Rate           MONEY      NOT NULL,
  PayFrequency   TINYINT    NOT NULL,
  ModifiedDate   DATETIME   NOT NULL DEFAULT GETDATE(),
  CONSTRAINT PK_EPH PRIMARY KEY CLUSTERED(EmployeeID, RateChangeDate)
);
GO

CREATE TABLE dbo.JobCandidate (
  JobCandidateID INT           IDENTITY(1,1) NOT NULL PRIMARY KEY,
  EmployeeID     INT           NULL,
  Resume         XML           NULL,
  ModifiedDate   DATETIME      NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.BusinessEntityAddress (
  BusinessEntityID INT         NOT NULL,
  AddressID        INT         NOT NULL,
  AddressTypeID    INT         NOT NULL,
  ModifiedDate     DATETIME    NOT NULL DEFAULT GETDATE(),
  CONSTRAINT PK_BEA PRIMARY KEY CLUSTERED(BusinessEntityID, AddressID, AddressTypeID)
);
GO

CREATE TABLE dbo.BusinessEntityContact (
  BusinessEntityID INT         NOT NULL,
  PersonID         INT         NOT NULL,
  ContactTypeID    INT         NOT NULL,
  ModifiedDate     DATETIME    NOT NULL DEFAULT GETDATE(),
  CONSTRAINT PK_BEC PRIMARY KEY CLUSTERED(BusinessEntityID, PersonID, ContactTypeID)
);
GO

CREATE TABLE dbo.ContactType (
  ContactTypeID INT          NOT NULL PRIMARY KEY,
  Name          NVARCHAR(50) NOT NULL,
  ModifiedDate  DATETIME     NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.EmailAddress (
  BusinessEntityID INT        NOT NULL,
  EmailAddressID   INT        IDENTITY(1,1) NOT NULL PRIMARY KEY,
  EmailAddress     NVARCHAR(50) NOT NULL,
  ModifiedDate     DATETIME    NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.CountryRegion (
  CountryRegionCode NCHAR(3)   NOT NULL PRIMARY KEY,
  Name              NVARCHAR(50) NOT NULL,
  ModifiedDate      DATETIME    NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.PersonPhone (
  BusinessEntityID   INT         NOT NULL,
  PhoneNumber        NVARCHAR(25) NOT NULL,
  PhoneNumberTypeID  INT         NOT NULL,
  ModifiedDate       DATETIME    NOT NULL DEFAULT GETDATE(),
  CONSTRAINT PK_PP PRIMARY KEY CLUSTERED(BusinessEntityID, PhoneNumber, PhoneNumberTypeID)
);
GO

CREATE TABLE dbo.StateProvince (
  StateProvinceID   INT        NOT NULL PRIMARY KEY,
  StateProvinceCode NCHAR(3)   NOT NULL,
  CountryRegionCode NCHAR(3)   NOT NULL,
  Name              NVARCHAR(50) NOT NULL,
  ModifiedDate      DATETIME   NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.PurchaseOrderDetail (
  PurchaseOrderDetailID INT     IDENTITY(1,1) NOT NULL PRIMARY KEY,
  PurchaseOrderID       INT     NOT NULL,
  ProductID             INT     NOT NULL,
  OrderQty              SMALLINT NOT NULL,
  UnitPrice             MONEY   NOT NULL,
  LineTotal             MONEY   NOT NULL,
  ModifiedDate          DATETIME NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.ProductCategory (
  ProductCategoryID INT          IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Name              NVARCHAR(50) NOT NULL,
  ModifiedDate      DATETIME     NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.ProductSubcategory (
  ProductSubcategoryID INT       IDENTITY(1,1) NOT NULL PRIMARY KEY,
  ProductCategoryID    INT       NOT NULL,
  Name                 NVARCHAR(50) NOT NULL,
  ModifiedDate         DATETIME   NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.Vendor (
  VendorID      INT           IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Name          NVARCHAR(50)  NOT NULL,
  AccountNumber NVARCHAR(25)  NOT NULL,
  ModifiedDate  DATETIME      NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.Store (
  StoreID       INT           IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Name          NVARCHAR(50)  NOT NULL,
  SalesPersonID INT           NOT NULL,
  Demographics  XML           NULL,
  ModifiedDate  DATETIME      NOT NULL DEFAULT GETDATE()
);
GO

--------------------------------------------------------------------------------
-- Step 2: Insert sample data (4 rows per table)
--------------------------------------------------------------------------------
INSERT INTO dbo.EmployeeDepartmentHistory (EmployeeID,DepartmentID,ShiftID,StartDate,ModifiedDate) VALUES
 (1,1,1,'2015-06-01',GETDATE()),
 (2,2,2,'2016-01-10',GETDATE()),
 (3,1,1,'2017-03-15',GETDATE()),
 (4,2,2,'2018-07-20',GETDATE());
GO

INSERT INTO dbo.EmployeePayHistory (EmployeeID,RateChangeDate,Rate,PayFrequency,ModifiedDate) VALUES
 (1,'2015-06-01',45.00,1,GETDATE()),
 (2,'2016-01-10',50.00,1,GETDATE()),
 (3,'2017-03-15',55.00,1,GETDATE()),
 (4,'2018-07-20',60.00,1,GETDATE());
GO

INSERT INTO dbo.JobCandidate (EmployeeID,Resume,ModifiedDate) VALUES
 (1,'<resume>Dev</resume>',GETDATE()),
 (2,'<resume>Mgr</resume>',GETDATE()),
 (3,'<resume>Analyst</resume>',GETDATE()),
 (4,'<resume>Clerk</resume>',GETDATE());
GO

INSERT INTO dbo.BusinessEntityAddress (BusinessEntityID,AddressID,AddressTypeID,ModifiedDate) VALUES
 (1,1,1,GETDATE()),
 (2,2,2,GETDATE()),
 (3,3,3,GETDATE()),
 (4,4,1,GETDATE());
GO

INSERT INTO dbo.BusinessEntityContact (BusinessEntityID,PersonID,ContactTypeID,ModifiedDate) VALUES
 (1,1,1,GETDATE()),
 (2,2,2,GETDATE()),
 (3,3,3,GETDATE()),
 (4,4,1,GETDATE());
GO

INSERT INTO dbo.ContactType (ContactTypeID,Name,ModifiedDate) VALUES
 (1,'Primary',GETDATE()),
 (2,'Secondary',GETDATE()),
 (3,'Emergency',GETDATE()),
 (4,'Billing',GETDATE());
GO

INSERT INTO dbo.EmailAddress (BusinessEntityID,EmailAddress,ModifiedDate) VALUES
 (1,'john.doe@example.com',GETDATE()),
 (2,'alice.smith@example.com',GETDATE()),
 (3,'bob.brown@example.com',GETDATE()),
 (4,'carol.jones@example.com',GETDATE());
GO

INSERT INTO dbo.CountryRegion (CountryRegionCode,Name,ModifiedDate) VALUES
 ('USA','United States',GETDATE()),
 ('CAN','Canada',GETDATE()),
 ('MEX','Mexico',GETDATE()),
 ('GBR','United Kingdom',GETDATE());
GO

INSERT INTO dbo.PersonPhone (BusinessEntityID,PhoneNumber,PhoneNumberTypeID,ModifiedDate) VALUES
 (1,'206-555-0100',1,GETDATE()),
 (2,'617-555-0200',2,GETDATE()),
 (3,'303-555-0300',3,GETDATE()),
 (4,'512-555-0400',4,GETDATE());
GO

INSERT INTO dbo.StateProvince (StateProvinceID,StateProvinceCode,CountryRegionCode,Name,ModifiedDate) VALUES
 (1,'WA','USA','Washington',GETDATE()),
 (2,'VA','USA','Virginia',GETDATE()),
 (3,'ON','CAN','Ontario',GETDATE()),
 (4,'BC','CAN','British Columbia',GETDATE());
GO

INSERT INTO dbo.PurchaseOrderDetail (PurchaseOrderID,ProductID,OrderQty,UnitPrice,LineTotal,ModifiedDate) VALUES
 (1,100,10,1150.00,11500.00,GETDATE()),
 (1,102,5,75.00,375.00,GETDATE()),
 (2,101,2,1400.00,2800.00,GETDATE()),
 (3,103,8,18.00,144.00,GETDATE());
GO

INSERT INTO dbo.ProductCategory (Name,ModifiedDate) VALUES
 ('Bikes',GETDATE()),
 ('Components',GETDATE()),
 ('Clothing',GETDATE()),
 ('Accessories',GETDATE());
GO

INSERT INTO dbo.ProductSubcategory (ProductCategoryID,Name,ModifiedDate) VALUES
 (1,'Road Bikes',GETDATE()),
 (1,'Mountain Bikes',GETDATE()),
 (2,'Handlebars',GETDATE()),
 (3,'Jerseys',GETDATE());
GO

INSERT INTO dbo.Vendor (Name,AccountNumber,ModifiedDate) VALUES
 ('Contoso Ltd','VN-1001',GETDATE()),
 ('Fabrikam Inc','VN-1002',GETDATE()),
 ('Adventure Works','VN-1003',GETDATE()),
 ('Pro Bike Suppliers','VN-1004',GETDATE());
GO

INSERT INTO dbo.Store (Name,SalesPersonID,Demographics,ModifiedDate) VALUES
 ('Redmond Store',1,'<demo></demo>',GETDATE()),
 ('Tacoma Store',2,'<demo></demo>',GETDATE()),
 ('London Store',3,'<demo></demo>',GETDATE()),
 ('Toronto Store',4,'<demo></demo>',GETDATE());
GO
