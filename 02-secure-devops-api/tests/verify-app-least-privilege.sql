/*
    verify-app-least-privilege.sql

    Purpose:
    Verify the runtime application's database security contract.

    Expected:
    1. id-dp800-app can execute dbo.CreateSupportTicket
    2. id-dp800-app cannot INSERT directly into dbo.SupportTickets

    Automation behavior:
    - expected security behavior -> script completes successfully
    - violated security contract -> THROW -> sqlcmd -b returns non-zero
*/

SET NOCOUNT ON;

PRINT N'TEST 1: Application identity can execute dbo.CreateSupportTicket';

EXECUTE AS USER = N'id-dp800-app';

BEGIN TRY
    DECLARE @NewTicketID INT;

    EXEC dbo.CreateSupportTicket
        @CustomerID = 3,
        @Title = N'Automated least-privilege verification',
        @TicketID = @NewTicketID OUTPUT;

    SELECT
        N'PASS' AS TestResult,
        N'EXECUTE dbo.CreateSupportTicket' AS TestName,
        @NewTicketID AS CreatedTicketID;
END TRY
BEGIN CATCH
    DECLARE @Test1Error nvarchar(2048) =
        CONCAT(
            N'Security contract failure: application identity could not execute ',
            N'dbo.CreateSupportTicket. Original error ',
            ERROR_NUMBER(),
            N': ',
            ERROR_MESSAGE()
        );

    REVERT;
    THROW 51001, @Test1Error, 1;
END CATCH;

REVERT;
GO


PRINT N'TEST 2: Application identity cannot INSERT directly into dbo.SupportTickets';

DECLARE @InsertDenied bit = 0;
DECLARE @InsertErrorNumber int;
DECLARE @InsertErrorMessage nvarchar(4000);

EXECUTE AS USER = N'id-dp800-app';

BEGIN TRY
    INSERT INTO dbo.SupportTickets
    (
        CustomerID,
        Title
    )
    VALUES
    (
        3,
        N'Unauthorized direct insert verification'
    );
END TRY
BEGIN CATCH
    SET @InsertErrorNumber = ERROR_NUMBER();
    SET @InsertErrorMessage = ERROR_MESSAGE();

    IF @InsertErrorNumber = 229
        SET @InsertDenied = 1;
END CATCH;

REVERT;

IF @InsertDenied = 1
BEGIN
    SELECT
        N'PASS' AS TestResult,
        N'Direct INSERT dbo.SupportTickets' AS TestName,
        @InsertErrorNumber AS ErrorNumber,
        @InsertErrorMessage AS Details;
END
ELSE IF @InsertErrorNumber IS NOT NULL
BEGIN
    DECLARE @UnexpectedInsertError nvarchar(2048) =
        CONCAT(
            N'Unexpected error while testing forbidden direct INSERT. Error ',
            @InsertErrorNumber,
            N': ',
            @InsertErrorMessage
        );

    THROW 51003, @UnexpectedInsertError, 1;
END
ELSE
BEGIN
    THROW 51002,
        'Security contract failure: direct INSERT unexpectedly succeeded.',
        1;
END;
GO
