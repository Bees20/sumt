USE [dba]
GO

/****** Object:  Table [dbo].[unusedindexes]    Script Date: 7/26/2021 7:29:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[unusedindexes](
	[databaseName] [varchar](100) NULL,
	[Tablename] [varchar](255) NULL,
	[IndexName] [varchar](255) NULL,
	[Seeks] [int] NULL,
	[scans] [int] NULL,
	[lookups] [int] NULL,
	[updates] [int] NULL,
	[indexsizeMB] [int] NULL,
	[Lastseek] [varchar](1) NULL,
	[lastscan] [varchar](1) NULL,
	[lastlookup] [varchar](1) NULL,
	[lastupdate] [smalldatetime] NULL,
	[DateInserted] [datetime] NULL
) ON [PRIMARY]
GO


