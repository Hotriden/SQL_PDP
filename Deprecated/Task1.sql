EXEC spDataRandomizer @Iteration = 100

-- VIEW Task 1 -- 
CREATE OR ALTER VIEW vShipmentSearch AS 
	SELECT shipment.ShipmentId as Id, originCity.Name as OriginCity, destinationCity.Name as DestinationCity, truck.BrandName as TruckBrandName, shipment.PickUpTime as DateTimeShipmentStarted,
	shipment.ReceiptTime as DateTimeShipmentCompleted, shipment.ShipmentWeight TotalWeightAllShipmentCargo, shipment.ShipmentVolume as TotalVolum, 
	truckRoute.Distance*truck.FuelConsumption/100 as FuelSpent
		FROM [US_Domastic_Company].[dbo].[Shipment] as shipment
		LEFT JOIN [US_Domastic_Company].[dbo].[ShipmentFlight] as shipmentFlight ON shipment.ShipmentId = shipmentFlight.ShipmentId
		LEFT JOIN [US_Domastic_Company].[dbo].[Truck] as truck ON truck.TruckId = shipmentFlight.TruckId
		LEFT JOIN [US_Domastic_Company].[dbo].[TruckRoute] as truckRoute ON shipmentFlight.TruckRouteId = truckRoute.TruckRouteId
		LEFT JOIN [US_Domastic_Company].[dbo].[Warehouse] as originWareHouse ON truckRoute.WarehouseOrigin = originWareHouse.WarehouseId
		LEFT JOIN [US_Domastic_Company].[dbo].[Warehouse] as destinationWareHouse ON truckRoute.WarehouseDestination = destinationWareHouse.WarehouseId
		LEFT JOIN [US_Domastic_Company].[dbo].[City] as originCity ON originWareHouse.CityId = originCity.CityId
		LEFT JOIN [US_Domastic_Company].[dbo].[City] as destinationCity ON destinationWareHouse.CityId = destinationCity.CityId

SELECT TOP(100) * FROM vShipmentSearch ORDER BY Id

-- CTE Task 1 without recursion --

;WITH CTE_shipmentSearch AS 
	(SELECT shipment.ShipmentId as Id, originCity.Name as OriginCity, destinationCity.Name as DestinationCity, truck.BrandName as TruckBrandName, shipment.PickUpTime as DateTimeShipmentStarted,
	shipment.ReceiptTime as DateTimeShipmentCompleted, shipment.ShipmentWeight TotalWeightAllShipmentCargo, shipment.ShipmentVolume as TotalVolum, 
	truckRoute.Distance*truck.FuelConsumption/100 as FuelSpent
		FROM [US_Domastic_Company].[dbo].[Shipment] as shipment
		LEFT JOIN [US_Domastic_Company].[dbo].[ShipmentFlight] as shipmentFlight ON shipment.ShipmentId = shipmentFlight.ShipmentId
		LEFT JOIN [US_Domastic_Company].[dbo].[Truck] as truck ON truck.TruckId = shipmentFlight.TruckId
		LEFT JOIN [US_Domastic_Company].[dbo].[TruckRoute] as truckRoute ON shipmentFlight.TruckRouteId = truckRoute.TruckRouteId
		LEFT JOIN [US_Domastic_Company].[dbo].[Warehouse] as originWareHouse ON truckRoute.WarehouseOrigin = originWareHouse.WarehouseId
		LEFT JOIN [US_Domastic_Company].[dbo].[Warehouse] as destinationWareHouse ON truckRoute.WarehouseDestination = destinationWareHouse.WarehouseId
		LEFT JOIN [US_Domastic_Company].[dbo].[City] as originCity ON originWareHouse.CityId = originCity.CityId
		LEFT JOIN [US_Domastic_Company].[dbo].[City] as destinationCity ON destinationWareHouse.CityId = destinationCity.CityId
		)
		SELECT TOP(100) * FROM CTE_shipmentSearch

-- CROSS APPLY -- 

SELECT TOP 100 shipment.ShipmentId as Id, cityOrigin.Name as OriginCity, cityDest.Name as DestinationCity, truck.BrandName as TruckBrandName, shipment.PickUpTime as DateTimeShipmentStarted,
	shipment.ReceiptTime as DateTimeShipmentCompleted, shipment.ShipmentWeight TotalWeightAllShipmentCargo, shipment.ShipmentVolume as TotalVolum, 
	truckRoute.Distance*truck.FuelConsumption/100 as FuelSpent
		FROM [US_Domastic_Company].[dbo].[Shipment] as shipment
		CROSS APPLY (
			SELECT ShipmentId, ShipmentFlightId, TruckId, TruckRouteId FROM [US_Domastic_Company].[dbo].[ShipmentFlight] as shipmentFlight WHERE shipment.ShipmentId = shipmentFlight.ShipmentId) as SF 
			CROSS APPLY (
				SELECT TruckId, BrandName, FuelConsumption FROM [US_Domastic_Company].[dbo].[Truck] as truck where SF.TruckId = truck.TruckId) truck
			CROSS APPLY (
				SELECT TruckRouteId, WarehouseOrigin, WarehouseDestination, Distance FROM [US_Domastic_Company].[dbo].[TruckRoute] as truckRoute WHERE SF.TruckRouteId = truckRoute.TruckRouteId) truckRoute
				CROSS APPLY (
					SELECT WarehouseId, CityId FROM [US_Domastic_Company].[dbo].[Warehouse] as wareHouse where truckRoute.WarehouseOrigin = wareHouse.WarehouseId) wareHouseOrigin
					CROSS APPLY (
						SELECT CityId, Name FROM [US_Domastic_Company].[dbo].[City] as city where wareHouseOrigin.CityId = city.CityId) cityOrigin
				CROSS APPLY (
					SELECT WarehouseId, CityId FROM [US_Domastic_Company].[dbo].[Warehouse] as wareHouse where truckRoute.WarehouseDestination = wareHouse.WarehouseId) wareHouseDest
					CROSS APPLY (
						SELECT CityId, Name FROM [US_Domastic_Company].[dbo].[City] as city where wareHouseDest.CityId = city.CityId) cityDest
		ORDER BY Id