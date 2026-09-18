SELECT
    s.name AS SequenceName,
    SCHEMA_NAME(s.schema_id) AS SchemaName,
    TYPE_NAME(s.user_type_id) AS DataType,
    s.start_value,
    s.increment,
    s.minimum_value,
    s.maximum_value,
    s.is_cycling,
    s.is_cached,
    s.current_value
FROM sys.sequences AS s
ORDER BY
    SchemaName,
    SequenceName;
GO

-- Verify sequence values
SELECT
    s.name AS SequenceName,
    SCHEMA_NAME(s.schema_id) AS SchemaName,
    TYPE_NAME(s.user_type_id) AS DataType,
    s.start_value,
    s.increment,
    s.is_cycling,
    s.is_cached,
    s.cache_size,
    s.current_value
FROM sys.sequences AS s
WHERE s.name = N'SupportTicketNumberSequence';
GO

SELECT *
FROM sys.sequences;
GO

-- Get the next value of the SupportTicketNumberSequence
SELECT NEXT VALUE FOR dbo.SupportTicketNumberSequence
    AS NextSupportTicketNumber;
GO

-- Get the current value of the SupportTicketNumberSequence and not use it
SELECT NEXT VALUE FOR dbo.SupportTicketNumberSequence
    AS ReservedButUnusedNumber;
GO

-- Inspect the current value of the SupportTicketNumberSequence
SELECT
    name,
    current_value,
    is_cached,
    cache_size
FROM sys.sequences
WHERE name = N'SupportTicketNumberSequence';
GO

-- Sequence +transaction rollbacks
BEGIN TRANSACTION;

SELECT NEXT VALUE FOR dbo.SupportTicketNumberSequence
    AS ValueInsideTransaction;

ROLLBACK TRANSACTION;
GO

-- Verify the current value after the rollback
SELECT NEXT VALUE FOR dbo.SupportTicketNumberSequence
    AS ValueAfterRollback;
GO