USE [dba]
GO

/****** Object:  Table [dbo].[DeadlockEvents]    Script Date: 7/26/2021 7:28:44 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DeadlockEvents](
	[AlertTime] [datetime] NULL,
	[DeadlockGraph] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


