USE ABC_ECommerce;
GO

-- Task 1
SELECT 
    c.CustomerID,
    c.CustomerName,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0) AS TotalAmountSpent
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
LEFT JOIN OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY c.CustomerID, c.CustomerName
ORDER BY TotalAmountSpent DESC;
GO

-- Task 2
WITH CustomerOrders AS
(
    SELECT 
        o.CustomerID,
        COUNT(o.OrderID) AS TotalOrders,
        SUM(
            CASE
                WHEN p.PaymentStatus <> 'Paid'
                     OR p.PaymentStatus IS NULL
                THEN 1
                ELSE 0
            END
        ) AS UnpaidOrderCount
    FROM Orders o
    LEFT JOIN Payments p
        ON o.OrderID = p.OrderID
    GROUP BY o.CustomerID
    HAVING COUNT(o.OrderID) > 3
)

SELECT
    c.CustomerName,
    co.TotalOrders,
    co.UnpaidOrderCount
FROM Customers c
INNER JOIN CustomerOrders co
    ON c.CustomerID = co.CustomerID
WHERE co.UnpaidOrderCount >= 1;

-- Task 3
SELECT 
    p.ProductID,
    p.ProductName,
    COUNT(DISTINCT o.CustomerID) AS DistinctCustomersCount,
    ISNULL(SUM(oi.Quantity), 0) AS TotalUnitsSold,
    ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0) AS TotalRevenue
FROM Products p
INNER JOIN OrderItems oi ON p.ProductID = oi.ProductID
INNER JOIN Orders o ON oi.OrderID = o.OrderID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalRevenue DESC;
GO

-- Task 4
SELECT 
    o.OrderID,
    o.OrderDate,
    ISNULL(p.PaymentStatus, 'Unpaid') AS PaymentStatus,
    p.PaymentDate,
    CASE 
        WHEN p.PaymentStatus = 'Paid' THEN DATEDIFF(DAY, o.OrderDate, p.PaymentDate)
        ELSE NULL 
    END AS DaysBetweenOrderAndPayment
FROM Orders o
LEFT JOIN Payments p ON o.OrderID = p.OrderID;
GO

-- Task 5
WITH RankedCategoryProducts AS (
    SELECT 
        p.CategoryID,
        p.ProductID,
        p.ProductName,
        ISNULL(SUM(oi.Quantity), 0) AS TotalUnitsSold,
        ROW_NUMBER() OVER (
            PARTITION BY p.CategoryID 
            ORDER BY ISNULL(SUM(oi.Quantity), 0) DESC, p.ProductID ASC
        ) AS SalesRank
    FROM Products p
    INNER JOIN OrderItems oi ON p.ProductID = oi.ProductID
    GROUP BY p.CategoryID, p.ProductID, p.ProductName
)
SELECT 
    c.CategoryName,
    rcp.ProductName,
    rcp.TotalUnitsSold,
    rcp.SalesRank
FROM RankedCategoryProducts rcp
INNER JOIN Categories c ON rcp.CategoryID = c.CategoryID
WHERE rcp.SalesRank <= 3
ORDER BY c.CategoryName ASC, rcp.SalesRank ASC;
GO

-- Task 6
WITH CustomerSpending AS (
    SELECT 
        c.CustomerName,
        ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0) AS TotalSpent
    FROM Customers c
    LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
    LEFT JOIN OrderItems oi ON o.OrderID = oi.OrderID
    GROUP BY c.CustomerID, c.CustomerName
)
SELECT 
    CustomerName,
    TotalSpent,
    (SELECT AVG(TotalSpent) FROM CustomerSpending) AS AverageSpendingOfAll,
    CASE 
        WHEN TotalSpent > (SELECT AVG(TotalSpent) FROM CustomerSpending) THEN 'Above Average'
        WHEN TotalSpent < (SELECT AVG(TotalSpent) FROM CustomerSpending) THEN 'Below Average'
        ELSE 'Average'
    END AS SpendingTier
FROM CustomerSpending
ORDER BY TotalSpent DESC;
GO

-- Task 7
WITH MonthlyRevenue AS (
    SELECT 
        CAST(FORMAT(o.OrderDate, 'yyyy-MM') AS VARCHAR(7)) AS SalesMonth,
        SUM(oi.Quantity * oi.UnitPrice) AS Revenue
    FROM Orders o
    INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID
    WHERE o.OrderDate >= DATEADD(MONTH, -12, GETDATE())
    GROUP BY CAST(FORMAT(o.OrderDate, 'yyyy-MM') AS VARCHAR(7))
)
SELECT 
    SalesMonth,
    Revenue AS MonthlyRevenue,
    SUM(Revenue) OVER (ORDER BY SalesMonth ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumulativeRevenue
FROM MonthlyRevenue
ORDER BY SalesMonth ASC;
GO

-- Task 8
WITH FirstOrderDetails AS (
    SELECT 
        c.CustomerID,
        c.CustomerName,
        c.RegistrationDate,
        MIN(o.OrderDate) AS FirstOrderDate
    FROM Customers c
    INNER JOIN Orders o ON c.CustomerID = o.CustomerID
    GROUP BY c.CustomerID, c.CustomerName, c.RegistrationDate
)
SELECT 
    CustomerName,
    RegistrationDate,
    FirstOrderDate,
    DATEDIFF(DAY, RegistrationDate, FirstOrderDate) AS DaysToFirstOrder
FROM FirstOrderDetails
WHERE DATEDIFF(DAY, RegistrationDate, FirstOrderDate) <= 7;
GO+

-- Task 9
WITH CategoryHierarchy AS (
    SELECT 
        CategoryID,
        CategoryName,
        ParentCategoryID,
        CAST(CategoryName AS VARCHAR(MAX)) AS CategoryPath,
        1 AS HierarchyLevel
    FROM Categories
    WHERE ParentCategoryID IS NULL

    UNION ALL

    SELECT 
        c.CategoryID,
        c.CategoryName,
        c.ParentCategoryID,
        CAST(ch.CategoryPath + ' > ' + c.CategoryName AS VARCHAR(MAX)) AS CategoryPath,
        ch.HierarchyLevel + 1 AS HierarchyLevel
    FROM Categories c
    INNER JOIN CategoryHierarchy ch ON c.ParentCategoryID = ch.CategoryID
)
SELECT 
    CategoryID,
    CategoryName,
    CategoryPath,
    HierarchyLevel
FROM CategoryHierarchy
ORDER BY HierarchyLevel ASC;
GO





-- Task 10
IF OBJECT_ID('dbo.vw_customer_order_summary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_customer_order_summary;
GO

CREATE VIEW vw_customer_order_summary AS
SELECT 
    c.CustomerName,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0) AS TotalAmountSpent,
    MAX(o.OrderDate) AS MostRecentOrderDate
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
LEFT JOIN OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY c.CustomerID, c.CustomerName;
GO

-- View test
SELECT TOP 10 
    CustomerName,
    TotalOrders,
    TotalAmountSpent,
    MostRecentOrderDate
FROM vw_customer_order_summary
ORDER BY TotalAmountSpent DESC;
GO

-- Task 11
IF EXISTS (SELECT name FROM sys.indexes WHERE name = N'IX_OrderItems_ProductID_Covering')
    DROP INDEX IX_OrderItems_ProductID_Covering ON OrderItems;
GO

CREATE NONCLUSTERED INDEX IX_OrderItems_ProductID_Covering
ON OrderItems (ProductID)
INCLUDE (OrderID, Quantity, UnitPrice);
GO

-- Task 12
IF OBJECT_ID('dbo.fn_customer_lifetime_value', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_customer_lifetime_value;
GO

CREATE FUNCTION fn_customer_lifetime_value
(
    @CustomerID INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @LTV DECIMAL(18,2);

    SELECT @LTV = ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0)
    FROM Orders o
    INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID
    INNER JOIN Payments p ON o.OrderID = p.OrderID
    WHERE o.CustomerID = @CustomerID
      AND p.PaymentStatus = 'Paid';

    RETURN @LTV;
END;
GO

-- Test function
SELECT 
    CustomerName,
    dbo.fn_customer_lifetime_value(CustomerID) AS ComputedLTV
FROM Customers
WHERE CustomerID IN (5, 4);
GO

-- Task 13
IF OBJECT_ID('dbo.fn_order_discount', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_order_discount;
GO

CREATE FUNCTION fn_order_discount
(
    @OrderID INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @OriginalTotal DECIMAL(18,2);
    DECLARE @DiscountedTotal DECIMAL(18,2);

    SELECT @OriginalTotal = ISNULL(SUM(Quantity * UnitPrice), 0)
    FROM OrderItems
    WHERE OrderID = @OrderID;

    IF @OriginalTotal > 10000.00
        SET @DiscountedTotal = @OriginalTotal * 0.90;
    ELSE IF @OriginalTotal > 5000.00
        SET @DiscountedTotal = @OriginalTotal * 0.95;
    ELSE
        SET @DiscountedTotal = @OriginalTotal;

    RETURN @DiscountedTotal;
END;
GO

-- Test function
SELECT 
    OrderID,
    SUM(Quantity * UnitPrice) AS OriginalTotal,
    dbo.fn_order_discount(OrderID) AS DiscountedTotal
FROM OrderItems
WHERE OrderID IN (7, 8, 1)
GROUP BY OrderID;
GO

-- Task 14
IF OBJECT_ID('dbo.fn_orders_by_date_range', 'IF') IS NOT NULL OR OBJECT_ID('dbo.fn_orders_by_date_range', 'TF') IS NOT NULL
    DROP FUNCTION dbo.fn_orders_by_date_range;
GO

CREATE FUNCTION fn_orders_by_date_range
(
    @StartDate DATE,
    @EndDate DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        o.OrderID,
        o.OrderDate,
        c.CustomerName,
        ISNULL(SUM(oi.Quantity), 0) AS TotalItems,
        ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0) AS OrderTotal
    FROM Orders o
    INNER JOIN Customers c ON o.CustomerID = c.CustomerID
    LEFT JOIN OrderItems oi ON o.OrderID = oi.OrderID
    WHERE o.OrderDate >= @StartDate AND o.OrderDate <= @EndDate
    GROUP BY o.OrderID, o.OrderDate, c.CustomerName
);
GO

-- Test with CROSS APPLY
WITH PastThreeCalendarMonths AS (
    SELECT 
        DATEADD(MONTH, -n, DATEADD(DAY, 1 - DATEPART(DAY, GETDATE()), CAST(GETDATE() AS DATE))) AS StartDate,
        EOMONTH(DATEADD(MONTH, -n, GETDATE())) AS EndDate
    FROM (VALUES (0), (1), (2)) AS M(n)
)
SELECT 
    FORMAT(pcm.StartDate, 'MMMM yyyy') AS SnapshotMonth,
    f.OrderID,
    f.CustomerName,
    f.TotalItems,
    f.OrderTotal
FROM PastThreeCalendarMonths pcm
CROSS APPLY dbo.fn_orders_by_date_range(pcm.StartDate, pcm.EndDate) f
ORDER BY pcm.StartDate DESC;
GO

-- Task 15
IF OBJECT_ID('dbo.sp_place_order', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_place_order;
GO

CREATE PROCEDURE sp_place_order
(
    @CustomerID INT,
    @Items dbo.OrderItemType READONLY
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Customers WHERE CustomerID = @CustomerID)
        BEGIN
            THROW 50001, 'Customer does not exist.', 16;
        END

        IF NOT EXISTS (SELECT 1 FROM @Items)
        BEGIN
            THROW 50002, 'The order must contain at least one item.', 16;
        END

        IF EXISTS (
            SELECT 1 
            FROM @Items i
            LEFT JOIN Products p ON i.ProductID = p.ProductID
            WHERE p.ProductID IS NULL
        )
        BEGIN
            THROW 50003, 'One or more Product IDs are invalid.', 16;
        END

        IF EXISTS (SELECT 1 FROM @Items WHERE Quantity <= 0)
        BEGIN
            THROW 50004, 'Quantity must be greater than zero.', 16;
        END

        DECLARE @InsufficientProduct VARCHAR(150);
        SELECT TOP 1 @InsufficientProduct = p.ProductName
        FROM @Items i
        INNER JOIN Products p ON i.ProductID = p.ProductID
        WHERE p.StockQuantity < i.Quantity;

        IF @InsufficientProduct IS NOT NULL
        BEGIN
            DECLARE @ErrorMsg NVARCHAR(250) = 'Insufficient stock for product: ' + @InsufficientProduct;
            THROW 50005, @ErrorMsg, 16;
        END

        DECLARE @NewOrderID INT;
        INSERT INTO Orders (CustomerID, OrderDate, OrderStatus)
        VALUES (@CustomerID, GETDATE(), 'Pending');
        
        SET @NewOrderID = SCOPE_IDENTITY();

        INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
        SELECT @NewOrderID, i.ProductID, i.Quantity, p.Price
        FROM @Items i
        INNER JOIN Products p ON i.ProductID = p.ProductID;

        UPDATE p
        SET p.StockQuantity = p.StockQuantity - i.Quantity
        FROM Products p
        INNER JOIN @Items i ON p.ProductID = i.ProductID;

        DECLARE @TotalAmount DECIMAL(10,2);
        SELECT @TotalAmount = SUM(i.Quantity * p.Price)
        FROM @Items i
        INNER JOIN Products p ON i.ProductID = p.ProductID;

        INSERT INTO Payments (OrderID, PaymentAmount, PaymentStatus, PaymentDate)
        VALUES (@NewOrderID, @TotalAmount, 'Pending', GETDATE());

        COMMIT TRANSACTION;
        
        SELECT @NewOrderID AS CreatedOrderID, 'Success' AS StatusMessage;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- Test Success Case
DECLARE @NewOrderItems dbo.OrderItemType;
INSERT INTO @NewOrderItems (ProductID, Quantity) VALUES (1, 1), (3, 2);
EXEC sp_place_order @CustomerID = 2, @Items = @NewOrderItems;
GO

-- Test Failure Case
BEGIN TRY
    DECLARE @InvalidItems dbo.OrderItemType;
    INSERT INTO @InvalidItems (ProductID, Quantity) VALUES (999, 1);
    EXEC sp_place_order @CustomerID = 2, @Items = @InvalidItems;
END TRY
BEGIN CATCH
    PRINT 'Expected error caught: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Task 16
IF OBJECT_ID('dbo.sp_monthly_sales_report', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_monthly_sales_report;
GO

CREATE PROCEDURE sp_monthly_sales_report
(
    @Year INT,
    @Month INT,
    @TotalOrders INT OUTPUT,
    @TotalRevenue DECIMAL(18,2) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        @TotalOrders = COUNT(DISTINCT o.OrderID),
        @TotalRevenue = ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0)
    FROM Orders o
    LEFT JOIN OrderItems oi ON o.OrderID = oi.OrderID
    WHERE DATEPART(YEAR, o.OrderDate) = @Year
      AND DATEPART(MONTH, o.OrderDate) = @Month;

    -- Top 5 products
    SELECT TOP 5
        p.ProductID,
        p.ProductName,
        SUM(oi.Quantity) AS TotalUnitsSold,
        SUM(oi.Quantity * oi.UnitPrice) AS ProductRevenue
    FROM Products p
    INNER JOIN OrderItems oi ON p.ProductID = oi.ProductID
    INNER JOIN Orders o ON oi.OrderID = o.OrderID
    WHERE DATEPART(YEAR, o.OrderDate) = @Year
      AND DATEPART(MONTH, o.OrderDate) = @Month
    GROUP BY p.ProductID, p.ProductName
    ORDER BY TotalUnitsSold DESC;

    -- Top 3 customers
    SELECT TOP 3
        c.CustomerID,
        c.CustomerName,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSpent
    FROM Customers c
    INNER JOIN Orders o ON c.CustomerID = o.CustomerID
    INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID
    WHERE DATEPART(YEAR, o.OrderDate) = @Year
      AND DATEPART(MONTH, o.OrderDate) = @Month
    GROUP BY c.CustomerID, c.CustomerName
    ORDER BY TotalSpent DESC;
END;
GO

-- Test report
DECLARE @OrdersOut INT;
DECLARE @RevOut DECIMAL(18,2);
DECLARE @TargetYear INT = DATEPART(YEAR, DATEADD(MONTH, -6, GETDATE()));
DECLARE @TargetMonth INT = DATEPART(MONTH, DATEADD(MONTH, -6, GETDATE()));

EXEC sp_monthly_sales_report 
    @Year = @TargetYear, 
    @Month = @TargetMonth, 
    @TotalOrders = @OrdersOut OUTPUT, 
    @TotalRevenue = @RevOut OUTPUT;

SELECT 
    @TargetYear AS ReportYear,
    @TargetMonth AS ReportMonth,
    @OrdersOut AS TotalOrders, 
    @RevOut AS TotalRevenue;
GO

-- Task 17
TRUNCATE TABLE RestockAlerts;
GO

DECLARE @ProdName VARCHAR(150);
DECLARE @StockQty INT;

DECLARE restock_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT ProductName, StockQuantity
FROM Products
WHERE StockQuantity < 10;

OPEN restock_cursor;
FETCH NEXT FROM restock_cursor INTO @ProdName, @StockQty;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO RestockAlerts (ProductName, CurrentStock, AlertTimestamp)
    VALUES (@ProdName, @StockQty, GETDATE());

    FETCH NEXT FROM restock_cursor INTO @ProdName, @StockQty;
END;

CLOSE restock_cursor;
DEALLOCATE restock_cursor;
GO

-- Verify restock alerts table
SELECT * FROM RestockAlerts;
GO

-- Task 18
IF OBJECT_ID('dbo.sp_run_monthly_sales_audit', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_run_monthly_sales_audit;
GO

CREATE PROCEDURE sp_run_monthly_sales_audit
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE MonthlySalesAudit;

    DECLARE @AuditYear INT;
    DECLARE @AuditMonth INT;
    DECLARE @OrdersTotal INT;
    DECLARE @RevenueTotal DECIMAL(18,2);

    -- Populate a temp table with the past 12 months using a simple loop
    DECLARE @PastMonths TABLE (Yr INT, Mn INT);
    DECLARE @i INT = 0;
    WHILE @i < 12
    BEGIN
        INSERT INTO @PastMonths (Yr, Mn)
        VALUES (
            DATEPART(YEAR, DATEADD(MONTH, -@i, GETDATE())), 
            DATEPART(MONTH, DATEADD(MONTH, -@i, GETDATE()))
        );
        SET @i = @i + 1;
    END;

    DECLARE audit_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT Yr, Mn FROM @PastMonths;

    OPEN audit_cursor;
    FETCH NEXT FROM audit_cursor INTO @AuditYear, @AuditMonth;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC sp_monthly_sales_report
            @Year = @AuditYear,
            @Month = @AuditMonth,
            @TotalOrders = @OrdersTotal OUTPUT,
            @TotalRevenue = @RevenueTotal OUTPUT;

        INSERT INTO MonthlySalesAudit (AuditYear, AuditMonth, TotalOrders, TotalRevenue)
        VALUES (@AuditYear, @AuditMonth, @OrdersTotal, @RevenueTotal);

        FETCH NEXT FROM audit_cursor INTO @AuditYear, @AuditMonth;
    END;

    CLOSE audit_cursor;
    DEALLOCATE audit_cursor;
END;
GO

-- Run audit and check highest revenue month
EXEC sp_run_monthly_sales_audit;
GO

SELECT TOP 1
    AuditYear,
    AuditMonth,
    TotalOrders,
    TotalRevenue AS PeakRevenue
FROM MonthlySalesAudit
ORDER BY TotalRevenue DESC;
GO
