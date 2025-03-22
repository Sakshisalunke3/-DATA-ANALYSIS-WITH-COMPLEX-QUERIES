CREATE DATABASE SalesDB;
USE SalesDB;
CREATE TABLE Staff(
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Department VARCHAR(50)
);

INSERT INTO Staff (EmployeeID, FirstName, LastName, Department)
VALUES
    (1, 'John', 'Doe', 'Sales'),
    (2, 'Jane', 'Smith', 'Sales'),
    (3, 'Alice', 'Johnson', 'HR'),
    (4, 'Bob', 'Brown', 'IT');

CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    EmployeeID INT,
    SaleAmount DECIMAL(18, 2),
    SaleDate DATE,
    FOREIGN KEY (EmployeeID) REFERENCES Staff(EmployeeID)
);
INSERT INTO Sales (SaleID, EmployeeID, SaleAmount, SaleDate)
VALUES
    (1, 1, 1000.00, '2023-01-01'),
    (2, 1, 1500.00, '2023-01-15'),
    (3, 2, 2000.00, '2023-01-10'),
    (4, 2, 2500.00, '2023-01-20'),
    (5, 1, 3000.00, '2023-02-01'),
    (6, 2, 3500.00, '2023-02-15'),
    (7, 3, 4000.00, '2023-02-20'),
    (8, 4, 4500.00, '2023-03-01');
    
SELECT * FROM Staff;
SELECT * FROM Sales;
 
 -- Running Total Of Sales by Employee
SELECT 
    EmployeeID,
    SaleDate,
    SaleAmount,
    SUM(SaleAmount) OVER (PARTITION BY EmployeeID ORDER BY SaleDate) AS RunningTotal
FROM 
    Sales;
   
-- Ranking employees by total sales
SELECT 
    EmployeeID,
    SUM(SaleAmount) AS TotalSales,
    RANK() OVER (ORDER BY SUM(SaleAmount) DESC) AS SalesRank
FROM 
    Sales
GROUP BY 
    EmployeeID;
 
 -- Moving Average of Sales
SELECT 
    EmployeeID,
    SaleDate,
    SaleAmount,
    AVG(SaleAmount) OVER (PARTITION BY EmployeeID ORDER BY SaleDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MovingAvg
FROM 
    Sales;
    
-- Cumulative Distribution Of sales
SELECT 
    EmployeeID,
    SaleAmount,
    CUME_DIST() OVER (ORDER BY SaleAmount) AS CumulativeDistribution
FROM 
    Sales;
    
--  some common subqueries
-- WHERE Clause
SELECT EmployeeID, FirstName, LastName
FROM Staff
WHERE EmployeeID IN (
	SELECT DISTINCT EmployeeID
	FROM Sales
	WHERE SaleAmount > (SELECT AVG(SaleAmount) FROM Sales)
    );
  
  -- SELECT Clause
SELECT EmployeeID, FirstName, LastName,
(SELECT SUM(SaleAmount) 
FROM Sales 
     WHERE Sales.EmployeeID = Staff.EmployeeID) AS TotalSales
FROM Staff;

-- FROM Clause
SELECT Department,
    SUM(TotalSales) AS DepartmentTotalSales
FROM (SELECT E.Department,
(SELECT SUM(SaleAmount) 
FROM Sales 
WHERE Sales.EmployeeID = E.EmployeeID) AS TotalSales
FROM 
	Staff E
) AS DeptSales
GROUP BY Department;

-- HAVING Clause
SELECT Department,
    SUM(SaleAmount) AS DepartmentTotalSales
FROM Staff E
JOIN 
    Sales S ON E.EmployeeID = S.EmployeeID
GROUP BY 
    Department
HAVING 
    SUM(SaleAmount) > (
        SELECT AVG(TotalSales)
        FROM (
            SELECT SUM(SaleAmount) AS TotalSales
            FROM Sales
            GROUP BY EmployeeID
        ) AS AvgSales
    );
    
    
