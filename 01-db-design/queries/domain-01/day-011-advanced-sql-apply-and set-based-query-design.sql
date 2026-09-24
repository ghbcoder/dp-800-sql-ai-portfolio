-- Select customers with no support tickets
SELECT
    c.CustomerID,
    c.Email,
    COUNT(t.TicketID) AS TicketCount
FROM dbo.Customers AS c
LEFT JOIN dbo.SupportTickets AS t
    ON t.CustomerID = c.CustomerID
GROUP BY
    c.CustomerID,
    c.Email
HAVING COUNT(t.TicketID) = 0
ORDER BY c.CustomerID;
GO

-- Get column details for the Customers table
SELECT
    c.name AS ColumnName,
    TYPE_NAME(c.user_type_id) AS DataType,
    c.max_length AS MaxLength,
    c.is_nullable AS IsNullable,
    c.is_identity AS IsIdentity,
    dc.definition AS DefaultDefinition
FROM sys.columns AS c
LEFT JOIN sys.default_constraints AS dc
    ON c.default_object_id = dc.object_id
WHERE c.object_id = OBJECT_ID(N'dbo.Customers')
ORDER BY c.column_id;
GO

-- Insert a test customer with no support tickets and verify the insertion
INSERT INTO dbo.Customers
(
    FullName,
    Email
)
VALUES
(
    N'DP800 Apply Test Customer',
    N'dp800-apply-no-tickets@example.com'
);

SELECT
    CustomerID,
    FullName,
    Email,
    CreatedAt
FROM dbo.Customers
WHERE Email = N'dp800-apply-no-tickets@example.com';
GO

-- Select the latest support ticket for each customer using CROSS APPLY
SELECT
    c.CustomerID,
    c.FullName,
    latest.TicketID,
    latest.Title,
    latest.Status,
    latest.CreatedAt
FROM dbo.Customers AS c
CROSS APPLY
(
    SELECT TOP (1)
        t.TicketID,
        t.Title,
        t.Status,
        t.CreatedAt
    FROM dbo.SupportTickets AS t
    WHERE t.CustomerID = c.CustomerID
    ORDER BY
        t.CreatedAt DESC,
        t.TicketID DESC
) AS latest
ORDER BY c.CustomerID;
GO


-- Select the latest support ticket for each customer using OUTER APPLY  
-- With ACTUAL EXECUTION PLAN turned on
--SupportTickets --> Index Seek-IX_SupportTickets_...~23% and Top N Sort~77%
SELECT
    c.CustomerID,
    c.FullName,
    latest.TicketID,
    latest.Title,
    latest.Status,
    latest.CreatedAt
FROM dbo.Customers AS c
OUTER APPLY
(
    SELECT TOP (1)
        t.TicketID,
        t.Title,
        t.Status,
        t.CreatedAt
    FROM dbo.SupportTickets AS t
    WHERE t.CustomerID = c.CustomerID
    ORDER BY
        t.CreatedAt DESC,
        t.TicketID DESC
) AS latest
ORDER BY c.CustomerID;
GO



SET STATISTICS IO ON;

-- Select the latest support ticket for each customer using OUTER APPLY with STATISTICS IO on
-- Baseline: 
-- OUTER APPLY — latest ticket/customer
-- Customers
--   Scan count:      1
--   Logical reads:   4
-- SupportTickets
--   Scan count:    102
--   Logical reads: 659
--   Physical reads:  0

SELECT
    c.CustomerID,
    c.FullName,
    latest.TicketID,
    latest.Title,
    latest.Status,
    latest.CreatedAt
FROM dbo.Customers AS c
OUTER APPLY
(
    SELECT TOP (1)
        t.TicketID,
        t.Title,
        t.Status,
        t.CreatedAt
    FROM dbo.SupportTickets AS t
    WHERE t.CustomerID = c.CustomerID
    ORDER BY
        t.CreatedAt DESC,
        t.TicketID DESC
) AS latest
ORDER BY c.CustomerID;
GO

SET STATISTICS IO OFF;
GO


-- Check if the index IX_SupportTickets_CustomerID_CreatedAt exists and its status
SELECT
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_disabled AS IsDisabled
FROM sys.indexes AS i
WHERE i.object_id = OBJECT_ID(N'dbo.SupportTickets')
  AND i.name = N'IX_SupportTickets_CustomerID_CreatedAt';
GO


-- Select the latest support ticket for each customer using OUTER APPLY  
-- With ACTUAL EXECUTION PLAN turned on
-- Top N is gone
SELECT
    c.CustomerID,
    c.FullName,
    latest.TicketID,
    latest.Title,
    latest.Status,
    latest.CreatedAt
FROM dbo.Customers AS c
OUTER APPLY
(
    SELECT TOP (1)
        t.TicketID,
        t.Title,
        t.Status,
        t.CreatedAt
    FROM dbo.SupportTickets AS t
    WHERE t.CustomerID = c.CustomerID
    ORDER BY
        t.CreatedAt DESC,
        t.TicketID DESC
) AS latest
ORDER BY c.CustomerID;
GO



SET STATISTICS IO ON;

-- Select the latest support ticket for each customer using OUTER APPLY with STATISTICS IO on
-- IO-Stats: 
-- SupportTickets logical reads	659-->235	−64.3%
-- SupportTickets scan count	102-->102	unchanged
-- Customers logical reads	    4-->4	unchanged
-- Top N Sort	Present	Gone	eliminated
-- Physical reads	            0-->0	unchanged
SELECT
    c.CustomerID,
    c.FullName,
    latest.TicketID,
    latest.Title,
    latest.Status,
    latest.CreatedAt
FROM dbo.Customers AS c
OUTER APPLY
(
    SELECT TOP (1)
        t.TicketID,
        t.Title,
        t.Status,
        t.CreatedAt
    FROM dbo.SupportTickets AS t
    WHERE t.CustomerID = c.CustomerID
    ORDER BY
        t.CreatedAt DESC,
        t.TicketID DESC
) AS latest
ORDER BY c.CustomerID;
GO

SET STATISTICS IO OFF;
GO

-- Select customers who have at least one open support ticket
SELECT
    c.CustomerID,
    c.FullName,
    c.Email
FROM dbo.Customers AS c
WHERE EXISTS
(
    SELECT 1
    FROM dbo.SupportTickets AS t
    WHERE t.CustomerID = c.CustomerID
      AND t.Status = N'Open'
);
GO


-- Select customers who do not have any support tickets
SELECT
    c.CustomerID,
    c.FullName,
    c.Email
FROM dbo.Customers AS c
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.SupportTickets AS t
    WHERE t.CustomerID = c.CustomerID
)
ORDER BY c.CustomerID;
GO


-- Select the total number of support tickets for each customer, broken down by status
SELECT
    t.CustomerID,
    COUNT(*) AS TotalTickets,
    -- SUM(1) AS AllTickets,
    SUM(CASE WHEN t.Status = N'Open' THEN 1 ELSE 0 END) AS OpenTickets,
    SUM(CASE WHEN t.Status = N'In Progress' THEN 1 ELSE 0 END) AS InProgressTickets,
    SUM(CASE WHEN t.Status = N'Resolved' THEN 1 ELSE 0 END) AS ResolvedTickets
FROM dbo.SupportTickets AS t
GROUP BY t.CustomerID
ORDER BY t.CustomerID;