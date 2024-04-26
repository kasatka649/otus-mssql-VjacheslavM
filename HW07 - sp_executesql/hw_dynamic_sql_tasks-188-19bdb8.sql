/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/

DECLARE @dml AS NVARCHAR(MAX)
DECLARE @ColumnName AS NVARCHAR(MAX)

SELECT @ColumnName = ISNULL(@ColumnName + ',','')  +QUOTENAME(CustomerName)
FROM [Sales].[Customers] 
--WHERE CustomerID BETWEEN 2 and 6
ORDER BY CustomerName

SET @dml = 
N'SELECT InvMonth, ' +@ColumnName + ' FROM
(
SELECT CONVERT(nvarchar,CA.InvMonth,104)  as InvMonth
,CustomerName
,	InvoiceID as CntInv
FROM  [Sales].[Invoices] AS P
CROSS APPLY (SELECT CAST(DATEADD(mm,DATEDIFF(mm,0,P.InvoiceDate),0) AS DATE) AS InvMonth) AS CA
INNER JOIN (SELECT CustomerID, CustomerName 
FROM [Sales].[Customers]
--WHERE CustomerID between 2 and 6
) as CS 
ON CS.CustomerID=P.CustomerID
)as SourceTable
PIVOT (COUNT(CntInv)
	FOR CustomerName IN (' + @ColumnName + ')) as PivotTable
ORDER BY CAST(InvMonth as date)'
EXEC sp_executesql @dml
