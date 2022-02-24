USE [dba]
GO

/****** Object:  Table [dbo].[lockinfo]    Script Date: 7/26/2021 7:28:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[lockinfo](
	[spid] [varchar](30) NOT NULL,
	[command] [nvarchar](32) NULL,
	[login] [nvarchar](260) NULL,
	[host] [nvarchar](128) NULL,
	[hostprc] [varchar](10) NULL,
	[endpoint] [sysname] NULL,
	[appl] [nvarchar](128) NULL,
	[dbname] [sysname] NULL,
	[prcstatus] [nvarchar](60) NULL,
	[ansiopts] [varchar](50) NULL,
	[spid_] [varchar](30) NULL,
	[trnopts] [varchar](60) NULL,
	[opntrn] [varchar](10) NULL,
	[trninfo] [varchar](60) NULL,
	[blklvl] [varchar](10) NOT NULL,
	[blkby] [varchar](30) NOT NULL,
	[cnt] [varchar](10) NOT NULL,
	[object] [nvarchar](550) NULL,
	[rsctype] [nvarchar](60) NOT NULL,
	[locktype] [nvarchar](60) NOT NULL,
	[lstatus] [nvarchar](60) NOT NULL,
	[ownertype] [nvarchar](60) NOT NULL,
	[rscsubtype] [varchar](1100) NOT NULL,
	[waittime] [varchar](19) NULL,
	[waittype] [nvarchar](60) NULL,
	[spid__] [varchar](30) NULL,
	[cpu] [varchar](25) NULL,
	[physio] [varchar](40) NULL,
	[logreads] [varchar](40) NULL,
	[memgrant] [varchar](19) NULL,
	[progress] [varchar](5) NULL,
	[tempdb] [varchar](40) NULL,
	[now] [datetime2](3) NOT NULL,
	[login_time] [varchar](16) NULL,
	[last_batch] [varchar](16) NULL,
	[trn_start] [varchar](16) NULL,
	[last_since] [varchar](17) NULL,
	[trn_since] [varchar](17) NULL,
	[clr] [char](3) NULL,
	[nstlvl] [char](3) NULL,
	[spid___] [varchar](30) NULL,
	[inputbuffer] [nvarchar](4000) NULL,
	[current_sp] [nvarchar](400) NULL,
	[curstmt] [nvarchar](max) NULL,
	[queryplan] [xml] NULL,
	[rowno] [int] NOT NULL,
 CONSTRAINT [aba_lockinfo2_pk] PRIMARY KEY CLUSTERED 
(
	[now] ASC,
	[rowno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


