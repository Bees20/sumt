USE [master]
GO

/****** Object:  Database [appUtilDb]    Script Date: 7/26/2021 6:26:56 AM ******/
CREATE DATABASE [appUtilDb]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'appUtilDb', FILENAME = N'D:\mssql\data\appUtilDb.mdf' , SIZE = 4194304KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1048576KB )
 LOG ON 
( NAME = N'appUtilDb_log', FILENAME = N'G:\mssql\logs\appUtilDb_log.ldf' , SIZE = 1048576KB , MAXSIZE = 2048GB , FILEGROWTH = 1048576KB )
GO



