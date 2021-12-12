USE [US_Domastic_Company]
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'User' and xtype='U')
	BEGIN
	CREATE TABLE [dbo].[User] (
		[UserId]                      BIGINT          NOT NULL IDENTITY(1,1),
		[NickName]				      NVARCHAR (50)   NULL,
		[Email]					      NVARCHAR (320)  NOT NULL,
		[RegistrationDate]			  DATE			  NOT NULL,

		CONSTRAINT [PK_User_1] PRIMARY KEY CLUSTERED ([UserId] ASC) WITH (FILLFACTOR = 80)
	);
	END

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'Role' and xtype='U')
	BEGIN
	CREATE TABLE [dbo].[Role] (
		[RoleId]					  BIGINT          NOT NULL IDENTITY(1,1),
		[Name]						  NVARCHAR (50)   NOT NULL,

		CONSTRAINT [PK_Role_1] PRIMARY KEY CLUSTERED ([RoleId] ASC) WITH (FILLFACTOR = 80)
	);
	END

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'User_Role' and xtype='U')
	BEGIN
	CREATE TABLE [dbo].[User_Role] (
		[UserId]                      BIGINT          NOT NULL,
		[RoleId]                      BIGINT          NOT NULL,

		CONSTRAINT [FK_User_Role] FOREIGN KEY (UserId) REFERENCES [dbo].[User] (UserId) ON UPDATE CASCADE ON DELETE CASCADE,
		CONSTRAINT [FK_Role_User] FOREIGN KEY (RoleId) REFERENCES [dbo].[Role] (RoleId) ON UPDATE CASCADE ON DELETE CASCADE
	);
	END

	IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'Customer' and xtype='U')
	BEGIN
	CREATE TABLE [dbo].[Customer](
		[CustomerId]                  BIGINT         NOT NULL IDENTITY(1,1),
		[UserId]		              BIGINT         NOT NULL,
		[IsPrimaryUserCustomer]		  BIT			 NOT NULL,
		[FirstName]					  NVARCHAR (20)  NOT NULL,
		[LastName]					  NVARCHAR (20)  NULL,
		[Email]					      NVARCHAR (320) NOT NULL,
		[PhoneNumber]				  NVARCHAR (15)  NULL,
		[RegistrationDateTime]		  DATE			 NOT NULL,
		[LastActivityDateTime]		  DATETIME		 NULL,
		[IsActive]					  BIT			 NOT NULL,

		CONSTRAINT [PK_Customer_1] PRIMARY KEY CLUSTERED ([CustomerId] ASC) WITH (FILLFACTOR = 80),
		CONSTRAINT [FK_Customer_to_User] FOREIGN KEY (UserId) REFERENCES [dbo].[User] (UserId) ON UPDATE CASCADE ON DELETE CASCADE
	);
	END

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'Cargo' and xtype='U')
	BEGIN
	CREATE TABLE [dbo].[Cargo](
		[CargoId]	                  BIGINT         NOT NULL IDENTITY(1,1),
		[CustomerId]                  BIGINT         NOT NULL,
		[CargoName]		              NVARCHAR (50)  NOT NULL,
		[Volume]				      INT			 NOT NULL,
		[Description]			      NVARCHAR (500) NULL,

		CONSTRAINT [PK_Cargo_1] PRIMARY KEY CLUSTERED ([CargoId] ASC) WITH (FILLFACTOR = 80),
		CONSTRAINT [FK_Cargo_to_Customer] FOREIGN KEY (CustomerId) REFERENCES [dbo].[Customer](CustomerId)
	);
	END

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'City' and xtype='U')
	BEGIN
	CREATE TABLE [dbo].[City](
		[CityId]		              BIGINT        NOT NULL IDENTITY(1,1),
		[Name]			              NVARCHAR (50) NOT NULL,
		[State]					      NVARCHAR (2)  NULL,

		CONSTRAINT [PK_City_1] PRIMARY KEY CLUSTERED ([CityId] ASC) WITH (FILLFACTOR = 80),
	);
	END

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'TruckRoute' and xtype='U')
	BEGIN
	CREATE TABLE [dbo].[TruckRoute](
		[TruckRouteId]				BIGINT			NOT NULL IDENTITY(1,1),
		[WarehouseOrigin]			BIGINT			NOT NULL,
		[WarehouseDestination]		BIGINT			NOT NULL,
		[Distance]					INT				NOT NULL,

		CONSTRAINT [PK_TruckToute_1] PRIMARY KEY CLUSTERED ([TruckRouteId] ASC) WITH (FILLFACTOR = 80),
		CONSTRAINT [FK_WareHouseOrigin_to_City]		 FOREIGN KEY (WarehouseOrigin)		REFERENCES [dbo].[City] (CityId),
		CONSTRAINT [FK_WareHouseDestination_to_City] FOREIGN KEY (WarehouseDestination) REFERENCES [dbo].[City] (CityId),
	);
	END

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'Warehouse' and xtype='U')
	BEGIN
	CREATE TABLE [dbo].[Warehouse](
		[WarehouseId]                 BIGINT          NOT NULL IDENTITY(1,1),
		[CityId]				      BIGINT		  NOT NULL,
		[WarehouseName]			      NVARCHAR (50)   NULL,
		[Capacity]				      INT			  NULL,

		CONSTRAINT [PK_WareHouse_1] PRIMARY KEY CLUSTERED ([WarehouseId] ASC) WITH (FILLFACTOR = 80),
		CONSTRAINT [FK_WareHouse_to_City] FOREIGN KEY (CityId) REFERENCES [dbo].[City] (CityId)
	);
	END

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'TruckDriver' and xtype='U')
	BEGIN
	CREATE TABLE [dbo].[TruckDriver](
		[TruckDriverId]               BIGINT          NOT NULL IDENTITY(1,1),
		[DriverFirstName]             NVARCHAR(20)    NOT NULL,
		[DriverSurName]               NVARCHAR(20)    NOT NULL,
		[ContactCellPhone]			  NVARCHAR(15)    NOT NULL,	
		[DriverUDN]		              NVARCHAR(20)    NOT NULL,

		[DriverInfoJSON]			  NVARCHAR(MAX)   NULL,

		CONSTRAINT [PK_TruckDriver_1] PRIMARY KEY CLUSTERED ([TruckDriverId] ASC) WITH (FILLFACTOR = 80),
		CONSTRAINT [Content should be formatted as JSON] CHECK ( ISJSON(DriverInfoJSON)>0),
	);
	END

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'Truck' and xtype='U')
	BEGIN
	CREATE TABLE [dbo].[Truck](
		[TruckId]					BIGINT			NOT NULL IDENTITY(1,1),
		[BrandName]					NVARCHAR(30)    NOT NULL,
		[PlateNumber]				NVARCHAR(10)    NOT NULL, 
		[Payload]					INT				NULL, 
		[CargoVolume]				INT				NULL, 
		[FuelConsumption]			INT				NULL,

		CONSTRAINT [PK_Truck_1] PRIMARY KEY CLUSTERED ([TruckId] ASC) WITH (FILLFACTOR = 80),
	);
	END

	
IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'RecipientContactInformation' and xtype='U')
	BEGIN
	CREATE TABLE [dbo].[RecipientContactInformation](
		[RecipientContactInfoId]	BIGINT			NOT NULL  IDENTITY(1,1),
		[ShipmentId]				BIGINT			NULL,
		[FirstName]					NVARCHAR (50)	NOT NULL,
		[LastName]					NVARCHAR (50)	NULL,
		[ContactCellPhone]			NVARCHAR (15)	NOT NULL,

		CONSTRAINT [PK_RecipientContactInfo_1] PRIMARY KEY CLUSTERED ([RecipientContactInfoId] ASC) WITH (FILLFACTOR = 80)
	);
	END
	
IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'ShipmentFlight' and xtype='U')
	BEGIN
	CREATE TABLE [dbo].[ShipmentFlight](
		[ShipmentFlightId]			BIGINT			NOT NULL IDENTITY(1,1),
		[TruckId]					BIGINT			NULL,
		[TruckDriverId]				BIGINT			NULL,
		[ShipmentId]				BIGINT			NULL,
		[TruckRouteId]				BIGINT			NULL
	
	CONSTRAINT	[PK_ShipmentFlightId] PRIMARY KEY CLUSTERED ([ShipmentFlightId] ASC) WITH (FILLFACTOR = 80)
	CONSTRAINT  [FK_ShipmentFlight_TruckId]		  FOREIGN KEY (TruckId)		  REFERENCES [dbo].[Truck] (TruckId),
	CONSTRAINT  [FK_ShipmentFlight_TruckDriverId] FOREIGN KEY (TruckDriverId) REFERENCES [dbo].[TruckDriver] (TruckDriverId),
	CONSTRAINT  [FK_ShipmentFlight_TruckRouteId]  FOREIGN KEY (TruckRouteId)  REFERENCES [dbo].[TruckRoute] (TruckRouteId)
	);
	END

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'Shipment' and xtype='U')
	BEGIN
	CREATE TABLE [dbo].[Shipment](
		[ShipmentId]				BIGINT			NOT NULL IDENTITY(1,1),
		[BOL]						NVARCHAR (10)	NOT NULL,
		[ProNumber]					NVARCHAR (10)	NULL,
		[CustomerId]				BIGINT			NOT NULL,
		[RecipientInformationId]	BIGINT			NULL,
		[ShipmentVolume]			INT				NOT NULL,
		[ShipmentWeight]			INT				NOT NULL,
		[IsHazard]					BIT				NOT NULL,
		[ShipmentDetails]			NVARCHAR(500)	NULL,
		[CreationTime]				DATETIME		NULL,
		[PickUpTime]				DATETIME		NULL,
		[ReceiptTime]				DATETIME		NULL,
		[ShipmentFlightId]			BIGINT			NULL,

		CONSTRAINT [PK_Shipment_1]				 PRIMARY KEY CLUSTERED ([ShipmentId] ASC) WITH (FILLFACTOR = 80),
		CONSTRAINT [FK_Shipment_to_Customer]	 FOREIGN KEY (CustomerId)	REFERENCES [dbo].[Customer] (CustomerId),
		CONSTRAINT [FK_Shipment_to_ShipmentInfo] FOREIGN KEY (RecipientInformationId) REFERENCES [dbo].[RecipientContactInformation] (RecipientContactInfoId) ON UPDATE CASCADE ON DELETE CASCADE,
		CONSTRAINT [FK_Shipment_to_ShipmentFlight] FOREIGN KEY (ShipmentFlightId) REFERENCES [dbo].[ShipmentFlight] (ShipmentFlightId) ON UPDATE CASCADE ON DELETE CASCADE
	);
	END

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'Cargo_Shipment' and xtype='U')
	BEGIN
	CREATE TABLE [dbo].[Cargo_Shipment](
		[CargoId]                      BIGINT          NOT NULL,
		[ShipmentId]                   BIGINT          NOT NULL,

		CONSTRAINT [PK_cargoShipment_to_cargo] FOREIGN KEY (CargoId) REFERENCES [dbo].[Cargo] (CargoId) ON UPDATE CASCADE ON DELETE CASCADE,
		CONSTRAINT [PK_cargoShipment_to_shipment] FOREIGN KEY (ShipmentId) REFERENCES [dbo].[Shipment] (ShipmentId) ON UPDATE CASCADE ON DELETE CASCADE
	);
	END

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'CargoList' and xtype='U')
	BEGIN
	CREATE TABLE [dbo].[CargoList] (Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY, CargoName Nvarchar(30))
	END

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'Name' and xtype='U')
	BEGIN
	CREATE TABLE dbo.Name (Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY, _name Nvarchar(50))
	END

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'SurName' and xtype='U')
	BEGIN
	CREATE TABLE dbo.SurName (Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY, _name Nvarchar(50))
	END

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'TruckBrand' and xtype='U')
	BEGIN
	CREATE TABLE dbo.TruckBrand (Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY, TruckBrandName Nvarchar(30))
	END