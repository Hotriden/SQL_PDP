--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--- To check index fragmentation -----------------------------------------------------
SELECT OBJECT_NAME(ix.object_ID) AS TableName, 
       ix.name AS IndexName, 
       ixs.index_type_desc AS IndexType, 
       ixs.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) ixs
     INNER JOIN sys.indexes ix ON ix.object_id = ixs.object_id
                                  AND ixs.index_id = ixs.index_id
WHERE ix.name is NOT NULL

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--- FIND LOCKED OBJECTS --------------------------------------------------------------
--------------------------------------------------------------------------------------
SELECT
    OBJECT_NAME(P.object_id) AS TableName,
    Resource_type, request_status,  request_session_id	
FROM
    sys.dm_tran_locks dtl
    join sys.partitions P
ON dtl.resource_associated_entity_id = p.hobt_id
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--- FIND OUT WHO LOCKED OBJECT -------------------------------------------------------
--------------------------------------------------------------------------------------
SELECT  L.request_session_id AS SPID, 
        DB_NAME(L.resource_database_id) AS DatabaseName,
        O.Name AS LockedObjectName, 
        P.object_id AS LockedObjectId, 
        L.resource_type AS LockedResource, 
        L.request_mode AS LockType,
        ST.text AS SqlStatementText,        
        ES.login_name AS LoginName,
        ES.host_name AS HostName,
        TST.is_user_transaction as IsUserTransaction,
        AT.name as TransactionName,
        CN.auth_scheme as AuthenticationMethod
FROM    sys.dm_tran_locks L
        JOIN sys.partitions P ON P.hobt_id = L.resource_associated_entity_id
        JOIN sys.objects O ON O.object_id = P.object_id
        JOIN sys.dm_exec_sessions ES ON ES.session_id = L.request_session_id
        JOIN sys.dm_tran_session_transactions TST ON ES.session_id = TST.session_id
        JOIN sys.dm_tran_active_transactions AT ON TST.transaction_id = AT.transaction_id
        JOIN sys.dm_exec_connections CN ON CN.session_id = ES.session_id
        CROSS APPLY sys.dm_exec_sql_text(CN.most_recent_sql_handle) AS ST
WHERE   resource_database_id = db_id()
ORDER BY L.request_session_id

--- TASK 3 ---

-- SUBTASK 1 --
SET IMPLICIT_TRANSACTIONS OFF -- SETUP Transaction

select IIF(@@OPTIONS & 2 = 0, 'OFF', 'ON') -- Check transaction state

SELECT * FROM sys.sysprocesses WHERE open_tran = 1 -- Check active transactions

BEGIN TRAN Transition_DeleteWareHouse_8
	DELETE US_Domastic_Company.dbo.Warehouse WHERE WarehouseId = 8
SAVE TRAN Transition_DeleteWareHouse_8

BEGIN TRAN Transition_DeleteWareHouse_16n24
	DELETE US_Domastic_Company.dbo.Warehouse WHERE WarehouseId = 16
	DELETE US_Domastic_Company.dbo.Warehouse WHERE WarehouseId = 24
SAVE TRAN Transition_DeleteWareHouse_16n24


COMMIT TRAN Transition_DeleteWareHouse_8
ROLLBACK TRAN Transition_DeleteWareHouse_16n24
commit tran
--- SUBTASK 2 --

DBCC useroptions