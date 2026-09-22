CREATE VIEW [dbo].[SupportTicketDetails]
AS
SELECT
    t.[TicketID],
    t.[CustomerID],
    c.[Email] AS [CustomerEmail],
    t.[Title],
    t.[Status],
    t.[CreatedAt]
FROM [dbo].[SupportTickets] AS t
INNER JOIN [dbo].[Customers] AS c
    ON t.[CustomerID] = c.[CustomerID];