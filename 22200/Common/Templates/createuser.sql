USE [master]
GO
if not exists (SELECT * FROM sys.server_principals WHERE name = '{{ username }}')
begin
CREATE LOGIN [{{ username }}] WITH PASSWORD=N'{{ pwd }}', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
ALTER SERVER ROLE [sysadmin] ADD MEMBER [{{ username }}]
end