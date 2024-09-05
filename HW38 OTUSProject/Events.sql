--Лог
SELECT * 
FROM [OTUS_projekt].[dbo].vLog
WHERE  [EventDate] BETWEEN getdate()-1 AND getdate()
ORDER BY [EVENTDATE] DESC

--реактивы
SELECT * FROM Reagent
WHERE ModifiedDate BETWEEN getdate()-1 AND getdate()
ORDER BY ID_reag DESC


--свойсва реактивов
SELECT TOP (10) *  FROM vFeature
ORDER BY ID_REAG DESC

--партии
SELECT top (10) * 
FROM [OTUS_projekt].[dbo].vBatchAll
ORDER BY Batch_ID DESC

--списания
SELECT top (10) * 
FROM [OTUS_projekt].[dbo].vUtil
ORDER BY Util_ID DESC

