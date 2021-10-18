CREATE OR ALTER PROCEDURE spDataRandomizer @Iteration int
AS 
	SET NOCOUNT ON
	DECLARE @i int = 0
	DECLARE @FromDate date = '2011-01-01'
	DECLARE @ToDate date = '2020-12-31'
	DECLARE @EmailDomains Table (id INT, name Varchar(25))
	Insert Into @EmailDomains Values 
		(1, 'gmail.com'),
		(2, 'yahoo.com'),
		(3, 'hotmail.com'),
		(4, 'aol.com'),
		(5, 'hotmail.co.uk'),
		(6, 'hotmail.fr'),
		(7, 'msn.com'),
		(8, 'comcast.net'),
		(9, 'live.com'),
		(10, 'rediffmail.com'),
		(11, 'ymail.com'),
		(12, 'outlook.com'),
		(13, 'cox.net'),
		(14, 'sbcglobal.net'),
		(15, 'verizon.net'),
		(16, 'googlemail.com'),
		(17, 'bigpond.com'),
		(18, 'yahoo.it'),
		(19, 'rocketmail.com'),
		(20, 'facebook.com');

	WHILE @i <  @Iteration
	BEGIN
		SET @i = @i + 1

		-- Generate Truck Route --


		-- Generate Users --

		DECLARE @userNickName NVARCHAR(20) = 
			(CONCAT(
				SUBSTRING(
					(SELECT _name FROM US_Domastic_Company.dbo.Name WHERE US_Domastic_Company.dbo.Name.Id = 
						(SELECT FLOOR(rand()*
							(SELECT Count(DISTINCT Id) FROM US_Domastic_Company.dbo.Name)+1))), 1,1),
					(SELECT _name FROM US_Domastic_Company.dbo.SurName WHERE Id =
						(SELECT FLOOR(rand()*
							(SELECT Count(DISTINCT Id) FROM US_Domastic_Company.dbo.SurName)+1))
						)        
					)
			);

		DECLARE @userEmail NVARCHAR(320) =
			CONCAT(@userNickname, '@', (SELECT name FROM @EmailDomains WHERE Id = FLOOR(rand()*20+1)))
			
		DECLARE @userRegistrationDateTime DATE = 
			(SELECT dateadd(day, rand(checksum(newid()))*(1+datediff(day, @FromDate, @ToDate)), @FromDate))

		INSERT INTO [US_Domastic_Company].[dbo].[User] (NickName, Email, RegistrationDate) VALUES(
			@userNickName,
			(UPPER(LEFT(@userEmail,1))+LOWER(SUBSTRING(@userEmail,2,LEN(@userEmail)))),
			@userRegistrationDateTime
		)

		-- Generate Customers --

		DECLARE @randomUserId INT = FLOOR(rand()*(SELECT Count(UserId) FROM [US_Domastic_Company].[dbo].[User])+1)
		DECLARE @isPrimaryUserCustomer BIT = 
			IIF((SELECT COUNT(Customer.userId) FROM [US_Domastic_Company].[dbo].[User] 
				JOIN US_Domastic_Company.dbo.Customer ON [User].[UserId] = Customer.UserId WHERE [User].[UserId] = @randomUserId) = 0, 1, 0)

		DECLARE @customerFirstName NVARCHAR(20) = 
					(SELECT _name FROM US_Domastic_Company.dbo.Name WHERE US_Domastic_Company.dbo.Name.Id = 
						(SELECT FLOOR(rand()*(SELECT Count(DISTINCT Id) FROM US_Domastic_Company.dbo.Name)+1)));

		DECLARE @customerLastName NVARCHAR(20) = 
					(SELECT _name FROM US_Domastic_Company.dbo.SurName WHERE US_Domastic_Company.dbo.SurName.Id = 
						(SELECT FLOOR(rand()*(SELECT Count(DISTINCT Id) FROM US_Domastic_Company.dbo.SurName)+1)));

		DECLARE @customerEmail NVARCHAR(320) = 
			CONCAT(@customerLastName, '@', (SELECT name FROM @EmailDomains WHERE Id = FLOOR(rand()*20+1)))

		DECLARE @customerPhoneNumber NVARCHAR(15) =
			CONCAT(
				'+1-', LEFT(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)), 3), 
				'-', LEFT(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)), 3), 
				'-', LEFT(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)), 4))

		DECLARE @customerRegistrationDate DATE = 
			(SELECT dateadd(day, rand(checksum(newid()))*(1+datediff(day, '2011-01-01', '2020-12-31')), '2011-01-01'))

		DECLARE @customerLastActivityDateTime DATETIME = 
			(DATEADD(SECOND, 
				ROUND(((
					datediff(second, '2021-01-01 00:00:00', '2021-10-10 12:30:00')-1) * RAND()), 0), '2021-01-01 00:00:00'))

		INSERT INTO US_Domastic_Company.dbo.Customer 
		(UserId, IsPrimaryUserCustomer, FirstName, LastName, Email, PhoneNumber, RegistrationDateTime, LastActivityDateTime, IsActive) 
		VALUES(
			@randomUserId,
			@isPrimaryUserCustomer,
			@customerFirstName,
			@customerLastName,
			@customerEmail,
			@customerPhoneNumber,
			@customerRegistrationDate,
			@customerLastActivityDateTime,
			CRYPT_GEN_RANDOM(1) % 2)

		-- Generate cargo --

		DECLARE @randomCustomerId INT = FLOOR(rand()*(SELECT Count(CustomerId) FROM US_Domastic_Company.dbo.Customer)+1)
		DECLARE @randomCargoName NVARCHAR(30) = 
			(SELECT CargoName FROM US_Domastic_Company.dbo.CargoList WHERE Id=(FLOOR(rand()*(SELECT Count(Id) FROM US_Domastic_Company.dbo.CargoList)+1)))
		INSERT INTO US_Domastic_Company.dbo.Cargo (CustomerId, CargoName, Volume, Description) VALUES(
			@randomCustomerId,
			@randomCargoName,
			FLOOR(rand()*1000)+1,
			'Some random description'
		)

		-- Generate warehouse --

		DECLARE @warehouseCity INT = FLOOR(rand()*(SELECT Count(CityId) FROM US_Domastic_Company.dbo.City)+1)
		DECLARE @warehouseName NVARCHAR(30) = 'WareHouse_' + (SELECT CONVERT(nvarchar(10), Count(WarehouseId)) FROM US_Domastic_Company.dbo.Warehouse)
		DECLARE @warehouseCapacity INT = FLOOR(rand()*(100000-1000)+1000)

		INSERT INTO US_Domastic_Company.dbo.Warehouse (CityId, WarehouseName, Capacity) VALUES(
			@warehouseCity,
			@warehouseName,
			@warehouseCapacity
		)

		
		DECLARE @OriginWareHouse INT = (SELECT FLOOR(rand()*
							(SELECT Count(DISTINCT WareHouseId) FROM US_Domastic_Company.dbo.Warehouse)+1))
		DECLARE @DestinationWareHouse INT = (SELECT FLOOR(rand()*
							(SELECT Count(DISTINCT WareHouseId) FROM US_Domastic_Company.dbo.Warehouse)+1))

		INSERT INTO US_Domastic_Company.dbo.TruckRoute (WarehouseOrigin, WarehouseDestination, Distance) VALUES(
			(SELECT WareHouseId FROM US_Domastic_Company.dbo.Warehouse WHERE WareHouseId = @OriginWareHouse),
			(SELECT WareHouseId FROM US_Domastic_Company.dbo.Warehouse WHERE WareHouseId = IIF(@OriginWareHouse != @DestinationWareHouse, @DestinationWareHouse, 
				(SELECT FLOOR(rand()*(SELECT Count(DISTINCT CityId) FROM US_Domastic_Company.dbo.City)+@DestinationWareHouse)))),
			(SELECT FLOOR(rand()*(3000-100)+100))
		);

		-- Generate truck driver --
		DECLARE @truckDriverFirstName NVARCHAR(20) = 
			(SELECT _name FROM US_Domastic_Company.dbo.Name WHERE US_Domastic_Company.dbo.Name.Id = 
				(SELECT FLOOR(rand()*(SELECT Count(DISTINCT Id) FROM US_Domastic_Company.dbo.Name)+1)));
		DECLARE @truckDriverSurName NVARCHAR(20) = 
			(SELECT _name FROM US_Domastic_Company.dbo.SurName WHERE US_Domastic_Company.dbo.SurName.Id = 
				(SELECT FLOOR(rand()*(SELECT Count(DISTINCT Id) FROM US_Domastic_Company.dbo.SurName)+1)));
		DECLARE @truckDriverPhone NVARCHAR(15) = 
			CONCAT(
				'+1-', LEFT(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)), 3), 
				'-', LEFT(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)), 3), 
				'-', LEFT(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)), 4))
		DECLARE @truckDriverUDN NVARCHAR(9) = 'UDN' + CONVERT(NVARCHAR(4) ,FLOOR(rand()*9999+1)) + (SELECT CHAR((rand()*25 + 65))+char((rand()*25 + 65)))

		INSERT INTO US_Domastic_Company.dbo.TruckDriver (DriverFirstName, DriverSurName, ContactCellPhone, DriverUDN) VALUES 
			(@truckDriverFirstName, @truckDriverSurName, @truckDriverPhone, @truckDriverUDN)


		-- Generate truck --
		DECLARE @truckBrandName NVARCHAR(30) = 
			(SELECT TruckBrandName FROM US_Domastic_Company.dbo.TruckBrand WHERE Id =
				(SELECT FLOOR(rand()*(SELECT Count(DISTINCT Id) FROM US_Domastic_Company.dbo.TruckBrand)+1)));

		DECLARE @truckPlateNumber NVARCHAR(10) = left(NEWID(),5)+'-'+left(NEWID(),2)
		DECLARE @truckPayload INT = FLOOR(rand()*(25000-11794)+11794)	
		DECLARE @truckCargoVolume INT = FLOOR(rand()*(120-80)+80)
		DECLARE @truckFuelConsumption INT = FLOOR(rand()*(45.0-30.0)+30.0)

		INSERT INTO US_Domastic_Company.dbo.Truck (BrandName, PlateNumber, Payload, CargoVolume, FuelConsumption) VALUES(
			@truckBrandName, @truckPlateNumber, @truckPayload, @truckCargoVolume, @truckFuelConsumption)

		-- Generate Shipment --
		DECLARE @shipmentBOL NVARCHAR(10) = CONVERT(varchar(255), NEWID())
		DECLARE @shipmentProNumber NVARCHAR(10) = CONVERT(varchar(255), NEWID())
		DECLARE @shipmentCustomerId INT = (SELECT CustomerId FROM US_Domastic_Company.dbo.Customer WHERE CustomerId = FLOOR(rand()*
			(SELECT Count(CustomerId) FROM US_Domastic_Company.dbo.Customer)+1))
		DECLARE @shipmentVolume INT = FLOOR(rand()*(1000-100)+100)
		DECLARE @shipmentWeight INT = FLOOR(rand()*(1000-100)+100)
		DECLARE @shipmentIsHazard BIT = CRYPT_GEN_RANDOM(1) % 2
		DECLARE @shipmentDetails NVARCHAR(500) = 'Lorem ipsum dolor sit amet. Amet repellendus aut beatae enim et iste accusamus ea perspiciatis cupiditate eum consequatur molestiae. Ad neque deleniti vel dolorem quisquam qui nesciunt quae et omnis consequatur. Qui laborum quia nam voluptas dolores est repellat galisum eos magnam quia sed rerum consectetur hic consequatur odit et numquam sunt. Et nihil voluptatibus eum odit fugit est praesentium dolorem et ratione fugit et omnis nostrum. Eum necessitatibus cumque in animi quia At ipsa molestias et nesciunt voluptatum aut aliquam quia ea aliquid ipsa. Eum adipisci consequatur ea veritatis optio eum quis recusandae. In ipsam perspiciatis eos ullam saepe sed distinctio voluptatem et voluptatem cumque. Aut commodi maxime non corporis quae porro maiores et reprehenderit quia!'
		DECLARE @shipmentCreationTime DATETIME = 
			(DATEADD(SECOND, 
				ROUND(((
					datediff(second, '2021-01-01 00:00:00', '2021-10-10 12:30:00')-1) * RAND()), 0), '2021-01-01 00:00:00'))
		DECLARE @shipmentPickUpTime DATETIME = 
			(DATEADD(SECOND, 
				ROUND(((
					datediff(second, '2021-01-01 00:00:00', '2021-10-10 12:30:00')-1) * RAND()), 0), '2021-01-01 00:00:00'))
		

		INSERT INTO US_Domastic_Company.dbo.Shipment (BOL, ProNumber, CustomerId, ShipmentVolume, ShipmentWeight, IsHazard, ShipmentDetails, CreationTime, PickUpTime)
			VALUES(
				@shipmentBOL,
				@shipmentProNumber,
				@shipmentCustomerId,
				@shipmentVolume,
				@shipmentWeight,
				@shipmentIsHazard,
				@shipmentDetails,
				@shipmentCreationTime,
				@shipmentPickUpTime
			)

		-- CargoShipment -- 
		DECLARE @cargoShipment_cargoId INT = FLOOR(rand()*(SELECT Count(CargoId) FROM US_Domastic_Company.dbo.Cargo)+1)
		DECLARE @cargoShipment_shipmentId INT = (SELECT ShipmentId FROM US_Domastic_Company.dbo.Shipment WHERE ShipmentId =
			(FLOOR(rand()*(SELECT Count(ShipmentId) FROM [US_Domastic_Company].[dbo].[Shipment])+1)))
		
		INSERT INTO US_Domastic_Company.dbo.Cargo_Shipment (ShipmentId, CargoId) VALUES(
			@cargoShipment_shipmentId,
			@cargoShipment_cargoId
			)

		-- UserRole --

		DECLARE @userWithoutRole BIGINT = 
			(SELECT TOP 1 userSearch.UserId From [US_Domastic_Company].[dbo].[User] as userSearch LEFT JOIN [US_Domastic_Company].[dbo].[User_Role] as user_roleSearch ON (userSearch.UserId = user_roleSearch.UserId) WHERE user_roleSearch.UserId IS NULL)
		INSERT INTO [US_Domastic_Company].[dbo].[User_Role] (UserId, RoleId) VALUES (@userWithoutRole, 3)

		-- RecipientContactInfo --
		DECLARE @recipientShipmentId BIGINT = FLOOR(rand()*(SELECT Count(ShipmentId) FROM US_Domastic_Company.dbo.Shipment)+1)
		DECLARE @recipientFirstName NVARCHAR(50) = 
			(SELECT _name FROM US_Domastic_Company.dbo.Name WHERE Id = FLOOR(rand()*(SELECT Count(id) FROM US_Domastic_Company.dbo.Name)+1))
		DECLARE @recipientSurName NVARCHAR(50) = 
			(SELECT _name FROM US_Domastic_Company.dbo.SurName WHERE Id = FLOOR(rand()*(SELECT Count(id) FROM US_Domastic_Company.dbo.SurName)+1))
		DECLARE @recipientPhone NVARCHAR(15) = 
			CONCAT(
				'+1-', LEFT(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)), 3), 
				'-', LEFT(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)), 3), 
				'-', LEFT(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)), 4))

		INSERT INTO [US_Domastic_Company].[dbo].[RecipientContactInformation] (ShipmentId, FirstName, LastName, ContactCellPhone) VALUES (
			@recipientShipmentId,
			@recipientFirstName,
			@recipientSurName,
			@recipientPhone
		)

		-- ShipmentFlight --
		DECLARE @shipmentFlight_truckId INT = FLOOR(rand()*(SELECT Count(TruckId) FROM US_Domastic_Company.dbo.Truck)+1)
		DECLARE @shipmentFlight_truckDriverId INT = FLOOR(rand()*(SELECT Count(TruckDriverId) FROM US_Domastic_Company.dbo.TruckDriver)+1)
		DECLARE @shipmentFlight_shipmentId INT = FLOOR(rand()*(SELECT Count(ShipmentId) FROM US_Domastic_Company.dbo.Shipment)+1)
		DECLARE @shipmentFlight_truckRoute INT = FLOOR(rand()*(SELECT Count(TruckRouteId) FROM US_Domastic_Company.dbo.TruckRoute)+1)

		INSERT INTO [US_Domastic_Company].[dbo].[ShipmentFlight] (TruckId, TruckDriverId, ShipmentId, TruckRouteId) VALUES (
			@shipmentFlight_truckId,
			@shipmentFlight_truckDriverId,
			@shipmentFlight_shipmentId,
			@shipmentFlight_truckRoute
		)
	END
GO

EXEC spDataRandomizer @Iteration = 100

CREATE OR ALTER VIEW vShipmentSearch AS 
	SELECT shipment.ShipmentId as Id, cityOrigin.Name as Origin, cityDestination.Name as DestinationCity, truck.BrandName as TruckBrand, shipment.PickUpTime as DateTimeShipmentStarted, 
		shipment.ReceiptTime as DateTimeShipmentCompleted, shipment.ShipmentWeight as TotalWeightAllShipmentCargo, shipment.ShipmentVolume as TotalVolum, 
		truckRoute.Distance*truck.FuelConsumption/100 as FuelSpent FROM [US_Domastic_Company].[dbo].[Shipment] as shipment 
			LEFT JOIN [US_Domastic_Company].[dbo].ShipmentFlight as shipFlight ON shipment.ShipmentId = shipFlight.ShipmentId
			LEFT JOIN [US_Domastic_Company].[dbo].TruckRoute as truckRoute ON shipFlight.TruckRouteId = truckRoute.TruckRouteId
			LEFT JOIN [US_Domastic_Company].[dbo].Warehouse as wareHouseOrigin ON truckRoute.WarehouseOrigin = wareHouseOrigin.CityId
			LEFT JOIN [US_Domastic_Company].[dbo].Warehouse as wareHouseDestination ON truckRoute.WarehouseDestination = wareHouseDestination.CityId
			LEFT JOIN [US_Domastic_Company].[dbo].City as cityOrigin ON wareHouseOrigin.CityId = cityOrigin.CityId
			LEFT JOIN [US_Domastic_Company].[dbo].City as cityDestination ON wareHouseDestination.CityId = cityDestination.CityId
			LEFT JOIN [US_Domastic_Company].[dbo].Truck as truck ON shipFlight.TruckId = truck.TruckId
			LEFT JOIN [US_Domastic_Company].[dbo].Cargo_Shipment as cargoShipment ON shipment.ShipmentId = cargoShipment.ShipmentId
			LEFT JOIN [US_Domastic_Company].[dbo].Cargo as cargo ON cargoShipment.CargoId = cargo.CargoId
	
SELECT TOP(100) * FROM vShipmentSearch