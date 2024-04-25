/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".
*/
-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------
USE WideWorldImporters
/*
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

SELECT InvMonth,[Sylvanite, MT],[Peeples Valley, AZ],[Medicine Lodge, KS],[Gasport, NY],[Jessie, ND]
FROM
(SELECT CONVERT(nvarchar,CA.InvMonth,104)  as InvMonth,CS.CustShort,	InvoiceID as CntInv
FROM  [Sales].[Invoices] AS P
CROSS APPLY (SELECT CAST(DATEADD(mm,DATEDIFF(mm,0,P.InvoiceDate),0) AS DATE) AS InvMonth) AS CA
INNER JOIN (SELECT CustomerID, CustomerName ,CustShort
FROM [Sales].[Customers]
CROSS APPLY (SELECT WorkString=CustomerName) F_Str
CROSS APPLY (SELECT p1=CHARINDEX('(',WorkString)) F_P1
CROSS APPLY (SELECT p2=CHARINDEX(')',WorkString)) F_P2
CROSS APPLY (SELECT CustShort=CONVERT(nvarchar(100),SUBSTRING(WorkString,p1+1,p2-p1-1)) ) F_StrFin
WHERE CustomerID BETWEEN 2 and 6) as CS 
ON CS.CustomerID=P.CustomerID
)as SourceTable
pivot
(
COUNT(CntInv)
FOR CustShort
in ([Sylvanite, MT],[Peeples Valley, AZ],[Medicine Lodge, KS],[Gasport, NY],[Jessie, ND])
)as PivotTable
ORDER BY CAST(InvMonth as date)


/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

SELECT   CustomerName,
	     valuekol as AddressLine
FROM [Sales].[Customers]
unpivot
(
valuekol for columnname in ([DeliveryAddressLine1],[DeliveryAddressLine2] ,[PostalAddressLine1],[PostalAddressLine2])
) as T_unpivot
WHERE [CustomerName] LIKE 'Tailspin Toys%'


/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

SELECT 	[CountryID]
       ,CountryName
	   ,valuekol as Code
 FROM
(SELECT  [CountryID],[CountryName],IsoAlpha3Code ,CONVERT(nvarchar(3),IsoNumericCode  ) as IsoNumericCodeStrType
FROM [Application].[Countries])p
unpivot
(
valuekol for columnname in ( [IsoAlpha3Code],IsoNumericCodeStrType )
) as T_unpivot

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT CustomerID,CustomerName AS 'Название',StockItemID as 'ид товара',Цена,InvoiceDate as 'дата покупки'
FROM  
(SELECT SC.CustomerID,CustomerName,StockItemID ,
				MAX(UnitPrice) as 'Цена',
				InvoiceDate 
				,ROW_NUMBER() OVER (PARTITION BY SC.CustomerID ORDER BY MAX(UnitPrice) DESC) as NumberPos_rownumber
  FROM [Sales].[InvoiceLines] IL 
  INNER JOIN [Sales].Invoices I ON I.[InvoiceID]=IL.[InvoiceID]
  INNER JOIN [Sales].Customers SC ON I.CustomerID=SC.CustomerID
GROUP BY SC.CustomerID,SC.CustomerName,StockItemID,InvoiceDate
  ) tbl
WHERE NumberPos_rownumber<=2

