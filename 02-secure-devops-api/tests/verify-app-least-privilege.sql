/*
    verify-app-least-privilege.sql

    Purpose:
    Verify the runtime application's database security contract.

    Expected security behavior:
    1. Application identity inherits approved permissions through
       SupportAppRuntime.
    2. Application identity can execute dbo.CreateSupportTicket.
    3. Application identity cannot INSERT directly into dbo.SupportTickets.

    These tests use EXECUTE AS USER to validate database authorization
    without requiring the application runtime itself.
*/

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
    SELECT
        N'FAIL' AS TestResult,
        N'EXECUTE dbo.CreateSupportTicket' AS TestName,
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

REVERT;
GO


PRINT N'TEST 2: Application identity cannot INSERT directly into dbo.SupportTickets';

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

    SELECT
        N'FAIL' AS TestResult,
        N'Direct INSERT dbo.SupportTickets' AS TestName,
        N'INSERT unexpectedly succeeded.' AS Details;
END TRY
BEGIN CATCH
    SELECT
        N'PASS' AS TestResult,
        N'Direct INSERT dbo.SupportTickets' AS TestName,
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS Details;
END CATCH;

REVERT;
GO