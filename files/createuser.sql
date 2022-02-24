USE [master]
GO
if not exists (SELECT * FROM sys.server_principals WHERE name = '{{ username }}')
begin
CREATE LOGIN [{{ username }}] FROM WINDOWS WITH DEFAULT_DATABASE=[master], EXEC master..sp_addsrvrolemember @loginame = N'{{ username }}', @rolename = N'sysadmin'
end
