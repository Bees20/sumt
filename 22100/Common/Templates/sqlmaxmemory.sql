EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
EXEC sp_configure 'max server memory', {{ maxmemory }}
GO
RECONFIGURE