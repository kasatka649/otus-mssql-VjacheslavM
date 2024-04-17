/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

TODO: 
SELECT 
	ap.FullName 
FROM Application.People AP
LEFT JOIN 
(SELECT SalespersonPersonID
FROM   Sales.Invoices  
WHERE Sales.Invoices.InvoiceDate = CONVERT(DATETIME, '2015-07-04', 102) 
GROUP BY SalespersonPersonID) SI
ON ap.PersonID=si.SalespersonPersonID
WHERE ap.IsSalesperson=1 and SalespersonPersonID is  NULL
ORDER BY PersonID


;WITH SI AS
(SELECT SalespersonPersonID
FROM   Sales.Invoices  
WHERE Sales.Invoices.InvoiceDate = CONVERT(DATETIME, '2015-07-04', 102) 
GROUP BY SalespersonPersonID)

SELECT 
	ap.FullName 
FROM Application.People AP
LEFT JOIN SI
ON ap.PersonID=si.SalespersonPersonID
WHERE ap.IsSalesperson=1 and SalespersonPersonID is  NULL
ORDER BY PersonID
/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

TODO: 
SELECT [StockItemID],[Description],MIN([UnitPrice]) AS 'Цена'  FROM [Sales].[InvoiceLines]
GROUP BY [StockItemID],[Description]
ORDER BY [StockItemID]



/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

TODO:
---------- 1)
  SELECT TOP(5)TransactionAmount,CustomerName
  FROM Sales.CustomerTransactions CT, Sales.Customers C
  WHERE CT.CustomerID=C.CustomerID 
  ORDER BY TransactionAmount DESC
----------- 2)
  SELECT TOP(5)TransactionAmount,CustomerName 
  FROM Sales.CustomerTransactions CT INNER JOIN Sales.Customers C
  ON CT.CustomerID=C.CustomerID
  ORDER BY TransactionAmount DESC
------------ 3)
  ;WITH CTE (TransactionAmount,CustomerID) AS
  (SELECT TOP(5)TransactionAmount,CustomerID
  FROM Sales.CustomerTransactions CT
  ORDER BY TransactionAmount DESC)
  -- вызов CTE
  SELECT TransactionAmount,C.CustomerName 
  FROM CTE INNER JOIN Sales.Customers C
  ON CTE.CustomerID=C.CustomerID
 
/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

TODO: 
;WITH CTE ( FullName,CustomerID) AS
(SELECT  AP.FullName, SI.CustomerID
FROM     Sales.Invoices AS SI 
INNER JOIN Application.People AS AP ON SI.PackedByPersonID = AP.PersonID
WHERE InvoiceID IN
	(SELECT InvoiceID 
	FROM Sales.InvoiceLines
    WHERE UnitPrice IN
		( SELECT  TOP(3) UnitPrice
		   FROM Sales.InvoiceLines 
		   ORDER BY UnitPrice DESC )
	)
)
--ВЫЗОВ CTE
SELECT  CityID
		,CityName,
	  	CTE.FullName
FROM [Application].[Cities] ac INNER JOIN SALES.Customers C
ON C.DeliveryMethodID=AC.CityID
INNER JOIN CTE
ON C.CustomerID =CTE.CustomerID
GROUP BY CityID
		,CityName,
		CTE.FullName
ORDER BY CTE.FullName

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

TODO: напишите здесь свое решение
