-- Create an event session to capture deadlock graphs in the database
CREATE EVENT SESSION [DP800_Deadlock_Monitor]
ON DATABASE
ADD EVENT sqlserver.database_xml_deadlock_report
ADD TARGET package0.ring_buffer
(
    SET max_memory = 1024
)
WITH
(
    MAX_MEMORY = 4 MB,
    STARTUP_STATE = OFF
);
GO

ALTER EVENT SESSION [DP800_Deadlock_Monitor]
ON DATABASE
STATE = START;
GO


-- Check the status of the deadlock monitor event session
SELECT
    s.name AS EventSessionName,
    CASE
        WHEN xs.name IS NOT NULL THEN 'Running'
        ELSE 'Stopped'
    END AS SessionStatus
FROM sys.database_event_sessions AS s
LEFT JOIN sys.dm_xe_database_sessions AS xs
    ON s.name = xs.name
WHERE s.name = N'DP800_Deadlock_Monitor';
GO


-- Retrieve deadlock events from the ring buffer target
;WITH RingBufferData AS
(
    SELECT
        CAST(t.target_data AS xml) AS TargetXml
    FROM sys.dm_xe_database_sessions AS s
    JOIN sys.dm_xe_database_session_targets AS t
        ON s.address = t.event_session_address
    WHERE s.name = N'DP800_Deadlock_Monitor'
      AND t.target_name = N'ring_buffer'
)
SELECT
    E.EventNode.value('@name', 'sysname') AS EventName,
    E.EventNode.value('@timestamp', 'datetime2') AS EventTimeUTC
FROM RingBufferData AS rb
CROSS APPLY rb.TargetXml.nodes('/RingBufferTarget/event') AS E(EventNode)
WHERE E.EventNode.value('@name', 'sysname')
      = N'database_xml_deadlock_report';
GO


-- Retrieve the deadlock graph from the ring buffer target
;WITH RingBufferData AS
(
    SELECT
        CAST(t.target_data AS xml) AS TargetXml
    FROM sys.dm_xe_database_sessions AS s
    INNER JOIN sys.dm_xe_database_session_targets AS t
        ON s.address = t.event_session_address
    WHERE s.name = N'DP800_Deadlock_Monitor'
      AND t.target_name = N'ring_buffer'
)
SELECT
    E.EventNode.value(
        '(@timestamp)[1]', 'datetime2(3)'
    ) AS EventTimeUTC,

    E.EventNode.query(
        '(data[@name="xml_report"]/value/deadlock)[1]'
    ) AS DeadlockGraph

FROM RingBufferData AS rb
CROSS APPLY rb.TargetXml.nodes(
    '/RingBufferTarget/event[@name="database_xml_deadlock_report"]'
) AS E(EventNode)
ORDER BY EventTimeUTC DESC;
GO


-- Stop the deadlock monitor event session before ending the script
ALTER EVENT SESSION [DP800_Deadlock_Monitor]
ON DATABASE
STATE = STOP;
GO


-- Ensure implicit transactions are turned off for the session
SET IMPLICIT_TRANSACTIONS OFF;
GO

SELECT
    @@SPID AS SessionId,
    @@TRANCOUNT AS TransactionCount,
    XACT_STATE() AS TransactionState,
    CASE
        WHEN @@OPTIONS & 2 = 2 THEN 'ON'
        ELSE 'OFF'
    END AS ImplicitTransactions;
GO


-- Capture the current transaction count and transaction state for later comparison
DECLARE @TranCount int;
DECLARE @XactState int;

SET @TranCount = @@TRANCOUNT;
SET @XactState = XACT_STATE();

SELECT
    @TranCount AS CapturedTranCount,
    @XactState AS CapturedXactState,
    @@TRANCOUNT AS LiveTranCount,
    XACT_STATE() AS LiveXactState;
GO


-- Stop the deadlock monitor event session before ending the script
ALTER EVENT SESSION [DP800_Deadlock_Monitor]
ON DATABASE
STATE = STOP;
GO