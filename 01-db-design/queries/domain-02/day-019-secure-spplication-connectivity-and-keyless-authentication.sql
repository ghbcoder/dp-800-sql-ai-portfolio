-- Query the support ticket created by the Python client using passwordless connectivity
SELECT
    TicketID,
    CustomerID,
    Title,
    Status,
    CreatedAt
FROM dbo.SupportTickets
WHERE TicketID = 7;
GO