;WITH CTE (CustomerID, StockItemID,BillToCustomerID,UnitPrice,Quantity,OrderID) AS 
(SELECT ord.CustomerID,
		det.StockItemID,
		inv.BillToCustomerID,
		det.UnitPrice,
		det.Quantity,
		ord.OrderID 
FROM Sales.Orders AS ord
	JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID
	JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID
	JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID
	 AND  inv.BillToCustomerID!= ord.CustomerId  AND 
	 (SELECT SUM(Total.UnitPrice*Total.Quantity)
		FROM Sales.OrderLines AS Total
			Join Sales.Orders AS ordTotal ON ordTotal.OrderID = Total.OrderID
		WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
)
SELECT  CTE.CustomerID, 
		CTE.StockItemID , 
		SUM(CTE.UnitPrice) as SumPrice, 
		SUM(CTE.Quantity) as SumQuantity, 
		COUNT(CTE.OrderID) as CountOrder
FROM CTE
	JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = CTE.StockItemID
	JOIN Warehouse.StockItems AS It ON It.StockItemID = CTE.StockItemID
WHERE it.SupplierID=12
GROUP BY CTE.CustomerID, CTE.StockItemID
ORDER BY CTE.CustomerID, CTE.StockItemID
