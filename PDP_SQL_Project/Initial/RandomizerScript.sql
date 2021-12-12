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

		DECLARE @doubleCounter INT = 0;
		while @doubleCounter < 2
		BEGIN
			DECLARE @warehouseCity INT = FLOOR(rand()*(SELECT Count(CityId) FROM US_Domastic_Company.dbo.City)+1)
			DECLARE @warehouseName NVARCHAR(30) = 'WareHouse_' + (SELECT CONVERT(nvarchar(10), Count(WarehouseId)) FROM US_Domastic_Company.dbo.Warehouse)
			DECLARE @warehouseCapacity INT = FLOOR(rand()*(100000-1000)+1000)

			INSERT INTO US_Domastic_Company.dbo.Warehouse (CityId, WarehouseName, Capacity) VALUES(
				@warehouseCity,
				@warehouseName,
				@warehouseCapacity
			)
			SET @doubleCounter = @doubleCounter + 1;
		END

		-- Generate Truck Route --

		DECLARE @OriginWareHouse INT = (SELECT FLOOR(rand()*
							(SELECT Count(DISTINCT WareHouseId) FROM US_Domastic_Company.dbo.Warehouse)+1))
		DECLARE @DestinationWareHouse INT = IIF((SELECT FLOOR(rand()*
							(SELECT Count(DISTINCT WareHouseId) FROM US_Domastic_Company.dbo.Warehouse)+1)) != @OriginWareHouse, (
								(SELECT FLOOR(rand()*
							(SELECT Count(DISTINCT WareHouseId) FROM US_Domastic_Company.dbo.Warehouse)+1))
							), @OriginWareHouse-1)

		INSERT INTO US_Domastic_Company.dbo.TruckRoute (WarehouseOrigin, WarehouseDestination, Distance) VALUES(
			(SELECT WareHouseId FROM US_Domastic_Company.dbo.Warehouse WHERE WareHouseId = @OriginWareHouse),
			(SELECT WareHouseId FROM US_Domastic_Company.dbo.Warehouse WHERE WareHouseId = @DestinationWareHouse),
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
		DECLARE @truckDriverInfoJSON NVARCHAR(MAX) = 
			N'{
				"id": 1,
				"data":
				{
					"PersonalData": { "Age": 20, "Sex": "Male" },
					"BankAccount": "Privat Bank",
					"QualificationLevel": { "A": true, "B": true, "C": false, "D": false }
				}
			}'

		INSERT INTO US_Domastic_Company.dbo.TruckDriver (DriverFirstName, DriverSurName, ContactCellPhone, DriverUDN, DriverInfoJSON) VALUES 
			(@truckDriverFirstName, @truckDriverSurName, @truckDriverPhone, @truckDriverUDN, @truckDriverInfoJSON)


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

		-- RecipientContactInfo --
		DECLARE @recipientFirstName NVARCHAR(50) = 
			(SELECT _name FROM US_Domastic_Company.dbo.Name WHERE Id = FLOOR(rand()*(SELECT Count(id) FROM US_Domastic_Company.dbo.Name)+1))
		DECLARE @recipientSurName NVARCHAR(50) = 
			(SELECT _name FROM US_Domastic_Company.dbo.SurName WHERE Id = FLOOR(rand()*(SELECT Count(id) FROM US_Domastic_Company.dbo.SurName)+1))
		DECLARE @recipientPhone NVARCHAR(15) = 
			CONCAT(
				'+1-', LEFT(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)), 3), 
				'-', LEFT(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)), 3), 
				'-', LEFT(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)), 4))

		INSERT INTO [US_Domastic_Company].[dbo].[RecipientContactInformation] (FirstName, LastName, ContactCellPhone) VALUES (
			@recipientFirstName,
			@recipientSurName,
			@recipientPhone
		)

		-- ShipmentFlight --
		DECLARE @shipmentFlight_truckId INT = FLOOR(rand()*(SELECT Count(TruckId) FROM US_Domastic_Company.dbo.Truck)+1)
		DECLARE @shipmentFlight_truckDriverId INT = FLOOR(rand()*(SELECT Count(TruckDriverId) FROM US_Domastic_Company.dbo.TruckDriver)+1)
		DECLARE @shipmentFlight_truckRoute INT = FLOOR(rand()*(SELECT Count(TruckRouteId) FROM US_Domastic_Company.dbo.TruckRoute)+1)
		DECLARE @shipmentFlight_shipmentId INT = (SELECT COUNT(ShipmentFlightId) FROM US_Domastic_Company.dbo.ShipmentFlight)+1

		INSERT INTO [US_Domastic_Company].[dbo].[ShipmentFlight] (TruckId, TruckDriverId, TruckRouteId, ShipmentId) VALUES (
			@shipmentFlight_truckId,
			@shipmentFlight_truckDriverId,
			@shipmentFlight_truckRoute,
			@shipmentFlight_shipmentId
		)

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
		DECLARE @shipmentCompleteTime DATETIME = DATEADD(day, 7, @shipmentCreationTime)
		DECLARE @shipmentPickUpTime DATETIME = DATEADD(day, (CRYPT_GEN_RANDOM(1) % 2), @shipmentCreationTime)
		DECLARE @shipmentContactInfoId BIGINT =
			(SELECT TOP 1 RecipientContactInfoId AS Id FROM [US_Domastic_Company].[dbo].[RecipientContactInformation] 
					WHERE US_Domastic_Company.dbo.RecipientContactInformation.ShipmentId IS NULL)
		DECLARE @shipmentFlight BIGINT =
			(SELECT TOP 1 ShipmentFlightId AS Id FROM [US_Domastic_Company].[dbo].[ShipmentFlight] ORDER BY Id DESC)

		INSERT INTO US_Domastic_Company.dbo.Shipment (BOL, RecipientInformationId, ProNumber, CustomerId, ShipmentVolume, ShipmentWeight, IsHazard, ShipmentDetails, CreationTime, ReceiptTime, PickUpTime, ShipmentFlightId)
			VALUES(
				@shipmentBOL,
				@shipmentContactInfoId,
				@shipmentProNumber,
				@shipmentCustomerId,
				@shipmentVolume,
				@shipmentWeight,
				@shipmentIsHazard,
				@shipmentDetails,
				@shipmentCreationTime,
				@shipmentCompleteTime,
				@shipmentPickUpTime,
				@shipmentFlight
			)
		UPDATE US_Domastic_Company.dbo.RecipientContactInformation SET ShipmentId = (SELECT TOP 1 ShipmentId FROM US_Domastic_Company.dbo.Shipment WHERE RecipientContactInfoId IS NOT NULL ORDER BY ShipmentId DESC)

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
	END
GO