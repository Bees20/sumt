EXEC sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE WITH OVERRIDE;  
GO  
EXEC sp_configure 'max degree of parallelism', {{ maxdegree }};  
GO  
RECONFIGURE WITH OVERRIDE;  
GO    