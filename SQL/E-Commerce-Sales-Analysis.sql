create database ecomerce_analytics;

use ecomerce_analytics;

CREATE TABLE customers(
	CustomerID VARCHAR(10) PRIMARY KEY,
	CustomerName VARCHAR(100),
	Age INT,
	City VARCHAR(50),
	Region VARCHAR(30),
	SignupDate DATE
);

-- product table--

CREATE TABLE Products
(
    ProductID VARCHAR(10) PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    CostPrice DECIMAL(12,2),
    SellingPrice DECIMAL(12,2)
   
);

-- Order Table --
CREATE TABLE Orders
(    
     OrderID VARCHAR(10) PRIMARY KEY,
     OrderDate DATE,
     CustomerID VARCHAR(10),
     PaymentMethod VARCHAR(30),
     OrderStatus VARCHAR(20),
     
     FOREIGN KEY (CustomerID)
     REFERENCES Customers(CustomerID)
);



-- Orrder Details --

CREATE TABLE OrderDetails
(
	 OrderDetailID VARCHAR(12) PRIMARY KEY,
     OrderID VARCHAR(10),
     ProductID VARCHAR(10),
     Quantity INT,
     UnitPrice DECIMAL(12,2),
     DiscountPct DECIMAL(5,2),
     SalesAmount DECIMAL(14,2),
     Profit DECIMAL(14,2),
     
     FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),
        
          
     FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)  
);


-- REturns --

CREATE TABLE Returns
(

    ReturnID VARCHAR(10) PRIMARY KEY,
    OrderID VARCHAR(10),
    ReturnDate DATE,
    ReturnReason VARCHAR(50),
    
	FOREIGN KEY (OrderID)
         REFERENCES Orders(OrderID)    
);
SHOW TABLES;

describe orders;
describe orderdetails;
describe returns;

ALTER TABLE Customers
ADD COLUMN Gender VARCHAR(10);

-- show data --
select * from customers limit 10;

-- row count -- 
select count(*) as TotalCustomers
from customers;


select count(*) as TotalProducts
from Products;

select * from Products limit 10;



select count(*) as TotalOrderDetails
from OrderDetails;
select count(*) as TotalReturns
from Returns;

-- single table validate--

SELECT 'Customers' AS TableName, COUNT(*) AS TotalRows
FROM Customers

UNION ALL

SELECT 'OrderDetails', COUNT(*)
FROM OrderDetails

UNION ALL

SELECT 'Orders', COUNT(*)
FROM Orders

UNION ALL

SELECT 'Products', COUNT(*)
FROM Products

UNION ALL

SELECT 'Returns', COUNT(*)
FROM Returns;


--- Duplicate Data --
select CustomerID,count(*) as DuplicateCount
from Customers
group by CustomerID
having count(*)>1;

-- NULL CHeck--
SELECT
    SUM(CustomerID IS NULL) AS CustomerID_Null,
    SUM(CustomerName IS NULL) AS CustomerName_Null,
    SUM(Gender IS NULL) AS Gender_Null,
    SUM(Age IS NULL) AS Age_Null,
    SUM(City IS NULL) AS City_Null,
    SUM(Region IS NULL) AS Region_Null,
    SUM(SignupDate IS NULL) AS SignupDate_Null
FROM Customers;

-- Foreign key Validdation --
SELECT
    'Orders → Customers' AS Relationship,
    COUNT(*) AS InvalidRows
FROM Orders o
LEFT JOIN Customers c
    ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL

UNION ALL

SELECT
    'OrderDetails → Orders',
    COUNT(*)
FROM OrderDetails od
LEFT JOIN Orders o
    ON od.OrderID = o.OrderID
WHERE o.OrderID IS NULL

UNION ALL

SELECT
    'OrderDetails → Products',
    COUNT(*)
FROM OrderDetails od
LEFT JOIN Products p
    ON od.ProductID = p.ProductID
WHERE p.ProductID IS NULL;

--  basic business data check  --

SELECT
      MIN(OrderDate) AS FirstOrderDate,
      MAX(OrderDate) AS LastOrderDate,
      COUNT(DISTINCT CustomerID) AS UniqueCustomers
FROM Orders;      


-- Database Select --

USE ecomerce_analytics;
-- Total Customer --
SELECT count(*) as TotalCustomer from Customers;


-- Total Order --

SELECT count(*) as TotalOrder from Orders;

-- Order Status Analysis --

select 
orderstatus, count(*) as TotalOrders
from Orders
group by orderstatus;

-- Deliver Order --
select count(*) as DeliverOrders
from Orders
where orderstatus = 'delivered';

-- Total Reveneu --
select 
sum(od.salesAmount) as TotalRevenue
from orders o
join orderdetails od
on o.orderid = od.orderid
where o.orderstatus = 'delivered';


-- Total Profit --
select 
sum(od.profit) as TotalProfit
from orders o
join orderdetails od
on o.orderid = od.orderid
where o.orderstatus = 'delivered';

-- Reveneue  + profit together --

-- Total Revenue + Total Profit --

SELECT 
    SUM(od.SalesAmount) AS TotalRevenue,
    SUM(od.Profit) AS TotalProfit
FROM
    Orders o
        JOIN
    OrderDetails od ON o.OrderID = od.OrderID
WHERE
    o.OrderStatus = 'delivered';

-- Average order Value --

-- Average Order Value (AOV) --

SELECT
    SUM(od.SalesAmount) / COUNT(DISTINCT o.OrderID) AS AverageOrderValue
FROM Orders o
JOIN OrderDetails od
    ON o.OrderID = od.OrderID
WHERE o.OrderStatus = 'delivered';

-- Category wise revenue --

SELECT
    p.Category,
    SUM(od.SalesAmount) AS TotalRevenue
FROM OrderDetails od
JOIN Products p
    ON od.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY TotalRevenue DESC;


-- Category Wise Profit --

SELECT
    p.Category,
    SUM(od.Profit) AS TotalProfit
FROM OrderDetails od
JOIN Products p
    ON od.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY TotalProfit DESC;


-- Category Wise Revenue & Profit --

SELECT
    p.Category,
    SUM(od.SalesAmount) AS TotalRevenue,
    SUM(od.Profit) AS TotalProfit
FROM Orders o
JOIN OrderDetails od
    ON o.OrderID = od.OrderID
JOIN Products p
    ON od.ProductID = p.ProductID
WHERE o.OrderStatus = 'delivered'
GROUP BY p.Category
ORDER BY TotalRevenue DESC;

-- Monthly Sales Trend --

SELECT
    DATE_FORMAT(o.OrderDate, '%Y-%m') AS SalesMonth,
    SUM(od.SalesAmount) AS TotalRevenue,
    SUM(od.Profit) AS TotalProfit
FROM Orders o
JOIN OrderDetails od
    ON o.OrderID = od.OrderID
WHERE o.OrderStatus = 'delivered'
GROUP BY DATE_FORMAT(o.OrderDate, '%Y-%m')
ORDER BY SalesMonth;

-- Region Wise Revenue --

SELECT
    c.Region,
    SUM(od.SalesAmount) AS TotalRevenue
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID
JOIN OrderDetails od
    ON o.OrderID = od.OrderID
WHERE o.OrderStatus = 'delivered'
GROUP BY c.Region
ORDER BY TotalRevenue DESC;

-- Top 10 Customers by Revenue --

SELECT
    c.CustomerID,
    c.CustomerName,
    SUM(od.SalesAmount) AS TotalRevenue
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID
JOIN OrderDetails od
    ON o.OrderID = od.OrderID
WHERE o.OrderStatus = 'delivered'
GROUP BY
    c.CustomerID,
    c.CustomerName
ORDER BY TotalRevenue DESC
LIMIT 10;

-- Top 10 Products by Revenue --

SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    SUM(od.Quantity) AS TotalQuantitySold,
    SUM(od.SalesAmount) AS TotalRevenue,
    SUM(od.Profit) AS TotalProfit
FROM Products p
JOIN OrderDetails od
    ON p.ProductID = od.ProductID
JOIN Orders o
    ON od.OrderID = o.OrderID
WHERE o.OrderStatus = 'delivered'
GROUP BY
    p.ProductID,
    p.ProductName,
    p.Category
ORDER BY TotalRevenue DESC
LIMIT 10;

-- Payment Method Analysis --

SELECT
    o.PaymentMethod,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    SUM(od.SalesAmount) AS TotalRevenue,
    SUM(od.Profit) AS TotalProfit
FROM Orders o
JOIN OrderDetails od
    ON o.OrderID = od.OrderID
WHERE o.OrderStatus = 'delivered'
GROUP BY o.PaymentMethod
ORDER BY TotalRevenue DESC;

DESCRIBE Returns;

-- Return Rate Analysis --

SELECT
    COUNT(DISTINCT r.OrderID) AS TotalReturnedOrders,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    ROUND(
        COUNT(DISTINCT r.OrderID) * 100.0 /
        COUNT(DISTINCT o.OrderID), 2
    ) AS ReturnRatePercentage
FROM Orders o
LEFT JOIN Returns r
    ON o.OrderID = r.OrderID;
    
    -- Return Reason Analysis --

SELECT
    ReturnReason,
    COUNT(*) AS TotalReturns
FROM Returns
GROUP BY ReturnReason
ORDER BY TotalReturns DESC;

-- Monthly Return Trend --

SELECT
    DATE_FORMAT(ReturnDate, '%Y-%m') AS ReturnMonth,
    COUNT(*) AS TotalReturns
FROM Returns
GROUP BY DATE_FORMAT(ReturnDate, '%Y-%m')
ORDER BY ReturnMonth;

-- Product Wise Returns --

SELECT
    p.ProductName,
    p.Category,
    SUM(od.Quantity) AS ReturnedQuantity,
    COUNT(DISTINCT r.OrderID) AS ReturnedOrders
FROM Returns r
JOIN OrderDetails od
    ON r.OrderID = od.OrderID
JOIN Products p
    ON od.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName, p.Category
ORDER BY ReturnedQuantity DESC;