USE [OTUS_projekt]
GO
/****** Object:  StoredProcedure [dbo].[GetNewInvoice]    Script Date: 18.07.2024 16:05:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[GetNewInvoice] 
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@LogID INT,
			@xml XML; 
	
	BEGIN TRAN; 

	
	RECEIVE TOP(1) 
		@TargetDlgHandle = Conversation_Handle, 
		@Message = Message_Body, 
		@MessageType = Message_Type_Name 
	FROM dbo.TargetQueue; 

	SELECT @Message; --не для прода

	SET @xml = CAST(@Message AS XML);

	--достали ИД
	SELECT @LogID = R.Iv.value('@LogId','INT') --тут используется язык XPath и он регистрозависимый в отличии от TSQL
	FROM @xml.nodes('/RequestMessage/LogEvent') as R(Iv);
	select @LogID as LogID --test --не для прода
	IF EXISTS (SELECT * FROM dbo.ChangeLog_USER_EVENTS  WHERE LogID = @LogID)
	BEGIN
		UPDATE dbo.ChangeLog_USER_EVENTS
		SET EventConfirmedForProcessing = GETDATE() 
		WHERE LogID = @LogID;
	END;
	
	SELECT @Message AS ReceivedRequestMessage, @MessageType; --не для прода
	
	-- Confirm and Send a reply
	IF @MessageType=N'//OTUS_projekt/SB/RequestMessage' --если наш тип сообщения
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; --ответ
	    --отправляем сообщение нами придуманное, что все прошло хорошо
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//OTUS_projekt/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle; --А вот и завершение диалога!!! - оно двухстороннее(пока-пока) ЭТО первый ПОКА
		                                   --НЕЛЬЗЯ ЗАВЕРШАТЬ ДИАЛОГ ДО ОТПРАВКИ ПЕРВОГО СООБЩЕНИЯ
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage; --не для прода - это для теста

	COMMIT TRAN;
END