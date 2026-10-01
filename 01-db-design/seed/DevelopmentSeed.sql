/*
    DevelopmentSeed.sql

    Purpose:
    Creates a small, repeatable development dataset for the
    AI-Enabled Support Knowledge Platform.

    This script is intentionally separate from the DACPAC schema deployment.
    It is for development/demo environments, not automatic production seeding.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    /* ---------------------------------------------------------
    Customers
    --------------------------------------------------------- */
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Customers
        WHERE Email = N'ada@example.test'
    )
    BEGIN
        INSERT INTO dbo.Customers
        (
            FullName,
            Email
        )
        VALUES
        (
            N'Ada Lovelace',
            N'ada@example.test'
        );
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Customers
        WHERE Email = N'grace@example.test'
    )
    BEGIN
        INSERT INTO dbo.Customers
        (
            FullName,
            Email
        )
        VALUES
        (
            N'Grace Hopper',
            N'grace@example.test'
        );
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Customers
        WHERE Email = N'alan@example.test'
    )
    BEGIN
        INSERT INTO dbo.Customers
        (
            FullName,
            Email
        )
        VALUES
        (
            N'Alan Turing',
            N'alan@example.test'
        );
    END;

    /* ---------------------------------------------------------
    Support tickets
    --------------------------------------------------------- */

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.SupportTickets
        WHERE Title = N'Unable to connect to analytics database'
    )
    BEGIN
        INSERT INTO dbo.SupportTickets
        (
            CustomerID,
            Title,
            AIMetadata
        )
        SELECT
            CustomerID,
            N'Unable to connect to analytics database',
            N'{
                "category": "database-connectivity",
                "priority": "high",
                "sentiment": "frustrated",
                "confidence": 0.94
            }'
        FROM dbo.Customers
        WHERE Email = N'ada@example.test';
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.SupportTickets
        WHERE Title = N'Query performance degraded after deployment'
    )
    BEGIN
        INSERT INTO dbo.SupportTickets
        (
            CustomerID,
            Title,
            AIMetadata
        )
        SELECT
            CustomerID,
            N'Query performance degraded after deployment',
            N'{
                "category": "query-performance",
                "priority": "medium",
                "sentiment": "neutral",
                "confidence": 0.89
            }'
        FROM dbo.Customers
        WHERE Email = N'grace@example.test';
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.SupportTickets
        WHERE Title = N'Need guidance configuring vector search'
    )
    BEGIN
        INSERT INTO dbo.SupportTickets
        (
            CustomerID,
            Title,
            AIMetadata
        )
        SELECT
            CustomerID,
            N'Need guidance configuring vector search',
            N'{
                "category": "ai-search",
                "priority": "medium",
                "sentiment": "curious",
                "confidence": 0.91
            }'
        FROM dbo.Customers
        WHERE Email = N'alan@example.test';
    END;

    /* ---------------------------------------------------------
    Ticket messages
    --------------------------------------------------------- */

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.TicketMessages AS tm
        INNER JOIN dbo.SupportTickets AS st
            ON st.TicketID = tm.TicketID
        WHERE st.Title = N'Unable to connect to analytics database'
        AND tm.MessageText =
            N'Connection attempts started failing after the database firewall configuration changed.'
    )
    BEGIN
        INSERT INTO dbo.TicketMessages
        (
            TicketID,
            MessageText
        )
        SELECT
            TicketID,
            N'Connection attempts started failing after the database firewall configuration changed.'
        FROM dbo.SupportTickets
        WHERE Title = N'Unable to connect to analytics database';
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.TicketMessages AS tm
        INNER JOIN dbo.SupportTickets AS st
            ON st.TicketID = tm.TicketID
        WHERE st.Title = N'Query performance degraded after deployment'
        AND tm.MessageText =
            N'A previously fast reporting query now takes significantly longer after the latest deployment.'
    )
    BEGIN
        INSERT INTO dbo.TicketMessages
        (
            TicketID,
            MessageText
        )
        SELECT
            TicketID,
            N'A previously fast reporting query now takes significantly longer after the latest deployment.'
        FROM dbo.SupportTickets
        WHERE Title = N'Query performance degraded after deployment';
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.TicketMessages AS tm
        INNER JOIN dbo.SupportTickets AS st
            ON st.TicketID = tm.TicketID
        WHERE st.Title = N'Need guidance configuring vector search'
        AND tm.MessageText =
            N'We want to retrieve relevant knowledge articles using semantic similarity rather than keyword matching alone.'
    )
    BEGIN
        INSERT INTO dbo.TicketMessages
        (
            TicketID,
            MessageText
        )
        SELECT
            TicketID,
            N'We want to retrieve relevant knowledge articles using semantic similarity rather than keyword matching alone.'
        FROM dbo.SupportTickets
        WHERE Title = N'Need guidance configuring vector search';
    END;


    /* ---------------------------------------------------------
    Knowledge articles
    --------------------------------------------------------- */

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.KnowledgeArticles
        WHERE Title = N'Troubleshoot Azure SQL connectivity and firewall rules'
    )
    BEGIN
        INSERT INTO dbo.KnowledgeArticles
        (
            Title,
            Content,
            Category
        )
        VALUES
        (
            N'Troubleshoot Azure SQL connectivity and firewall rules',
            N'When an application cannot connect to Azure SQL Database, verify the logical server firewall configuration, client IP rules, network connectivity, DNS resolution, and Microsoft Entra authentication configuration. Confirm that the connecting identity has a database principal and the required permissions.',
            N'database-connectivity'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.KnowledgeArticles
        WHERE Title = N'Investigate SQL query performance regressions'
    )
    BEGIN
        INSERT INTO dbo.KnowledgeArticles
        (
            Title,
            Content,
            Category
        )
        VALUES
        (
            N'Investigate SQL query performance regressions',
            N'When query performance changes after a deployment, compare execution plans, examine logical reads and duration, review index usage, inspect parameter sensitivity, and use Query Store to identify plan changes or regressions.',
            N'query-performance'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.KnowledgeArticles
        WHERE Title = N'Use vector search for semantic knowledge retrieval'
    )
    BEGIN
        INSERT INTO dbo.KnowledgeArticles
        (
            Title,
            Content,
            Category
        )
        VALUES
        (
            N'Use vector search for semantic knowledge retrieval',
            N'Semantic retrieval represents text as numerical embeddings and compares vectors by similarity. A support application can embed a user question, search stored knowledge article embeddings for similar content, and provide the retrieved articles as grounding context to an AI model.',
            N'ai-search'
        );
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;