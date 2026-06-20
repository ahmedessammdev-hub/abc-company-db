CREATE DATABASE ABC_ECommerce;
GO
USE ABC_ECommerce;
GO


CREATE TABLE Categories
(
    CategoryID INT IDENTITY(1,1),
    CategoryName VARCHAR(100) NOT NULL,
    ParentCategoryID INT NULL,
    
    CONSTRAINT PK_Categories PRIMARY KEY (CategoryID),
    CONSTRAINT FK_Categories_Parent FOREIGN KEY (ParentCategoryID) REFERENCES Categories(CategoryID)
);
GO

CREATE TABLE Customers
(
    CustomerID INT IDENTITY(1,1),
    CustomerName VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    RegistrationDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    
    CONSTRAINT PK_Customers PRIMARY KEY (CustomerID),
    CONSTRAINT UQ_Customers_Email UNIQUE (Email)
);
GO

CREATE TABLE Products
(
    ProductID INT IDENTITY(1,1),
    ProductName VARCHAR(150) NOT NULL,
    CategoryID INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    
    CONSTRAINT PK_Products PRIMARY KEY (ProductID),
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT CK_Products_Price CHECK (Price >= 0.00),
    CONSTRAINT CK_Products_Stock CHECK (StockQuantity >= 0)
);
GO

CREATE TABLE Orders
(
    OrderID INT IDENTITY(1,1),
    CustomerID INT NOT NULL,
    OrderDate DATETIME NOT NULL DEFAULT GETDATE(),
    OrderStatus VARCHAR(20) NOT NULL DEFAULT 'Pending',
    
    CONSTRAINT PK_Orders PRIMARY KEY (OrderID),
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT CK_Orders_Status CHECK (OrderStatus IN ('Pending', 'Completed', 'Cancelled'))
);
GO

CREATE TABLE OrderItems
(
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    
    CONSTRAINT PK_OrderItems PRIMARY KEY (OrderID, ProductID),
    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    CONSTRAINT FK_OrderItems_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CONSTRAINT CK_OrderItems_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_OrderItems_UnitPrice CHECK (UnitPrice >= 0.00)
);
GO

CREATE TABLE Payments
(
    PaymentID INT IDENTITY(1,1),
    OrderID INT NOT NULL,
    PaymentDate DATETIME NOT NULL DEFAULT GETDATE(),
    PaymentAmount DECIMAL(10,2) NOT NULL,
    PaymentStatus VARCHAR(20) NOT NULL DEFAULT 'Pending',
    
    CONSTRAINT PK_Payments PRIMARY KEY (PaymentID),
    CONSTRAINT FK_Payments_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT CK_Payments_Amount CHECK (PaymentAmount >= 0.00),
    CONSTRAINT CK_Payments_Status CHECK (PaymentStatus IN ('Pending', 'Paid', 'Failed'))
);
GO

CREATE TABLE RestockAlerts
(
    AlertID INT IDENTITY(1,1),
    ProductName VARCHAR(150) NOT NULL,
    CurrentStock INT NOT NULL,
    AlertTimestamp DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT PK_RestockAlerts PRIMARY KEY (AlertID)
);
GO

CREATE TABLE MonthlySalesAudit
(
    AuditID INT IDENTITY(1,1),
    AuditYear INT NOT NULL,
    AuditMonth INT NOT NULL,
    TotalOrders INT NOT NULL,
    TotalRevenue DECIMAL(18,2) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT PK_MonthlySalesAudit PRIMARY KEY (AuditID)
);
GO

-- Table type for sp_place_order input
CREATE TYPE dbo.OrderItemType AS TABLE
(
    ProductID INT NOT NULL,
    Quantity INT NOT NULL
);
GO