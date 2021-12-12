USE [master]
GO
IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'DataBase')

	BEGIN

CREATE DATABASE [US_Domastic_Company] ON PRIMARY
( NAME = US_Domastic_Company_dat,  
    FILENAME = 'C:\Program Files\Microsoft SQL Server\KVP_PDP\US_Domastic_Company.mdf',  
    SIZE = 10MB,  
    MAXSIZE = 5000MB,  
    FILEGROWTH = 5MB )  
LOG ON  
( NAME = Sales_log,  
    FILENAME = 'C:\Program Files\Microsoft SQL Server\KVP_PDP\US_Domastic_Company.ldf',  
    SIZE = 5MB,  
    MAXSIZE = 250MB,  
    FILEGROWTH = 5MB );
	END

GO
    USE [US_Domastic_Company]
GO
    CREATE SCHEMA UDC_Schema;
