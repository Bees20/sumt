USE [dba]
GO

/****** Object:  Table [dbo].[Stats_Collection]    Script Date: 7/26/2021 7:29:33 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Stats_Collection](
	[databasename] [varchar](100) NULL,
	[Tablename] [varchar](255) NULL,
	[StatisticsName] [varchar](255) NULL,
	[rows] [int] NULL,
	[rows_sampled] [int] NULL,
	[percentage_sampled] [int] NULL,
	[last_updated] [smalldatetime] NULL,
	[modification_counter] [int] NULL,
	[DateInserted] [datetime] NULL
) ON [PRIMARY]
GO


