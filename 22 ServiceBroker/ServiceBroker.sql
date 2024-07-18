---Отправка сообщений при добавлении строки в таблице Логов (когда происходят изменения в БД)
ALTER TABLE dbo.ChangeLog_USER_EVENTS
ADD EventConfirmedForProcessing DATETIME;

--CHECK Service Broker 
select name, is_broker_enabled
from sys.databases;

USE master
ALTER DATABASE OTUS_projekt
SET ENABLE_BROKER  WITH ROLLBACK IMMEDIATE; 
GO

--ALTER AUTHORIZATION  ON DATABASE::OTUS_projekt TO [sa];

--ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;
-----------------------------------
-- For Request
CREATE MESSAGE TYPE
[//OTUS_projekt/SB/RequestMessage]
VALIDATION=WELL_FORMED_XML; 
-- For Reply
CREATE MESSAGE TYPE
[//OTUS_projekt/SB/ReplyMessage]
VALIDATION=WELL_FORMED_XML; 
----------------------------
CREATE CONTRACT [//OTUS_projekt/SB/Contract]
      ([//OTUS_projekt/SB/RequestMessage]
         SENT BY INITIATOR,
       [//OTUS_projekt/SB/ReplyMessage]
         SENT BY TARGET      );
---------------------------
CREATE QUEUE TargetQueue;
GO
CREATE SERVICE [//OTUS_projekt/SB/TargetService]
       ON QUEUE TargetQueue
       ([//OTUS_projekt/SB/Contract]);
----------------------------------------

CREATE QUEUE InitiatorQueue;
GO
CREATE SERVICE [//OTUS_projekt/SB/InitiatorService]
       ON QUEUE InitiatorQueue
       ([//OTUS_projekt/SB/Contract]);
--------------------------------------------

ALTER QUEUE [dbo].[InitiatorQueue] WITH STATUS = ON 
                                          ,RETENTION = OFF 
										  ,POISON_MESSAGE_HANDLING (STATUS = OFF) 
	                                      ,ACTIVATION (STATUS = ON 
										              ,PROCEDURE_NAME = dbo.ConfirmInvoice
													  ,MAX_QUEUE_READERS = 1 													                         
													  ,EXECUTE AS OWNER 		  ) 

GO
ALTER QUEUE [dbo].[TargetQueue] WITH STATUS = ON 
                                       ,RETENTION = OFF 
									   ,POISON_MESSAGE_HANDLING (STATUS = OFF)
									   ,ACTIVATION (STATUS = ON 
									               ,PROCEDURE_NAME = dbo.GetNewInvoice
												   ,MAX_QUEUE_READERS = 1
												   ,EXECUTE AS OWNER 		   ) 

GO

--TEST
--добавление/удаление ед. измерения
EXEC	[dbo].[spAddUnitMeasure]
		@UnitMeasureCode = N'test',
		@Name = N'TEST',
		@CURRENT_USER = VVM,
		@HOST_NAME = PC;
GO
EXEC	[dbo].[spDelUnitMeasure]
		@UnitMeasureCode = 'test',
		@CURRENT_USER = V,
		@HOST_NAME = P


--список диалогов
SELECT conversation_handle, is_initiator, s.name as 'local service', 
far_service, sc.name 'contract', ce.state_desc
FROM sys.conversation_endpoints ce --представление диалогов(постепенно очищается) чтобы ее не переполнять - --НЕЛЬЗЯ ЗАВЕРШАТЬ ДИАЛОГ ДО ОТПРАВКИ ПЕРВОГО СООБЩЕНИЯ
LEFT JOIN sys.services s
ON ce.service_id = s.service_id
LEFT JOIN sys.service_contracts sc
ON ce.service_contract_id = sc.service_contract_id
ORDER BY conversation_handle;