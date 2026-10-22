
-- Create a session for simulating blocking scenario Write-Write in RCSI (Read Committed Snapshot Isolation)
SET XACT_ABORT ON;
SET LOCK_TIMEOUT 10000;

EXEC sys.sp_set_session_context
    @key = N'CustomerId',
    @value = 1;

SELECT @@SPID AS SessionA_SPID;

BEGIN TRANSACTION;

UPDATE dbo.SupportTickets
SET Status = N'In Progress'
WHERE TicketId = 8
  AND CustomerId = 1
  AND Status = N'Open';

SELECT
    @@ROWCOUNT AS RowsUpdated,
    @@TRANCOUNT AS ActiveTransactions;

-- Rollback the transaction to release any locks held by this session
-- Execute this section after testing completed to release locks and clean up the transaction
ROLLBACK TRANSACTION;

SELECT
    @@TRANCOUNT AS ActiveTransactions,
    XACT_STATE() AS TransactionState;    
GO
-- End of blocking session simulation for Session A


-- Begin fail-safe transaction for Session A on DeadlockLabA table
SET NOCOUNT ON;
SET XACT_ABORT ON;

-- Fail-safe for an abandoned lab session:
SET LOCK_TIMEOUT 30000;

SELECT @@SPID AS SessionA_SPID;

BEGIN TRANSACTION;

UPDATE dbo.DeadlockLabA
SET Value = Value + 1
WHERE Id = 1;

SELECT
    @@ROWCOUNT AS RowsUpdated,
    @@TRANCOUNT AS ActiveTransactions,
    XACT_STATE() AS TransactionState;
GO

-- Try to update DeadlockLabB table within the same transaction
UPDATE dbo.DeadlockLabB
SET Value = Value + 10
WHERE Id = 1;
GO

-- Rollback the transaction to release any locks held by this session
-- Execute this section after testing completed to release locks and clean up the transaction
IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

SELECT
    @@SPID AS SessionId,
    @@TRANCOUNT AS ActiveTransactions,
    XACT_STATE() AS TransactionState;
GO
-- End of fail-safe transaction for Session A


-- Check the status of the current session and transaction
SELECT
    @@SPID AS SessionId,
    @@TRANCOUNT AS TransactionCount,
    XACT_STATE() AS TransactionState,
    CASE
        WHEN @@TRANCOUNT = 0
        THEN 'No active user transaction'
        ELSE 'Transaction requires investigation'
    END AS TransactionStatus;
GO