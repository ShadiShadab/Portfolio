
 --## potential useful tables/data ##--

 SELECT OrderID, CustomerID, OrderDate
FROM Sales.Orders

SELECT OrderLineID, OrderID, StockItemID, Quantity, UnitPrice
FROM Sales.OrderLines

SELECT InvoiceLineID, InvoiceID, StockItemID, Quantity, UnitPrice, LineProfit, TaxAmount 
FROM Sales.InvoiceLines

SELECT  StockItemID, SUM(LineProfit)
FROM Sales.InvoiceLines
GROUP BY StockItemID

SELECT InvoiceID, CustomerID, BillToCustomerID, OrderID, SalesPersonPersonID,  InvoiceDate, CustomerPurchaseOrderNumber, DeliveryInstructions
FROM Sales.Invoices

SELECT CustomerTransactionID, CustomerID, InvoiceID, TransactionDate, TransactionAmount, TaxAmount, AmountExcludingTax
FROM Sales.CustomerTransactions

SELECT CustomerID, BillToCustomerID, CustomerCategoryID, DeliveryCityID, PostalCityID, DeliveryPostalCode, PostalAddressLine2 as City
FROM Sales.Customers

SELECT CustomerCategoryID, CustomerCategoryName
FROM Sales.CustomerCategories


SELECT StateProvinceID, StateProvinceCode, StateProvinceName, CountryID, SalesTerritory
FROM Application.StateProvinces


SELECT CountryID, CountryName, Continent, Subregion
FROM Application.Countries

SELECT CityID, CityName, StateProvinceID 
FROM Application.Cities

  --##Sales Analysis##--

  --1) Sales per day

 SELECT Distinct OrderDate, SUM(Quantity*UnitPrice) as Sales
FROM Sales.Orders
left join Sales.OrderLines
on Sales.Orders.OrderID = Sales.OrderLines.OrderID
Group by  OrderDate
Order by OrderDate

--2) Sales per customer & date
 
 SELECT Distinct CustomerID, SUM(Quantity*UnitPrice) as Sales, MONTH(OrderDate) AS Month
FROM Sales.Orders
left join Sales.OrderLines
on Sales.Orders.OrderID = Sales.OrderLines.OrderID
Group by CustomerID,  MONTH(OrderDate)
Order by MONTH(OrderDate)

--3)Total Sales per month each year

SELECT YEAR(TransactionDate) AS Year, MONTH(TransactionDate) AS Month, SUM(AmountExcludingTax) as TotalSales
      FROM Sales.CustomerTransactions
      GROUP BY year(TransactionDate),month(TransactionDate)
      ORDER BY year(TransactionDate), month(TransactionDate) 

--4)Total Sales per year

SELECT YEAR(TransactionDate) AS Year,  SUM(AmountExcludingTax) as TotalSalesPerCity
      FROM Sales.CustomerTransactions
      GROUP BY year(TransactionDate)
      ORDER BY year(TransactionDate)

--5) Sales per stockItem 

 SELECT Distinct Sales.OrderLines.StockItemID, SUM(Quantity * Sales.OrderLines.UnitPrice) as Sales, YEAR(OrderDate) AS Year, Quantity, Sales.OrderLines.UnitPrice, TypicalWeightPerUnit
FROM Sales.Orders
left join Sales.OrderLines
on Sales.Orders.OrderID = Sales.OrderLines.OrderID
left join Warehouse.StockItems
on Warehouse.StockItems.StockItemID = Sales.OrderLines.StockItemID
WHERE Quantity > 10
Group by YEAR(OrderDate), Quantity, Sales.OrderLines.UnitPrice, TypicalWeightPerUnit, Sales.OrderLines.StockItemID
Order by YEAR(OrderDate)

--6) Sales per customer category and date

SELECT distinct CustomerCategoryName, SUM(AmountExcludingTax) as TotalSalesPerCategory, TransactionDate
FROM Sales.Customers AS SC
LEFT JOIN Sales.CustomerTransactions AS SCT
       ON SC.CustomerID = SCT.CustomerID
LEFT JOIN Sales.CustomerCategories AS CUCAT
       ON SC.CustomerCategoryID = CUCAT.CustomerCategoryID
WHERE AmountExcludingTax <> 0
GROUP BY CustomerCategoryName, TransactionDate
ORDER BY TransactionDate

--7) Total Sales per city AND ProvinceState

SELECT distinct StateProvinceName, CityName, YEAR(TransactionDate) AS Year, SUM(AmountExcludingTax) as TotalSalesPerCity
FROM Application.Cities AS AC
LEFT JOIN Sales.Customers AS SC
ON AC.CityID = SC.PostalCityID
LEFT JOIN Application.StateProvinces AS ASP
ON ASP.StateProvinceID = AC.StateProvinceID
LEFT JOIN Sales.CustomerTransactions AS SCT
       ON SC.CustomerID = SCT.CustomerID
WHERE PostalCityID IS NOT NULL and AmountExcludingTax <> 0
GROUP BY  StateProvinceName,  CityName, YEAR(TransactionDate)
ORDER BY YEAR(TransactionDate) , SUM(AmountExcludingTax) DESC


--8) Seing each Customer belongs to which categories and the total number of each Category

SELECT  CustomerID, CustomerCategoryName, 
count(CustomerCategoryName) OVER (PARTITION BY CustomerCategoryName) AS TotalNumberOfCategory
FROM Sales.CustomerCategories AS CUCAT
LEFT JOIN Sales.Customers CUST
          ON CUST.CustomerCategoryID = CUST.CustomerCategoryID



 --##Preparing Data for Visualization & forecasting the sales##--
 SELECT InvoiceLineID, InvoiceID, StockItemID, Quantity, UnitPrice, LineProfit, TaxAmount 
FROM Sales.InvoiceLines
 SELECT*
FROM Sales.CustomerTransactions AS SCT
LEFT JOIN Sales.InvoiceLines AS SIL
	   ON SIL.InvoiceID = SCT.InvoiceID
SELECT CustomerTransactionID, CustomerID, InvoiceID, TransactionDate, TransactionAmount, TaxAmount, AmountExcludingTax
FROM Sales.CustomerTransactions

 SELECT distinct SC.CustomerID,  CustomerCategoryName, StockItemID, StateProvinceName, CityName, ASP.LatestRecordedPopulation AS Population, SUM(AmountExcludingTax) as TotalSales, LineProfit,
 YEAR(TransactionDate) AS Year, MONTH(TransactionDate) AS Month, TransactionDate
 FROM Application.Cities AS AC
LEFT JOIN Sales.Customers AS SC
       ON AC.CityID = SC.PostalCityID
LEFT JOIN Application.StateProvinces AS ASP
       ON ASP.StateProvinceID = AC.StateProvinceID
LEFT JOIN Sales.CustomerTransactions AS SCT
       ON SC.CustomerID = SCT.CustomerID
LEFT JOIN Sales.InvoiceLines AS SIL
	   ON SIL.InvoiceID = SCT.InvoiceID
LEFT JOIN Sales.CustomerCategories AS CUCAT
       ON SC.CustomerCategoryID = CUCAT.CustomerCategoryID
WHERE PostalCityID IS NOT NULL and AmountExcludingTax <> 0
GROUP BY  StateProvinceName, StateProvinceName, CityName, SC.CustomerID, CustomerCategoryName,LineProfit,StockItemID,
YEAR(TransactionDate), MONTH(TransactionDate), ASP.LatestRecordedPopulation, TransactionDate
ORDER BY YEAR(TransactionDate), MONTH(TransactionDate), TransactionDate


SELECT distinct CustomerCategoryName, SUM(AmountExcludingTax) as TotalSalesPerCategory,  YEAR(TransactionDate) AS Year
FROM Sales.Customers AS SC
LEFT JOIN Sales.CustomerTransactions AS SCT
       ON SC.CustomerID = SCT.CustomerID
LEFT JOIN Sales.CustomerCategories AS CUCAT
       ON SC.CustomerCategoryID = CUCAT.CustomerCategoryID
WHERE AmountExcludingTax <> 0
GROUP BY  YEAR(TransactionDate), CustomerCategoryName
ORDER BY  YEAR(TransactionDate)


 SELECT Distinct Sales.OrderLines.StockItemID,(Quantity * Sales.OrderLines.UnitPrice) as Sales, Quantity, Sales.OrderLines.UnitPrice, TypicalWeightPerUnit AS Weight,
 YEAR(OrderDate) AS Year,  MONTH(OrderDate) AS Month
FROM Sales.Orders
left join Sales.OrderLines
on Sales.Orders.OrderID = Sales.OrderLines.OrderID
left join Warehouse.StockItems
on Warehouse.StockItems.StockItemID = Sales.OrderLines.StockItemID
Group by YEAR(OrderDate), MONTH(OrderDate), Sales.OrderLines.StockItemID, Quantity, Sales.OrderLines.UnitPrice, TypicalWeightPerUnit
Order by YEAR(OrderDate)



SELECT Distinct Warehouse.StockItems.StockItemID, (Quantity * Sales.OrderLines.UnitPrice) as Sales,
  Quantity, Sales.OrderLines.UnitPrice, TypicalWeightPerUnit AS Weight
FROM Sales.Orders
left join Sales.OrderLines
on Sales.Orders.OrderID = Sales.OrderLines.OrderID
left join Warehouse.StockItems
on Warehouse.StockItems.StockItemID = Sales.OrderLines.StockItemID
Group by  Warehouse.StockItems.StockItemID, Quantity, Sales.OrderLines.UnitPrice, TypicalWeightPerUnit
