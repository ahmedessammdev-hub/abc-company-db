USE ABC_ECommerce;
GO

-- Categories
SET IDENTITY_INSERT Categories ON;
INSERT INTO Categories (CategoryID, CategoryName, ParentCategoryID) VALUES
(1, 'Electronics', NULL),
(2, 'Mobiles', 1),
(3, 'Smartphones', 2),
(4, 'Tablets', 2),
(5, 'Computers', 1),
(6, 'Laptops', 5),
(7, 'Fashion', NULL),
(8, 'Men''s Wear', 7),
(9, 'Women''s Wear', 7),
(10, 'Home & Living', NULL),
(11, 'Kitchen', 10),
(12, 'Coffee Makers', 11),
(13, 'Microwaves', 11);
SET IDENTITY_INSERT Categories OFF;
GO

-- Customers
SET IDENTITY_INSERT Customers ON;
INSERT INTO Customers (CustomerID, CustomerName, Email, RegistrationDate) VALUES
(1, 'Ahmed Ali', 'ahmed.ali@example.com', DATEADD(day, -400, GETDATE())),
(2, 'John Smith', 'john.smith@example.com', DATEADD(day, -30, GETDATE())),
(3, 'Sarah Connor', 'sarah.connor@example.com', DATEADD(day, -40, GETDATE())),
(4, 'David Miller', 'david.miller@example.com', DATEADD(day, -60, GETDATE())),
(5, 'Alice Cooper', 'alice.cooper@example.com', DATEADD(day, -300, GETDATE())),
(6, 'Bob Jones', 'bob.jones@example.com', DATEADD(day, -400, GETDATE()));
SET IDENTITY_INSERT Customers OFF;
GO

-- Products
SET IDENTITY_INSERT Products ON;
INSERT INTO Products (ProductID, ProductName, CategoryID, Price, StockQuantity) VALUES
(1, 'iPhone 15 Pro', 3, 1200.00, 15),
(2, 'Samsung Galaxy S24', 3, 1100.00, 5),   
(3, 'MacBook Air M3', 6, 1500.00, 20),
(4, 'Dell XPS 13', 6, 1300.00, 8),          
(5, 'Espresso Barista Pro', 12, 600.00, 3),  
(6, 'Samsung Smart Oven', 13, 300.00, 12),
(7, 'Ergonomic Desk Chair', 10, 250.00, 30);
SET IDENTITY_INSERT Products OFF;
GO

-- Orders
SET IDENTITY_INSERT Orders ON;
INSERT INTO Orders (OrderID, CustomerID, OrderDate, OrderStatus) VALUES
(1, 1, DATEADD(month, -11, GETDATE()), 'Completed'),
(2, 1, DATEADD(month, -10, GETDATE()), 'Completed'),
(3, 1, DATEADD(month, -8, GETDATE()), 'Completed'),
(4, 1, DATEADD(month, -5, GETDATE()), 'Pending'),
(5, 2, DATEADD(day, -28, GETDATE()), 'Completed'),
(6, 3, DATEADD(day, -25, GETDATE()), 'Completed'),
(7, 5, DATEADD(month, -9, GETDATE()), 'Completed'),
(8, 5, DATEADD(month, -6, GETDATE()), 'Completed'),
(9, 5, DATEADD(month, -4, GETDATE()), 'Completed'),
(10, 5, DATEADD(month, -3, GETDATE()), 'Completed'),
(11, 6, DATEADD(month, -12, GETDATE()), 'Completed'),
(12, 6, DATEADD(month, -7, GETDATE()), 'Completed'),
(13, 6, DATEADD(month, -2, GETDATE()), 'Completed'),
(14, 6, DATEADD(month, -1, GETDATE()), 'Completed');
SET IDENTITY_INSERT Orders OFF;
GO

-- OrderItems
INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice) VALUES
(1, 1, 1, 1200.00),
(2, 6, 2, 300.00),
(3, 2, 1, 1100.00),
(4, 7, 1, 250.00),
(5, 3, 1, 1500.00),
(6, 7, 1, 250.00),
(7, 1, 5, 1200.00), 
(8, 3, 8, 1500.00), 
(9, 4, 3, 1300.00), 
(10, 5, 2, 600.00), 
(10, 7, 4, 250.00), 
(11, 6, 1, 300.00),
(12, 2, 1, 1100.00),
(13, 7, 2, 250.00),
(14, 6, 1, 300.00);
GO

-- Payments
SET IDENTITY_INSERT Payments ON;
INSERT INTO Payments (PaymentID, OrderID, PaymentDate, PaymentAmount, PaymentStatus) VALUES
(1, 1, DATEADD(day, 2, DATEADD(month, -11, GETDATE())), 1200.00, 'Paid'),
(2, 2, DATEADD(day, 1, DATEADD(month, -10, GETDATE())), 600.00, 'Paid'),
(3, 3, DATEADD(day, 4, DATEADD(month, -8, GETDATE())), 1100.00, 'Paid'),
(4, 4, DATEADD(month, -5, GETDATE()), 250.00, 'Pending'), 
(5, 5, DATEADD(day, 2, DATEADD(day, -28, GETDATE())), 1500.00, 'Paid'),
(6, 6, DATEADD(day, 1, DATEADD(day, -25, GETDATE())), 250.00, 'Paid'),
(7, 7, DATEADD(day, 1, DATEADD(month, -9, GETDATE())), 6000.00, 'Paid'),
(8, 8, DATEADD(day, 3, DATEADD(month, -6, GETDATE())), 12000.00, 'Paid'),
(9, 9, DATEADD(day, 1, DATEADD(month, -4, GETDATE())), 3900.00, 'Paid'),
(10, 10, DATEADD(day, 2, DATEADD(month, -3, GETDATE())), 2200.00, 'Paid'),
(11, 11, DATEADD(day, 1, DATEADD(month, -12, GETDATE())), 300.00, 'Paid'),
(12, 12, DATEADD(day, 5, DATEADD(month, -7, GETDATE())), 1100.00, 'Paid'),
(13, 13, DATEADD(day, 1, DATEADD(month, -2, GETDATE())), 500.00, 'Paid'),
(14, 14, DATEADD(day, 2, DATEADD(month, -1, GETDATE())), 300.00, 'Paid');
SET IDENTITY_INSERT Payments OFF;
GO
