
-- Create a new support ticket and retrieve its ID
DECLARE @NewTicketID INT;

EXEC [dbo].[CreateSupportTicket]
    @CustomerID = 1,
    @Title = N'Test ticket created through stored procedure',
    @TicketID = @NewTicketID OUTPUT;

SELECT @NewTicketID AS NewTicketID;
GO

-- Attempt to create a support ticket with an invalid customer ID
DECLARE @NewTicketID INT;

EXEC [dbo].[CreateSupportTicket]
    @CustomerID = 999999,
    @Title = N'This ticket should fail',
    @TicketID = @NewTicketID OUTPUT;

SELECT @NewTicketID AS NewTicketID;
GO

-- Verify that the failed ticket creation did not insert a new record
SELECT
    [TicketID],
    [CustomerID],
    [Title],
    [Status],
    [CreatedAt]
FROM [dbo].[SupportTickets]
WHERE [Title] = N'This ticket should fail';
GO

-- Retrieve all tickets for a specific customer with a specific status
SELECT
    [TicketID],
    [CustomerID],
    [Title],
    [Status],
    [CreatedAt]
FROM [dbo].[GetTicketsByCustomerAndStatus]
(
    3,
    N'In Progress'
);
GO

-- Measure IO statistics for retrieving tickets by customer and status
SET STATISTICS IO ON;

SELECT 
    [TicketID],
    [CustomerID],
    [Title],
    [Status],
    [CreatedAt]
FROM [dbo].[GetTicketsByCustomerAndStatus]
(
    3,
    N'In Progress'
);

SET STATISTICS IO OFF;
GO

-- Measure the execution plan for retrieving tickets by customer and status
SET SHOWPLAN_XML ON;
GO

SELECT
    [TicketID],
    [CustomerID],
    [Title],
    [Status],
    [CreatedAt]
FROM [dbo].[GetTicketsByCustomerAndStatus]
(
    3,
    N'In Progress'
);
GO
SET SHOWPLAN_XML OFF;
GO

-- Retrieve tickets for a specific customer and status created on or after a specific date
SELECT
    [TicketID],
    [CustomerID],
    [Title],
    [Status],
    [CreatedAt]
FROM [dbo].[GetTicketsByCustomerAndStatus]
(
    3,
    N'In Progress'
)
WHERE [CreatedAt] >= '2026-01-01';
GO

-- Retrieve tickets for a specific customer and status with TicketID greater than 15000
SET SHOWPLAN_XML ON;
GO
SELECT
    [TicketID],
    [CustomerID],
    [Title],
    [Status],
    [CreatedAt]
FROM [dbo].[GetTicketsByCustomerAndStatus]
(
    3,
    N'In Progress'
)
WHERE [TicketID] > 15000;
GO
SET SHOWPLAN_XML OFF;
GO

-- Retrieve customer information along with their tickets for a specific status
SELECT
    c.[CustomerID],
    c.[Email],
    t.[TicketID],
    t.[Title],
    t.[Status]
FROM [dbo].[Customers] AS c
INNER JOIN [dbo].[GetTicketsByCustomerAndStatus]
(
    3,
    N'In Progress'
) AS t
    ON c.[CustomerID] = t.[CustomerID];
GO
