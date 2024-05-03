/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/
 INSERT INTO [Purchasing].[Suppliers]
  (    [SupplierName]
      ,[SupplierCategoryID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
       ,[DeliveryCityID]
      ,[PostalCityID]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
       ,[DeliveryPostalCode]
       ,[PostalAddressLine1]
       ,[PostalPostalCode]
      ,[LastEditedBy]
     	  ) 
  SELECT TOP (5) [SupplierName] +'TEST'
	  ,[SupplierCategoryID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryPostalCode]
      ,[PostalAddressLine1]
      ,[PostalPostalCode]
      ,[LastEditedBy]
  FROM [Purchasing].[Suppliers] 

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

  DELETE FROM [Purchasing].[Suppliers] WHERE SupplierID=(SELECT MAX([SupplierID]) FROM [Purchasing].[Suppliers])


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE [Purchasing].[Suppliers] 
 SET [SupplierName]=(SELECT [SupplierName]+'_UpdateTest' WHERE SupplierID=(SELECT MAX([SupplierID]) FROM [Purchasing].[Suppliers]))
 WHERE SupplierID=(SELECT MAX([SupplierID]) FROM [Purchasing].[Suppliers])
/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

CREATE SCHEMA [OTUS];
SELECT TOP(10) * INTO OTUS.[Suppliers] FROM [Purchasing].[Suppliers]

MERGE OTUS.[Suppliers]   AS Target
USING  [Purchasing].[Suppliers]  AS Source
ON (Target.SupplierID = Source.SupplierID)
WHEN MATCHED 
    THEN UPDATE 
        SET [SupplierName] = Source.[SupplierName]+'__MergeTestUPDATE2'
WHEN NOT MATCHED 
    THEN INSERT (
	[SupplierID],
	 [SupplierName] 
	  , [SupplierCategoryID]
      , [PrimaryContactPersonID]
      , [AlternateContactPersonID]
      , [DeliveryCityID]
      , [PostalCityID]
      , [PaymentDays]
      , [PhoneNumber]
      , [FaxNumber]
      , [WebsiteURL]
      , [DeliveryAddressLine1]
      , [DeliveryPostalCode]
      , [PostalAddressLine1]
      , [PostalPostalCode]
      , [LastEditedBy]
	  ,ValidFrom
	  ,ValidTo	  )
VALUES
(  	Source.SupplierID
	,Source.[SupplierName] +'__MergeTestTTT5'
	  ,Source.[SupplierCategoryID]
      ,Source.[PrimaryContactPersonID]
      ,Source.[AlternateContactPersonID]
      ,Source.[DeliveryCityID]
      ,Source.[PostalCityID]
      ,Source.[PaymentDays]
      ,Source.[PhoneNumber]
      ,Source.[FaxNumber]
      ,Source.[WebsiteURL]
      ,Source.[DeliveryAddressLine1]
      ,Source.[DeliveryPostalCode]
      ,Source.[PostalAddressLine1]
      ,Source.[PostalPostalCode]
      ,Source.[LastEditedBy]
	  ,GETDATE()
      ,GETDATE())
--WHEN NOT MATCHED BY SOURCE
--    THEN 
--        DELETE
OUTPUT deleted.*,$action,inserted.*;


/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bcp in
*/

DECLARE @out varchar(250);
set @out = 'bcp  [WideWorldImporters].[Application].[DeliveryMethods] OUT "C:\tmp\demo.txt" -T -S ' + @@SERVERNAME + ' -c';
EXEC master..xp_cmdshell @out

--CREATE SCHEMA [OTUS];
SELECT * INTO OTUS.[DeliveryMethods]
FROM [Application].[DeliveryMethods]
WHERE 1=2  

DECLARE @in varchar(250);
set @in = 'bcp WideWorldImporters.OTUS.DeliveryMethods IN "C:\tmp\demo.txt" -T -S ' + @@SERVERNAME + ' -c';
EXEC master..xp_cmdshell @in;