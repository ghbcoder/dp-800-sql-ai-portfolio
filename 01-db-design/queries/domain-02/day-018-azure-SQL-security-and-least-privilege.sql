-- Query to retrieve information about the temporal table and its associated history table for 'dbo.SupportTickets'
SELECT
    t.name AS TableName,
    t.temporal_type_desc,
    OBJECT_SCHEMA_NAME(t.history_table_id) AS HistorySchema,
    OBJECT_NAME(t.history_table_id) AS HistoryTable
FROM sys.tables AS t
WHERE t.object_id = OBJECT_ID(N'dbo.SupportTickets');
GO


-- Query to count the existing rows in the 'dbo.SupportTickets' table
SELECT COUNT_BIG(*) AS ExistingTicketRows
FROM dbo.SupportTickets;
GO


-- Query to retrieve the current system date and time, both local and UTC
SELECT
    SYSDATETIME()    AS SystemDateTime,
    SYSUTCDATETIME() AS SystemUtcDateTime;
GO


-- Query to retrieve information about the temporal table and its associated history table for 'dbo.SupportTickets' (repeated for verification)
SELECT
    t.name AS TableName,
    t.temporal_type_desc,
    OBJECT_SCHEMA_NAME(t.history_table_id) AS HistorySchema,
    OBJECT_NAME(t.history_table_id) AS HistoryTable
FROM sys.tables AS t
WHERE t.object_id = OBJECT_ID(N'dbo.SupportTickets');
GO


-- Query to retrieve the top 5 most recent support tickets along with their temporal validity period
SELECT TOP (5)
    TicketID,
    Status,
    CreatedAt,
    ValidFrom,
    ValidTo
FROM dbo.SupportTickets
ORDER BY TicketID DESC;
GO


-- Query to retrieve the current UTC date and time before performing an update operation
SELECT SYSUTCDATETIME() AS BeforeUpdateTime;
GO


-- Update the status of a specific support ticket to 'In Progress'
UPDATE dbo.SupportTickets
SET Status = N'In Progress'
WHERE TicketID = 20008;
GO


-- Query to retrieve the current UTC date and time after performing the update operation
SELECT SYSUTCDATETIME() AS AfterUpdateTime; --2026-09-27 14:30:06.3376731
GO


-- Query to retrieve the historical records for the specific support ticket
SELECT
    TicketID,
    Status,
    ValidFrom,
    ValidTo
FROM dbo.SupportTickets
WHERE TicketID = 20008;
GO


-- Query to retrieve all historical records for the specific support ticket using the temporal table syntax
SELECT
    TicketID,
    Status,
    ValidFrom,
    ValidTo
FROM dbo.SupportTicketsHistory
WHERE TicketID = 20008
ORDER BY ValidFrom;
GO


-- Query to retrieve the historical record for the specific support ticket as of a specific point in time
SELECT
    TicketID,
    Status,
    ValidFrom,
    ValidTo
FROM dbo.SupportTickets
FOR SYSTEM_TIME AS OF '2026-09-27T14:29:08.3814444'
WHERE TicketID = 20008;
GO


-- Update the status of the specific support ticket to 'Closed' to create a new historical record
UPDATE dbo.SupportTickets
SET Status = N'Closed'
WHERE TicketID = 20008;
GO


-- Query to retrieve all historical records for the specific support ticket, including the current record
SELECT
    TicketID,
    Status,
    ValidFrom,
    ValidTo
FROM dbo.SupportTickets
FOR SYSTEM_TIME ALL
WHERE TicketID = 20008
ORDER BY ValidFrom;
GO


-- Query to retrieve the historical records for the specific support ticket within a specific time range
SELECT
    TicketID,
    Status,
    ValidFrom,
    ValidTo
FROM dbo.SupportTickets
FOR SYSTEM_TIME FROM
    '2026-09-27T14:29:00'
TO
    '2026-09-27T18:41:00'
WHERE TicketID = 20008
ORDER BY ValidFrom;
GO


-- Query A: FROM ... TO
SELECT
    N'FROM_TO' AS QueryType,
    TicketID,
    Status,
    ValidFrom,
    ValidTo
FROM dbo.SupportTickets
FOR SYSTEM_TIME FROM
    '2026-09-27T14:24:18.7651167'
TO
    '2026-09-27T14:29:48.2678137'
WHERE TicketID = 20008
ORDER BY ValidFrom;
GO


-- Query B: BETWEEN ... AND
SELECT
    N'BETWEEN_AND' AS QueryType,
    TicketID,
    Status,
    ValidFrom,
    ValidTo
FROM dbo.SupportTickets
FOR SYSTEM_TIME BETWEEN
    '2026-09-27T14:24:18.7651167'
AND
    '2026-09-27T14:29:48.2678137'
WHERE TicketID = 20008
ORDER BY ValidFrom;
GO


-- Query to retrieve the indexes for the historical table of the support tickets
SELECT
    i.name AS IndexName,
    i.type_desc AS IndexType,
    c.name AS ColumnName,
    ic.key_ordinal,
    ic.is_descending_key
FROM sys.indexes AS i
JOIN sys.index_columns AS ic
    ON i.object_id = ic.object_id
   AND i.index_id = ic.index_id
JOIN sys.columns AS c
    ON ic.object_id = c.object_id
   AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID(N'dbo.SupportTicketsHistory')
ORDER BY i.index_id, ic.key_ordinal;
GO


-- Query to retrieve the temporal table properties for the support tickets table
SELECT
    name,
    temporal_type_desc,
    history_retention_period,
    history_retention_period_unit_desc
FROM sys.tables
WHERE object_id = OBJECT_ID(N'dbo.SupportTickets');
GO


-- Query to retrieve the historical records for the specific support ticket contained within a specific time range
SELECT
    TicketID,
    Status,
    ValidFrom,
    ValidTo
FROM dbo.SupportTickets
FOR SYSTEM_TIME CONTAINED IN
(
    '2026-09-27T14:24:18.7651167',
    '2026-09-27T18:40:15.5489205'
)
WHERE TicketID = 20008
ORDER BY ValidFrom;
GO