USE [OTUS_projekt]
GO
/****** Object:  StoredProcedure [dbo].[ADD_Feature]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[ADD_Feature] 	 -- ADD Reagent & related Features
	@Reag_Name nvarchar(255) ,
    @Catalog_num nvarchar(20),
	@Series_num nvarchar(20),
	@ID_Group_Lab int,
	@Notes nvarchar(200)
	,@CURRENT_USER sysname NULL 
	,@HOST_NAME SYSNAME Null 
	,@Cleanliness [nvarchar](50)=''
    ,@Purpose [nvarchar](150)=''
    ,@Storage_conditions [nvarchar](150)=''
    ,@Level_report [nvarchar](50)=''
	,@Storage [nvarchar](50)=''
	

	WITH EXECUTE AS Caller
 AS 

BEGIN
DECLARE @ID_reag int
--@return_status INT,
  SET XACT_ABORT, NOCOUNT ON;
  IF @Reag_Name=NULL  or @Reag_Name=''
			BEGIN
				SELECT 1,'You must give a Reag_Name '
				ROLLBACK TRANSACTION;
				RETURN  1
			END 
    IF exists(select 1 from dbo.Reagent where Reag_Name=@Reag_Name)
		IF exists(select 1 from dbo.Reagent where Catalog_num=@Catalog_num)
			IF exists(select 1 from dbo.Reagent where Series_num=@Series_num)
				BEGIN
					SELECT 2,'Такой реактив уже есть в базе'
					ROLLBACK TRANSACTION;
					RETURN  2
				END
	BEGIN TRY
        BEGIN TRANSACTION;
			INSERT INTO dbo.Reagent
			   (
			   [Reag_Name]
			   ,[Catalog_num]
			   ,[Series_num]
			   )
			 VALUES
			   ( 
				@Reag_Name, 
				@Catalog_num, 
				@Series_num 
	    	   )

	SELECT @ID_reag =SCOPE_IDENTITY() 

	INSERT INTO [dbo].[Feature]
			   (
			   [Cleanliness]
			   ,[Purpose]
			   ,[ID_Group_lab]
			   ,[Storage_conditions]
			   ,[Level_report]
			   ,[ID_reag]
			   ,[Notes]
			   ,[Storage] )
		 VALUES
			   (
			   
			   @Cleanliness,
			   @Purpose, 
			   @ID_Group_lab,
			   @Storage_conditions,
			   @Level_report,
			   @ID_reag,
			   @Notes,
			   @Storage 
			  )
		
		IF @ID_reag>0
			BEGIN
				DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128),@EVENT VARCHAR(50)
					
				SET @EVENT='Добавлен реактив '
		
			   SET @ProcName = OBJECT_NAME(@@PROCID)
			   SET @SqlCommand=@EVENT+TRIM(@Reag_Name)+' ' + TRIM(@Catalog_num) +' ' +TRIM(@Series_num) 
		   
			   EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=@ID_reag,@ID_Batch=0,@ID_Other=0,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
		   
			   SET @SqlCommand='Добавлены свойства реактива:  Чистота: '+@Cleanliness
				+', Назначениие: ' + @Purpose +', код лаборатории - ' +CONVERT(NVARCHAR(3),@ID_Group_Lab)+', Условия хранения: '+@Storage_conditions+
				', Степень отчетности: ' +@Level_report+ ', Место хранения: '+@Storage+', Примечания: '+@Notes
			
				EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=@ID_reag,@ID_Batch=0,@ID_Other=0,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
				SELECT 0 AS 'Successful updating',@EVENT
			END
		ELSE
			BEGIN
				SELECT 3,'NO NEW reagent added'

				
			END
	
	COMMIT TRANSACTION;
    END TRY
		
    BEGIN CATCH
          IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[Add_Manufacturer]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Add_Manufacturer]
 @Manufacturer nvarchar(100)
 ,@CURRENT_USER sysname NULL 
,@HOST_NAME SYSNAME Null 
 AS
 BEGIN
 SET XACT_ABORT, NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
			DECLARE @Manuf_ID int
			

			INSERT INTO [dbo].[Manufacturer]
				(Manufacturer)
			VALUES (@Manufacturer)
			SELECT @Manuf_ID=SCOPE_IDENTITY() 
			
			
		   DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128)
		   SET @ProcName = OBJECT_NAME(@@PROCID)
		   SET @SqlCommand=	'Добавлен изготовитель № '+CONVERT(NVARCHAR(10),@Manuf_ID) +' '+TRIM(@Manufacturer)
		   EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=0,@ID_Batch=0,@ID_Other=@Manuf_ID,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
			IF @Manuf_ID>0
				SELECT 0 as sUCCESSFULL, 'Добавлен изготовитель'
			ELSE
				SELECT 1, 'FAILED'
			
	COMMIT TRANSACTION;
    END TRY
	BEGIN CATCH
        
        IF @@TRANCOUNT > 0
        BEGIN
            SELECT ERROR_NUMBER(),ERROR_MESSAGE()
			ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
	RETURN @Manuf_ID
END
GO
/****** Object:  StoredProcedure [dbo].[Add_Supplier]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Add_Supplier]
 @CompanyName nvarchar(40)
 ,@ContactName nvarchar(30) =''
,@ContactTitle nvarchar(30) =''
,@Address nvarchar(60)  =''
,@City nvarchar(15)  =''
,@Region nvarchar(15)  =''
,@PostalCode nvarchar(10)  =''
,@Country nvarchar(15)  =''
,@Phone nvarchar(24)  =''
,@Fax nvarchar(24)  =''
,@HomePage ntext  =''
,@DirectorName nvarchar(30)  =''
,@NOTE nvarchar(max)  =''
,@EmaiL nvarchar(30)  =''
,@CURRENT_USER sysname NULL
,@HOST_NAME SYSNAME NULL 
 AS
 BEGIN
 SET XACT_ABORT, NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
			DECLARE @ID_Supplier int,@RCOUNT INT

			SELECT @ID_Supplier=ISNULL(MAX(ID_Supplier),0)+1 FROM DBO.SUPPLIERS

			INSERT INTO [dbo].[Suppliers]
						([ID_Supplier]
						,[CompanyName]
						,[ContactName]
						   ,[ContactTitle]
						   ,[Address]
						   ,[City]
						   ,[Region]
						   ,[PostalCode]
						   ,[Country]
						   ,[Phone]
						   ,[Fax]
						   ,[HomePage]
						   ,[DirectorName]
						   ,[NOTE]
						   ,[Email]
						)
					VALUES
						(@ID_Supplier,
						@CompanyName 
					   ,@ContactName
					   ,@ContactTitle
					   ,@Address
					   ,@City
					   ,@Region
					   ,@PostalCode
					   ,@Country
					   ,@Phone
					   ,@Fax
					   ,@HomePage
					   ,@DirectorName
					   ,@NOTE
					   ,@EmaiL
					)
				IF @@ROWCOUNT>0
					BEGIN
					   DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128)
					   SET @ProcName = OBJECT_NAME(@@PROCID)
					   SET @SqlCommand=	'Добавлен поставщик № '+CONVERT(NVARCHAR(10),@ID_Supplier) +' '+TRIM(@CompanyName)
					   EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Other=@ID_Supplier,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
					   SELECT 0 AS 'Successful inserting','Добавлен поставщик'
					END
				ELSE
					SELECT 1,'WARNING: FAILED!!!'
		COMMIT TRANSACTION;
    END TRY
		BEGIN CATCH
  
			IF @@TRANCOUNT > 0
			BEGIN
				SELECT ERROR_NUMBER(),ERROR_MESSAGE()
				ROLLBACK TRANSACTION;
			END

			EXECUTE [dbo].[uspLogError];
		END CATCH;
	
END
GO
/****** Object:  StoredProcedure [dbo].[AddRoleMember]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddRoleMember]
@RoleName sysname,
@emp_id int
,@CURRENT_USER sysname NULL 
,@HOST_NAME SYSNAME Null 
--WITH EXECUTE AS OWNER
AS
BEGIN
    SET XACT_ABORT, NOCOUNT ON;
	DECLARE @STR nvarchar(max),@UserName sysname
	SELECT @UserName=[USER] FROM EMPLOYEE WHERE emp_id=@emp_id
	
    IF NOT EXISTS (SELECT 1 FROM sys.database_role_members AS drm
                            INNER JOIN sys.database_principals AS dpr
                            ON drm.role_principal_id = dpr.principal_id
                            AND dpr.type = N'R'
                            INNER JOIN sys.database_principals AS dpu
                            ON drm.member_principal_id = dpu.principal_id
                            AND dpu.type = N'S'
                            WHERE dpr.name = @RoleName
                            AND dpu.name = @UserName)
		BEGIN	
				BEGIN TRY
						BEGIN TRANSACTION;
							DECLARE @SQL nvarchar(max) = N'ALTER ROLE ' + QUOTENAME(@RoleName)
													   + N' ADD MEMBER ' + QUOTENAME(@UserName) + N';'
							
							EXEC sp_executesql @SQL;
							IF @RoleName='DB_admin'
								BEGIN
									SET @SQL=N'USE master;
											GRANT CONTROL SERVER TO ' + QUOTENAME(@UserName) +N';'
								
									EXEC sp_executesql @SQL;
								END
					
							UPDATE EMPLOYEE SET RoleMember=@RoleName WHERE  emp_id=@emp_id
							IF @@ROWCOUNT>0
								BEGIN

								   DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128)
								   SET @ProcName = OBJECT_NAME(@@PROCID)
								   SET @SqlCommand='Добавлен оператор БД  '+@UserName +' в группу '+@RoleName 
								   EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Other=@emp_id,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
	    							SELECT 0 AS 'Successfull inserting',@SqlCommand
								END
							ELSE
								SELECT 1,'Unable to add user ' + @UserName + N' to role ' + @RoleName

						COMMIT TRANSACTION;
						END TRY
						BEGIN CATCH
							IF @@TRANCOUNT > 0
								BEGIN
									SELECT   ERROR_NUMBER(), ERROR_MESSAGE()
									ROLLBACK TRANSACTION;
								END
							EXECUTE [dbo].[uspLogError];
           				END CATCH;
		END	
	ELSE 
		BEGIN
			SET @STR=N' The User ' + @UserName + N' already exists  in the '+ @RoleName+' group' 
			--PRINT @STR
			SELECT 2, @STR
		END

END
GO
/****** Object:  StoredProcedure [dbo].[DropRoleMember]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DropRoleMember]
@RoleName sysname,
@emp_id int
 ,@CURRENT_USER sysname 
 ,@HOST_NAME sysname 
--WITH EXECUTE AS OWNER
AS
BEGIN
    SET XACT_ABORT, NOCOUNT ON;
	DECLARE @STR nvarchar(max),@UserName sysname
	SELECT @UserName=[USER] FROM EMPLOYEE WHERE emp_id=@emp_id
    IF EXISTS (SELECT 1 FROM sys.database_role_members AS drm
                            INNER JOIN sys.database_principals AS dpr
                            ON drm.role_principal_id = dpr.principal_id
                            AND dpr.type = N'R'
                            INNER JOIN sys.database_principals AS dpu
                            ON drm.member_principal_id = dpu.principal_id
                            AND dpu.type = N'S'
                            WHERE dpr.name = @RoleName
                            AND dpu.name = @UserName)
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION;
					DECLARE @SQL nvarchar(max) = N'ALTER ROLE ' + QUOTENAME(@RoleName)
											   + N' DROP MEMBER ' + QUOTENAME(@UserName) + N';'
					--EXECUTE (@SQL);
					EXEC sp_executesql @SQL;
					IF @RoleName='DB_admin'
								BEGIN
									SET @SQL=N'USE master;
										DENY  CONTROL SERVER TO ' + QUOTENAME(@UserName) +N';'
									--EXECUTE (@SQL);
									EXEC sp_executesql @SQL;
								END
					IF EXISTS(SELECT 1 FROM sys.database_role_members AS drm
									INNER JOIN sys.database_principals AS dpr
									ON drm.role_principal_id = dpr.principal_id
									AND dpr.type = N'R'
									INNER JOIN sys.database_principals AS dpu
									ON drm.member_principal_id = dpu.principal_id
									AND dpu.type = N'S'
									WHERE dpu.name = @UserName
									AND dpr.principal_id IN (SELECT max(dpr.principal_id) 
									FROM sys.database_role_members AS drm
									INNER JOIN sys.database_principals AS dpr
									ON drm.role_principal_id = dpr.principal_id
									AND dpr.type = N'R'
									INNER JOIN sys.database_principals AS dpu
									ON drm.member_principal_id = dpu.principal_id
									AND dpu.type = N'S'
									WHERE dpu.name = @UserName))
						BEGIN
							SELECT @RoleName= dpr.[name] FROM sys.database_role_members AS drm
									INNER JOIN sys.database_principals AS dpr
									ON drm.role_principal_id = dpr.principal_id
									AND dpr.type = N'R'
									INNER JOIN sys.database_principals AS dpu
									ON drm.member_principal_id = dpu.principal_id
									AND dpu.type = N'S'
									WHERE dpu.name = @UserName
									AND dpr.principal_id IN (SELECT max(dpr.principal_id) 
									FROM sys.database_role_members AS drm
									INNER JOIN sys.database_principals AS dpr
									ON drm.role_principal_id = dpr.principal_id
									AND dpr.type = N'R'
									INNER JOIN sys.database_principals AS dpu
									ON drm.member_principal_id = dpu.principal_id
									AND dpu.type = N'S'
									WHERE	dpu.name = @UserName)
						END
				ELSE
					BEGIN
						SET  @RoleName=''
					END
					UPDATE EMPLOYEE SET RoleMember=@RoleName WHERE emp_id=@emp_id
					IF @@ROWCOUNT>0
						BEGIN
							DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128)
							SET @ProcName = OBJECT_NAME(@@PROCID)
							SET @SqlCommand='Перемещен оператор БД  '+@UserName +' в группу '+@RoleName 
							EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Other=@emp_id,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
	    					SELECT 0 AS 'Successfull inserting',@SqlCommand
						END
							ELSE
								SELECT 1,'Unable to drop user ' + @UserName + N' from role ' + @RoleName
				COMMIT TRANSACTION;
			END TRY
				BEGIN CATCH
     
					IF @@TRANCOUNT > 0
						BEGIN
							SELECT   ERROR_NUMBER(), ERROR_MESSAGE()
							ROLLBACK TRANSACTION;
						END
					EXECUTE [dbo].[uspLogError];
        
				END CATCH;
		END;
	ELSE
		BEGIN
			SET @STR=N' The User ' + @UserName + N' does not exists in the '+ @RoleName+' group' 
			SELECT 2, @STR
		END
END;
GO
/****** Object:  StoredProcedure [dbo].[spAdd_Batch]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spAdd_Batch]

	  @ID_Reag int,
      @Qty decimal(18,3),
      @UnitMeasureCode nchar(5),
	  @Date_of_receipt date=NULL, --Дата поступления
      @ID_Supplier int ,  
      @Date_of_expiration date  =NULL, --Годен до
      @Notes nvarchar(250) ='' ,
	  @Manuf_ID int =NULL,
	  @DateManuf date =NULL, --Дата изготовления,
	  @Manuf nvarchar(40)='',
	  @IsDateExpiration bit,
	  @QtyOnebottle int, --кол-во реактива в условном флаконе
	  @UnitMeasureOneBottle nchar(5) --ед. измер. реактива в условном флаконе
	  ,@IsQuantitative bit=0
	 ,@CURRENT_USER sysname NULL
	 ,@HOST_NAME sysname NULL 
AS
BEGIN

SET XACT_ABORT, NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
			DECLARE @SqlCommand varchar(max)='', @ProcName NVARCHAR(128),@EVENT VARCHAR(50), @Batch_ID int
			IF @Manuf<>'' 
			BEGIN
				IF NOT EXISTS (SELECT 1 FROM Manufacturer WHERE Manufacturer=@Manuf)
					BEGIN
						EXEC @Manuf_ID=Add_Manufacturer @Manuf
						PRINT 'NEW Manufacturer WAS ADDED'
					END
				ELSE
					SELECT @Manuf_ID=Manuf_ID FROM Manufacturer WHERE Manufacturer=@Manuf
			END
			IF @Manuf_ID=0 
				SET @Manuf_ID=NULL
			IF @Date_of_receipt='' OR @Date_of_receipt=NULL
				BEGIN
					SET @Date_of_receipt=NULL
					SET @SqlCommand='Дата получения:не указана'
				END
			ELSE
				BEGIN
					SET @SqlCommand='Дата получения: '+convert(nvarchar(10),@Date_of_receipt)
					IF @Date_of_receipt>GETDATE() 
						BEGIN
							SELECT 2,' Дата получения больше текущей даты '
							ROLLBACK TRANSACTION; 
							RETURN 2
						END
				END

				IF @Date_of_expiration='' OR @Date_of_expiration=NULL
					BEGIN
						SET @Date_of_expiration=NULL
						SET @SqlCommand=@SqlCommand+' Срок хранения:не указан '
					END
				ELSE
					BEGIN
						SET @SqlCommand=@SqlCommand +' Срок хранения: '+convert(nvarchar(10),@Date_of_expiration)
						IF @Date_of_expiration<@Date_of_receipt
						BEGIN
							SELECT 4,'Дата ХРАНЕНИЯ больше даты ПОЛУЧЕНИЯ'
							ROLLBACK TRANSACTION; 
							RETURN 4
						END
					END

			IF @DateManuf='' OR @DateManuf=NULL
				BEGIN
					SET @DateManuf=NULL
					SET @SqlCommand=@SqlCommand + ' Дата изготовления:не указана'
				END
			ELSE
				BEGIN
					SET @SqlCommand=@SqlCommand+' Дата изготовления: '+convert(nvarchar(10),@DateManuf)
					IF @DateManuf>GETDATE() 
						BEGIN
							SELECT 1,'Дата изготовления больше текущей даты'
							ROLLBACK TRANSACTION; 
							RETURN 1
						END
				END
			
			IF NOT EXISTS (SELECT 1 FROM Suppliers WHERE ID_Supplier=@ID_Supplier)
					BEGIN
						SELECT 6,'Поставщик не найден'
						ROLLBACK TRANSACTION;
						RETURN 6
					END

			--IF (@QtyOnebottle=0 OR @QtyOnebottle IS NULL)
			--	BEGIN
			--			SELECT 7,'Для флакона должен быть указан объем и ед. измерения'
			--			--ROLLBACK TRANSACTION;
			--			RETURN 7
			--	END
			INSERT INTO [dbo].[Batch]
				   (
				   [ID_Reag]
				   ,[Qty]
				   ,UnitMeasureCode
				   ,[Date_of_receipt]
				   ,[ID_Supplier]
				   ,[Date_of_expiration]
				   ,[Notes]
				   ,Manuf_ID
				   ,DateManuf
				   ,Initial_qty
				   ,IsDateExpiration
				   ,IsQuantitative)
			 VALUES
				(  	@ID_Reag ,
					@Qty ,
					@UnitMeasureCode ,
					@Date_of_receipt ,
					@ID_Supplier ,
					@Date_of_expiration ,
					@Notes ,
					@Manuf_ID ,
					@DateManuf,
					@Qty,
					@IsDateExpiration,
					@IsQuantitative)

			SELECT @Batch_ID= SCOPE_IDENTITY()  
		
		IF @Batch_ID>0
		BEGIN
				--IF @UnitMeasureCode='флак'
				IF @QtyOnebottle>0
				BEGIN
					DECLARE @n int=0
					WHILE @n<  @Qty
					BEGIN  
					   INSERT INTO SubBatch
								( batch_id,
								qty,
								UnitMeasureCode,
								Initial_qty)
						VALUES
							(	@Batch_ID,
								@QtyOnebottle ,
								@UnitMeasureOneBottle ,
								@QtyOnebottle )
				   SET @n=@n+1
					   IF @n>@Qty
						  BREAK  
					   ELSE  
						  CONTINUE  
					END   
				END
				
				SET @SqlCommand='Добавлена партия '
				SET @ProcName = OBJECT_NAME(@@PROCID)
				SET @SqlCommand=@SqlCommand+ CONVERT(NVARCHAR(5),@Batch_ID)+ ', '+CONVERT(NVARCHAR(10),@Qty)+ ' '+@UnitMeasureCode +
				', Примечание: '+@Notes +', ID Изготовителя: '+convert(nvarchar(10),ISNULl(@Manuf_ID,0)) 	

				EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=@ID_reag,@ID_Batch=@Batch_ID,@ID_Other=@ID_Supplier,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
				SELECT 0 AS 'Successful insertion',@SqlCommand
			END
		 ELSE
				SELECT 5 AS Failed, 'Warning! No rows have been added'
		COMMIT TRANSACTION;
    END TRY
	BEGIN CATCH
       
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
            ROLLBACK TRANSACTION;
        END
        EXECUTE [dbo].[uspLogError];
    END CATCH;
	
END
GO
/****** Object:  StoredProcedure [dbo].[spAdd_Document]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spAdd_Document]

	@Name_doc nvarchar(250) =null,
	@TYPE_doc int  ,
	@Year nchar (4) =NULL,
	@Path_doc nvarchar(250) ,
	@ID_Reag int ,
	@Notes nvarchar(250) =NULL,
	@Descript nvarchar(250) =NULL
	,@CURRENT_USER sysname NULL
	,@HOST_NAME SYSNAME NULL 
AS
BEGIN
DECLARE  @SqlCommand varchar(max), @ProcName NVARCHAR(128),@Rcount int, @NameTypeDoc NVARCHAR (10)
	SET XACT_ABORT, NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

   			INSERT INTO [dbo].[Documents]
				   (
				   [Name_doc]
				   ,[TYPE_doc]
				   ,[Year]
				   ,[Path_doc]
				   ,[ID_Reag]
				   ,Notes
				   ,Descript)
			 VALUES
				   (
				   @Name_doc
				   ,@TYPE_doc
				   ,@Year
				   ,@Path_doc
				   ,@ID_Reag
				   ,@Notes 
				   ,@Descript 
				   )
				  
				 DECLARE @id_doc INT
				SELECT @id_doc= SCOPE_IDENTITY() 
				SELECT @NameTypeDoc=NameTypeDoc FROM TypeDoc WHERE ID_TYPE_DOC=@TYPE_doc
				IF @@ROWCOUNT>0
					BEGIN				
					   SET @ProcName = OBJECT_NAME(@@PROCID)
					   SET @SqlCommand=	'Добавлен документ № '+CONVERT(NVARCHAR(10),@id_doc) + ', Тип документа:'+@NameTypeDoc+', Наименование:' +@Name_doc+ ', Год: '+ @Year +
					   ', Файл -'+ @Path_doc+', Примечание:'+@Notes+', Описание:'+@Descript	
					   EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=@ID_reag,@ID_Batch=0,@ID_Other=@id_doc,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
					   SELECT 0 AS 'Result of UPDATE','Добавлен документ'
					END
				ELSE
					SELECT 1 , 'Failure'
					
		COMMIT TRANSACTION;
    END TRY
	BEGIN CATCH
        
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END
GO
/****** Object:  StoredProcedure [dbo].[spAdd_Employee]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spAdd_Employee]

        @fname varchar(20) NULL,
        @minit varchar(20) NULL,
        @lname varchar(30),
     @job_id int,
        --@job_lvl tinyint=NULL,
        --@hire_date datetime=NULL,
		@User nvarchar (20) Null,
		@emp_id INT OUT,
		@Pswd varchar(50)
		,@CURRENT_USER sysname NULL
	    ,@HOST_NAME SYSNAME NULL 
AS
BEGIN
SET XACT_ABORT, NOCOUNT ON;
DECLARE @RoleMember nvarchar(50),@EmpIDAdm int,@RCount int --,@TempPswd varchar(7)
		SET @RoleMember='DB_User'
		IF CURRENT_USER='dbo'
			SET @EmpIDAdm=0
		ELSE
			SELECT @EmpIDAdm=emp_ID from employee where [user]=CONVERT(sysname, CURRENT_USER)


    BEGIN TRY
        BEGIN TRANSACTION;
INSERT INTO [dbo].[employee]
           (
           [fname]
           ,[minit]
           ,[lname]
           ,[job_id]
           --,[job_lvl]
           --,[hire_date]
		   ,[user]
		   ,RoleMember
		   ,IsPermittedToLogon
		   ,LastEditedBy
		   
		   )
     VALUES
           (
		    @fname ,
			@minit ,
			@lname ,
          @job_id, 
			--@job_lvl,
			--@hire_date,
			@User,
			@RoleMember,
			0,
			@EmpIDAdm
			)
			SELECT @emp_id=SCOPE_IDENTITY() 

		
		DECLARE @salt UNIQUEIDENTIFIER=NEWID()
		INSERT INTO EmpPs (Emp_id,PSWD,HPSWD,salt) VALUES (@emp_id,@Pswd,HASHBYTES('SHA2_512', @Pswd+CAST(@salt AS NVARCHAR(36))),@salt)
		
		INSERT INTO UserActive (Emp_id) VALUES (@emp_id)
		IF @@rowcount>0
			BEGIN
				DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128)
				SET @ProcName = OBJECT_NAME(@@PROCID)
				SET @SqlCommand=	'Добавлен сотрудник № '+convert(nvarchar(6),@emp_id)+ ' - '+@lname+ ' '+ @fname +', Login - '+@User
				EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=0,@ID_Batch=0,@ID_Other=@emp_id,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
				SELECT 0 AS 'successful addition','Добавлен сотрудник'
			END
		ELSE
				SELECT 1, 'Failed' 
				
		COMMIT TRANSACTION;
    END TRY
	BEGIN CATCH
        
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
            ROLLBACK TRANSACTION;
        END
        EXECUTE [dbo].[uspLogError];
    END CATCH;
END
GO
/****** Object:  StoredProcedure [dbo].[spAdd_User2]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spAdd_User2]
	@membername     sysname='TST',
	@Lname nvarchar(30)='Testov',
	@Fname nvarchar(20)='Test',
	@Minit nvarchar(20)='Testovich'
	,@Job_id int=0
	,@CURRENT_USER sysname 
    ,@HOST_NAME sysname  
	--WITH EXECUTE AS owner
	AS
BEGIN

SET XACT_ABORT, NOCOUNT ON;
	DECLARE  	@rolename   sysname='DB_USER',
				@stmtR		nvarchar(4000),
				@emp_id int=0,
				@Pswd nvarchar(15)='Lbr524', -- = Lbr + (Текущий Месяц Май-5) + (Текущий Год-24)
				@ParmDefinition nvarchar(500);

	IF EXISTS(SELECT 1 FROM employee WHERE job_id=@Job_id)
	BEGIN
		SELECT 2 AS 'FAILURE' , 'У сотрудника с этим ID уже есть уч. запись в БД LabNeo_Reagent!'
		RETURN 
	END
	BEGIN TRY
        BEGIN TRANSACTION;
			
			SET @stmtR = 'CREATE LOGIN '+ QUOTENAME(@membername, ']') + ' WITH PASSWORD= N'''+@Pswd+''' MUST_CHANGE, DEFAULT_DATABASE=[LabNeo_Reagent],CHECK_EXPIRATION=on, CHECK_POLICY=ON';
			SET @ParmDefinition = N'@Pswd nvarchar(15), @membername sysname';
			SET @Pswd='Lbr'+convert(nvarchar(2),MONTH(GETDATE()))+CONVERT(nvarchar(2),Right(YEAR(GETDATE()),2))
			EXEC sp_executesql @stmtR,
				@ParmDefinition,
				@Pswd=@Pswd,
				@membername = @membername;

			SET @stmtR = 'CREATE USER '+ QUOTENAME(@membername, ']') + ' FOR LOGIN '++ QUOTENAME(@membername, ']') + ' WITH DEFAULT_SCHEMA=[dbo]'
			SET @ParmDefinition = N'@membername sysname';
			EXEC sp_executesql @stmtR,
				@ParmDefinition,
				@membername = @membername;

			SET @stmtR = 'ALTER ROLE '+ QUOTENAME(@rolename, ']')+ ' ADD MEMBER '+ QUOTENAME(@membername, ']')
			SET @ParmDefinition = N'@rolename sysname, @membername sysname';
			
			EXEC sp_executesql @stmtR,
				@ParmDefinition,
				@rolename=@rolename,
				@membername = @membername;
			
			EXEC dbo.spAdd_Employee @Job_id=@Job_id, @lname=@Lname ,	@Fname=@Fname ,	@Minit=@Minit ,@user=@membername ,@emp_id=@emp_id OUTPUT,
			@Pswd=@Pswd,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
	
		DECLARE @SqlCommand nvarchar(max), @ProcName nvarchar(128)
				   SET @ProcName = OBJECT_NAME(@@PROCID)
				   SET @SqlCommand=	'Создана уч. запись с ID- '+convert(nvarchar(6),@emp_id)+ ', Login - '+@membername
				   EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Other=@emp_id,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
				   IF @emp_id>0
						select 0 AS 'successfully' , 'Добавлен пользователь в БД LabNeo_Reagent. Временный пароль - '+@Pswd
					ELSE
						select 1 , 'FAILURE'

		COMMIT TRANSACTION;
    END TRY
	BEGIN CATCH
        
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT   ERROR_NUMBER(), ERROR_MESSAGE()
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END
GO
/****** Object:  StoredProcedure [dbo].[spAddLab]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[spAddLab]
 @Lab nvarchar(100),
 @Room nvarchar(6)=''
 ,@CURRENT_USER sysname NULL
 ,@HOST_NAME SYSNAME NULL 

 AS
 BEGIN
 SET XACT_ABORT, NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
			DECLARE @ID_Group_Lab int,@rcount int,@DepartmentID int
			IF EXISTS(SELECT 1 FROM LabNeo_IT.dbo.vDepartment WHERE Department=@LAB)
				SELECT @ID_Group_Lab=DepartmentID FROM LabNeo_IT.dbo.vDepartment WHERE Department=@LAB
			ELSE
				SELECT @ID_Group_Lab=ISNULL(MAX(ID_Group_Lab),0)+1 FROM dbo.Group_Lab
			
			INSERT INTO [dbo].Group_Lab
							(	ID_Group_Lab,
								Name_Gr_Lab,
								Room )
					VALUES
						(	@ID_Group_Lab,
							@Lab,	
							@Room	)
			
			IF @@ROWCOUNT >0
			BEGIN
				DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128)
				   SET @ProcName = OBJECT_NAME(@@PROCID)
				   SET @SqlCommand=	'Добавлена Лаборатория № '+CONVERT(NVARCHAR(10),@ID_Group_Lab) +' Название: '+@Lab+', Помещение:'+ @Room	
				   EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Other=@ID_Group_Lab,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
		    		SELECT 0 AS 'Successfull inserting','Добавлена Лаборатория'
			END
			ELSE
				SELECT 1 , 'WARNINNG: FAILED!!!'
		COMMIT TRANSACTION;
    END TRY
	BEGIN CATCH
        
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END
GO
/****** Object:  StoredProcedure [dbo].[spAddUnitMeasure]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spAddUnitMeasure]
 @UnitMeasureCode nvarchar(5),
 @Name nvarchar(50)
 ,@IsQuantitative bit=0
 ,@CURRENT_USER sysname NULL
 ,@HOST_NAME SYSNAME NULL 
 AS
 BEGIN
 SET XACT_ABORT, NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
			DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128)

			IF EXISTS (SELECT 1 FROM UnitMeasure WHERE UnitMeasureCode=@UnitMeasureCode)
				BEGIN
					EXEC spUPDUnitMeasure @UnitMeasureCode=@UnitMeasureCode,  @NameUnMes=@Name  , @IsQuantitative=@IsQuantitative, @CURRENT_USER=@CURRENT_USER  ,@HOST_NAME =@HOST_NAME
					
				END
			ELSE
			BEGIN
				INSERT INTO [dbo].[UnitMeasure]
				   ( [UnitMeasureCode]
				   ,[Name] 
				   ,IsQuantitative)
					VALUES
				   (@UnitMeasureCode 
				   ,@Name
				   ,@IsQuantitative)
				END
		   IF @@rowcount>0
			   BEGIN
				   SET @SqlCommand='Добавлена ед. измерения '+ @UnitMeasureCode +'- '+TRIM(@Name)
				   SET @ProcName = OBJECT_NAME(@@PROCID)
				   EXEC spADDEventLog @SqlCommand,@ProcName,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
				   SELECT 0 AS 'SUCCESSFULL  inserting','Добавлена ед. измерения '
			   END
		   ELSE
				SELECT 1 , 'WARNINNG: FAILED!!!'

		COMMIT TRANSACTION;
    END TRY
	BEGIN CATCH
        
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER() AS ErrNum,ERROR_MESSAGE() AS ErrMSG
            ROLLBACK TRANSACTION;
        END
        EXECUTE [dbo].[uspLogError];
    END CATCH;
	--RETURN 0
END
GO
/****** Object:  StoredProcedure [dbo].[spChangePassword]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spChangePassword]
@LOGON NVARCHAR(20),
@OldPSWD nvarchar(40),
@NewPSWD nvarchar(40)
,@HOST_NAME SYSNAME NULL 
--WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
	 BEGIN TRY
        BEGIN TRANSACTION;
			DECLARE @Emp_ID INT,@SqlCommand NVARCHAR(MAX),@ProcName NVARCHAR(128),@salt UNIQUEIDENTIFIER=NEWID()
			SELECT @Emp_ID=Emp_ID FROM EMPLOYEE WHERE [USER]=@LOGON

			SET @SqlCommand = 'ALTER LOGIN '+ quotename(@LOGON, ']') +' WITH PASSWORD = '''+@NewPSWD +''' OLD_PASSWORD = '''+@OldPSWD+''''
					EXEC (@SqlCommand)
			SELECT @salt=salt FROM EmpPs WHERE Emp_ID = @Emp_ID 
			UPDATE EmpPs
			SET  
				PSWD=@NewPSWD,
				HPswd = HASHBYTES('SHA2_512', @NewPSWD+CAST(@salt AS NVARCHAR(36))),
				SALT=@SALT
				WHERE Emp_ID = @Emp_ID
				AND HPswd = HASHBYTES('SHA2_512', @OldPSWD+CAST(@salt AS NVARCHAR(36)));
				
				IF @@rowcount>0
				BEGIN
					SET @ProcName = OBJECT_NAME(@@PROCID)
					SET @SqlCommand=	'Пароль изменен, USER:' +@LOGON 
					EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@CURRENT_USER=@LOGON,@HOST_NAME=@HOST_NAME
					SELECT 0 AS 'Success ','Пароль изменен'
				END
				ELSE
					SELECT 1 , 'WARNINNG: FAILED!!!Возможно, пароль изменен, но не внесена информация в таблицу паролей!'

		COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
       
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[spDEL_Batch]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDEL_Batch] 
			@Batch_ID int
			,@CURRENT_USER sysname NULL
			,@HOST_NAME sysname NULL 
AS
BEGIN
	SET XACT_ABORT, NOCOUNT ON;
	
	BEGIN TRY
        BEGIN TRANSACTION;
			DECLARE @id_reag INT 
			SELECT @id_reag=ID_reag FROM dbo.BATCH WHERE Batch_ID=@BATCH_ID
			IF EXISTS(select 1 from SubBatch where Batch_ID=@BATCH_ID)
				DELETE FROM SubBatch WHERE Batch_ID=@BATCH_ID

			DELETE FROM Batch WHERE Batch_ID=@BATCH_ID
			IF @@ROWCOUNT>0
				BEGIN
				   DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128),@EVENT VARCHAR(50)
				   SET @EVENT='Удалена партия '
				   SET @ProcName = OBJECT_NAME(@@PROCID)
				   SET @SqlCommand=	@EVENT+ CONVERT(NVARCHAR(5),@Batch_ID)
				   EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=@ID_reag,@ID_Batch=@Batch_ID,@ID_Other=0,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
				   SELECT 0 AS 'Successful deletion',@EVENT
				END
			ELSE
				BEGIN
					SELECT 2,'THERE IS NO BATCH WITH THIS ID'
					RETURN 2
				END

		COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
       
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
			RAISERROR ('CHECK FOR RELATED UTILIZATIONS BEFORE DELETING THE Batch', 16, 1);
            ROLLBACK TRANSACTION;
        END
        EXECUTE [dbo].[uspLogError];
    END CATCH;

END
GO
/****** Object:  StoredProcedure [dbo].[spDEL_Doc]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spDEL_Doc] 
			@ID_Doc int
			,@CURRENT_USER sysname NULL
			,@HOST_NAME SYSNAME NULL 
AS
BEGIN

	SET XACT_ABORT, NOCOUNT ON;
		
	BEGIN TRY
        BEGIN TRANSACTION;
			DECLARE @ID_REAG int,@RCount int
			IF NOT EXISTS(SELECT 1 FROM dbo.Documents WHERE ID_Doc=@ID_Doc)
			BEGIN
				SELECT 2 AS FAILURE, 'Нет документа с таким ID'
				RETURN 2
			END
			SELECT @ID_REAG=ID_REAG FROM dbo.Documents WHERE ID_Doc=@ID_Doc
			DELETE dbo.Documents WHERE ID_Doc=@ID_Doc
			IF @@rowcount>0
				BEGIN
					DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128)
					SET @ProcName = OBJECT_NAME(@@PROCID)
					SET @SqlCommand=	'Удален документ ' + CONVERT(NVARCHAR(5),@ID_Doc)
					EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=@ID_reag,@ID_Batch=0,@ID_Other=@ID_Doc,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
					SELECT 0 AS 'Successful deletion','Удален документ'
				END
			ELSE
				BEGIN
					SELECT 1 AS FAILURE, 'Warning! No deleted documents!'
					ROLLBACK TRANSACTION;
					RETURN 1
				END

		COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
       
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
			ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;

END
GO
/****** Object:  StoredProcedure [dbo].[spDel_Employee]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spDel_Employee]

		@emp_id INT
		,@CURRENT_USER sysname NULL
		,@HOST_NAME SYSNAME NULL 
AS
BEGIN

SET XACT_ABORT, NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128),@USER_NAME NVARCHAR(20),@Rcount int
		SELECT @USER_NAME= [USER] FROM employee WHERE emp_id=@emp_id
		SET @SqlCommand = 'DROP USER '+ quotename(@USER_NAME, ']') 

		EXEC (@SqlCommand)
		SET @SqlCommand = 'DROP LOGIN '+ quotename(@USER_NAME, ']') 
		EXEC (@SqlCommand)
		DELETE [dbo].[USERActive] WHERE emp_id=@emp_id
		DELETE [dbo].[emppS] WHERE emp_id=@emp_id
		DELETE [dbo].[employee] WHERE emp_id=@emp_id
		IF @@ROWCOUNT>0
		BEGIN
		   SET @ProcName = OBJECT_NAME(@@PROCID)
		   SET @SqlCommand=	'Удален сотрудник № '+CONVERT(NVARCHAR(10),@emp_id) +', USER:' +@USER_NAME
		   EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=0,@ID_Batch=0,@ID_Other=@emp_id,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
			SELECT 0 AS 'Successful deletion','Удален сотрудник'
		END
		Else 
			SELECT 1,'WARNING!The employee was not deleted'

		COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
       
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END
GO
/****** Object:  StoredProcedure [dbo].[spDEL_Reagent]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDEL_Reagent] 
			@ID_Reag int
			,@CURRENT_USER sysname NULL
			,@HOST_NAME SYSNAME NULL 
AS
BEGIN
	SET XACT_ABORT, NOCOUNT ON;
		
	BEGIN TRY
        BEGIN TRANSACTION;
	
			DECLARE @MaxID_DOC int
			DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128),@EVENT VARCHAR(50)
			WHILE EXISTS (SELECT 1 FROM dbo.DOCUMENTS WHERE ID_reag=@ID_reag ) 
					BEGIN  
					   SELECT @MaxID_DOC=MAX(ID_DOC) FROM dbo.DOCUMENTS WHERE ID_reag=@ID_reag
					   DELETE  dbo.DOCUMENTS WHERE ID_DOC=@MaxID_DOC
					   IF EXISTS (SELECT 1 FROM dbo.DOCUMENTS WHERE ID_reag=@ID_reag )  
						    CONTINUE
					   ELSE  
						    BREAK
					END  
					
				DELETE dbo.Reagent WHERE ID_Reag=@ID_Reag
			IF @@ROWCOUNT>0
			BEGIN
					SET @EVENT='Удален реактив '
					SET @ProcName = OBJECT_NAME(@@PROCID)
 				    EXEC spADDEventLog @SqlCommand=@EVENT,@Source=@ProcName,@ID_Reag=@ID_reag,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
					SELECT 0 AS 'Successful deletion',@EVENT
				END
			ELSE
					SELECT 2,'THERE IS NO REAGENT WITH THIS ID'
		
				
		COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
			RAISERROR ('CHECK FOR RELATED Batches BEFORE DELETING THE Reagent', 16, 1);
            ROLLBACK TRANSACTION;
        END
        EXECUTE [dbo].[uspLogError];
    END CATCH;
END
GO
/****** Object:  StoredProcedure [dbo].[spDELLab]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spDELLab] 
			@ID_Group_Lab int
		   ,@CURRENT_USER sysname NULL
		   ,@HOST_NAME SYSNAME NULL 
AS
BEGIN

	SET XACT_ABORT, NOCOUNT ON;
		IF EXISTS (SELECT 1 FROM FEATURE WHERE ID_Group_Lab=@ID_Group_Lab)
			begin
				SELECT 1,'Rejected. Perhaps this Laboratory is associated with some reagents. CHECK FOR RELATED REAGENTS BEFORE DELETING THE LAB'
				ROLLBACK TRANSACTION;
				RETURN 1
			END
	BEGIN TRY
        BEGIN TRANSACTION;
			
			DELETE DBO.Group_Lab WHERE ID_Group_Lab=@ID_Group_Lab
			
			  IF @@ROWCOUNT>0
				BEGIN
				   DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128),@EVENT VARCHAR(50)
				   SET @EVENT='Удалена лаборатория '
				   SET @ProcName = OBJECT_NAME(@@PROCID)
				   SET @SqlCommand=	@EVENT + ' № ' +CONVERT(NVARCHAR(5),@ID_Group_Lab)
				   EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=0,@ID_Batch=0,@ID_Other=@ID_Group_Lab,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
		        	SELECT 0 AS 'Successful deletion',@EVENT
				END
			 ELSE
				
					SELECT 2,'THERE IS NO Laboratory WITH THIS ID'
				
		COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
       
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
			RAISERROR ('CHECK FOR RELATED REAGENTS BEFORE DELETING THE LAB', 16, 1);
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
	SELECT 0
END
GO
/****** Object:  StoredProcedure [dbo].[spDELManufacturer]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spDELManufacturer] 
			@Manuf_ID int
			,@CURRENT_USER sysname NULL
			,@HOST_NAME SYSNAME NULL 
AS
BEGIN
	SET XACT_ABORT, NOCOUNT ON;
		IF exists (select 1 from dbo.BATCH where Manuf_ID=@Manuf_ID)
		BEGIN
				select 1, 'Этот изготовитель уже есть в некоторых партиях реактивов'
				ROLLBACK TRANSACTION;
				RETURN 1
		END
	BEGIN TRY
        BEGIN TRANSACTION;
			DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128),@EVENT VARCHAR(50)
			DELETE Manufacturer WHERE  Manuf_ID=@Manuf_ID
			IF @@rowcount>0			 	
				BEGIN
				   SET @EVENT='Удален изготовитель '
				   SET @ProcName = OBJECT_NAME(@@PROCID)
				   SET @SqlCommand=	@EVENT+ CONVERT(NVARCHAR(5),@Manuf_ID)
				   EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Other=@Manuf_ID,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
				   SELECT 0 AS 'Successful deletion',@EVENT
				END
			ELSE
				BEGIN
					SELECT 2,'THERE IS NO MANUFACTURER WITH THIS ID'
				END
		COMMIT TRANSACTION;
    END TRY
    
	BEGIN CATCH
       
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
			RAISERROR ('CHECK FOR RELATED BATCHES BEFORE DELETING THE MANUFACTURER', 16, 1);
            ROLLBACK TRANSACTION;
        END
		
        EXECUTE [dbo].[uspLogError];
    END CATCH;
	
END
GO
/****** Object:  StoredProcedure [dbo].[spDELSupplier]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spDELSupplier] 
			@ID_Supplier int,
			@CURRENT_USER sysname ='testuser', 
			@HOST_NAME SYSNAME ='testPC' 
  
AS
BEGIN
	SET XACT_ABORT, NOCOUNT ON;
		IF exists (select 1 from dbo.BATCH where ID_Supplier=@ID_Supplier)
		BEGIN
				select 1,'Rejected. Perhaps this supplier is associated with batches of reagents.'
				RETURN 1
		END
	BEGIN TRY
        BEGIN TRANSACTION;
			
			DELETE Suppliers WHERE  ID_Supplier=@ID_Supplier
			
			 IF @@ROWCOUNT>0
				BEGIN
					DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128),@EVENT VARCHAR(50)
					
					SET @EVENT='Удален поставщик '
				    SET @ProcName = OBJECT_NAME(@@PROCID)
				    SET @SqlCommand=@EVENT	+ CONVERT(NVARCHAR(5),@ID_Supplier)
				    EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=0,@ID_Batch=0,@ID_Other=@ID_Supplier,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
					
					SELECT 0 AS 'Successful deletion',@@ROWCOUNT,@EVENT
				END
			ELSE
				BEGIN
					SELECT 2,'THERE IS NO SUPPLIER WITH THIS ID'
					RETURN 2
				END

		COMMIT TRANSACTION;
    END TRY
		
	BEGIN CATCH
       
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
			RAISERROR ('CHECK FOR RELATED BATCHES BEFORE DELETING THE Supplier', 16, 1);
            ROLLBACK TRANSACTION;
        END
		
        EXECUTE [dbo].[uspLogError];
    END CATCH;
	
END
GO
/****** Object:  StoredProcedure [dbo].[spDelUnitMeasure]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spDelUnitMeasure]
 @UnitMeasureCode nvarchar(3)
 ,@CURRENT_USER sysname NULL
 ,@HOST_NAME SYSNAME NULL 

 AS
 BEGIN
 SET XACT_ABORT, NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
			IF exists (select 1 from dbo.BATCH where UnitMeasureCode=@UnitMeasureCode)
				BEGIN
					select 1,'Rejected. Perhaps this supplier is associated with batches of reagents.'
					ROLLBACK TRANSACTION;
					RETURN 1
				END
			DELETE  UnitMeasure WHERE [UnitMeasureCode]=@UnitMeasureCode
			DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128),@RCount int
            IF @@rowcount>0
		   		BEGIN
					SET @ProcName = OBJECT_NAME(@@PROCID)
					SET @SqlCommand='Удалена ед. измерения '+@UnitMeasureCode
					EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=0,@ID_Batch=0,@ID_Other=0,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
					SELECT 0 AS 'Result of DELETE','Удалена ед. измерения'
				END
			ELSE
				SELECT 1,'Warning: No rows were deleted!';
		COMMIT TRANSACTION;
    END TRY
    
	BEGIN CATCH
       
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END
GO
/****** Object:  StoredProcedure [dbo].[spEmployeeDISABLE_ENABLE]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spEmployeeDISABLE_ENABLE]

		@emp_id INT,
		@STATUS BIT
		,@CURRENT_USER sysname NULL
		,@HOST_NAME SYSNAME NULL 
AS
BEGIN

SET XACT_ABORT, NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128),@USER_NAME NVARCHAR(20),@EmpIDAdm int,@STATUS_text NVARCHAR (10),@RCOUNT INT,@ValidTo datetime
		SELECT @USER_NAME= [USER] FROM employee WHERE emp_id=@emp_id
		
		IF CURRENT_USER='dbo'
			SET @EmpIDAdm=0
		ELSE
			SELECT @EmpIDAdm=emp_ID from employee where [user]=CONVERT(sysname, CURRENT_USER)

		SET @SqlCommand = 'ALTER LOGIN '+ quotename(@USER_NAME, ']') 
		IF @STATUS=0
			BEGIN
				SET @STATUS_text='DISABLE'
				SET @ValidTo=getdate()
			END
		ELSE
			BEGIN
				SET @STATUS_text='ENABLE'
				SET @ValidTo=NULL
				
			END
		SET @SqlCommand= @SqlCommand+' '+ @STATUS_text
		
		EXEC (@SqlCommand)

		 
		 UPDATE [dbo].[employee] 
			SET LastEditedBy=@EmpIDAdm,
				ValidTo=@ValidTo
			WHERE emp_id=@emp_id

		IF @@ROWCOUNT>0
			BEGIN
				SET @ProcName = OBJECT_NAME(@@PROCID)
				SET @SqlCommand=	'Статус уч. записи ' +@USER_NAME+ ' изменен на:'+@STATUS_text
				EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=0,@ID_Batch=0,@ID_Other=@emp_id,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
				SELECT 0 AS 'Success ','Статус уч. записи -' + @STATUS_text
			END
		Else
				SELECT 1,'Статус уч. записи НЕ изменен'
		COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
       
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END
GO
/****** Object:  StoredProcedure [dbo].[spErrLog]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spErrLog]
	@ErrorLogID int = 0 OUTPUT 
AS
BEGIN
	SET XACT_ABORT, NOCOUNT ON;
  IF EXISTS (SELECT 1 FROM ErrorLog WHERE ErrorTime BETWEEN GetDate()-1 and GetDate()) 
  BEGIN
	DECLARE @errornumber INT, @ErrorSeverity INT, @ErrorState INT
	SELECT @ErrorLogID=MAX(ErrorLogID) FROM ErrorLog WHERE ErrorTime BETWEEN GetDate()-1 and GetDate()
	SELECT @errornumber=errornumber, @ErrorSeverity=ErrorSeverity, @ErrorState=ErrorState FROM ErrorLog WHERE ErrorLogID=@ErrorLogID 
	
	PRINT 'There are errors in DBase! NEED TO CHECK ERRORLOG TABLE!'
		RAISERROR (@errornumber, -- Message id.
       @ErrorSeverity, -- Severity,
       @ErrorState, -- State,
       N'My custom message');
	THROW @errornumber, 'My custom message - There are errors in DBase! NEED TO CHECK ERRORLOG TABLE!', 1;
--BEGIN
--    RAISERROR(@ErrorLogID, @ErrorSeverity, @ErrorState, 'alerting');
--    RETURN(1) -- Failure
 END
END
GO
/****** Object:  StoredProcedure [dbo].[spLogin]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spLogin]
    @USER NVARCHAR(20)
    ,@PSWD NVARCHAR(128)
	,@HOST_NAME sysname null
   
AS
BEGIN

    SET XACT_ABORT, NOCOUNT ON;

    DECLARE @emp_id INT,@MSG NVARCHAR(200)

    SELECT @emp_id=emp_id FROM [dbo].employee WHERE [USER]=@USER
	IF(@emp_id IS NOT NULL)
		BEGIN
			IF NOT EXISTS (SELECT TOP 1 emp_id FROM [dbo].EmpPs WHERE emp_id=@emp_id AND HPSWD=HASHBYTES('SHA2_512', @PSWD+CAST(Salt AS NVARCHAR(36))))
		      
			   SELECT 1, 'Incorrect password'
		   ELSE 
			   BEGIN
					SELECT 0, 'User successfully logged in'
					EXEC spCheckActiveEmployee @USER,1,@USER,@HOST_NAME
			   END
		END
    ELSE
       SELECT 2, 'Invalid login'




END
GO
/****** Object:  StoredProcedure [dbo].[spResetIdentityField]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[spResetIdentityField]
  @pSchemaName NVARCHAR(1000)
, @pTableName NVARCHAR(1000) 
, @max   INT=0

AS
BEGIN
	DECLARE @fullTableName   NVARCHAR(2000) = @pSchemaName + '.' + @pTableName;

	DECLARE @identityColumn   NVARCHAR(1000);

	SELECT @identityColumn = c.[name]
	FROM sys.tables t
		 INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
		 INNER JOIN sys.columns c ON c.[object_id] = t.[object_id]
	WHERE     c.is_identity = 1
		  AND t.name = @pTableName
		  AND s.[name] = @pSchemaName

	IF @identityColumn IS NULL
	  BEGIN
		RAISERROR(
		  'One of the following is true: 1. the table you specified doesn''t have an identity field, 2. you specified an invalid schema, 3. you specified an invalid table'
		, 16
		, 1);
		RETURN;
	  END;

	DECLARE @sqlString   NVARCHAR(MAX) = N'SELECT @maxOut = max(' + @identityColumn + ') FROM ' + @fullTableName;

	EXECUTE sp_executesql @stmt = @sqlString, @params = N'@maxOut int OUTPUT', @maxOut = @max OUTPUT

	IF @max IS NULL
	  SET @max = 0

	print(@max)

	DBCC CHECKIDENT (@fullTableName, RESEED, @max)
END

--exec pResetIdentityField 'dbo', 'Table',0
GO
/****** Object:  StoredProcedure [dbo].[spResetPswd]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spResetPswd]
@LOGON NVARCHAR(20)
--,@UserPswd nvarchar(40)
,@CURRENT_USER sysname NULL
,@HOST_NAME SYSNAME NULL 
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
	BEGIN TRY
        BEGIN TRANSACTION;
	DECLARE @Emp_ID INT,@SqlCommand NVARCHAR(MAX),@ProcName NVARCHAR(128),@RCount int, @TMPPswd nvarchar(40)
	SELECT @Emp_ID=Emp_ID FROM EMPLOYEE WHERE [USER]=@LOGON

	SET @TMPPswd='Lbr'+convert(varchar(2),MONTH(getdate()))+convert(varchar(2),Right(Year(getdate()),2))
	SET @SqlCommand = 'ALTER LOGIN '+ quotename(@LOGON, ']') +' WITH PASSWORD = '''+@TMPPswd +''' MUST_CHANGE,CHECK_EXPIRATION=ON'
			EXEC (@SqlCommand)
    
	UPDATE employee
    SET IsPermittedToLogon = 0
    WHERE Emp_ID = @Emp_ID AND IsPermittedToLogon = 1;

	DECLARE @salt UNIQUEIDENTIFIER=NEWID()
	UPDATE EmpPs 
	SET HPswd=HASHBYTES('SHA2_512', @TMPPswd+CAST(@salt AS NVARCHAR(36))),
		Pswd= @TMPPswd,
		SALT=@SALT
	WHERE Emp_ID = @Emp_ID;
	
	IF @@rowcount>0
	BEGIN
		SET @ProcName = OBJECT_NAME(@@PROCID)
		SET @SqlCommand=	'The password has been reset for login  - '+@LOGON
		EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=0,@ID_Batch=0,@ID_Other=@emp_id,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
		SELECT 0 AS 'Successfull activation','Временный пароль - '+@TMPPswd
	END
		ELSE
			SELECT 1,'Failed'

		COMMIT TRANSACTION;
    END TRY
	BEGIN CATCH
        
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
            ROLLBACK TRANSACTION;
        END
        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[spResetPswd_ByUser]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spResetPswd_ByUser]
@LOGON NVARCHAR(20)
,@UserPswd nvarchar(40)
,@CURRENT_USER sysname NULL
,@HOST_NAME SYSNAME NULL 
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
	BEGIN TRY
        BEGIN TRANSACTION;
	DECLARE @Emp_ID INT,@SqlCommand NVARCHAR(MAX),@ProcName NVARCHAR(128)
	SELECT @Emp_ID=Emp_ID FROM EMPLOYEE WHERE [USER]=@LOGON

	SET @SqlCommand = 'ALTER LOGIN '+ quotename(@LOGON, ']') +' WITH PASSWORD = '''+@UserPswd +''''
			EXEC (@SqlCommand)
    
	DECLARE @salt UNIQUEIDENTIFIER=NEWID()
	UPDATE EmpPs 
	SET HPswd=HASHBYTES('SHA2_512', @UserPswd+CAST(@salt AS NVARCHAR(36))),
		Pswd= @UserPswd,
		SALT=@SALT
	WHERE Emp_ID = @Emp_ID;
	
	IF @@rowcount>0
		BEGIN
			SET @ProcName = OBJECT_NAME(@@PROCID)
			SET @SqlCommand=	'Пароль изменен для Login - '+@LOGON
			EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=0,@ID_Batch=0,@ID_Other=@emp_id,@CURRENT_USER=@LOGON,@HOST_NAME=@HOST_NAME
			SELECT 0 AS 'Successfull reset','Пароль изменен'
		END
	ELSE
			SELECT 1,'Failed'

		COMMIT TRANSACTION;
    END TRY
	BEGIN CATCH
        
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
            ROLLBACK TRANSACTION;
        END
        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[spROLLBACK_Utilization]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spROLLBACK_Utilization] 
			@Util_ID int
			,@CURRENT_USER sysname NULL
			,@HOST_NAME SYSNAME NULL 
AS
BEGIN

	SET XACT_ABORT, NOCOUNT ON;
	   
	DECLARE @Batch_ID int,  @Qty_UTIL decimal(18,3), @ID_REAG int,@RCOUNT int
	SELECT @Batch_ID=Batch_ID FROM [dbo].[Util] WHERE Util_ID=@Util_ID
	SELECT @Qty_UTIL=QTY FROM dbo.Util Where Util_ID=@Util_ID
	SELECT @ID_REAG=ID_REAG FROM dbo.Util Where Util_ID=@Util_ID
	BEGIN TRY
        BEGIN TRANSACTION;
			UPDATE dbo.BATCH SET QTY=Qty+@Qty_UTIL WHERE Batch_ID=@Batch_ID
			DELETE dbo.Util WHERE Util_ID=@Util_ID
			IF @@ROWCOUNT>0
				BEGIN
					DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128),@EVENT VARCHAR(50)
					
					SET @EVENT='Отменено списание '
					SET @ProcName = OBJECT_NAME(@@PROCID)
					SET @SqlCommand= @EVENT	 + CONVERT(NVARCHAR(10),@Qty_UTIL)+ ' единиц с партии № '+CONVERT(NVARCHAR(10),@Batch_ID)
					EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=@ID_REAG,@ID_Batch=@Batch_ID,@ID_Other=@Util_ID,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
										
					SELECT 0 AS 'Successful deleting',@EVENT
				END
			ELSE
					SELECT 2,'THERE IS NO UPDATE WITH THIS ID'
							
		COMMIT TRANSACTION;
    END TRY
    
	BEGIN CATCH
       
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END
GO
/****** Object:  StoredProcedure [dbo].[spRunChkActEmp]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spRunChkActEmp]
	@IsActive bit
	,@CURRENT_USER sysname 
	,@HOST_NAME sysname 
	,@WindowsUserName nvarchar(40)=''

AS
BEGIN
	
	SET XACT_ABORT, NOCOUNT ON;
	
    BEGIN TRY
        BEGIN TRANSACTION;

			EXEC spCheckActiveEmployee @CURRENT_USER, @IsActive,@CURRENT_USER ,@HOST_NAME,@WindowsUserName  

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		 IF @@TRANCOUNT > 0
				BEGIN
					SELECT ERROR_NUMBER(),ERROR_MESSAGE()
					ROLLBACK TRANSACTION;
				END

				EXECUTE [dbo].[uspLogError];
			END CATCH;

End
GO
/****** Object:  StoredProcedure [dbo].[spUPD_Batch]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUPD_Batch]

	  @Batch_ID int,
      @Qty decimal(6,3),
      @UnitMeasureCode nchar(5),
      @Date_of_receipt date,
      @ID_Supplier int,
      @Date_of_expiration date,
      @Notes nvarchar(250),
	  @Manuf_ID int =NULL,
	  @DateManuf date =NULL, --Дата изготовления
	  @Manuf nvarchar(40)='',
	  @IsDateExpiration bit
	  ,@QtyOnebottle int --кол-во реактива в условном флаконе
	  ,@UnitMeasureOneBottle nchar(5) --ед. измер. реактива в условном флаконе
	  ,@IsQuantitative bit=0
	  ,@CURRENT_USER sysname NULL
	  ,@HOST_NAME sysname NULL 
AS
BEGIN
	SET XACT_ABORT, NOCOUNT ON;
	BEGIN TRY
        BEGIN TRANSACTION;
		
		DECLARE @SqlCommand varchar(max)='', @ProcName nvarchar(128)
		DECLARE @UnitMeasureCodeOLD nchar(5),@RCount int,@QtyOld decimal(6,3)
		IF @Manuf<>'' 
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM Manufacturer WHERE Manufacturer=@Manuf)
				BEGIN
					EXEC @Manuf_ID=Add_Manufacturer @Manufacturer=@Manuf,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
					SET @SqlCommand= 'Добавлен новый изготовитель - '+@Manuf +'; '
				END
			ELSE
				SELECT @Manuf_ID=Manuf_ID FROM Manufacturer WHERE Manufacturer=@Manuf
		END
		IF @Manuf_ID=0 
			SET @Manuf_ID=NULL

		IF @Date_of_receipt='' OR @Date_of_receipt=NULL
				BEGIN
					SET @Date_of_receipt=NULL
					SET @SqlCommand=@SqlCommand+'Дата получения:не указана; '
				END
			ELSE
				BEGIN
					SET @SqlCommand=@SqlCommand+' Дата получения: '+convert(nvarchar(10),@Date_of_receipt) +'; '
					IF @Date_of_receipt>GETDATE() 
						BEGIN
							SELECT 2, 'Дата получения больше текущей даты'
							ROLLBACK TRANSACTION;
							RETURN 2
						END
				END

				IF @Date_of_expiration='' OR @Date_of_expiration=NULL
				BEGIN
					SET @Date_of_expiration=NULL
					SET @SqlCommand=@SqlCommand +'Срок хранения:не указан; '
				END
			ELSE
				SET @SqlCommand=@SqlCommand + 'Срок хранения: '+convert(nvarchar(10),@Date_of_expiration) +'; '


			IF @DateManuf='' OR @DateManuf=NULL
				BEGIN
					SET @DateManuf=NULL
					SET @SqlCommand= @SqlCommand + 'Дата изготовления:не указана; '
				END
			ELSE
				BEGIN
					SET @SqlCommand=@SqlCommand+ ' Дата изготовления: '+convert(nvarchar(10),@DateManuf) +'; '
				
					IF @DateManuf>GETDATE() 
						BEGIN
							SELECT 1,'Дата изготовления больше текущей даты'
							ROLLBACK TRANSACTION;
							RETURN 1
						END
					ELSE IF @DateManuf>@Date_of_receipt 
						BEGIN
							SELECT 4, 'Дата изготовления больше даты получения'
							ROLLBACK TRANSACTION;
							RETURN 4
						END
				END
			 
			SELECT @UnitMeasureCodeOLD=UnitMeasureCode FROM BATCH WHERE  Batch_ID=@Batch_ID
			IF @UnitMeasureCodeOLD<>@UnitMeasureCode 
			BEGIN
				IF EXISTS(SELECT 1 FROM Util WHERE Batch_ID=@Batch_ID)
					BEGIN
						SELECT 6, 'Невозможно изменить ед. измерения - возможно, были списания с этой партии.'
						ROLLBACK TRANSACTION;
						RETURN 6
					END
				ELSE
					SET @SqlCommand=@SqlCommand+ ' Изменена ед. измерения: '+RTRIM(@UnitMeasureCode) +'; '
			END

			SELECT @QtyOld=QTY FROM BATCH WHERE  Batch_ID=@Batch_ID
			IF @QtyOld<>@Qty 
			BEGIN
			SET @SqlCommand= @SqlCommand + 'Изменено количество - ' +convert(nvarchar(10),@Qty) +'; '
				IF @QtyOnebottle>0
				BEGIN
					DECLARE @SubCount int,
							@n int=1,
							@MaxSubBatch_ID int
					SELECT @SubCount=COUNT(*) FROM SubBatch WHERE Batch_ID=@Batch_ID AND QTY>0
					IF  @SubCount<@Qty
					BEGIN
						SET @SubCount=@Qty-@SubCount
						WHILE @n<=  @SubCount
						BEGIN  
							INSERT INTO SubBatch
									( batch_id,
									qty,
									UnitMeasureCode,
									Initial_qty)
							VALUES
								(	@Batch_ID,
									@QtyOnebottle ,
									@UnitMeasureOneBottle ,
									@QtyOnebottle )
							SET @n=@n+1
							IF @n>@Qty
								BREAK  
							ELSE  
								CONTINUE  
						END   
					END

					IF  @SubCount>@Qty
						
					BEGIN
						SET @SubCount=@SubCount-@Qty
						WHILE @n<=  @SubCount
						BEGIN  
							SELECT @MaxSubBatch_ID=MAX(SubBatch_ID) FROM SubBatch WHERE Batch_ID=@Batch_ID AND Date_of_opening IS NULL AND QTY>0
							DELETE SubBatch
							WHERE SubBatch_ID=@MaxSubBatch_ID
							SET @n=@n+1
							IF @n>@Qty
								BREAK  
							ELSE  
								CONTINUE  
						END   
					END
					
				END
			END



			UPDATE [dbo].[Batch]
  			SET[Qty]=@Qty,
				UnitMeasureCode=@UnitMeasureCode,
				[Date_of_receipt]=@Date_of_receipt,
				[ID_Supplier]=@ID_Supplier,
				[Date_of_expiration]=@Date_of_expiration,
				Notes=@Notes,
				Manuf_ID =@Manuf_ID,
				DateManuf=@DateManuf,
				IsDateExpiration=@IsDateExpiration,
				IsQuantitative=@IsQuantitative
			 WHERE Batch_ID=@Batch_ID
			 
			 IF @@ROWCOUNT>0
				BEGIN	
					DECLARE @ID_REAG int
					SELECT @ID_REAG=ID_REAG  from [dbo].[Batch] WHERE Batch_ID=@Batch_ID
					SET @ProcName = OBJECT_NAME(@@PROCID)
					SET @SqlCommand='Изменена партия '+ CONVERT(nvarchar(5),@Batch_ID)+ '; ' + @SqlCommand + '; '
					EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=@ID_reag,@ID_Batch=@Batch_ID,@ID_Other=@ID_Supplier,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
					
					SELECT 0 AS 'SUCCESSFUL UPDATE!',@SqlCommand
	 			 END
			 ELSE
				 	SELECT 7 , 'Warning! No rows have been updated!'
	 COMMIT TRANSACTION;
    END TRY
    
	BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
            ROLLBACK TRANSACTION;
        END
        EXECUTE [dbo].[uspLogError];
    END CATCH;
		
		
END
GO
/****** Object:  StoredProcedure [dbo].[spUPD_Doc]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spUPD_Doc]
	@ID_Doc int,
	@Name_doc nvarchar(250) ,
	@TYPE_doc int ,
	@Year nchar (4) ,
	@Path_doc nvarchar(250) ,
	@ID_Reag int ,
	@Notes nvarchar(250),
	@Descript nvarchar(250)
	,@CURRENT_USER sysname NULL
    ,@HOST_NAME SYSNAME NULL 

AS
BEGIN
DECLARE @StrSP nvarchar(max),  @SqlCommand varchar(max), @ProcName NVARCHAR(128),@Rcount int, @NameTypeDoc NVARCHAR (10)
	SET XACT_ABORT, NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
		
   			UPDATE dbo.Documents 
			SET
				   [Name_doc]=@Name_doc
				   ,[TYPE_doc]=@TYPE_doc
				   ,[Year]=@Year
				   ,[Path_doc]=@Path_doc
				   ,Notes=@Notes
				   ,Descript=@Descript
			WHERE ID_Doc=@ID_Doc
			IF @@ROWCOUNT>0
				BEGIN
					SELECT @NameTypeDoc=NameTypeDoc FROM TypeDoc WHERE ID_TYPE_DOC=@TYPE_doc
					SET @ProcName = OBJECT_NAME(@@PROCID)
					SET @SqlCommand=	'Изменен документ № ' +convert(nvarchar(5),@ID_Doc) + ', Тип документа:'+@NameTypeDoc+', Наименование:'+ @Name_doc +', Год:'+ @Year+
					', Файл:'+@Path_doc+', Примечание:'+@Notes+', Описание:'+@Descript
					EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=@ID_reag,@ID_Other=@ID_Doc,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
					SELECT 0 AS 'Result of UPDATE','Изменен документ'
				END		
		    ELSE
				SELECT 1,'Внимание! Документ не изменен! Возможно, документ был удален.'
	     COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
   
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END
GO
/****** Object:  StoredProcedure [dbo].[spUPD_Reagent_Feature]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spUPD_Reagent_Feature]
		@ID_reag INT,
   		@Reag_Name nvarchar(255) ,
		@Catalog_num nvarchar(20),
		@Series_num nvarchar(20),
		@ID_Group_Lab int,
		@Notes nvarchar(200)
		,@CURRENT_USER sysname NULL
        ,@HOST_NAME SYSNAME NULL 
		,@Cleanliness [nvarchar](50)=''
		,@Purpose [nvarchar](150)=''
		,@Storage_conditions [nvarchar](150)=''
		,@Level_report [nvarchar](50)=''
		,@Storage [nvarchar](50)=''
		
AS
BEGIN

	SET XACT_ABORT, NOCOUNT ON;
	BEGIN TRY
        BEGIN TRANSACTION;
			 DECLARE @return_value INT=0
			 IF NOT EXISTS(SELECT 1 FROM dbo.Reagent WHERE ID_reag = @ID_reag)
        BEGIN
			SET @return_value=1
            SELECT @return_value, 'Этого реактива нет в БД' AS strMessage
            Rollback TRan
            RETURN @return_value
        END
			UPDATE [dbo].[Reagent]
			SET  Reag_Name=@Reag_Name
				,Catalog_num=@Catalog_num
				,Series_num=@Series_num
				WHERE ID_reag=@ID_reag

			UPDATE [dbo].[Feature]
			SET  ID_Group_lab = @ID_Group_lab
				,Notes=@Notes
				,[Cleanliness] = @Cleanliness
			    ,[Purpose] = @Purpose
			    ,[Storage_conditions] = @Storage_conditions
			    ,[Level_report] = @Level_report
			    ,[Storage] = @Storage
			WHERE ID_reag=@ID_reag
			 IF @@ROWCOUNT>0
				BEGIN
					DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128),@EVENT VARCHAR(50) 
					SET @EVENT='Изменен реактив '
					SET @ProcName = OBJECT_NAME(@@PROCID)
		   		    SET @SqlCommand=@EVENT +TRIM(@Reag_Name)+' ' + TRIM(@Catalog_num) +' ' +TRIM(@Series_num)+' Чистота: '+@Cleanliness
					+', Назначениие: ' + @Purpose +', код лаборатории - ' +CONVERT(NVARCHAR(3),@ID_Group_Lab)+', Условия хранения: '+@Storage_conditions+
					', Степень отчетности: ' +@Level_report+ ', Место хранения: '+@Storage+', Примечания: '+@Notes
					EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=@ID_reag,@ID_Batch=0,@ID_Other=0,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
					
					SELECT @return_value AS 'Successful updating',@EVENT
				END
			ELSE
					SET @return_value =2
					IF (@@ERROR <> 0 OR @return_value <> 0) --GOTO QuitWithRollback
					BEGIN
						ROLLBACK TRANSACTION;
						SELECT @return_value,'THERE IS NO UPDATE WITH THIS ID'
						RETURN @return_value;	
					END
			
		--QuitWithRollback:
		
		COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
         IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
	
	


END
GO
/****** Object:  StoredProcedure [dbo].[spUPD_Utilization]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[spUPD_Utilization] 
	@Util_ID INT,
	@QtyNew decimal(18,3),
	@Purpose nvarchar(250)='',
	@Util_date date,
	@Employee nvarchar(50)='',
	 @Date_of_opening date,
      @NumDay INT
	,@CURRENT_USER sysname NULL
	,@HOST_NAME SYSNAME NULL
AS
BEGIN

	SET XACT_ABORT, NOCOUNT ON;
 DECLARE  @QTYRest decimal(6,3),@Batch_ID int,@ID_Reag int,@QTY_BATCH decimal(6,3),@QTYUtil decimal(6,3),@Date_of_expiration_after_of_opening date,@Date_of_receipt date
 DECLARE @SqlCommand varchar(max)='', @ProcName NVARCHAR(128)
	IF NOT EXISTS (SELECT 1 FROM UTIL WHERE Util_ID=@Util_ID)
		BEGIN
			SELECT  1 , 'Уже нет этой записи'
			RETURN 1
		END
	BEGIN TRY
        BEGIN TRANSACTION; 
			SELECT @Batch_ID=Batch_ID, @ID_Reag=ID_Reag FROM Util WHERE Util_ID=@Util_ID
			SELECT  @Date_of_receipt=Date_of_receipt FROM Batch WHERE Batch_ID=@Batch_ID
			IF @Date_of_opening=''  
			Begin
				SET @Date_of_opening=NULL
				SET @Date_of_expiration_after_of_opening=NULL
				SEt @SqlCommand='не вскрыта '
				IF @NumDay>0
					SET @SqlCommand=@SqlCommand+', Срок хранения после вскрытия '+convert(nvarchar(5),@NumDay)+' дней '
			END
			ELSE
				BEGIN
					IF @Date_of_opening>GETDATE() 
						BEGIN
							SELECT 3, 'Дата открытия больше текущей даты'
							ROLLBACK TRANSACTION;
							RETURN 3
						END
					ELSE IF @Date_of_opening<@Date_of_receipt
						BEGIN
							SELECT 5, 'Дата открытия больше даты получения'
							ROLLBACK TRANSACTION;
							RETURN 5
						END

					set @Date_of_expiration_after_of_opening=DateAdd(day,@NumDay,@Date_of_opening)
					SET @SqlCommand='вскрыта: '+convert(nvarchar(10),@Date_of_opening)+' , хранить после вскрытия ' +convert(nvarchar(5),@NumDay)+' до: ' + convert(nvarchar(10),@Date_of_expiration_after_of_opening)
				END
			
					
			SELECT @QTYUtil= Qty FROM  dbo.UTIL WHERE Util_ID=@Util_ID
			SELECT @QTY_BATCH=QTY FROM dbo.BATCH WHERE Batch_ID=@Batch_ID
			IF @QTYUtil>@QtyNew
				SELECT @QTY_BATCH=@QTY_BATCH+(@QTYUtil-@QtyNew)
			ELSE
				SELECT @QTY_BATCH=@QTY_BATCH-(@QtyNew-@QTYUtil)

			UPDATE dbo.BATCH 
				SET QTY=@QTY_BATCH ,
				Date_of_opening=@Date_of_opening,
				NumDay=@NumDay,
				Date_of_expiration_after_of_opening=@Date_of_expiration_after_of_opening  
			WHERE Batch_ID=@Batch_ID


			UPDATE  [dbo].[Util]
			SET
			    [Qty]=@QtyNew
			   ,[Purpose]=@Purpose
			   ,[Util_date]=@Util_date
			   ,[Employee]=@Employee
			   ,ModifiedDate=GETDATE()
			   WHERE Util_ID=@Util_ID
		  IF @@ROWCOUNT>0 
			BEGIN
				
				SET @SqlCommand='Изменено списание '
				SET @ProcName = OBJECT_NAME(@@PROCID)
				SET @SqlCommand=@SqlCommand+ ' из партии № '+CONVERT(NVARCHAR(5),@Batch_ID)+'; Количество: '+CONVERT(NVARCHAR(10),cast(@QtyNew as float))+'; Назначение: '+@Purpose+
				'; Дата списания: '+CONVERT(NVARCHAR(10),@Util_date)+'; Получил: ' +@Employee
				EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=@ID_Reag,@ID_Batch=@Batch_ID,@ID_Other=@Util_ID,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
				SELECT  0 AS 'Successful update', @SqlCommand
			END
		ELSE
			SELECT  2 , 'FAILURE'

		COMMIT TRANSACTION;
	END TRY
			BEGIN CATCH
      
				IF @@TRANCOUNT > 0
				BEGIN
					SELECT ERROR_NUMBER(),ERROR_MESSAGE()
					ROLLBACK TRANSACTION;
				END
					EXECUTE [dbo].[uspLogError];
			END CATCH;
END
GO
/****** Object:  StoredProcedure [dbo].[spUPDManufacturer_SEL]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spUPDManufacturer_SEL]
		@Manuf_ID INT,
	    @Str nvarchar(max)
		,@CURRENT_USER sysname NULL
        ,@HOST_NAME SYSNAME NULL 
	
AS
BEGIN

	SET XACT_ABORT, NOCOUNT ON;
	BEGIN TRY
        BEGIN TRANSACTION;
	
			DECLARE @StrSP nvarchar(max)
			SET @StrSP='UPDATE dbo.Manufacturer SET ' + @Str  + ' WHERE Manuf_ID=' +trim(convert(nvarchar(5),@Manuf_ID))
			EXEC (@StrSP)
	
			DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128)
			SET @ProcName = OBJECT_NAME(@@PROCID)
			SET @SqlCommand='Изменены данные изготовителя с ID ' +convert(nvarchar(5),@Manuf_ID) +' '+ @Str
			EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=0,@ID_Batch=0,@ID_Other=@Manuf_ID,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
							 
			SELECT 0 AS 'Result of UPDATE',@@ROWCOUNT,'Изменены данные изготовителя'
				
	  COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
      
        IF @@TRANCOUNT > 0
        BEGIN
			SELECT ERROR_NUMBER(),ERROR_MESSAGE()
			ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
		
END
GO
/****** Object:  StoredProcedure [dbo].[spUPDSupplier]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spUPDSupplier]
	
	  @ID_Supplier INT
		,@CompanyName nvarchar(40)
		 ,@ContactName nvarchar(30) =NULL
		,@ContactTitle nvarchar(30) =NULL
		,@Address nvarchar(60) NULL
		,@City nvarchar(15) NULL
		,@Region nvarchar(15) NULL
		,@PostalCode nvarchar(10) NULL
		,@Country nvarchar(15) NULL
		,@Phone nvarchar(24) NULL
		,@Fax nvarchar(24) NULL
		,@HomePage ntext NULL
		,@DirectorName nvarchar(30) NULL
		,@NOTE nvarchar(max) NULL
		,@EmaiL nvarchar(30) NULL
		,@CURRENT_USER sysname NULL
		,@HOST_NAME SYSNAME NULL 
AS
BEGIN

	SET XACT_ABORT, NOCOUNT ON;
	BEGIN TRY
        BEGIN TRANSACTION;
			DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128),@RCount int
			
			UPDATE [dbo].SUPPLIERS
            SET 
				CompanyName=@CompanyName, 
				ContactName=@ContactName,
				ContactTitle=@ContactTitle
				,[Address]=@Address
				,City=@City
				,Region=@Region
				,PostalCode=@PostalCode
				,Country=@Country
				,Phone=@Phone
				,Fax=@Fax
				,HomePage=@HomePage
				,DirectorName=@DirectorName
				,NOTE=@NOTE
				,EmaiL=@EmaiL
			 WHERE ID_Supplier=@ID_Supplier
			 
			  IF @@rowcount>0
					BEGIN
	    			  SET @ProcName = OBJECT_NAME(@@PROCID)
					  SET @SqlCommand=	'Изменен Поставщик №'+convert(nvarchar(5),@ID_Supplier)
					  EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Other=@ID_Supplier,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
					  SELECT 0 AS 'Success of UPDATE','Изменен поставщик'
					END
			  ELSE
					SELECT 1, 'Warning: No rows were updated';
				

	 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        
        IF @@TRANCOUNT > 0
        BEGIN
            SELECT ERROR_NUMBER(),ERROR_MESSAGE()
			ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
		 
		
END
GO
/****** Object:  StoredProcedure [dbo].[spUPDSupplier_SELECTIVELY]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spUPDSupplier_SELECTIVELY]
		@ID_Supplier INT,
	    @Str nvarchar(max)
		,@CURRENT_USER sysname ='V'
		,@HOST_NAME SYSNAME ='PC1' 
AS
BEGIN
	SET XACT_ABORT, NOCOUNT ON;
	BEGIN TRY
      BEGIN TRANSACTION;
			declare @StrSP nvarchar(max)
			SET @StrSP='UPDATE dbo.Suppliers SET ' + @Str  + ' WHERE ID_Supplier=' +trim(convert(nvarchar(6),@ID_Supplier))
			exec (@StrSP)
	
					DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128)
					SET @ProcName = OBJECT_NAME(@@PROCID)
					SET @SqlCommand=	'Изменен поставщик №' +convert(nvarchar(6),@ID_Supplier) +' '+ @Str
					EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=0,@ID_Batch=0,@ID_Other=@ID_Supplier,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
		
			--IF @@ROWCOUNT > 0  
			--		BEGIN
				SELECT 0 AS 'Success of UPDATE',@@ROWCOUNT,'Изменен поставщик'
			--		End
			--	ELSE
			--		SELECT 1, 'Warning: No rows were updated';
	 COMMIT TRANSACTION;
    END TRY
	
    BEGIN CATCH
		IF @@TRANCOUNT > 0
			BEGIN
				SELECT ERROR_NUMBER(),ERROR_MESSAGE()
				ROLLBACK TRANSACTION;
			END
		EXECUTE [dbo].[uspLogError];
    END CATCH;
END
GO
/****** Object:  StoredProcedure [dbo].[spUPDUnitMeasure]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUPDUnitMeasure]
		 @UnitMeasureCode nchar(5)
		 ,@NameUnMes nvarchar(50) NULL
		 ,@IsQuantitative bit=0
		 ,@CURRENT_USER sysname NULL
         ,@HOST_NAME SYSNAME NULL 
AS
BEGIN
	SET XACT_ABORT, NOCOUNT ON;
	BEGIN TRY
        BEGIN TRANSACTION;
		DECLARE @SqlCommand varchar(max), @ProcName NVARCHAR(128)
			UPDATE [dbo].UnitMeasure
       		SET 
				UnitMeasureCode=@UnitMeasureCode, 
				[Name]=@NameUnMes
				,IsQuantitative=@IsQuantitative
			 WHERE UnitMeasureCode=@UnitMeasureCode
			 IF @@ROWCOUNT >0
				 BEGIN
					SET @ProcName = OBJECT_NAME(@@PROCID)
					SET @SqlCommand=	'Изменена единица измерения '+@UnitMeasureCode +', Название - ' +@NameUnMes
					EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
					SELECT 0 AS 'Success of UPDATE','Изменена единица измерения'
				End
			ELSE
				SELECT 1 AS 'FAILURE', 'Warning: No rows were updated';
				
	 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
      
        IF @@TRANCOUNT > 0
        BEGIN
            SELECT ERROR_NUMBER(),ERROR_MESSAGE()
			ROLLBACK TRANSACTION;
        END
        EXECUTE [dbo].[uspLogError];
    END CATCH;
END
GO
/****** Object:  StoredProcedure [dbo].[spUtilButtleOne]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[spUtilButtleOne] 
           @SubBatch_ID int
           ,@Qty decimal(6,3)
 		   ,@Notes nvarchar(250)
           ,@Util_date date
           ,@Employee nvarchar(50)
		   ,@Date_of_opening date =NULL --Дата вскрытия упаковки
		  ,@NumDay int=0 --кол-во дней хранения после вскрытия 
		  ,@CURRENT_USER sysname NULL
		  ,@HOST_NAME SYSNAME NULL
AS
BEGIN

	SET XACT_ABORT, NOCOUNT ON;
 DECLARE @Util_ID INT, @QTYRest decimal(18,3),@Date_of_expiration_after_of_opening date,@Batch_ID int,@ID_Reag int,@UnitMeasureCode nchar(5)
 DECLARE @SqlCommand varchar(max)='', @ProcName NVARCHAR(128),@EVENT VARCHAR(50)
	BEGIN TRY
        BEGIN TRANSACTION;
		SELECT @Batch_ID=Batch_ID, @UnitMeasureCode=UnitMeasureCode FROM SubBatch WHERE SubBatch_ID=@SubBatch_ID
		SELECT @ID_Reag=ID_Reag FROM Batch WHERE Batch_ID=@Batch_ID
		IF @Date_of_opening=''  
			BEGIN
				SELECT 8,'Необходимо указать дату вскрытия и Срок хранения после вскрытия'
				RETURN 8
			END
			ELSE
				BEGIN
					IF @Date_of_opening>GETDATE() 
						BEGIN
							SELECT 3,'Дата открытия больше текущей даты'
							RETURN 3
						END
					set @Date_of_expiration_after_of_opening=DateAdd(day,@NumDay,@Date_of_opening)
					SET @SqlCommand='Вскрыта: '+convert(nvarchar(10),@Date_of_opening)+' , хранить после вскрытия ' +convert(nvarchar(5),@NumDay)+' д. до: ' + convert(nvarchar(10),@Date_of_expiration_after_of_opening) +'; '
				END

			SELECT @QTYRest= Qty-@Qty FROM  dbo.SubBatch WHERE SubBatch_ID=@SubBatch_ID
			IF @QTYRest<0
			BEGIN
				SELECT 2, 'Попытка списать больше существующего остатка. Операция отменена.'
				RETURN 2
			END
			UPDATE dbo.SubBatch 
			SET QTY=@QTYRest,
				Date_of_opening=@Date_of_opening,
				NumDay=@NumDay,
				Notes=@Notes,
				Util_date=@Util_date,
				ModifiedDate=getdate(),
				Date_of_expiration_after_of_opening=@Date_of_expiration_after_of_opening  
			WHERE SubBatch_ID=@SubBatch_ID

			DECLARE @QtyCount int, @N int=0,@MaxSubBatch_ID int
		    SELECT @QtyCount=COUNT(*) FROM SubBatch WHERE Batch_ID=@Batch_ID AND QTY>0

			UPDATE BATCH 
			SET QTY=@QtyCount
			WHERE Batch_ID=@Batch_ID

			INSERT INTO [dbo].[Util]
					   ([Batch_ID]
					   ,[ID_Reag]
					   ,[Qty]
					   ,UnitMeasureCode
					   ,[Purpose]
					   ,[Util_date]
					   ,[Employee])
				   VALUES
					   (@Batch_ID,
					   @ID_Reag,
					   @Qty,
					   @UnitMeasureCode,
					   @Notes,
					   @Util_date,
					   @Employee)
						
		IF @@ROWCOUNT>0
			BEGIN
				
				SET @SqlCommand=@SqlCommand + 'Списано '
				SET @ProcName = OBJECT_NAME(@@PROCID)
				SET @SqlCommand=@SqlCommand+ CONVERT(NVARCHAR(10),cast(@Qty as float))+' '+RTRIM(@UnitMeasureCode) +'; Назначение: '+@Notes+
				'; Дата списания: '+CONVERT(NVARCHAR(10),@Util_date)+'; Получил: ' +@Employee
				EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=@ID_Reag,@ID_Batch=@Batch_ID,@ID_Other=@Util_ID,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
				SELECT  0 AS 'Successful update', @SqlCommand
			END
		ELSE
			SELECT  1 , 'FAILURE'

		COMMIT TRANSACTION;
	END TRY
			BEGIN CATCH
      
				IF @@TRANCOUNT > 0
				BEGIN
					SELECT ERROR_NUMBER(),ERROR_MESSAGE()
					ROLLBACK TRANSACTION;
				END
					EXECUTE [dbo].[uspLogError];
			END CATCH;
END
GO
/****** Object:  StoredProcedure [dbo].[spUtilization]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spUtilization] 
			   @Batch_ID int,
			   --@ID_Reag int,
			   @Qty decimal(18,3),
			   --@UnitMeasureCode char(5),
			   @Purpose nvarchar(250),
			   @Util_date date,
			   @Employee nvarchar(50),
				@Date_of_opening date =NULL, --Дата вскрытия упаковки
				@NumDay int=0 --кол-во дней хранения после вскрытия 
			  ,@CURRENT_USER sysname NULL
			  ,@HOST_NAME sysname NULL
AS
BEGIN
	SET XACT_ABORT, NOCOUNT ON;
 DECLARE @Util_ID INT, @QTYRest decimal(18,3),@Date_of_expiration_after_of_opening date,@ID_Reag int, @UnitMeasureCode varchar(5)
 DECLARE @SqlCommand varchar(max)='', @ProcName nvarchar(128),@EVENT varchar(50)

 SELECT @ID_Reag=ID_Reag ,@UnitMeasureCode=UnitMeasureCode FROM Batch WHERE Batch_ID=@Batch_ID
	BEGIN TRY
        BEGIN TRANSACTION;
		IF @Date_of_opening=''  
			BEGIN
				SET @Date_of_opening=NULL
				SET @Date_of_expiration_after_of_opening=NULL
				SEt @SqlCommand='Не вскрыта; '
				--IF @NumDay>0
				--	SET @SqlCommand=@SqlCommand+'Срок хранения после вскрытия '+convert(nvarchar(5),@NumDay)+' д.; '
			END
			ELSE
				BEGIN
					IF @Date_of_opening>GETDATE() 
						BEGIN
							SELECT 3,'Дата открытия больше текущей даты'
							--ROLLBACK TRANSACTION; 
							RETURN 3
						END
					set @Date_of_expiration_after_of_opening=DateAdd(day,@NumDay,@Date_of_opening)
					SET @SqlCommand='Вскрыта: '+convert(nvarchar(10),@Date_of_opening)+' , хранить после вскрытия ' +convert(nvarchar(5),@NumDay)+' д. до: ' + convert(nvarchar(10),@Date_of_expiration_after_of_opening)+'; '
				END

			SELECT @QTYRest= Qty-@Qty FROM  dbo.BATCH WHERE Batch_ID=@Batch_ID
			IF @QTYRest<0
			BEGIN
				SELECT 4, 'Попытка списать больше существующего остатка. Операция отменена.'
				RETURN 4
			END
			UPDATE dbo.BATCH 
			SET QTY=@QTYRest,
				Date_of_opening=@Date_of_opening,
				NumDay=@NumDay,
				Date_of_expiration_after_of_opening=@Date_of_expiration_after_of_opening  
			WHERE Batch_ID=@Batch_ID

			INSERT INTO [dbo].[Util]
				   ([Batch_ID]
				   ,[ID_Reag]
				   ,[Qty]
				   ,UnitMeasureCode
				   ,[Purpose]
				   ,[Util_date]
				   ,[Employee])
			   VALUES
	   			  ( @Batch_ID,
				   @ID_Reag,
				   @Qty,
				   @UnitMeasureCode,
				   @Purpose,
				   @Util_date,
				   @Employee)
		  SELECT @Util_ID=SCOPE_IDENTITY()  
		  DECLARE @QtyCount int, @N int=1,@MaxSubBatch_ID int
		  SELECT @QtyCount=COUNT(*) FROM SubBatch WHERE Batch_ID=@Batch_ID 
		  AND QTY=(SELECT Initial_qty FROM SubBatch WHERE Batch_ID=@Batch_ID GROUP BY Batch_ID,Initial_qty)
		  IF @QtyCount>=@QTY
			  WHILE @N<=@QTY
			  BEGIN
					SELECT @MaxSubBatch_ID=MAX(SubBatch_ID) FROM SubBatch WHERE Batch_ID=@Batch_ID 
					AND QTY=(SELECT Initial_qty FROM SubBatch WHERE Batch_ID=@Batch_ID GROUP BY Batch_ID,Initial_qty)
					UPDATE SubBatch 
						SET QTY=0,
							Notes='Емкость списана одномоментно'
					WHERE SubBatch_ID=@MaxSubBatch_ID
					SET @N=@N+1
					IF @N>@QTY
						BREAK
					ELSE
						CONTINUE
			  END
		 ELSE
			BEGIN
				SELECT 5,'Попытка списать больше существующего остатка. Операция отменена.'
				ROLLBACK TRANSACTION; 
				RETURN 5
			END

		IF @Util_ID>0
			BEGIN
				
				SET @SqlCommand=@SqlCommand +'Списано '
				SET @ProcName = OBJECT_NAME(@@PROCID)
				SET @SqlCommand=@SqlCommand+ CONVERT(nvarchar(10),cast(@Qty as float))+' '+@UnitMeasureCode +' из партии № '+CONVERT(nvarchar(5),@Batch_ID)+'; Назначение: '+@Purpose+
				'; Дата списания: '+CONVERT(nvarchar(10),@Util_date)+'; Получил: ' +@Employee
				EXEC spADDEventLog @SqlCommand=@SqlCommand,@Source=@ProcName,@ID_Reag=@ID_Reag,@ID_Batch=@Batch_ID,@ID_Other=@Util_ID,@CURRENT_USER=@CURRENT_USER,@HOST_NAME=@HOST_NAME
				SELECT  0 AS 'Successful update', @SqlCommand
			END
		ELSE
			SELECT  1 , 'FAILURE'

		COMMIT TRANSACTION;
	END TRY
			BEGIN CATCH
      
				IF @@TRANCOUNT > 0
				BEGIN
					SELECT ERROR_NUMBER(),ERROR_MESSAGE()
					ROLLBACK TRANSACTION;
				END
					EXECUTE [dbo].[uspLogError];
			END CATCH;
END
GO
/****** Object:  StoredProcedure [dbo].[uspLogError]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspLogError] 
    @ErrorLogID [int] = 0 OUTPUT
AS                              
BEGIN
    SET XACT_ABORT, NOCOUNT ON;

   
    SET @ErrorLogID = 0;

    BEGIN TRY

        IF ERROR_NUMBER() IS NULL
            RETURN;

      
        IF XACT_STATE() = -1
        BEGIN
            PRINT 'Откат... ' ;
            RETURN;
        END

        INSERT [dbo].[ErrorLog] 
            (
            [UserName], 
            [ErrorNumber], 
            [ErrorSeverity], 
            [ErrorState], 
            [ErrorProcedure], 
            [ErrorLine], 
            [ErrorMessage],
			Host
            ) 
        VALUES 
            (
            CONVERT(sysname, CURRENT_USER), 
            ERROR_NUMBER(),
            ERROR_SEVERITY(),
            ERROR_STATE(),
            ERROR_PROCEDURE(),
            ERROR_LINE(),
            ERROR_MESSAGE(),
			HOST_NAME ()
            );

        SET @ErrorLogID = @@IDENTITY;
    END TRY
    BEGIN CATCH
        PRINT 'Ошибка!!! : ';
        EXECUTE [dbo].[uspPrintError];
        RETURN -1;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[uspPrintError]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspPrintError] 
AS
BEGIN
    SET XACT_ABORT, NOCOUNT ON;

    PRINT 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
          ', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
          ', State ' + CONVERT(varchar(5), ERROR_STATE()) + 
          ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') + 
          ', Line ' + CONVERT(varchar(5), ERROR_LINE());
    PRINT ERROR_MESSAGE();
END;
GO
/****** Object:  DdlTrigger [backup_objects]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Object:  DdlTrigger [backup_objects]    Script Date: 30.11.2023 16:00:42 ******/

CREATE   TRIGGER [backup_objects]
ON DATABASE
FOR CREATE_PROCEDURE, 
    ALTER_PROCEDURE, 
    DROP_PROCEDURE,
    CREATE_TABLE, 
    ALTER_TABLE, 
    DROP_TABLE,
    CREATE_FUNCTION, 
    ALTER_FUNCTION, 
    DROP_FUNCTION,
    CREATE_VIEW,
    ALTER_VIEW,
    DROP_VIEW
AS
 
SET NOCOUNT ON
 BEGIN 
	DECLARE @data XML
	SET @data = EVENTDATA()
 
	INSERT INTO changelog(databasename, eventtype, 
		objectname, objecttype, sqlcommand, loginname)
	VALUES(
	@data.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'varchar(256)'),
	@data.value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(50)'), 
	@data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(256)'), 
	@data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(25)'), 
	@data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'varchar(max)'), 
	@data.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(256)')
	)

	declare @DBVer nvarchar(25), @logID int
	Select @logID= max(logid) from changelog
	--select @DBVer=isnull(convert(decimal(18,2),max(DBVersion)),0)+0.01 from [LBRBuildVer]
	select @DBVer=max(isnull(convert(decimal(6,2),(DBVersion)),0))+0.01 from [LBRBuildVer]
	INSERT INTO [dbo].[LBRBuildVer]
			   (DBVersion
			   ,[VersionDate]
			   ,[ModifiedDate]
			   ,LogID)
		 VALUES
			   (  @DBVer
			   ,getdate()
			   ,getdate()
			   ,@logID
			)
END 
GO
DISABLE TRIGGER [backup_objects] ON DATABASE
GO
/****** Object:  DdlTrigger [ddlDatabaseTriggerLog]    Script Date: 28.05.2024 8:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [ddlDatabaseTriggerLog] ON DATABASE 
FOR DDL_DATABASE_LEVEL_EVENTS AS 
BEGIN
    SET NOCOUNT ON;

    DECLARE @data XML;
    DECLARE @schema sysname;
    DECLARE @object sysname;
    DECLARE @eventType sysname;

    SET @data = EVENTDATA();
    SET @eventType = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'sysname');
    SET @schema = @data.value('(/EVENT_INSTANCE/SchemaName)[1]', 'sysname');
    SET @object = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'sysname') 

    IF @object IS NOT NULL
        PRINT '  ' + @eventType + ' - ' + @schema + '.' + @object;
    ELSE
        PRINT '  ' + @eventType + ' - ' + @schema;

    IF @eventType IS NULL
        PRINT CONVERT(nvarchar(max), @data);

    INSERT [dbo].[DatabaseLog] 
        (
        [PostTime], 
        [DatabaseUser], 
        [Event], 
        [Schema], 
        [Object], 
        [TSQL], 
        [XmlEvent]
        ) 
    VALUES 
        (
        GETDATE(), 
        CONVERT(sysname, CURRENT_USER), 
        @eventType, 
        CONVERT(sysname, @schema), 
        CONVERT(sysname, @object), 
        @data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(max)'), 
        @data
        );
END;
GO
DISABLE TRIGGER [ddlDatabaseTriggerLog] ON DATABASE
GO
ENABLE TRIGGER [backup_objects] ON DATABASE
GO
ENABLE TRIGGER [ddlDatabaseTriggerLog] ON DATABASE
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Logs error information in the ErrorLog table about the error that caused execution to jump to the CATCH block of a TRY...CATCH construct. Should be executed from within the scope of a CATCH block otherwise it will return without inserting error information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'uspLogError'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Output parameter for the stored procedure uspLogError. Contains the ErrorLogID value corresponding to the row inserted by uspLogError in the ErrorLog table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'uspLogError', @level2type=N'PARAMETER',@level2name=N'@ErrorLogID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Prints error information about the error that caused execution to jump to the CATCH block of a TRY...CATCH construct. Should be executed from within the scope of a CATCH block otherwise it will return without printing any error information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'uspPrintError'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Database trigger to audit all of the DDL changes made to the AdventureWorks 2016 database.' , @level0type=N'TRIGGER',@level0name=N'ddlDatabaseTriggerLog'
GO
