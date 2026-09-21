CREATE FUNCTION dbo.GetTicketsByCustomerAndStatus
(
    @CustomerID INT,
    @Status NVARCHAR(30)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        [TicketID],
        [CustomerID],
        [Title],
        [Status],
        [CreatedAt]
    FROM [dbo].[SupportTickets]
    WHERE [CustomerID] = @CustomerID
      AND [Status] = @Status
);