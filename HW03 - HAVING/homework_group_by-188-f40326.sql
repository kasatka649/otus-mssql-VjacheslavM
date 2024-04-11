/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT  
	Year(InvoiceDate) AS 'YEAR',
	MONTH(InvoiceDate) AS 'MONTH',
	SUM(ExtendedPrice) AS 'Общая сумма',
	AVG(UNITPRICE) AS 'Средняя цена'
FROM [Sales].[InvoiceLines] IL 
INNER JOIN Sales.Invoices I ON IL.InvoiceID=I.InvoiceID
GROUP BY MONTH(InvoiceDate),YEAR(InvoiceDate)
ORDER BY YEAR DESC,MONTH

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT  
	Year(InvoiceDate) AS 'YEAR',
	MONTH(InvoiceDate) AS 'MONTH',
	SUM(ExtendedPrice) AS 'Общая сумма'
FROM [Sales].[InvoiceLines] IL 
INNER JOIN Sales.Invoices I ON IL.InvoiceID=I.InvoiceID
GROUP BY 
YEAR(InvoiceDate),MONTH(InvoiceDate)
HAVING SUM(ExtendedPrice)>4600000
ORDER BY YEAR,MONTH

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT  
	Year(InvoiceDate) AS 'YEAR',
	MONTH(InvoiceDate) AS 'MONTH',
	[Description] AS 'Наименование товара',
	SUM(ExtendedPrice) AS 'Общая сумма',
	MIN(InvoiceDate) AS 'Дата первой продажи',
	SUM([Quantity]) AS 'Количество проданного'
FROM [Sales].[InvoiceLines] IL 
INNER JOIN Sales.Invoices I ON IL.InvoiceID=I.InvoiceID
GROUP BY 
YEAR(InvoiceDate),MONTH(InvoiceDate),[Description]
HAVING SUM([Quantity])<50
ORDER BY YEAR,MONTH

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
