GO
CREATE FUNCTION [security].[fn_SupportTicketRlsPredicate]
(
    @CustomerID int
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT 1 AS IsAllowed
    WHERE
        @CustomerID = TRY_CAST(SESSION_CONTEXT(N'CustomerId') AS int)
);
GO