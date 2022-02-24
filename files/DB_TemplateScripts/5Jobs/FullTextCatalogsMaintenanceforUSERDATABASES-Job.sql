USE [msdb]
GO

/****** Object:  Job [Full Text Catalogs maintenance for user databases]    Script Date: 7/26/2021 6:47:44 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 7/26/2021 6:47:44 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Full Text Catalogs maintenance for user databases', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQL DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Changing FTC to AUTO]    Script Date: 7/26/2021 6:47:44 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Changing FTC to AUTO', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=2, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=2, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sp_MSforeachdb ''IF ''''?'''' NOT IN (''''MASTER'''',''''msdb'''',''''model'''',''''tempdb'''',''''DBA'''',''''LITESPEEDLOCAL'''')
BEGIN
USE ?

DECLARE @Name varchar(100)

DECLARE FullText_Catalog CURSOR 
FOR 
SELECT OBJECT_NAME([object_id]) FROM sys.fulltext_indexes
where change_tracking_state_desc LIKE ''''%MANUAL%'''' or change_tracking_state_desc LIKE ''''%OFF%'''' 

OPEN FullText_Catalog

FETCH NEXT FROM FullText_Catalog 
INTO @Name

WHILE @@FETCH_STATUS = 0
BEGIN

  -- Reset Full Text Catalog population to AUTO for a given database
declare @sql varchar(1000)
set @sql = ''''ALTER FULLTEXT INDEX ON  '''' + @Name + '''' SET CHANGE_TRACKING AUTO;'''';
exec(@sql)
PRINT ''''The FULL TEXT Catalog '''' + @Name + '''' has been SET to AUTO TRACKING Successfully for database ?!''''

   FETCH NEXT FROM FullText_Catalog INTO @Name
END

CLOSE FullText_Catalog
DEALLOCATE FullText_Catalog

END''', 
		@database_name=N'master', 
		@output_file_name=N'N:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\FTC_Maintenance_$(JOBID)_$(STEPID)_$(STRTDT)_$(STRTTM).txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Reorganizing the Full text indexes]    Script Date: 7/26/2021 6:47:44 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Reorganizing the Full text indexes', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'sp_msforeachdb ''if ''''?'''' NOT IN  (''''master'''',''''msdb'''',''''model'''',''''tempdb'''',''''litespeedlocal'''',''''dba'''')
begin
use ?
PRINT ''''The Full text catalogs are being Reorganized for '''' + db_name()
--create curson to hold FTC names
declare ctable cursor for      
select Name from sys.fulltext_catalogs 
declare @Name sysname 
declare @ExecSQL nvarchar(512)  
open ctable 
fetch next FROM ctable into @Name  

while (@@FETCH_STATUS = 0)                  
BEGIN
BEGIN            
SET @ExecSQL = ''''ALTER FULLTEXT CATALOG ''''+ @Name + '''' REORGANIZE''''     
EXEC sp_executesql @ExecSQL
Print @ExecSQL
END        
fetch next FROM ctable into @Name    
END 
close ctable 
deallocate ctable 
PRINT ''''Completed Reorganization of Full text catalogs for '''' + db_name()
end
''
', 
		@database_name=N'master', 
		@output_file_name=N'N:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\FTC_Maintenance_$(JOBID)_$(STEPID)_$(STRTDT)_$(STRTTM).txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every Week on Sundays', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20111111, 
		@active_end_date=99991231, 
		@active_start_time=40500, 
		@active_end_time=235959, 
		@schedule_uid=N'7f22bab1-2ccf-49be-a009-5975bd0a45df'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO



