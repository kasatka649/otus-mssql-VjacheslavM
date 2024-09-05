EXECUTE AS USER='OtusUser'
GO

--добавление реактива
DECLARE 
	@Reag_Name nvarchar(255) ='Bacteriological Gelatin' ,
    @Catalog_num nvarchar(20)='1213',
	@Series_num nvarchar(20)='bbb789'

EXEC ADD_Feature  @Reag_Name=@Reag_Name,
					@Catalog_num=@Catalog_num,
					@Series_num=@Series_num,
					@ID_Group_Lab=35,
					@Notes='Bacteriological Gelatin is a C-nitro compound that is chlorobenzene carrying a nitro substituent at each of the 2- and 4-positions. 
					It has a role as an epitope, an allergen and a sensitiser. It is a C-nitro compound and a member of monochlorobenzenes.',
					@Cleanliness='4th degree',
					@Purpose='Dinitrochlorobenzene has been used in trials studying the treatment of HIV Infections.',
					@Storage_conditions='~ +20 degree C',
					@Level_report='High',
					@Storage='Room #3.16', 
					@CURRENT_USER='OTUSUSER',
					@HOST_NAME='WS-018'

DECLARE @ID_REAG int
SELECT @ID_REAG=ID_REAG 
FROM reagent 
WHERE Reag_Name=@Reag_Name AND Catalog_num=@Catalog_num AND Series_num=@Series_num
--добавление партии
EXEC spADD_Batch @ID_Reag =@ID_REAG, 
				@Qty =3, 
				@UnitMeasureCode ='флак ', 
				@Date_of_receipt ='2024-09-02', 
				@ID_Supplier =1, 
				@Date_of_expiration   ='',
				@Notes ='', 
				@Manuf_ID = 1, 
				@DateManuf  ='2024-05-28', 
				@Manuf ='', 
				@IsDateExpiration =0, 
				@QtyOnebottle =30, 
				@UnitMeasureOneBottle ='мл   ', 
				@CURRENT_USER ='OTUSUSER',
				@HOST_NAME ='WS-018'

-- списание партии

DECLARE @Batch_ID int
SELECT  @Batch_ID=Batch_ID  FROM Batch WHERE ID_REAG=@ID_REAG 
 

EXEC	[dbo].[spUtilization]
		@Batch_ID = @Batch_ID,
		@Qty = 1,
		@Purpose = N'''тест''',
		@Util_date = '2024-09-02',
		@Employee = N'''Отусов''',
		@Date_of_opening = '2024-09-02',
		@NumDay = 10,
		@CURRENT_USER = 'OTUSUSER',
		@HOST_NAME = 'WS-018'


--списание подпартии
select * from SubBatch where Batch_ID=@Batch_ID
DECLARE @SubBatch_ID int
SELECT  @SubBatch_ID=min(SubBatch_ID)   FROM SubBatch WHERE Batch_ID=@Batch_ID and Qty>0
--SELECT  @SubBatch_ID
EXEC	[dbo].[spUtilButtleOne]
		@SubBatch_ID = @SubBatch_ID,
		@Qty = 5,
		@Notes = N'Тест',
		@Util_date = '2024-09-02',
		@Employee = N'Отусов',
		@Date_of_opening = '2024-09-02',
		@NumDay = 10,
		@CURRENT_USER = 'OTUSUSER',
		@HOST_NAME = 'WS-018'



SELECT * FROM VBATCHALL WHERE  Reag_Name=@Reag_Name AND Catalog_num=@Catalog_num AND Series_num=@Series_num


