USE [dbaAdmin]
GO

/****** Object:  Table [dbo].[CommandLog]    Script Date: 7/26/2021 6:19:10 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CommandLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseName] [sysname] NULL,
	[SchemaName] [sysname] NULL,
	[ObjectName] [sysname] NULL,
	[ObjectType] [char](2) NULL,
	[IndexName] [sysname] NULL,
	[IndexType] [tinyint] NULL,
	[StatisticsName] [sysname] NULL,
	[PartitionNumber] [int] NULL,
	[ExtendedInfo] [xml] NULL,
	[Command] [nvarchar](max) NOT NULL,
	[CommandType] [nvarchar](60) NOT NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NULL,
	[ErrorNumber] [int] NULL,
	[ErrorMessage] [nvarchar](max) NULL,
 CONSTRAINT [PK_CommandLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


