/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".
*/
-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT 
	StockItemID, 
	StockItemName 
FROM [Warehouse].[StockItems]
WHERE StockItemName LIKE '%urgent%' OR StockItemName LIKE 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT   
	s.SupplierID,
	s.SupplierName 
FROM Purchasing.Suppliers s  
LEFT Join Purchasing.PurchaseOrders p ON s.SupplierID = p.SupplierID  
WHERE PurchaseOrderID IS NULL
ORDER BY S.SupplierID

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

SELECT DISTINCT
	o.OrderID, 
	 CONVERT(varchar, o.OrderDate, 104) AS [Дата заказа],
	 FORMAT(o.OrderDate, 'MMMM', 'ru-ru') AS [Название месяца],
	 DATEPART(quarter, o.OrderDate) AS [Номер квартала],
	 CASE WHEN Month(o.OrderDate) BETWEEN 1 AND 4 THEN 1 WHEN Month(o.OrderDate) BETWEEN 5 AND 8 THEN 2 ELSE 3 END AS [ТРЕТЬ ГОДА],
	 c.CustomerName as [Имя заказчика]
FROM Sales.Orders o
INNER Join 	Sales.OrderLines s ON o.OrderID=s.OrderID
INNER Join 	Sales.Customers c ON c.CustomerID=o.CustomerID
WHERE (UnitPrice>100 OR Quantity>20) AND o.PickingCompletedWhen IS NOT NULL
ORDER BY [Номер квартала],[ТРЕТЬ ГОДА],[Дата заказа]


/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT       
		DM.DeliveryMethodName AS 'способ доставки',
		PO.ExpectedDeliveryDate AS 'дата доставки', 
		S.SupplierName AS 'имя поставщика', 
		P.FullName AS 'имя контактного лица принимавшего заказ'
FROM    Purchasing.Suppliers AS S 
INNER JOIN   Application.DeliveryMethods AS DM ON S.DeliveryMethodID = DM.DeliveryMethodID 
INNER JOIN   Purchasing.PurchaseOrders AS PO ON DM.DeliveryMethodID = PO.DeliveryMethodID 
INNER JOIN   Application.People AS P ON P.PersonID = PO.ContactPersonID
WHERE        MONTH(PO.ExpectedDeliveryDate) = 1 
AND YEAR(PO.ExpectedDeliveryDate) = '2013' 
AND (DM.DeliveryMethodName = 'Air Freight' OR   DM.DeliveryMethodName = 'Refrigerated Air Freight') 
AND PO.IsOrderFinalized = 1

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

SELECT DISTINCT TOP (10) 
		so.CustomerPurchaseOrderNumber, 
		so.OrderDate,
		Sales.Customers.CustomerName, 
		Application.People.FullName AS SalespersonPerson
FROM	Sales.Customers 
INNER JOIN  Sales.Orders AS so ON Sales.Customers.CustomerID = so.CustomerID 
AND			Sales.Customers.CustomerID = so.CustomerID 
INNER JOIN   Application.People ON so.SalespersonPersonID =Application.People.PersonID
ORDER BY so.OrderDate DESC, so.CustomerPurchaseOrderNumber

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT DISTINCT 
				c.CustomerID, 
				c.CustomerName, 
				c.PhoneNumber
FROM            Warehouse.StockItems 
INNER JOIN      Sales.OrderLines ON Warehouse.StockItems.StockItemID = Sales.OrderLines.StockItemID 
INNER JOIN      Sales.Orders ON Sales.OrderLines.OrderID =Sales.Orders.OrderID 
INNER JOIN      Sales.Customers AS c ON Sales.Orders.CustomerID = c.CustomerID 
AND Sales.Orders.CustomerID =c.CustomerID
WHERE   Warehouse.StockItems.StockItemName = N'Chocolate frogs 250g'
