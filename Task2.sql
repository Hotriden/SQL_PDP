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