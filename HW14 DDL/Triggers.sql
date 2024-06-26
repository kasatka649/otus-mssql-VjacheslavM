USE [OTUS_projekt]
GO
/****** Object:  Trigger [dbo].[iReagent]    Script Date: 28.05.2024 8:49:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[iReagent]
   ON  [dbo].[Reagent] 
   AFTER INSERT
AS 
BEGIN
	DECLARE @Count int;
	SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;
	SET NOCOUNT ON;

   BEGIN TRY
   	
		DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128),@ID_Reag int,@CURRENT_USER sysname =CURRENT_USER,@HOST_NAME sysname=HOST_NAME()
		SELECT  @ID_Reag=INSERTED.ID_Reag FROM INSERTED
		   SET @ProcName = OBJECT_NAME(@@PROCID)
		   IF @ProcName is null 
				SET @ProcName='iReagent'
		   Print @ProcName
		   SET @SqlCommand='Добавлен реактив' 
		   EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=@ID_Reag,@ID_Batch=0,@ID_Other=0,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
		
    END TRY
    BEGIN CATCH
        EXECUTE [dbo].[uspPrintError];
     
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;

END
USE [OTUS_projekt]
GO
/****** Object:  Trigger [dbo].[uReagent]    Script Date: 28.05.2024 8:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[uReagent]
   ON  [dbo].[Reagent] 
   AFTER UPDATE
AS 
BEGIN
	DECLARE @Count int;
    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;
	SET NOCOUNT ON;

   BEGIN TRY

		
   	 	DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128),@ID_Reag int,@Reag_name NVARCHAR(255),@OldReag_name NVARCHAR(255),@Catalog_num NVARCHAR(20),@OldCatalog_num NVARCHAR(20),@Series_num NVARCHAR(20),@OldSeries_num NVARCHAR(20), @CURRENT_USER  sysname =CURRENT_USER,@HOST_NAME sysname=HOST_NAME()
		SELECT  @ID_Reag=INSERTED.ID_Reag,@Reag_name=INSERTED.Reag_name,@Catalog_num=INSERTED.Catalog_num,@Series_num=INSERTED.Series_num FROM INSERTED
		SELECT  @OldReag_name=DELETED.Reag_name,@OldCatalog_num=DELETED.Catalog_num,@OldSeries_num=DELETED.Series_num FROM DELETED
		
		UPDATE dbo.Reagent 
			SET ModifiedDate=GETDATE()
			WHERE  ID_Reag=@ID_Reag

		IF @OldReag_name<>@Reag_name
		BEGIN
			DECLARE @SqlCommandREAG NVARCHAR(255)
		   SET @SqlCommandREAG='Новое название реактива - ' + @Reag_name +'; '
		END

		IF @Catalog_num<>@OldCatalog_num
		BEGIN
			DECLARE @SqlCommandcATALOG NVARCHAR(255)
			SET @SqlCommandcATALOG='Новый каталожный номер - ' + @Catalog_num +'; '
		END
		IF @Series_num<>@OldSeries_num
		BEGIN
			DECLARE @SqlCommandSeries NVARCHAR(255)
			SET @SqlCommandSeries='Новый номер серии - ' + @Series_num +'; '
		END
			SET @SqlCommand=ISNULL(@SqlCommandREAG,'') +  ISNULL(@SqlCommandcATALOG,'') + ISNULL(@SqlCommandSeries,'')
			IF @SqlCommand=''
				RETURN
			IF @@ROWCOUNT>0
				BEGIN
					SET @ProcName = OBJECT_NAME(@@PROCID)
					IF @ProcName is null 
						SET @ProcName='uReagent'
					EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=@ID_Reag,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
				END

    END TRY
    BEGIN CATCH
        EXECUTE [dbo].[uspPrintError];
     
        IF @@TRANCOUNT > 0
        BEGIN
            SELECT ERROR_NUMBER(),ERROR_MESSAGE()
			ROLLBACK TRANSACTION;
        END
        EXECUTE [dbo].[uspLogError];
    END CATCH;

END
