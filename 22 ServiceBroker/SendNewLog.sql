USE [OTUS_projekt]
GO
/****** Object:  StoredProcedure [dbo].[SendNewInvoice]    Script Date: 18.07.2024 16:05:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[SendNewInvoice]
	@LogId int
AS
BEGIN
	SET NOCOUNT ON;

    --Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(4000);
	
	BEGIN TRAN 

	--Формируем XML с корнем RequestMessage где передадим номер инвойса(в принципе сообщение может быть любым)
	SELECT @RequestMessage = (SELECT LogId
							  FROM dbo.ChangeLog_USER_EVENTS AS LogEvent
							  WHERE LogId = @LogId
							  FOR XML AUTO, root('RequestMessage')); 
	
	
	--Создаем диалог
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//OTUS_projekt/SB/InitiatorService] 
	TO SERVICE
	'//OTUS_projekt/SB/TargetService'   
	ON CONTRACT
	[//OTUS_projekt/SB/Contract]        
	WITH ENCRYPTION=OFF;       

	--отправляем одно наше подготовленное сообщение, но можно отправить и много сообщений, которые будут обрабатываться строго последовательно)
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//OTUS_projekt/SB/RequestMessage]
	(@RequestMessage);
	
	
	--SELECT @RequestMessage AS SentRequestMessage;
	
	COMMIT TRAN 
END
