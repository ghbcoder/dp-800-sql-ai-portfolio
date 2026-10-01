CREATE ROLE [SupportAppRuntime];
GO

GRANT EXECUTE
    ON OBJECT::dbo.CreateSupportTicket
    TO [SupportAppRuntime];
GO