USE [OTUS_projekt]
GO
/****** Object:  DatabaseRole [DB_admin]    Script Date: 27.05.2024 10:25:45 ******/
CREATE ROLE [DB_admin]
GO
/****** Object:  DatabaseRole [DB_Supervisor]    Script Date: 27.05.2024 10:25:45 ******/
CREATE ROLE [DB_Supervisor]
GO
/****** Object:  DatabaseRole [DB_User]    Script Date: 27.05.2024 10:25:45 ******/
CREATE ROLE [DB_User]
GO
ALTER ROLE [DB_User] ADD MEMBER [DB_admin]
GO
ALTER ROLE [DB_Supervisor] ADD MEMBER [DB_admin]
GO
ALTER ROLE [DB_User] ADD MEMBER [DB_Supervisor]
GO
/****** Object:  UserDefinedFunction [dbo].[DeclensionSurname]    Script Date: 27.05.2024 10:25:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Table [dbo].[Batch]    Script Date: 27.05.2024 10:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Batch](
	[Batch_ID] [int] IDENTITY(1,1) NOT NULL,
	[ID_Reag] [int] NOT NULL,
	[Qty] [decimal](18, 3) NULL,
	[UnitMeasureCode] [nchar](5) NOT NULL,
	[Date_of_receipt] [date] NULL,
	[ID_Supplier] [int] NOT NULL,
	[Date_of_expiration] [date] NULL,
	[Date_of_opening] [date] NULL,
	[Date_of_expiration_after_of_opening] [date] NULL,
	[Notes] [nvarchar](250) NULL,
	[Manuf_ID] [int] NULL,
	[DateManuf] [date] NULL,
	[NumDay] [int] NULL,
	[Initial_qty] [decimal](6, 3) NULL,
	[ModifiedDate] [datetime] NULL,
	[IsDateExpiration] [bit] NULL,
	[IsQuantitative] [bit] NULL,
 CONSTRAINT [PK_Batch] PRIMARY KEY CLUSTERED 
(
	[Batch_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Documents]    Script Date: 27.05.2024 10:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Documents](
	[ID_doc] [int] IDENTITY(1,1) NOT NULL,
	[Name_doc] [nvarchar](100) NULL,
	[TYPE_doc] [int] NULL,
	[Year] [nchar](4) NULL,
	[Path_doc] [nvarchar](250) NOT NULL,
	[ID_Reag] [int] NOT NULL,
	[Notes] [nvarchar](250) NULL,
	[Descript] [nvarchar](250) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Documents] PRIMARY KEY CLUSTERED 
(
	[ID_doc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[employee]    Script Date: 27.05.2024 10:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[employee](
	[emp_id] [int] IDENTITY(1,1) NOT NULL,
	[fname] [varchar](20) NULL,
	[minit] [varchar](20) NULL,
	[lname] [varchar](30) NOT NULL,
	[job_id] [int] NULL,
	[job_lvl] [tinyint] NULL,
	[user] [nvarchar](20) NOT NULL,
	[RoleMember] [nvarchar](50) NULL,
	[IsPermittedToLogon] [bit] NULL,
	[LastEditedBy] [int] NULL,
	[ValidFrom] [datetime2](7) NULL,
	[ValidTo] [datetime2](7) NULL,
	[ModifiedDate] [datetime] NULL,
	[Enabl] [bit] NULL,
	[FullSelect] [bit] NULL,
 CONSTRAINT [PK_emp_id] PRIMARY KEY NONCLUSTERED 
(
	[emp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [AK_user] UNIQUE NONCLUSTERED 
(
	[user] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmpPs]    Script Date: 27.05.2024 10:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmpPs](
	[EMP_ID] [int] NOT NULL,
	[Pswd] [nvarchar](128) NULL,
	[HPswd] [varbinary](max) NULL,
	[ModifiedDate] [datetime] NULL,
	[Salt] [uniqueidentifier] NULL,
 CONSTRAINT [PK_EmpPs] PRIMARY KEY CLUSTERED 
(
	[EMP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Feature]    Script Date: 27.05.2024 10:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Feature](
	[ID_Feature] [int] IDENTITY(1,1) NOT NULL,
	[Cleanliness] [nvarchar](255) NULL,
	[Purpose] [nvarchar](255) NULL,
	[ID_Group_lab] [int] NULL,
	[Storage_conditions] [nvarchar](255) NULL,
	[Level_report] [nvarchar](255) NULL,
	[ID_reag] [int] NOT NULL,
	[NOTES] [nvarchar](max) NULL,
	[Storage] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Feature] PRIMARY KEY CLUSTERED 
(
	[ID_Feature] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Group_Lab]    Script Date: 27.05.2024 10:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Group_Lab](
	[ID_Group_Lab] [int] NULL,
	[Name_Gr_Lab] [nvarchar](100) NOT NULL,
	[Room] [nvarchar](6) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [AK_Lab] UNIQUE NONCLUSTERED 
(
	[Name_Gr_Lab] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Manufacturer]    Script Date: 27.05.2024 10:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Manufacturer](
	[Manuf_ID] [int] IDENTITY(1,1) NOT NULL,
	[Manufacturer] [nvarchar](100) NOT NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [Manuf_ID_PK] PRIMARY KEY CLUSTERED 
(
	[Manuf_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [AK_Manuf] UNIQUE NONCLUSTERED 
(
	[Manufacturer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Reagent]    Script Date: 27.05.2024 10:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reagent](
	[ID_reag] [int] IDENTITY(1,1) NOT NULL,
	[Reag_Name] [nvarchar](255) NOT NULL,
	[Catalog_num] [nvarchar](20) NULL,
	[Series_num] [nvarchar](20) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Reagent] PRIMARY KEY CLUSTERED 
(
	[ID_reag] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SubBatch]    Script Date: 27.05.2024 10:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubBatch](
	[SubBatch_ID] [int] IDENTITY(1,1) NOT NULL,
	[Qty] [decimal](6, 3) NULL,
	[UnitMeasureCode] [nchar](5) NOT NULL,
	[Date_of_opening] [date] NULL,
	[Date_of_expiration_after_of_opening] [date] NULL,
	[Notes] [nvarchar](250) NULL,
	[NumDay] [int] NULL,
	[Initial_qty] [decimal](6, 3) NULL,
	[ModifiedDate] [datetime] NULL,
	[Batch_ID] [int] NULL,
	[Util_date] [date] NULL,
 CONSTRAINT [PK_SubBatch] PRIMARY KEY CLUSTERED 
(
	[SubBatch_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Suppliers]    Script Date: 27.05.2024 10:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Suppliers](
	[ID_Supplier] [int] NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[ContactName] [nvarchar](30) NULL,
	[ContactTitle] [nvarchar](30) NULL,
	[Address] [nvarchar](60) NULL,
	[City] [nvarchar](15) NULL,
	[Region] [nvarchar](15) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[Country] [nvarchar](15) NULL,
	[Phone] [nvarchar](24) NULL,
	[Fax] [nvarchar](24) NULL,
	[HomePage] [ntext] NULL,
	[DirectorName] [nvarchar](30) NULL,
	[NOTE] [nvarchar](max) NULL,
	[Email] [nvarchar](30) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Suppliers] PRIMARY KEY CLUSTERED 
(
	[ID_Supplier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [AK_CompanyName] UNIQUE NONCLUSTERED 
(
	[CompanyName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TypeDoc]    Script Date: 27.05.2024 10:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TypeDoc](
	[ID_TYPE_DOC] [int] NOT NULL,
	[NameTypeDoc] [nvarchar](20) NULL,
 CONSTRAINT [PK_TypeDoc] PRIMARY KEY CLUSTERED 
(
	[ID_TYPE_DOC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UnitMeasure]    Script Date: 27.05.2024 10:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UnitMeasure](
	[UnitMeasureCode] [nchar](5) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[ModifiedDate] [datetime] NULL,
	[IsQuantitative] [bit] NULL,
 CONSTRAINT [PK_UnitMeasure_UnitMeasureCode] PRIMARY KEY CLUSTERED 
(
	[UnitMeasureCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserActive]    Script Date: 27.05.2024 10:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserActive](
	[EMP_ID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Util]    Script Date: 27.05.2024 10:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Util](
	[Util_ID] [int] IDENTITY(1,1) NOT NULL,
	[Batch_ID] [int] NOT NULL,
	[ID_Reag] [int] NOT NULL,
	[Qty] [decimal](18, 3) NULL,
	[UnitMeasureCode] [nchar](5) NOT NULL,
	[Purpose] [nvarchar](250) NULL,
	[Util_date] [date] NULL,
	[Employee] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Util] PRIMARY KEY CLUSTERED 
(
	[Util_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

GO
ALTER TABLE [dbo].[Batch] ADD  CONSTRAINT [DF_Batch_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
Go
ALTER TABLE [dbo].[Documents] ADD  CONSTRAINT [DF_Documents_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO
ALTER TABLE [dbo].[employee] ADD  CONSTRAINT [DF_Emp_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO
ALTER TABLE [dbo].[employee] ADD  CONSTRAINT [DF_employee_Enabl]  DEFAULT ((0)) FOR [Enabl]
GO
ALTER TABLE [dbo].[EmpPs] ADD  CONSTRAINT [DF_Password_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO
ALTER TABLE [dbo].[Feature] ADD  CONSTRAINT [DF_Feature_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO
ALTER TABLE [dbo].[Group_Lab] ADD  CONSTRAINT [DF_Group_Lab_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO
ALTER TABLE [dbo].[Manufacturer] ADD  CONSTRAINT [DF_Manufacturer_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO
ALTER TABLE [dbo].[Reagent] ADD  CONSTRAINT [DF_Reagent_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO
ALTER TABLE [dbo].[SubBatch] ADD  CONSTRAINT [DF_SubBatch_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO
ALTER TABLE [dbo].[Suppliers] ADD  CONSTRAINT [DF_Suppliers_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO
ALTER TABLE [dbo].[UnitMeasure] ADD  CONSTRAINT [DF_UnitMeasure_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO
ALTER TABLE [dbo].[UserActive] ADD  CONSTRAINT [DF_UserActive_IsActive]  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[UserActive] ADD  DEFAULT (getdate()) FOR [ModifiedDate]
GO
ALTER TABLE [dbo].[Util] ADD  CONSTRAINT [DF_Util_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO
ALTER TABLE [dbo].[Batch]  WITH CHECK ADD  CONSTRAINT [FK_Batch_Manuf] FOREIGN KEY([Manuf_ID])
REFERENCES [dbo].[Manufacturer] ([Manuf_ID])
GO
ALTER TABLE [dbo].[Batch] CHECK CONSTRAINT [FK_Batch_Manuf]
GO
ALTER TABLE [dbo].[Batch]  WITH CHECK ADD  CONSTRAINT [FK_Batch_Reag] FOREIGN KEY([ID_Reag])
REFERENCES [dbo].[Reagent] ([ID_reag])
GO
ALTER TABLE [dbo].[Batch] CHECK CONSTRAINT [FK_Batch_Reag]
GO
ALTER TABLE [dbo].[Batch]  WITH CHECK ADD  CONSTRAINT [FK_Batch_Supplier] FOREIGN KEY([ID_Supplier])
REFERENCES [dbo].[Suppliers] ([ID_Supplier])
GO
ALTER TABLE [dbo].[Batch] CHECK CONSTRAINT [FK_Batch_Supplier]
GO
ALTER TABLE [dbo].[Batch]  WITH CHECK ADD  CONSTRAINT [FK_Batch_UnitMeasure] FOREIGN KEY([UnitMeasureCode])
REFERENCES [dbo].[UnitMeasure] ([UnitMeasureCode])
GO
ALTER TABLE [dbo].[Batch] CHECK CONSTRAINT [FK_Batch_UnitMeasure]
GO
ALTER TABLE [dbo].[Documents]  WITH CHECK ADD  CONSTRAINT [FK_Documents_ReagID] FOREIGN KEY([ID_Reag])
REFERENCES [dbo].[Reagent] ([ID_reag])
GO
ALTER TABLE [dbo].[Documents] CHECK CONSTRAINT [FK_Documents_ReagID]
GO
ALTER TABLE [dbo].[Documents]  WITH CHECK ADD  CONSTRAINT [FK_Documents_TypeDoc] FOREIGN KEY([TYPE_doc])
REFERENCES [dbo].[TypeDoc] ([ID_TYPE_DOC])
GO
ALTER TABLE [dbo].[Documents] CHECK CONSTRAINT [FK_Documents_TypeDoc]
GO
ALTER TABLE [dbo].[EmpPs]  WITH CHECK ADD  CONSTRAINT [FK_EmpPS_ID] FOREIGN KEY([EMP_ID])
REFERENCES [dbo].[employee] ([emp_id])
GO
ALTER TABLE [dbo].[EmpPs] CHECK CONSTRAINT [FK_EmpPS_ID]
GO
ALTER TABLE [dbo].[Feature]  WITH CHECK ADD  CONSTRAINT [FK_Feature_Feature] FOREIGN KEY([ID_Feature])
REFERENCES [dbo].[Feature] ([ID_Feature])
GO
ALTER TABLE [dbo].[Feature] CHECK CONSTRAINT [FK_Feature_Feature]
GO
ALTER TABLE [dbo].[Feature]  WITH CHECK ADD  CONSTRAINT [FK_Feature_Reag] FOREIGN KEY([ID_reag])
REFERENCES [dbo].[Reagent] ([ID_reag])
GO
ALTER TABLE [dbo].[Feature] CHECK CONSTRAINT [FK_Feature_Reag]
GO
ALTER TABLE [dbo].[SubBatch]  WITH CHECK ADD  CONSTRAINT [FK_SubBatch_Batch] FOREIGN KEY([Batch_ID])
REFERENCES [dbo].[Batch] ([Batch_ID])
GO
ALTER TABLE [dbo].[SubBatch] CHECK CONSTRAINT [FK_SubBatch_Batch]
GO
ALTER TABLE [dbo].[SubBatch]  WITH CHECK ADD  CONSTRAINT [FK_SubBatch_UnitMeasure] FOREIGN KEY([UnitMeasureCode])
REFERENCES [dbo].[UnitMeasure] ([UnitMeasureCode])
GO
ALTER TABLE [dbo].[SubBatch] CHECK CONSTRAINT [FK_SubBatch_UnitMeasure]
GO
ALTER TABLE [dbo].[UserActive]  WITH CHECK ADD  CONSTRAINT [FK_UserActive_ID] FOREIGN KEY([EMP_ID])
REFERENCES [dbo].[employee] ([emp_id])
GO
ALTER TABLE [dbo].[UserActive] CHECK CONSTRAINT [FK_UserActive_ID]
GO
ALTER TABLE [dbo].[Util]  WITH CHECK ADD  CONSTRAINT [FK_Util_Batch] FOREIGN KEY([Batch_ID])
REFERENCES [dbo].[Batch] ([Batch_ID])
GO
ALTER TABLE [dbo].[Util] CHECK CONSTRAINT [FK_Util_Batch]
GO
ALTER TABLE [dbo].[Util]  WITH CHECK ADD  CONSTRAINT [FK_Util_Measure] FOREIGN KEY([UnitMeasureCode])
REFERENCES [dbo].[UnitMeasure] ([UnitMeasureCode])
GO
ALTER TABLE [dbo].[Util] CHECK CONSTRAINT [FK_Util_Measure]
GO
ALTER TABLE [dbo].[Util]  WITH CHECK ADD  CONSTRAINT [FK_Util_Reag] FOREIGN KEY([ID_Reag])
REFERENCES [dbo].[Reagent] ([ID_reag])
GO
ALTER TABLE [dbo].[Util] CHECK CONSTRAINT [FK_Util_Reag]
GO
