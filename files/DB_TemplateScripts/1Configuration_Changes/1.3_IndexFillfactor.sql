EXEC sys.sp_configure N'fill factor (%)', N'85'
GO
EXEC sys.sp_configure N'backup compression default', N'1'
GO
RECONFIGURE WITH OVERRIDE
GO
