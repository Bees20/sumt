sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
 
sp_configure 'Database Mail XPs', 1;
GO
RECONFIGURE
GO

EXECUTE msdb.dbo.sysmail_add_profile_sp  
    @profile_name = 'SQL DBA',  
    @description = 'Default Email Account' ;  
GO

-- Grant access to the profile to the DBMailUsers role  
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp  
    @profile_name = 'SQL DBA',  
    @principal_name = 'public',  
    @is_default = 1 ;
GO

EXEC msdb.dbo.sp_add_operator @name=N'SQL DBA',
        @enabled=1,
        @email_address=N'od-dba@sumtotalsystems.com',
        @category_name=N'[Uncategorized]'
GO

EXECUTE msdb.dbo.sysmail_add_account_sp  
    @account_name = 'SQL DBA',  
    @description = 'Default Email Account',  
    @email_address = 'od-dba@sumtotalsystems.com',  
    @display_name = 'SQL DBA',  
    @mailserver_name = '$(smtp)',
    @port = 25;  
GO

EXECUTE msdb.dbo.sysmail_add_profileaccount_sp  
    @profile_name = 'SQL DBA',  
    @account_name = 'SQL DBA',  
    @sequence_number =1 ;  
GO
