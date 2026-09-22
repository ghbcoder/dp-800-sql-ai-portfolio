-- Select the top 10 support ticket details from the view
SELECT TOP (10)
    [TicketID],
    [CustomerID],
    [CustomerEmail],
    [Title],
    [Status],
    [CreatedAt]
FROM [dbo].[SupportTicketDetails]
ORDER BY [TicketID];
GO


-- Show the execution plan for the following query
SET SHOWPLAN_XML ON;
GO

SELECT
    [TicketID],
    [CustomerID],
    [CustomerEmail],
    [Title],
    [Status],
    [CreatedAt]
FROM [dbo].[SupportTicketDetails]
WHERE [CustomerID] = 3
  AND [Status] = N'In Progress';
GO

SET SHOWPLAN_XML OFF;
GO


-- Your query to analyze IO statistics goes here
SET STATISTICS IO ON;
GO

SELECT
    [TicketID],
    [CustomerID],
    [CustomerEmail],
    [Title],
    [Status],
    [CreatedAt]
FROM [dbo].[SupportTicketDetails]
WHERE [CustomerID] = 3
  AND [Status] = N'In Progress';
GO

SET STATISTICS IO OFF;
GO


-- CTE to get active tickets for each customer
WITH ActiveTickets AS
(
    SELECT
        [TicketID],
        [CustomerID],
        [CustomerEmail],
        [Title],
        [Status],
        [CreatedAt]
    FROM [dbo].[SupportTicketDetails]
    WHERE [Status] IN (N'Open', N'In Progress')
)
SELECT
    [CustomerID],
    COUNT(*) AS [ActiveTicketCount]
FROM ActiveTickets
GROUP BY [CustomerID];
GO


