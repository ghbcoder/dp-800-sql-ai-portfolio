-- This query retrieves the ticket information for specific customers (CustomerID 2 and 3)
SELECT
    TicketID,
    CustomerID,
    Status,
    COUNT(*) OVER
    (
        PARTITION BY CustomerID
    ) AS CustomerTicketCount
FROM dbo.SupportTickets
WHERE CustomerID IN (2, 3)
ORDER BY CustomerID, TicketID;
GO


-- This query ranks the tickets for specific customers (CustomerID 2 and 3) based on their creation date, with the most recent tickets first.
SELECT
    TicketID,
    CustomerID,
    Status,
    CreatedAt,
    ROW_NUMBER() OVER
    (
        PARTITION BY CustomerID
        ORDER BY CreatedAt DESC, TicketID DESC
    ) AS TicketRank
FROM dbo.SupportTickets
WHERE CustomerID IN (2, 3)
ORDER BY CustomerID, TicketRank;
GO


-- This query retrieves the total ticket count for specific customers (CustomerID 2 and 3).
SELECT
    CustomerID,
    COUNT(*) AS TicketCount
FROM dbo.SupportTickets
WHERE CustomerID IN (2, 3)
GROUP BY CustomerID
ORDER BY CustomerID;
GO


-- This query retrieves the top 5 customers with the highest ticket count.
SELECT TOP (5)
    CustomerID,
    COUNT(*) AS TicketCount
FROM dbo.SupportTickets
GROUP BY CustomerID
ORDER BY TicketCount DESC, CustomerID;
GO


-- This query ranks the tickets for specific customers (CustomerID 3 and 4) based on their creation date, with the most recent tickets first.
SELECT 
    TicketID,
    CustomerID,
    Status,
    CreatedAt,
    ROW_NUMBER() OVER
    (
        PARTITION BY CustomerID
        ORDER BY CreatedAt DESC, TicketID DESC
    ) AS TicketRank
FROM dbo.SupportTickets
WHERE CustomerID IN (3, 4)
ORDER BY CustomerID, TicketRank;
GO


-- This query retrieves the most recent ticket for each customer.
WITH RankedTickets AS
(
    SELECT
        TicketID,
        CustomerID,
        Title,
        Status,
        CreatedAt,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY CreatedAt DESC, TicketID DESC
        ) AS TicketRank
    FROM dbo.SupportTickets
)
SELECT
    TicketID,
    CustomerID,
    Title,
    Status,
    CreatedAt
FROM RankedTickets
WHERE TicketRank = 1
ORDER BY CustomerID;
GO


-- This query demonstrates the use of ROW_NUMBER, RANK, and DENSE_RANK functions on a set of ticket scores.
WITH TicketScores AS
(
    SELECT *
    FROM (VALUES
        (N'A', 100),
        (N'B',  90),
        (N'C',  90),
        (N'D',  80),
        (N'E',  70)
    ) AS v(TicketName, Score)
)
SELECT
    TicketName,
    Score,
    ROW_NUMBER() OVER (ORDER BY Score DESC) AS RowNumberValue,
    RANK()       OVER (ORDER BY Score DESC) AS RankValue,
    DENSE_RANK() OVER (ORDER BY Score DESC) AS DenseRankValue
FROM TicketScores
ORDER BY Score DESC;
GO


-- This query retrieves the previous ticket creation date for the top 10 tickets of CustomerID 3.
SELECT TOP(10)
    TicketID,
    CustomerID,
    CreatedAt,
    LAG(CreatedAt) OVER
    (
        PARTITION BY CustomerID
        ORDER BY CreatedAt, TicketID
    ) AS PreviousTicketCreatedAt
FROM dbo.SupportTickets
WHERE CustomerID = 3
ORDER BY CreatedAt, TicketID;
GO


-- This query calculates the time difference in milliseconds between consecutive tickets for CustomerID 3.
WITH TicketTimeline AS
(
    SELECT
        TicketID,
        CustomerID,
        CreatedAt,
        LAG(CreatedAt) OVER
        (
            PARTITION BY CustomerID
            ORDER BY CreatedAt, TicketID
        ) AS PreviousTicketCreatedAt
    FROM dbo.SupportTickets
    WHERE CustomerID = 3
)
SELECT TOP (10)
    TicketID,
    CustomerID,
    CreatedAt,
    PreviousTicketCreatedAt,
    DATEDIFF_BIG
    (
        MILLISECOND,
        PreviousTicketCreatedAt,
        CreatedAt
    ) AS MillisecondsSincePreviousTicket
FROM TicketTimeline
ORDER BY CreatedAt, TicketID;
GO


-- This query retrieves the previous and next ticket creation dates for the top 10 tickets of CustomerID 3.
SELECT TOP (1000)
    TicketID,
    CustomerID,
    CreatedAt,

    LAG(CreatedAt) OVER
    (
        PARTITION BY CustomerID
        ORDER BY CreatedAt, TicketID
    ) AS PreviousCreatedAt,

    LEAD(CreatedAt) OVER
    (
        PARTITION BY CustomerID
        ORDER BY CreatedAt, TicketID
    ) AS NextCreatedAt

FROM dbo.SupportTickets
WHERE CustomerID = 3
ORDER BY CreatedAt, TicketID;
GO


-- This query calculates the running ticket count for CustomerID 3.
SELECT TOP (10)
    TicketID,
    CustomerID,
    CreatedAt,

    COUNT(*) OVER
    (
        PARTITION BY CustomerID
        ORDER BY CreatedAt, TicketID
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningTicketCount
FROM dbo.SupportTickets
WHERE CustomerID = 3
ORDER BY CreatedAt, TicketID;
GO


-- This query compares the count of tickets using ROWS and RANGE window frames for CustomerID 3.
SELECT TOP (10)
    TicketID,
    CreatedAt,

    COUNT(*) OVER
    (
        ORDER BY CreatedAt
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS CountWithRows,

    COUNT(*) OVER
    (
        ORDER BY CreatedAt
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS CountWithRange

FROM dbo.SupportTickets
WHERE CustomerID = 3
ORDER BY CreatedAt, TicketID;
GO


-- This query retrieves the most recent ticket for each customer using the ROW_NUMBER() window function.
SET STATISTICS IO ON;
GO

WITH RankedTickets AS
(
    SELECT
        TicketID,
        CustomerID,
        Title,
        Status,
        CreatedAt,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY CreatedAt DESC, TicketID DESC
        ) AS TicketRank
    FROM dbo.SupportTickets
)
SELECT
    TicketID,
    CustomerID,
    Title,
    Status,
    CreatedAt
FROM RankedTickets
WHERE TicketRank = 1
ORDER BY CustomerID;

SET STATISTICS IO OFF;
GO


-- This query demonstrates the use of RANGE window frame with sample ticket data.
WITH SampleTickets AS
(
    SELECT *
    FROM (VALUES
        (N'A', N'10:00'),
        (N'B', N'10:00'),
        (N'C', N'10:05')
    ) AS SampleTickets(CustomerID, CreatedAt)
)
SELECT 
    CustomerID,
    COUNT(*) OVER
    (
        PARTITION BY CustomerID
        ORDER BY CreatedAt
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )
FROM SampleTickets;
GO


-- This query demonstrates the difference between RANGE and ROWS window frames with test data.
WITH TestData AS
(
    SELECT *
    FROM
    (
        VALUES
            (1, 101, CAST('2026-09-25T10:00:00' AS datetime2)),
            (1, 102, CAST('2026-09-25T10:00:00' AS datetime2)),
            (1, 103, CAST('2026-09-25T10:05:00' AS datetime2))
    ) AS v(CustomerID, TicketID, CreatedAt)
)
SELECT
    TicketID,
    CreatedAt,

    COUNT(*) OVER
    (
        PARTITION BY CustomerID
        ORDER BY CreatedAt
        RANGE BETWEEN UNBOUNDED PRECEDING
                  AND CURRENT ROW
    ) AS CountWithRange,

    COUNT(*) OVER
    (
        PARTITION BY CustomerID
        ORDER BY CreatedAt, TicketID
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS CountWithRows
FROM TestData
ORDER BY TicketID;
GO