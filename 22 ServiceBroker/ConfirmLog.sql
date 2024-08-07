USE [OTUS_projekt]
GO
/****** Object:  StoredProcedure [dbo].[ConfirmInvoice]    Script Date: 18.07.2024 16:06:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--ответ на первое ПОКА
ALTER PROCEDURE [dbo].[ConfirmInvoice]
AS
BEGIN
	--Receiving Reply Message from the Target.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER,
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

	    --Получаем сообщение от таргета которое находится у инициатора
		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorQueue; 
		
		END CONVERSATION @InitiatorReplyDlgHandle; --ЭТО второй ПОКА
		
		SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage; --не для прода

	COMMIT TRAN; 
END


