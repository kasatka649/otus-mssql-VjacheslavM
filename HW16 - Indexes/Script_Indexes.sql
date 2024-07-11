USE [OTUS_projekt]
GO

CREATE TABLE [dbo].[ChangeLog_USER_EVENTS](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[SqlCommand] [varchar](max) NOT NULL,
	[EventDate] [datetime] NOT NULL,
	[LoginName] [varchar](50) NOT NULL,
	[Source] [nvarchar](100) NULL,
	[ID_Reag] [int] NULL,
	[PCName] [nvarchar](20) NULL,
	[ID_Batch] [int] NULL,
	[ID_other] [int] NULL,
 CONSTRAINT [PK_ChangeLog_USER_EVENTS] PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[ChangeLog_USER_EVENTS] ADD  CONSTRAINT [DF_USER_EVENTS_EventDate]  DEFAULT (getdate()) FOR [EventDate]
GO

CREATE FULLTEXT CATALOG [Otus_FT_Catalog] WITH ACCENT_SENSITIVITY = ON
AS DEFAULT
GO

CREATE FULLTEXT INDEX ON [dbo].[ChangeLog_USER_EVENTS](SqlCommand LANGUAGE Russian)
KEY INDEX PK_ChangeLog_USER_EVENTS 
ON (Otus_FT_Catalog)
WITH (
  CHANGE_TRACKING = AUTO, 
  STOPLIST = SYSTEM );
GO

SELECT LogID
      ,SqlCommand
      ,EventDate
      ,LoginName
      ,Source
      ,PCName
  FROM OTUS_projekt.dbo.ChangeLog_USER_EVENTS
  WHERE CONTAINS (SqlCommand, N'FORMSOF(INFLECTIONAL, "документ")');

SELECT LogID
      ,SqlCommand
      ,EventDate
      ,Source
      ,PCName
	  ,t.[KEY]
      ,t.[RANK]
FROM OTUS_projekt.dbo.ChangeLog_USER_EVENTS s
INNER JOIN CONTAINSTABLE(OTUS_projekt.dbo.ChangeLog_USER_EVENTS, SqlCommand,  N'"изменена" NEAR "партия"' ) AS t
ON s.LogID = t.[KEY]
ORDER BY t.RANK DESC;

