CREATE PROCEDURE dbo.CreateSupportTicket
    @CustomerID INT,
    @Title NVARCHAR(200),
    @TicketID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        INSERT INTO dbo.SupportTickets
        (
            CustomerID,
            Title
        )
        VALUES
        (
            @CustomerID,
            @Title
        );

        SET @TicketID = CONVERT(INT, SCOPE_IDENTITY());
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END