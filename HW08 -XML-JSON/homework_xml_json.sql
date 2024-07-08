/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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

USE WideWorldImporters;

/*
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/
-- ------------
-- OPEN XML
---------------
DECLARE @xmlDocument XML;
-- Считываем XML-файл в переменную
SELECT @xmlDocument = BulkColumn
FROM OPENROWSET
(BULK 'C:\Users\mvv\Documents\OTUS\XML-JSON\StockItems.xml', 
 SINGLE_CLOB)
AS data;
-- Проверяем, что в @xmlDocument
SELECT @xmlDocument AS [@xmlDocument];

DECLARE @docHandle INT;
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument;

SELECT *
FROM OPENXML(@docHandle, N'/StockItems/Item')
WITH ( [StockItemName] nvarchar(100) '@Name', 
	[SupplierID]  int 'SupplierID',
	[UnitPackageID]  int  'Package/UnitPackageID',
	[OuterPackageID]  int  'Package/OuterPackageID',
	[QuantityPerOuter]  int   'Package/QuantityPerOuter',
	[TypicalWeightPerUnit]  decimal (18, 3)'Package/TypicalWeightPerUnit'  ,
	[LeadTimeDays]  int 'LeadTimeDays' ,
	[IsChillerStock]  bit 'IsChillerStock'  ,
	[TaxRate]  decimal (18, 3)  'TaxRate',
	[UnitPrice]  decimal (18, 2)  'UnitPrice'	);

DROP TABLE IF EXISTS Warehouse.StockItems_OTUS;

CREATE TABLE Warehouse.StockItems_OTUS(
	[StockItemName] [nvarchar](100)  ,
	[SupplierID] [int] ,
	[UnitPackageID] [int] ,
	[OuterPackageID] [int] ,
	[QuantityPerOuter] [int] ,
	[TypicalWeightPerUnit] [decimal](18, 3) ,
	[LeadTimeDays] [int] ,
	[IsChillerStock] [bit] ,
	[TaxRate] [decimal](18, 3) ,
	[UnitPrice] [decimal](18, 2) );

INSERT INTO Warehouse.StockItems_OTUS
 (  [StockItemName] ,
	[SupplierID] ,
	[UnitPackageID]  ,
	[OuterPackageID]  ,
	[QuantityPerOuter] ,
	[TypicalWeightPerUnit]   ,
	[LeadTimeDays]  ,
	[IsChillerStock],
	[TaxRate]  ,
	[UnitPrice]  )
SELECT *
FROM OPENXML(@docHandle, N'/StockItems/Item')
WITH ( [StockItemName] nvarchar(100) '@Name', 
	[SupplierID]  int 'SupplierID',
	[UnitPackageID]  int  'Package/UnitPackageID',
	[OuterPackageID]  int  'Package/OuterPackageID',
	[QuantityPerOuter]  int   'Package/QuantityPerOuter',
	[TypicalWeightPerUnit]  decimal (18, 3)'Package/TypicalWeightPerUnit'  ,
	[LeadTimeDays]  int 'LeadTimeDays' ,
	[IsChillerStock]  bit 'IsChillerStock'  ,
	[TaxRate]  decimal (18, 3)  'TaxRate',
	[UnitPrice]  decimal (18, 2)  'UnitPrice'	);
-- Надо удалить handle
EXEC sp_xml_removedocument @docHandle;
--SELECT * FROM Warehouse.StockItems_OTUS;
GO
-- ------------
-- XQuery
---------------
DECLARE @x XML;
SET @x = (SELECT * FROM OPENROWSET (BULK 'C:\Users\Mihajlovskij\Documents\OTUS\XML-JSON\StockItems.xml', SINGLE_BLOB)  AS d);

SELECT  
  t.Supplier.value('(@Name)[1]', 'varchar(100)') AS [StockItemName],
  t.Supplier.value('(SupplierID)[1]', 'int' ) AS [SupplierID]   ,
  t.Supplier.value('(Package/UnitPackageID)[1]', 'int') AS [UnitPackageID],
  t.Supplier.value('(Package/OuterPackageID)[1]','int') AS [OuterPackageID] ,
  t.Supplier.value('(Package/QuantityPerOuter)[1]', 'int') AS [QuantityPerOuter],
  t.Supplier.value('(Package/TypicalWeightPerUnit)[1]','decimal (18, 3)') AS [TypicalWeightPerUnit],
  t.Supplier.value('(LeadTimeDays)[1]','int') AS  [LeadTimeDays],
  t.Supplier.value('(IsChillerStock)[1]', 'bit') AS [IsChillerStock],
  t.Supplier.value('(TaxRate)[1]',  'decimal (18, 3)') AS  [TaxRate],
  t.Supplier.value('(UnitPrice)[1]','decimal (18, 2)') AS [UnitPrice]
FROM @x.nodes('/StockItems/Item') AS t(Supplier);

INSERT INTO Warehouse.StockItems_OTUS
 (  [StockItemName] ,
	[SupplierID] ,
	[UnitPackageID]  ,
	[OuterPackageID]  ,
	[QuantityPerOuter] ,
	[TypicalWeightPerUnit]   ,
	[LeadTimeDays]  ,
	[IsChillerStock],
	[TaxRate]  ,
	[UnitPrice]  )
SELECT  
  t.Supplier.value('(@Name)[1]', 'varchar(100)') AS [StockItemName],
  t.Supplier.value('(SupplierID)[1]', 'int' ) AS [SupplierID]   ,
  t.Supplier.value('(Package/UnitPackageID)[1]', 'int') AS [UnitPackageID],
  t.Supplier.value('(Package/OuterPackageID)[1]','int') AS [OuterPackageID] ,
  t.Supplier.value('(Package/QuantityPerOuter)[1]', 'int') AS [QuantityPerOuter],
  t.Supplier.value('(Package/TypicalWeightPerUnit)[1]','decimal (18, 3)') AS [TypicalWeightPerUnit],
  t.Supplier.value('(LeadTimeDays)[1]','int') AS  [LeadTimeDays],
  t.Supplier.value('(IsChillerStock)[1]', 'bit') AS [IsChillerStock],
  t.Supplier.value('(TaxRate)[1]',  'decimal (18, 3)') AS  [TaxRate],
  t.Supplier.value('(UnitPrice)[1]','decimal (18, 2)') AS [UnitPrice]
FROM @x.nodes('/StockItems/Item') AS t(Supplier);

MERGE [Warehouse].[StockItems] AS TARGET
USING [Warehouse].[StockItems_OTUS] AS O
    ON (TARGET.StockItemName = O.StockItemName)
WHEN MATCHED 
    THEN UPDATE 
	SET [UnitPackageID]=o.[UnitPackageID]
	 , [OuterPackageID]=o.[OuterPackageID]
	  ,[QuantityPerOuter]=o.[QuantityPerOuter]
	  ,[TypicalWeightPerUnit]=o.[TypicalWeightPerUnit]
	  ,[LeadTimeDays]=o.[LeadTimeDays]
	  ,[IsChillerStock]=o.[IsChillerStock]
	  ,[TaxRate]=o.[TaxRate]
	  ,[UnitPrice]=o.[UnitPrice]
WHEN NOT MATCHED 
  THEN INSERT (StockItemName,[SupplierID],[UnitPackageID], [OuterPackageID],[QuantityPerOuter],[TypicalWeightPerUnit],[LeadTimeDays],[IsChillerStock],
	[TaxRate],[UnitPrice],LastEditedBy	)
        VALUES (O.StockItemName,O.[SupplierID],o.[UnitPackageID], o.[OuterPackageID],o.[QuantityPerOuter],o.[TypicalWeightPerUnit],o.[LeadTimeDays],o.[IsChillerStock],
		o.[TaxRate],o.[UnitPrice],1)
		OUTPUT inserted.*;

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/
 SELECT TOP 15 [StockItemName]  '@Name'
	 ,[SupplierID] [SupplierID]
	  ,UnitPackageID as [Package/UnitPackageID]
	 , [OuterPackageID]  [Package/OuterPackageID]
	  ,[QuantityPerOuter]  [Package/QuantityPerOuter]
	  ,[TypicalWeightPerUnit]  [Package/TypicalWeightPerUnit]
	  ,[LeadTimeDays]  [LeadTimeDays]
	  ,[IsChillerStock]  [IsChillerStock]
	  ,[TaxRate]  [TaxRate]
	  ,[UnitPrice]  [UnitPrice]
 FROM [Warehouse].StockItems ORDER BY StockItemID DESC
 FOR XML PATH('Item'), ROOT('StockItems')


/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/
SELECT 
    StockItemID,  
	StockItemName,
    JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS CountryOfManufacture,
	JSON_VALUE(CustomFields, '$.Tags[0]') AS FirstTag
FROM Warehouse.StockItems;

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/
SELECT 
    StockItemID,  
	StockItemName,
CustomFields
FROM Warehouse.StockItems
WHERE 	JSON_VALUE(CustomFields, '$.Tags[0]')='Vintage'
