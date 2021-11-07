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

EXEC spGetDriverData @FieldName = 'DriverSurName', @FieldValue = 'Caravella';

-- Dynamic string implementation --

DECLARE @SqlString NVARCHAR(MAX);
DECLARE @ParamDefinition NVARCHAR(500);
DECLARE @firstParam NVARCHAR(50);
DECLARE @secondParam NVARCHAR(50);

SET @firstParam = 'DriverSurName';
SET @secondParam = '''Caravella''';
SET @ParamDefinition = N'@FieldName NVARCHAR(500), @FieldValue NVARCHAR(500)'

SET @SqlString = N'SELECT DriverFirstName as FirstName, DriverSurName as LastName, DriverUDN as UDN FROM US_Domastic_Company.dbo.TruckDriver 
				WHERE '+@FieldName + ' = ' + @FieldValue;

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

-- Task 3 --
CREATE OR ALTER PROCEDURE spGetDriverDataByXML @XCriteria as XML
AS
BEGIN
	DECLARE @SQL VARCHAR(MAX)

	SET @SQL = 'SELECT DriverFirstName as FirstName, DriverSurName as LastName, DriverUDN as UDN FROM US_Domastic_Company.dbo.TruckDriver 
		WHERE @XCriteria.value(' + 'truckDriverId' + ', ROOT ' + ('driverPersonalInfo')
    PRINT(@SQL)
	EXEC(@SQL)	
END

--- XML FILE EXAMPLE
DECLARE @XMLExample as XML
SET @XMLExample = '<?xml version="1.0" encoding="UTF-8"?>
<driverdata>
  <driverPersonalInfo>
    <truckDriverId>112</truckDriverId>
    <driverFirstName>Jannet</driverFirstName>
    <driverSurName>Teske</driverSurName>
    <driverUdn>UDN3176CV</driverUdn>
  </driverPersonalInfo>
  <driverPersonalInfo>
    <truckDriverId>113</truckDriverId>
    <driverFirstName>Fonda</driverFirstName>
    <driverSurName>Mull</driverSurName>
    <driverUdn>UDN4817RI</driverUdn>
  </driverPersonalInfo>
  <driverPersonalInfo>
    <truckDriverId>114</truckDriverId>
    <driverFirstName>Laverna</driverFirstName>
    <driverSurName>Hugel</driverSurName>
    <driverUdn>UDN7157RX</driverUdn>
  </driverPersonalInfo>
</driverdata>'

EXEC spGetDriverDataByXML @XCriteria = @XMLExample