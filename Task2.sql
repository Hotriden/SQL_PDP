-- TASK 1 --
-- SP implementation --
CREATE OR ALTER PROCEDURE spGetDriverData @FieldName NVARCHAR(max), @FieldValue NVARCHAR(max)
AS
BEGIN
	DECLARE @SQL VARCHAR(MAX)

	SET @SQL = 'SELECT DriverFirstName as FirstName, DriverSurName as LastName, DriverUDN as UDN FROM US_Domastic_Company.dbo.TruckDriver 
				WHERE ' + @FieldName + ' = ' + ''''+@FieldValue+''''
    PRINT(@SQL)
	EXEC(@SQL)	
END

EXEC spGetDriverData @FieldName = 'DriverSurName', @FieldValue = 'Nathe';

-- Dynamic string implementation --

DECLARE @SqlString NVARCHAR(MAX);
DECLARE @ParamDefinition NVARCHAR(500);
DECLARE @firstParam NVARCHAR(500);
DECLARE @secondParam NVARCHAR(500);

SET @SqlString = N'SELECT DriverFirstName as FirstName, DriverSurName as LastName, DriverUDN as UDN FROM US_Domastic_Company.dbo.TruckDriver 
				WHERE @FieldName = @FieldValue';
SET @ParamDefinition = N'@FieldName NVARCHAR(500), @FieldValue NVARCHAR(500)'
SET @firstParam = 'DriverSurName';
SET @secondParam = 'Nathe';

exec sp_executesql @SqlString, @ParamDefinition, @FieldName=@firstParam, @FieldValue=@secondParam

-----------------------------

-- Task 1a

CREATE OR ALTER PROCEDURE spGetDriverDataOneA @FirstFieldName NVARCHAR(max), @SecondField NVARCHAR(max), @ThirdField NVARCHAR(max)
AS
BEGIN
	DECLARE @SQL VARCHAR(MAX)

	SET @SQL = 'SELECT DriverFirstName as FirstName, DriverSurName as LastName, DriverUDN as UDN FROM US_Domastic_Company.dbo.TruckDriver 
				WHERE ' + @FirstFieldName + ' = ' + ''''+@SecondField+''''
	EXEC(@SQL)	
END

EXEC spGetDriverData @FieldName = 'DriverSurName', @FieldValue = 'Nathe';


-- SEARCH JSON FROM FIELD --
SELECT JSON_VALUE(DriverInfoJSON, '$.data.PersonalData.Age') as Age
	FROM US_Domastic_Company.dbo.TruckDriver

-- Task 2 --
-- Insert into table duplicated values --
INSERT INTO [US_Domastic_Company].[dbo].[Truck] (BrandName, PlateNumber, Payload, FuelConsumption, CargoVolume) VALUES ('MAN', '1ABC234', 17500, 20, 95)
-- Get Count of duplicated plate numbers --
SELECT COUNT(*) FROM [US_Domastic_Company].[dbo].[Truck] GROUP BY PlateNumber HAVING COUNT(*) > 1
-- Get rid of duplicated plate numbers from tail --
DELETE T FROM (SELECT * , DupRank = ROW_NUMBER() OVER (PARTITION BY PlateNumber ORDER BY TruckId)
	FROM [US_Domastic_Company].[dbo].[Truck]) AS T WHERE DupRank > 1