Выбираем в своем проекте таблицу-кандидат для секционирования и добавляем партиционирование. 
Если в проекте нет такой таблицы, то делаем анализ базы данных из первого модуля, 
выбираем таблицу и делаем ее секционирование, 
с переносом данных по секциям (партициям) - исходя из того, что таблица большая, пишем скрипты миграции в секционированную таблицу.

--выбрана для секционирования таблица [OTUS_projekt].[dbo].[Comments] - 176456 rows
/*
CREATE TABLE [dbo].[Comments](
	[Id] [int] NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[Text] [nvarchar](700) NOT NULL,
	[emp_id] [int] NOT NULL,
 CONSTRAINT [PK_Comments] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
*/
SELECT Year(CreationDate) AS 'Year',COUNT(ID) as cnt
FROM  [Comments]
GROUP BY Year(CreationDate) 
/*
Result:
Year	cnt
2008	13624
2013	25807
2012	26697
2011	33622
2009	39243
2010	37463
*/
--создадим файловую группу
ALTER DATABASE OTUS_projekt ADD FILEGROUP [YearData]
GO
ALTER DATABASE OTUS_projekt ADD FILE 
( NAME = N'Years', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SERV22DEV\MSSQL\DATA\Yeardata.ndf' , 
SIZE = 1GB , FILEGROWTH = 100MB ) TO FILEGROUP [YearData]
GO
--создаем функцию партиционирования по годам!
CREATE PARTITION FUNCTION [fnYearPartition](datetime) AS RANGE RIGHT FOR VALUES
('2007-01-01','2008-01-01','2009-01-01','2010-01-01','2011-01-01','2012-01-01', '2013-01-01','2014-01-01' );																																																									
GO
-- партиционируем, используя созданную функцию
CREATE PARTITION SCHEME [schmYearPartition] AS PARTITION [fnYearPartition] 
ALL TO ([YearData])
GO

SELECT * INTO CommentsNew FROM Comments
GO
CREATE TABLE [dbo].[CommentsNew](
	[Id] [int] NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[Text] [nvarchar](700) NOT NULL,
	[emp_id] [int] NOT NULL
) ON  [schmYearPartition](CreationDate) --в схеме [schmYearPartition] по ключу [CreationDate]
GO
--создадим кластерный индекс в той же схеме с тем же ключом
ALTER TABLE [dbo].CommentsNew ADD CONSTRAINT PK_dbo_CommentsNew 
PRIMARY KEY CLUSTERED  (CreationDate, ID)
 ON [schmYearPartition](CreationDate);
--экспорт данных из таблицы в файл
 DECLARE @out varchar(250);
set @out = 'bcp  [OTUS_projekt].[dbo].[Comments] OUT "C:\tmp\OTUSCom.txt" -T -S ' + @@SERVERNAME + ' -c';
EXEC master..xp_cmdshell @out
--импорт данных из файла в  партиционированную таблицу
DECLARE @IN varchar(250);
set @IN = 'bcp  [OTUS_projekt].[dbo].[Comments] IN "C:\tmp\OTUSCom.txt" -T -S ' + @@SERVERNAME + ' -c';
EXEC master..xp_cmdshell @IN

 select count(*)  FROM [OTUS_projekt].[dbo].[CommentsNew]

 --смотрим как конкретно по диапазонам распределились данные
SELECT  $PARTITION.fnYearPartition(CreationDate) AS Partition
		, COUNT(*) AS [COUNT]
		, MIN(CreationDate)
		,MAX(CreationDate) 
FROM CommentsNew
GROUP BY $PARTITION.fnYearPartition(CreationDate) 
ORDER BY Partition ;  
/*
Partition	COUNT	(No column name)	(No column name)
3	       13624	2008-08-02 04:00:34.100	   2008-12-31 23:33:07.467
4	       39243	2009-01-01 01:38:35.810	   2009-12-31 23:53:14.707
5	       37463	2010-01-01 00:08:37.267	   2010-12-31 23:22:13.410
6	       33622	2011-01-01 02:30:07.227	   2011-12-31 23:59:13.703
7	       26697	2012-01-01 02:00:50.870	   2012-12-31 21:46:49.410
8	       25807	2013-01-01 00:46:40.223	   2013-12-31 19:25:59.037

пустыми почему-то оказались первые 2 секции, хотя я планировал первую и последнюю (2007 & 2014)
*/

--смерджим 2 пустые секции для удаления лишней пустой секции слева
Alter Partition Function fnYearPartition() MERGE RANGE ('20070101');


SELECT  $PARTITION.fnYearPartition(CreationDate) AS Partition
		, COUNT(*) AS [COUNT]
		, MIN(CreationDate)
		,MAX(CreationDate) 
FROM CommentsNew
GROUP BY $PARTITION.fnYearPartition(CreationDate) 
ORDER BY Partition ;  
/*
Partition	COUNT	(No column name)	(No column name)
2	13624	2008-08-02 04:00:34.100	2008-12-31 23:33:07.467
3	39243	2009-01-01 01:38:35.810	2009-12-31 23:53:14.707
4	37463	2010-01-01 00:08:37.267	2010-12-31 23:22:13.410
5	33622	2011-01-01 02:30:07.227	2011-12-31 23:59:13.703
6	26697	2012-01-01 02:00:50.870	2012-12-31 21:46:49.410
7	25807	2013-01-01 00:46:40.223	2013-12-31 19:25:59.037
*/