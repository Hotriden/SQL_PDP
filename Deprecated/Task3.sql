-- To check index fragmentation
SELECT OBJECT_NAME(ix.object_ID) AS TableName, 
       ix.name AS IndexName, 
       ixs.index_type_desc AS IndexType, 
       ixs.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) ixs
     INNER JOIN sys.indexes ix ON ix.object_id = ixs.object_id
                                  AND ixs.index_id = ixs.index_id
WHERE ix.name is NOT NULL
--------------------------------------------------------------------------------------

--- TASK 3 ---

-- SUBTASK 1 --
SET IMPLICIT_TRANSACTIONS ON -- SETUP Transaction

select IIF(@@OPTIONS & 2 = 0, 'OFF', 'ON') -- Check transaction state

SELECT * FROM sys.sysprocesses WHERE open_tran = 1 -- Check active transactions

BEGIN TRAN Transition_DeleteWareHouse_8
	DELETE US_Domastic_Company.dbo.Warehouse WHERE WarehouseId = 9
SAVE TRAN Transition_DeleteWareHouse_8

BEGIN TRAN Transition_DeleteWareHouse_16n24
	DELETE US_Domastic_Company.dbo.Warehouse WHERE WarehouseId = 16
	DELETE US_Domastic_Company.dbo.Warehouse WHERE WarehouseId = 24
SAVE TRAN Transition_DeleteWareHouse_16n24

COMMIT TRAN Transition_DeleteWareHouse_8
ROLLBACK TRAN Transition_DeleteWareHouse_16n24

--- SUBTASK 2 --