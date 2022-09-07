1) Product association:

SELECT distinct   Name, a.ProductID AS Item_1, b.ProductID AS Item_2,
        
COUNT(*) AS times_bought_together
FROM SalesLT.SalesOrderDetail a
JOIN SalesLT.SalesOrderDetail b
ON a.SalesOrderID = b.SalesOrderID
Join SalesLT.Product 
on SalesLT.Product.ProductID = b.ProductID
WHERE a.ProductID > b.ProductID 
GROUP BY Name, a.ProductID,  b.ProductID
ORDER BY times_bought_together DESC



2) Geography

SELECT*
FROM SalesLT.Address

SELECT CountryRegion, StateProvince, City, sum(OrderQty * UnitPrice - UnitPriceDiscount) as Revenue, SalesLT.SalesOrderDetail.SalesOrderID
FROM SalesLT.SalesOrderHeader 
INNER JOIN SalesLT.CustomerAddress on SalesLT.SalesOrderHeader.CustomerID = SalesLT.CustomerAddress.CustomerID
LEFT JOIN SalesLT.Address
ON SalesLT.CustomerAddress.AddressID = SalesLT.Address.AddressID
Join SalesLT.SalesOrderDetail
on SalesLT.SalesOrderDetail.SalesOrderID = SalesLT.SalesOrderHeader.SalesOrderID
WHERE SalesLT.SalesOrderDetail.SalesOrderID IS NOT NULL
GROUP BY CountryRegion, StateProvince, City, SalesLT.SalesOrderDetail.SalesOrderID
ORDER BY Revenue DESC

3) Dead products

SELECT Name
FROM SalesLT.Product
LEFT JOIN SalesLT.SalesOrderDetail
on SalesLT.SalesOrderDetail.ProductID = SalesLT.Product.ProductID
WHERE SalesOrderID IS NULL

4) Customers

SELECT FirstName, LastName, Title, SalesLT.SalesOrderHeader.CustomerID, SalesLT.SalesOrderDetail.SalesOrderID, sum(OrderQty * UnitPrice - UnitPriceDiscount) as purchase
FROM SalesLT.SalesOrderHeader
LEFT JOIN SalesLT.SalesOrderDetail
ON SalesLT.SalesOrderHeader.SalesOrderID = SalesLT.SalesOrderDetail.SalesOrderID
LEFT join SalesLT.Customer
ON SalesLT.SalesOrderHeader.CustomerID = SalesLT.Customer.CustomerID
WHERE SalesLT.SalesOrderDetail.SalesOrderID IS not NULL
GROUP BY  FirstName, LastName, SalesLT.SalesOrderDetail.SalesOrderID,Title, SalesLT.SalesOrderHeader.CustomerID
ORDER BY purchase DESC