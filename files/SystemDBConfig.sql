Use master 
Go
ALTER DATABASE [MSDB] MODIFY FILE ( NAME = MSDBData , FILENAME = 'D:\mssql\data\MSDBData.mdf' );
ALTER DATABASE [MSDB] MODIFY FILE ( NAME = MSDBLog, FILENAME = 'G:\mssql\logs\MSDBLog.ldf' );

USE master
GO
ALTER DATABASE model MODIFY FILE (NAME = modeldev, FILENAME = 'D:\mssql\data\model.mdf');
ALTER DATABASE model MODIFY FILE (NAME = modellog, FILENAME = 'G:\mssql\logs\modellog.ldf');
