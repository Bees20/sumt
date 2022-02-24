EXEC sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE ;  
GO  
EXEC sp_configure 'min memory per query', 8192 ;  
GO  
RECONFIGURE;  
GO 