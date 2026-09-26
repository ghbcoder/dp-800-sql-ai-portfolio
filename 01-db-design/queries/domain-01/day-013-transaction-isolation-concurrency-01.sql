-- Select the top 5 most recent support tickets
SELECT TOP (5)
    TicketID,
    CustomerID,
    Title,
    Status
FROM dbo.SupportTickets
ORDER BY TicketID DESC;
GO


-- Update the status of a specific support ticket and view the changes
BEGIN TRANSACTION;

UPDATE dbo.SupportTickets
SET Status = N'In Progress'
WHERE TicketID = 20008;

SELECT
    TicketID,
    Status
FROM dbo.SupportTickets
WHERE TicketID = 20008;

-- Commit the transaction to save the changes
COMMIT TRANSACTION;
GO


-- View the current isolation level settings for the database
SELECT
    name,
    is_read_committed_snapshot_on,
    snapshot_isolation_state_desc
FROM sys.databases
WHERE name = DB_NAME();
GO


-- Start a new transaction and update the status of a specific support ticket
BEGIN TRANSACTION;

UPDATE dbo.SupportTickets
SET Status = N'In Progress'
WHERE TicketID = 20008;

-- deliberately leave the transaction open
ROLLBACK TRANSACTION;
GO


-- Update the status of the support ticket to 'Resolved' and view the changes
UPDATE dbo.SupportTickets
SET Status = N'Resolved'
WHERE TicketID = 20008;

SELECT
    TicketID,
    Status
FROM dbo.SupportTickets
WHERE TicketID = 20008;
GO


-- Demonstrate Deadlock scenario with two transactions
BEGIN TRANSACTION;

UPDATE dbo.SupportTickets
SET Status = N'In Progress'
WHERE TicketID = 20008;

UPDATE dbo.SupportTickets
SET Status = N'Resolved'
WHERE TicketID = 20007;

-- Deliberately leave the transaction open to simulate a deadlock scenario

-- Transaction has been deadlocked and rolled back
-- End of deadlock demonstration
GO



-- Demonstrate SNAPSHOT update conflicts
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

BEGIN TRANSACTION;

SELECT
    TicketID,
    Status
FROM dbo.SupportTickets
WHERE TicketID = 20008;

-- Trigger SNAPSHOT update conflict by attempting to update the same row in another transaction
UPDATE dbo.SupportTickets
SET Status = N'In Progress'
WHERE TicketID = 20008;

SELECT
    XACT_STATE() AS XactState,
    @@TRANCOUNT AS TranCount;