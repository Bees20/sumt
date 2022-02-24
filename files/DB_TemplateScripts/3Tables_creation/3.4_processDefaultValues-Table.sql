USE [dba]
GO

/****** Object:  Table [dbo].[processDefaultValues]    Script Date: 7/26/2021 7:35:10 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[processDefaultValues](
	[emailRecipient] [varchar](300) NULL,
	[emailProfile] [varchar](75) NULL,
	[fileSizeAuditRetention] [int] NULL
) ON [PRIMARY]
GO


