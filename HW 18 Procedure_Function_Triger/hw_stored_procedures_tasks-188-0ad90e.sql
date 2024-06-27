/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/
USE WideWorldImporters;
IF OBJECT_ID (N'dbo.fGetMaxInvoice', N'FN') IS NOT NULL
DROP FUNCTION dbo.fGetMaxInvoice;
GO
CREATE FUNCTION dbo.fGetMaxInvoice()
RETURNS int
AS
BEGIN
    DECLARE @Result int;
    SELECT @Result = 
    (SELECT        TOP 1  CS.CustomerID
	FROM          Sales.Invoices SI 
	INNER JOIN    Sales.InvoiceLines IL ON SI.InvoiceID = IL.InvoiceID 
	INNER JOIN    Sales.Customers CS ON SI.CustomerID = CS.CustomerID
	GROUP BY SI.InvoiceID, CS.CustomerID
	ORDER BY SUM(IL.Quantity * IL.UnitPrice)  DESC	)
   	RETURN @Result;
END;
GO
SELECT dbo.fGetMaxInvoice()


/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

IF OBJECT_ID(N'OTUS.uspGetSumInvoice', N'P') IS NOT NULL
DROP PROCEDURE OTUS.uspGetSumInvoice;
GO
CREATE PROCEDURE OTUS.uspGetSumInvoice(@СustomerID int=NUll)
AS
    SET NOCOUNT ON;
	IF @СustomerID IS NULL 
	BEGIN
		SET @СustomerID=dbo.fGetMaxInvoice()
		PRINT 'The ID of the Customer with the highest purchase amount is selected'
	END
    SELECT   TOP 1   SUM(IL.Quantity * IL.UnitPrice) as  [SUM]
 	FROM          Sales.Invoices SI 
	INNER JOIN    Sales.InvoiceLines IL ON SI.InvoiceID = IL.InvoiceID 
	INNER JOIN    Sales.Customers CS ON SI.CustomerID = CS.CustomerID
	WHERE CS.CustomerID = @СustomerID
	GROUP BY SI.InvoiceID
	ORDER BY [SUM] DESC;
	
GO
DECLARE @СustomerID int
EXEC OTUS.uspGetSumInvoice @СustomerID

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

IF OBJECT_ID (N'OTUS.uspTest', N'P') IS NOT NULL
DROP PROCEDURE OTUS.uspTest;
GO
CREATE PROCEDURE OTUS.uspTest
AS
BEGIN
	SET NOCOUNT OFF;
	SELECT        CS.CustomerID, CS.CustomerName, CS.BillToCustomerID, CS.CustomerCategoryID, CS.BuyingGroupID, CS.AlternateContactPersonID, 
					CS.PrimaryContactPersonID, CS.DeliveryMethodID, CS.DeliveryCityID, CS.PostalCityID, CS.CreditLimit, CS.StandardDiscountPercentage, 
					CS.AccountOpenedDate, SI.InvoiceID, SI.OrderID, SI.DeliveryMethodID AS Expr1, SI.ContactPersonID, SI.AccountsPersonID, 
					SI.SalespersonPersonID, SI.CreditNoteReason, SI.Comments, IL.StockItemID, IL.Description, IL.PackageTypeID, 
					IL.Quantity, IL.UnitPrice, IL.TaxAmount, IL.LineProfit, IL.ExtendedPrice, IL.LastEditedBy, 
					IL.LastEditedWhen
	FROM            Sales.InvoiceLines AS IL
	INNER JOIN      Sales.Invoices AS SI ON IL.InvoiceID = SI.InvoiceID 
	LEFT OUTER JOIN Sales.Customers as CS ON SI.CustomerID = CS.CustomerID AND SI.BillToCustomerID = CS.CustomerID
END;
GO
EXEC OTUS.uspTest  ;

IF OBJECT_ID (N'OTUS.fTEST') IS NOT NULL
DROP FUNCTION OTUS.fTEST;
GO
CREATE FUNCTION OTUS.fTEST()
RETURNS TABLE 
AS
RETURN 
(	SELECT        CS.CustomerID, CS.CustomerName, CS.BillToCustomerID, CS.CustomerCategoryID, CS.BuyingGroupID, CS.AlternateContactPersonID, 
					CS.PrimaryContactPersonID, CS.DeliveryMethodID, CS.DeliveryCityID, CS.PostalCityID, CS.CreditLimit, CS.StandardDiscountPercentage, 
					CS.AccountOpenedDate, SI.InvoiceID, SI.OrderID, SI.DeliveryMethodID AS Expr1, SI.ContactPersonID, SI.AccountsPersonID, 
					SI.SalespersonPersonID, SI.CreditNoteReason, SI.Comments, IL.StockItemID, IL.Description, IL.PackageTypeID, 
					IL.Quantity, IL.UnitPrice, IL.TaxAmount, IL.LineProfit, IL.ExtendedPrice, IL.LastEditedBy, 
					IL.LastEditedWhen
	FROM            Sales.InvoiceLines AS IL
	INNER JOIN      Sales.Invoices AS SI ON IL.InvoiceID = SI.InvoiceID 
	LEFT OUTER JOIN Sales.Customers as CS ON SI.CustomerID = CS.CustomerID AND SI.BillToCustomerID = CS.CustomerID);

GO
SELECT * from OTUS.fTEST();
/*
В теории: "Процедуры и Функции  сокращают затраты на компиляцию кода Transact-SQL за счет кэширования планов и их повторного использования для повторного выполнения. 
Это означает, что пользовательскую функцию не нужно повторно анализировать и оптимизировать при каждом использовании, что приводит к гораздо более быстрому выполнению."
В реальности не увидел разницы, хотя старался сделать довольно большие запросы.
*/

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/
IF OBJECT_ID (N'OTUS.fGetCustomerId') IS NOT NULL
DROP FUNCTION OTUS.fGetCustomerId;
GO
CREATE FUNCTION OTUS.fGetCustomerId(@CustomerName NVARCHAR(50))
RETURNS INT
AS
BEGIN
    DECLARE @Result INT;
    SELECT @Result = 
   	(SELECT CustomerID FROM Sales.Customers c 
	WHERE c.CustomerName LIKE @CustomerName);

    RETURN @Result;
END;
GO
IF OBJECT_ID (N'OTUS.fGetInvoiceItemDate') IS NOT NULL
DROP FUNCTION OTUS.fGetInvoiceItemDate;
GO
CREATE FUNCTION OTUS.fGetInvoiceItemDate( @CustomerName NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
 	 SELECT c.CustomerName [Customer]
       , i.SalespersonPersonID [SalesPerson]
         , l.[Description],
		 InvoiceDate
    FROM Sales.Customers c
    CROSS APPLY (
		SELECT *
		FROM Sales.Invoices i
		WHERE c.CustomerID = i.CustomerID) AS i
			CROSS APPLY (
				SELECT *
				FROM Sales.InvoiceLines l
				WHERE l.InvoiceID = i.InvoiceID
				AND c.CustomerID = OTUS.fGetCustomerId(@CustomerName)) AS l
);
GO
DECLARE @CustomerName NVARCHAR(50)='Erik Malk'
SELECT * FROM OTUS.fGetInvoiceItemDate(@CustomerName)
/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
