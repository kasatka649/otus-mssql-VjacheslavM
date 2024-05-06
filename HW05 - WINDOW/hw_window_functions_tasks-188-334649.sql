/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "06 - Оконные функции".
*/
-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------
USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/
set statistics time, io on
;with cte as
(SELECT SUM(Quantity*UnitPrice) MonthSum,MONTH(InvoiceDate) M,YEAR(InvoiceDate) Y
	  FROM  [Sales].[InvoiceLines] SIL 
	  INNER JOIN   [Sales].[Invoices] SINV ON SIL.[InvoiceID]=SINV.InvoiceID
	  WHERE   InvoiceDate>='2015-01-01'
	  GROUP BY YEAR(InvoiceDate),MONTH(InvoiceDate)   )

SELECT InvoiceID 'id продажи'
	 , CustomerName 'название клиента'
	 ,InvoiceDate 'дата продажи'
	  , InvoiceSum 'сумма продажи'
	  , MonthSum 'сумма за месяц'
	  , Total 'сумма с нарастающим итогом'
FROM
(SELECT SINV.InvoiceID AS InvoiceID
	 , CustomerName 
	 ,InvoiceDate
	  ,SUM(Quantity*UnitPrice) InvoiceSum
  FROM Sales.InvoiceLines SIL 
  INNER JOIN   Sales.Invoices SINV ON SIL.InvoiceID=SINV.InvoiceID
  INNER JOIN Sales.Customers SC ON SC.CustomerID=SINV.CustomerID
  WHERE   InvoiceDate>='2015-01-01'
GROUP BY SINV.InvoiceID,CustomerName,InvoiceDate)MN 
INNER JOIN 
(SELECT  S.MonthSum,M,Y,
       (SELECT SUM(t2.MonthSum)
FROM cte t2
WHERE T2.M <= S.M AND T2.Y <= S.Y) AS Total
FROM cte s )TL
ON TL.M=MONTH(MN.INVOICEDATE) AND TL.Y=YEAR(MN.InvoiceDate)
ORDER BY InvoiceID

 --SQL Server Execution Times:
 --  CPU time = 3234 ms,  elapsed time = 4625 ms.

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

set statistics time, io on
SELECT 
	SINV.InvoiceID 'id продажи'
	 , CustomerName 'название клиента'
	 ,InvoiceDate 'дата продажи'
	 , SUM(Quantity*UnitPrice) OVER ( partition BY SINV.InvoiceID )
	 'сумма продажи'
	 ,MONTH(InvoiceDate) AS M,YEAR(InvoiceDate) AS  Y
	 , SUM(Quantity*UnitPrice) OVER (partition BY MONTH(InvoiceDate)  ORDER BY YEAR(InvoiceDate),MONTH(InvoiceDate))  'сумма за месяц'
	 ,SUM(Quantity*UnitPrice) OVER ( ORDER BY YEAR(InvoiceDate),MONTH(InvoiceDate)  RANGE    unbounded preceding  )   'сумма с нарастающим итогом'
  FROM Sales.InvoiceLines SIL 
  INNER JOIN   Sales.Invoices SINV ON SIL.InvoiceID=SINV.InvoiceID
  INNER JOIN Sales.Customers SC ON SC.CustomerID=SINV.CustomerID
  WHERE   InvoiceDate>='2015-01-01'
 
 --SQL Server Execution Times:
 --  CPU time = 218 ms,  elapsed time = 915 ms.

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/
SELECT Месяц, [Кол-во],StockItemID,Описание
 FROM  ( SELECT StockItemID,
				Description as 'Описание',
				SUM(Quantity) as 'Кол-во',
				MONTH(InvoiceDate) as 'Месяц',
				ROW_NUMBER() OVER (PARTITION BY MONTH(InvoiceDate) ORDER BY SUM(Quantity) DESC) as NumberPos_rownumber
  FROM [Sales].[InvoiceLines] IL 
  INNER JOIN [Sales].Invoices I ON I.[InvoiceID]=IL.[InvoiceID]
  WHERE YEAR(InvoiceDate)='2016'  
  GROUP BY MONTH(InvoiceDate),StockItemID,Description ) tbl
  WHERE NumberPos_rownumber<=2
  ORDER BY Месяц
  /*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

SELECT  StockItemID
      ,StockItemName
      ,[Brand]
      ,[UnitPrice]
	 ,LEFT(StockItemName,1) as 'ItemNameBegin'
--* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
	,ROW_NUMBER() OVER (PARTITION BY LEFT(StockItemName,1)  ORDER BY StockItemID) as RowNum_Pos
--* посчитайте общее количество товаров и выведите полем в этом же запросе
		,COUNT(StockItemID) OVER ( )  as 'общее количество товаров'  
--* посчитайте общее количество товаров в зависимости от первой буквы названия товара 
, count(StockItemID) over  (PARTITION BY LEFT(StockItemName,1)  ORDER BY LEFT(StockItemName,1)  RANGE CURRENT ROW) as 'кол-во с 1-й буквой товара'
--* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
,'следующий id' = lead(StockItemID,1) over ( order by StockItemName asc)
--* предыдущий ид товара с тем же порядком отображения (по имени)
,'предыдущий id' = lag(StockItemID,1) over ( order by StockItemName asc)
--* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
,'название -2 строки назад' = ISNULL(lag(StockItemName,2) over ( order by StockItemName asc),'No items') 
--* сформируйте 30 групп товаров по полю вес товара на 1 шт
	  ,ntile(30) over ( order by TypicalWeightPerUnit) as 'Группа №'
FROM [Warehouse].[StockItems]
ORDER BY StockItemName



/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/
SELECT SalespersonPersonID,
		FullName as 'Фамилия сотрудника',
		CustomerID,
		CustomerName as 'Название клиента',
		InvoiceDate 'Дата продажи',
		InvoiceSum as 'Сумма сделки' 
FROM 
(SELECT SI.InvoiceID,InvoiceDate,SalespersonPersonID,FullName,SI.CustomerID,CustomerName,InvoiceSum=SUM((IL.UnitPrice*IL.Quantity))
--,LastClient=first_value (SI.CustomerID) over (partition by SalespersonPersonID order by SI.InvoiceID desc rows between 
--unbounded preceding and unbounded following) -- for check
,DENSE_RANK() OVER (PARTITION BY SalespersonPersonID ORDER BY SI.InvoiceID DESC) as DENSE_RANK_NumberPos
  FROM [Sales].[Invoices] SI
  INNER JOIN Application.People AP ON AP.PersonID=SI.SalespersonPersonID
  INNER JOIN Sales.Customers SC ON SI.CustomerID=SC.CustomerID
  INNER JOIN [Sales].InvoiceLines IL ON SI.InvoiceID=IL.InvoiceID
GROUP BY SalespersonPersonID,FullName,SI.InvoiceID,InvoiceDate, SI.CustomerID,CustomerName
)tbl
WHERE DENSE_RANK_NumberPos=1

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

 SELECT CustomerID,
		CustomerName AS 'Название',
		StockItemID as 'ид товара',
		Цена,
		InvoiceDate as 'дата покупки'
FROM  
(SELECT SC.CustomerID,CustomerName,StockItemID ,
				MAX(UnitPrice) as 'Цена',
				InvoiceDate 
				,DENSE_RANK() OVER (PARTITION BY SC.CustomerID ORDER BY MAX(UnitPrice) DESC) as DENSE_RANK_NumberPos
  FROM [Sales].[InvoiceLines] IL 
  INNER JOIN [Sales].Invoices I ON I.[InvoiceID]=IL.[InvoiceID]
  INNER JOIN [Sales].Customers SC ON I.CustomerID=SC.CustomerID
GROUP BY SC.CustomerID,SC.CustomerName,StockItemID,InvoiceDate  ) tbl
WHERE DENSE_RANK_NumberPos<=2


Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 