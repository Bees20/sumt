USE [master]
GO

/****** Object:  Database [dbaAdmin]    Script Date: 7/26/2021 6:28:54 AM ******/
CREATE DATABASE [dbaAdmin]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'dbaAdmin', FILENAME = N'D:\MSSQL\Data\dbaAdmin.mdf' , SIZE = 1048576KB , MAXSIZE = UNLIMITED, FILEGROWTH = 524288KB )
 LOG ON 
( NAME = N'dbaAdmin_Log', FILENAME = N'G:\MSSQL\Logs\dbaAdmin_log.ldf' , SIZE = 1048576KB , MAXSIZE = 2048GB , FILEGROWTH = 1048576KB )
GO

