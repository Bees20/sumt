USE [msdb]
GO

/****** Object:  Job [Winter2016-Failed_Job]    Script Date: 7/26/2021 7:20:59 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 7/26/2021 7:20:59 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Winter2016-Failed_Job', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'$(login)', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step-1]    Script Date: 7/26/2021 7:20:59 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step-1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF  Not EXISTS (select [name] from dba.sys.tables where [name]=''UseMeForFailedJobs'')
BEGIN
create table dba..UseMeForFailedJobs
(MyServerName nvarchar(255),
DbName nvarchar(255),
JobName nvarchar(255),
JobInstanceId uniqueidentifier,
ScheduledFireTImeUTC datetime,
FireTimeUtc datetime,
IsErrored bit
);
END
Delete dba..UseMeForFailedJobs

EXEC sp_MSforeachdb ''IF ''''?'''' NOT IN (''''tempdb'''',''''model'''',''''msdb'''',"master","W16_Tenant_Logs","dba","Database Snapshots","Portal_logs")
BEGIN

declare @var datetime
declare @starttime datetime
set @var=getutcdate()
set @var=dateadd(minute,-(datepart(minute, getdate())%15),@var)
set @var=dateadd(second,-(datepart(second,getdate())%60),@var)
set @var=dateadd(millisecond,-(datepart(millisecond,getdate())%1000),@var) 
set @starttime=dateadd(minute,-15,@var)
--select @var,@starttime;
use ?
IF  EXISTS (select [name] from sys.tables where [name]="SystemJobAudit")
BEGIN
Insert  into dba..UseMeForFailedJobs
select @@servername as [MyServerName], DB_NAME() AS [DBName],JobName,JobInstanceId,scheduledFireTimeUTC,FireTimeUTC,IsErrored from SystemJobAudit where Iserrored=1 and 
(jobname  like "DataImport%" or jobname  like "TrainingMigration%" or jobname like "%Notification%") and 
 dateadd(minute,jobrundurationMins,FireTimeUTC)  between @starttime and @var 
END
END''


DECLARE @Temp1 table (MyServerName nvarchar(255),DbName nvarchar(255),JobName nvarchar(255),JobInstanceId uniqueidentifier,ScheduledFireTImeUTC datetime,FireTimeUtc datetime,IsErrored bit) 
Insert Into @Temp1 ( MyServerName,DbName,JobName,JobInstanceId,ScheduledFireTImeUTC,FireTimeUtc,IsErrored) 
Select * from dba..UseMeForFailedJobs  order by FireTimeUTC desc 
DECLARE @tableHTMLD  NVARCHAR(MAX) 
DECLARE @tableHTMLR  NVARCHAR(MAX) 
DECLARE @tableHTMLF  NVARCHAR(MAX) 
Declare @subject varchar(256)
SET @tableHTMLR=NULL  
SET @tableHTMLD =    
    N''<H1>Quartz Jobs Failure</H1>'' +    
    N''<H2>Create a P1 case for production jobs and route it to App support. Engage on call if the alerts repeat.
                Create a p2 case for stage and route it to App support team!</H2>'' +    
    N''&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'' +  
        N''&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;''  
  
SET @tableHTMLR =    
    N''<table border="1">'' +    
    N''<tr bgcolor="#F70707"  color="#0B0000"><th>ServerName</th>'' +  
    N''<th>JDatabaseName</th>'' + N''<th>JobName</th>''+N''<th>JobInstanceId</th>''+ N''<th>ScheduledFireTImeUTC</th>''+ N''<th>FireTimeUtc</th>''+      
      CAST ( ( SELECT td = MyServerName,       '''',    
                    td = DbName, '''',    
                    td = JobName, '''',   
                    td = JobInstanceId, '''',
                    td = ScheduledFireTImeUTC, '''',
                    td = FireTimeUtc   
              FROM @Temp1  
                             
             FOR XML PATH(''tr''), TYPE     
    ) AS NVARCHAR(MAX) ) + 

        N''</table>'' +  
      N''&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'' +  
      N''&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'' +  
      N''&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'' +  
      N''&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;''  
Set @tableHTMLF = @tableHTMLD + @tableHTMLR

print @tableHTMLF
print @tableHTMLD
print @tableHTMLR

Set @subject = N''Quartz Jobs Failure'' 
   IF (@tableHTMLR is not NULL)
   Begin
exec msdb.dbo.sp_send_dbmail  
   @profile_name = ''OD-DBA'',  
   @recipients = N''coalerts@sumtotalsystems.com'',  
    
   @importance = N''High'',  
   @subject = @subject,    
   @body = @tableHTMLF,  
   @body_format = ''HTML'' ; 
     End
     ELSE
     Print ''NoResults(NULL)''', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 minutes', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20161205, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'6a53fe45-803a-4557-a0eb-10ab55ec218c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
