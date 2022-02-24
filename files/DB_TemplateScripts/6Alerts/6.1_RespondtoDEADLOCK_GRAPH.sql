USE [msdb]
GO

/****** Object:  Alert [Respond to DEADLOCK_GRAPH]    Script Date: 7/26/2021 8:10:03 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Respond to DEADLOCK_GRAPH', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'[Uncategorized]', 
		@wmi_namespace=N'\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER', 
		@wmi_query=N'SELECT * FROM DEADLOCK_GRAPH', 
		@job_name=N'Capture Deadlock Graph'
GO


