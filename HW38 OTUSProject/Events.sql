--���
SELECT * 
FROM [OTUS_projekt].[dbo].vLog
WHERE  [EventDate] BETWEEN getdate()-1 AND getdate()
ORDER BY [EVENTDATE] DESC

--��������
SELECT * FROM Reagent
WHERE ModifiedDate BETWEEN getdate()-1 AND getdate()
ORDER BY ID_reag DESC


--������� ���������
SELECT TOP (10) *  FROM vFeature
ORDER BY ID_REAG DESC

--������
SELECT top (10) * 
FROM [OTUS_projekt].[dbo].vBatchAll
ORDER BY Batch_ID DESC

--��������
SELECT top (10) * 
FROM [OTUS_projekt].[dbo].vUtil
ORDER BY Util_ID DESC

