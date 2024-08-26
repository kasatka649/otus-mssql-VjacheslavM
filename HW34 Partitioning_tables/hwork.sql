�������� � ����� ������� �������-�������� ��� ��������������� � ��������� �����������������. 
���� � ������� ��� ����� �������, �� ������ ������ ���� ������ �� ������� ������, 
�������� ������� � ������ �� ���������������, 
� ��������� ������ �� ������� (���������) - ������ �� ����, ��� ������� �������, ����� ������� �������� � ���������������� �������.

--������� ��� ��������������� ������� [OTUS_projekt].[dbo].[Comments] - 176456 rows
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
--�������� �������� ������
ALTER DATABASE OTUS_projekt ADD FILEGROUP [YearData]
GO
ALTER DATABASE OTUS_projekt ADD FILE 
( NAME = N'Years', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SERV22DEV\MSSQL\DATA\Yeardata.ndf' , 
SIZE = 1GB , FILEGROWTH = 100MB ) TO FILEGROUP [YearData]
GO
--������� ������� ����������������� �� �����!
CREATE PARTITION FUNCTION [fnYearPartition](datetime) AS RANGE RIGHT FOR VALUES
('2007-01-01','2008-01-01','2009-01-01','2010-01-01','2011-01-01','2012-01-01', '2013-01-01','2014-01-01' );																																																									
GO
-- ��������������, ��������� ��������� �������
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
) ON  [schmYearPartition](CreationDate) --� ����� [schmYearPartition] �� ����� [CreationDate]
GO
--�������� ���������� ������ � ��� �� ����� � ��� �� ������
ALTER TABLE [dbo].CommentsNew ADD CONSTRAINT PK_dbo_CommentsNew 
PRIMARY KEY CLUSTERED  (CreationDate, ID)
 ON [schmYearPartition](CreationDate);
--������� ������ �� ������� � ����
 DECLARE @out varchar(250);
set @out = 'bcp  [OTUS_projekt].[dbo].[Comments] OUT "C:\tmp\OTUSCom.txt" -T -S ' + @@SERVERNAME + ' -c';
EXEC master..xp_cmdshell @out
--������ ������ �� ����� �  ������������������ �������
DECLARE @IN varchar(250);
set @IN = 'bcp  [OTUS_projekt].[dbo].[Comments] IN "C:\tmp\OTUSCom.txt" -T -S ' + @@SERVERNAME + ' -c';
EXEC master..xp_cmdshell @IN

 select count(*)  FROM [OTUS_projekt].[dbo].[CommentsNew]

 --������� ��� ��������� �� ���������� �������������� ������
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

������� ������-�� ��������� ������ 2 ������, ���� � ���������� ������ � ��������� (2007 & 2014)
*/

--�������� 2 ������ ������ ��� �������� ������ ������ ������ �����
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