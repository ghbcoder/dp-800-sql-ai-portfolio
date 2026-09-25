
-- Update the status of a specific support ticket to 'Resolved'
-- Running this query while an update transaction is in progress resulting in blocking because the actual isolation level is READ COMMITTED.
UPDATE dbo.SupportTickets
SET Status = N'Resolved'
WHERE TicketID = 20008;


-- View the status of the specific support ticket after the update while UPDATE transaction is in progress
SELECT
    TicketID,
    Status
FROM dbo.SupportTickets
WHERE TicketID = 20008;
GO


-- Set the transaction isolation level to READ COMMITTED and start a new transaction
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION;

SELECT
    TicketID,
    Status
FROM dbo.SupportTickets
WHERE TicketID = 20008;

-- Commit the transaction to release any locks
COMMIT TRANSACTION;
GO


-- Set the transaction isolation level to SNAPSHOT and start a new transaction
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

BEGIN TRANSACTION;

SELECT
    TicketID,
    Status
FROM dbo.SupportTickets
WHERE TicketID = 20008;

-- Commit the transaction to release any locks
COMMIT TRANSACTION;
GO

-- Demonstrate deadlock scenario with two transactions
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION;

UPDATE dbo.SupportTickets
SET Status = N'Closed'
WHERE TicketID = 20007;

-- Deliberately leave the transaction open to simulate a deadlock scenario
UPDATE dbo.SupportTickets
SET Status = N'Resolved'
WHERE TicketID = 20008;

-- Commit the transaction to release any locks
COMMIT TRANSACTION;
GO


-- View the status of the support tickets involved in the deadlock scenario
SELECT
    TicketID,
    Status
FROM dbo.SupportTickets
WHERE TicketID IN (20007, 20008)
ORDER BY TicketID;
GO
-- End of deadlock demonstration


-- Demonstrate SNAPSHOT update conflicts
UPDATE dbo.SupportTickets
SET Status = N'Closed'
WHERE TicketID = 20008;

SELECT TicketID, Status
FROM dbo.SupportTickets
WHERE TicketID = 20008;
GO

-- Restore rowa
UPDATE dbo.SupportTickets
SET Status = N'Resolved'
WHERE TicketID = 20008;

SELECT TicketID, Status
FROM dbo.SupportTickets
WHERE TicketID = 20008;
GO

