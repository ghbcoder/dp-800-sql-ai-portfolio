-- Check the current database's isolation settings for RCSI and snapshot isolation
SELECT
    name AS DatabaseName,
    is_read_committed_snapshot_on AS RCSIEnabled,
    snapshot_isolation_state_desc AS SnapshotIsolationState
FROM sys.databases
WHERE name = DB_NAME();
GO


-- Retrieve the top 10 support tickets ordered by TicketId descending
SELECT TOP (10)
    TicketId,
    CustomerId,
    Status
FROM dbo.SupportTickets
ORDER BY TicketId DESC;
GO


-- Retrieve the current database, user, and session context for CustomerId
SELECT
    DB_NAME() AS DatabaseName,
    USER_NAME() AS DatabaseUser,
    SESSION_CONTEXT(N'CustomerID') AS CurrentCustomerId;
GO


-- Set the session context for CustomerId to 1
EXEC sys.sp_set_session_context
    @key = N'CustomerID',
    @value = 1;
GO

-- Retrieve the top 10 support tickets for the current CustomerId
SELECT TOP (10)
    TicketId,
    CustomerId,
    Status
FROM dbo.SupportTickets
ORDER BY TicketId DESC;
GO


-- Retrieve the current locks held by the session with ID 101
SELECT
    request_session_id AS SessionId,
    resource_type AS ResourceType,
    resource_description AS ResourceDescription,
    request_mode AS LockMode,
    request_status AS LockStatus
FROM sys.dm_tran_locks
WHERE request_session_id = 101
ORDER BY
    resource_type,
    request_mode;
GO


-- Check if optimized locking is enabled for the current database
SELECT
    name AS DatabaseName,
    is_optimized_locking_on AS OptimizedLockingEnabled
FROM sys.databases
WHERE name = DB_NAME();
GO


-- Check if optimized locking is enabled for the current database (again)
SELECT
    name AS DatabaseName,
    is_optimized_locking_on AS OptimizedLockingEnabled
FROM sys.databases
WHERE name = DB_NAME();
GO


-- Set the session context for CustomerId to 1 and retrieve the support ticket with TicketId 8
EXEC sys.sp_set_session_context
    @key = N'CustomerId',
    @value = 1;

SELECT
    TicketId,
    CustomerId,
    Status
FROM dbo.SupportTickets
WHERE TicketId = 8;
GO


-- Create tables and insert initial data for deadlock lab scenario
IF OBJECT_ID(N'dbo.DeadlockLabA', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DeadlockLabA
    (
        Id int NOT NULL PRIMARY KEY,
        Value int NOT NULL
    );
END;

IF OBJECT_ID(N'dbo.DeadlockLabB', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DeadlockLabB
    (
        Id int NOT NULL PRIMARY KEY,
        Value int NOT NULL
    );
END;

IF NOT EXISTS
(
    SELECT 1 FROM dbo.DeadlockLabA WHERE Id = 1
)
    INSERT INTO dbo.DeadlockLabA VALUES (1, 0);

IF NOT EXISTS
(
    SELECT 1 FROM dbo.DeadlockLabB WHERE Id = 1
)
    INSERT INTO dbo.DeadlockLabB VALUES (1, 0);

SELECT 'Table A' AS TableName, *
FROM dbo.DeadlockLabA;

SELECT 'Table B' AS TableName, *
FROM dbo.DeadlockLabB;


-- Check the status of database event sessions
SELECT
    s.name AS EventSessionName,
    CASE
        WHEN xs.name IS NOT NULL THEN 'Running'
        ELSE 'Stopped'
    END AS SessionStatus
FROM sys.database_event_sessions AS s
LEFT JOIN sys.dm_xe_database_sessions AS xs
    ON s.name = xs.name
ORDER BY s.name;
GO