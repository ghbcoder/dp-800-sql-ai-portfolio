-- inspect the ticket distribution
SELECT TOP (10)
    CustomerID,
    COUNT(*) AS TicketCount
FROM dbo.SupportTickets
GROUP BY CustomerID
ORDER BY TicketCount DESC, CustomerID;
GO


-- inspect the ticket count for a specific customer
SELECT
    CustomerID,
    COUNT(*) AS TicketCount
FROM dbo.SupportTickets
WHERE CustomerID = 1
GROUP BY CustomerID;
GO


-- Establishing the basline
SET STATISTICS IO ON;

SELECT
    TicketID,
    Title,
    Status,
    CreatedAt
FROM dbo.SupportTickets
WHERE CustomerID = 1;

SET STATISTICS IO OFF;
-- Result: Table '[dbo].[SupportTickets]'. Scan count 1, logical reads 2, physical reads 0 
--         100% Index seek - IX_SupportTickets_CustomerID_CreatedAt
GO


-- inspect the distinct status values
SELECT DISTINCT Status
FROM dbo.SupportTickets
ORDER BY Status;
GO


-- insert a large number of test tickets for performance testing
;WITH N AS
(
    SELECT TOP (20000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects AS a
    CROSS JOIN sys.all_objects AS b
)
INSERT INTO dbo.SupportTickets
(
    CustomerID,
    Title,
    Status,
    CreatedAt
)
SELECT
    1,
    CONCAT(N'Enterprise performance test ticket ', n),
    CASE n % 4
        WHEN 0 THEN N'Open'
        WHEN 1 THEN N'In Progress'
        WHEN 2 THEN N'Resolved'
        ELSE N'Closed'
    END,
    DATEADD(MINUTE, -n, SYSUTCDATETIME())
FROM N;
GO


-- inspect the ticket count for multiple specific customers
SELECT
    CustomerID,
    COUNT(*) AS TicketCount
FROM dbo.SupportTickets
WHERE CustomerID IN (1, 3)
GROUP BY CustomerID
ORDER BY CustomerID;
GO


-- create or alter stored procedure to get tickets by customer
CREATE OR ALTER PROCEDURE dbo.GetTicketsByCustomer
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        TicketID,
        Title,
        Status,
        CreatedAt
    FROM dbo.SupportTickets
    WHERE CustomerID = @CustomerID;
END;
GO


-- inspect the metadata for the stored procedure dbo.GetTicketsByCustomer
SELECT
    OBJECT_SCHEMA_NAME(object_id) AS SchemaName,
    name,
    type_desc
FROM sys.objects
WHERE object_id = OBJECT_ID(N'dbo.GetTicketsByCustomer');
GO


-- inspect the current query store options
SELECT
    actual_state_desc,
    desired_state_desc,
    readonly_reason,
    current_storage_size_mb,
    max_storage_size_mb
FROM sys.database_query_store_options;
GO


-- inspect the current parameter sensitive plan optimization setting
SELECT
    name,
    value,
    value_for_secondary
FROM sys.database_scoped_configurations
WHERE name = N'PARAMETER_SENSITIVE_PLAN_OPTIMIZATION';
GO


-- execute the stored procedure for a specific customer to observe the query performance
SET STATISTICS IO ON;

EXEC dbo.GetTicketsByCustomer @CustomerID = 3;

SET STATISTICS IO OFF;

-- Result: Table '[dbo].[SupportTickets]'. Scan count 1, logical reads 8, physical reads 0
-- Customer 3
-- ────────────────────────
-- Estimated rows      200
-- Actual rows         200
-- Rows read           200
-- Logical reads         8
-- ────────────────────────
-- Estimation error      0%
GO


-- Execute the stored procedure for another specific customer to observe the query performance
SET STATISTICS IO ON;

EXEC dbo.GetTicketsByCustomer
    @CustomerID = 1;

SET STATISTICS IO OFF;
-- Result: Table '[dbo].[SupportTickets]'. Scan count 1, logical reads 344, physical reads 0
--                   Customer 3        Customer 1
--                   ──────────        ──────────
-- Actual rows             200            20,002
-- Estimated rows          200               200
-- Rows read               200            20,002
-- Logical reads             8               344
GO


-- inspect the cached plans for the stored procedure dbo.GetTicketsByCustomer
SELECT
    cp.usecounts,
    cp.size_in_bytes,
    st.text,
    qp.query_plan
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
WHERE st.objectid = OBJECT_ID(N'dbo.GetTicketsByCustomer');
GO


-- recompile the stored procedure to clear its cached plan
EXEC sys.sp_recompile N'dbo.GetTicketsByCustomer';
GO


-- execute the stored procedure after recompilation to observe the query performance
SET STATISTICS IO ON;

EXEC dbo.GetTicketsByCustomer
    @CustomerID = 1;

SET STATISTICS IO OFF;

-- Result: Table '[dbo].[SupportTickets]'. Scan count 1, logical reads 344, physical reads 0

--                          SMALL-COMPILED PLAN     LARGE-COMPILED PLAN
--                          Customer 3 first        Customer 1 first
--                          ───────────────────     ────────────────────
-- Estimated rows                  200                    20,002
-- Actual rows                  20,002                    20,002
-- Logical reads                   344                       344
-- Estimated subtree cost       0.00494                   0.24270

GO


-- execute the stored procedure for customer 3 after recompilation to observe the query performance
SET STATISTICS IO ON;

EXEC dbo.GetTicketsByCustomer
    @CustomerID = 3;

SET STATISTICS IO OFF;

-- Result: Table '[dbo].[SupportTickets]'. Scan count 1, logical reads 8, physical reads 0

-- Customer 3
-- Plan estimate:   20,002
-- Actual rows:        200
-- Logical reads:        8

GO


-- Using Query Store
-- Query Store information for the stored procedure dbo.GetTicketsByCustomer
SELECT
    q.query_id,
    p.plan_id,
    p.is_forced_plan,
    p.last_compile_start_time,
    rs.count_executions,
    rs.avg_duration,
    rs.avg_cpu_time,
    rs.avg_logical_io_reads
FROM sys.query_store_query AS q
JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats AS rs
    ON p.plan_id = rs.plan_id
WHERE q.object_id = OBJECT_ID(N'dbo.GetTicketsByCustomer')
ORDER BY
    q.query_id,
    p.plan_id,
    rs.last_execution_time;
GO


-- Query Store plan details for query_id 980
SELECT
    p.plan_id,
    p.query_id,
    p.is_forced_plan,
    p.is_parallel_plan,
    p.compatibility_level,
    TRY_CONVERT(XML, p.query_plan) AS QueryPlan
FROM sys.query_store_plan AS p
WHERE p.query_id = 980
ORDER BY p.plan_id;
GO


-- Execute the query for customer 3 with OPTION (RECOMPILE) to observe the query performance
DECLARE @CustomerID INT = 3;

SELECT
    TicketID,
    Title,
    Status,
    CreatedAt
FROM dbo.SupportTickets
WHERE CustomerID = @CustomerID
OPTION (RECOMPILE);
GO


-- Execute the query for customer 1 with OPTION (RECOMPILE) to observe the query performance
DECLARE @CustomerID INT = 1;

SELECT
    TicketID,
    Title,
    Status,
    CreatedAt
FROM dbo.SupportTickets
WHERE CustomerID = @CustomerID
OPTION (RECOMPILE);
GO



-- Execute the query for customer 1 with OPTION (OPTIMIZE FOR (@CustomerID UNKNOWN)) to observe the query performance
DECLARE @CustomerID INT = 1;

SELECT
    TicketID,
    Title,
    Status,
    CreatedAt
FROM dbo.SupportTickets
WHERE CustomerID = @CustomerID
OPTION (OPTIMIZE FOR (@CustomerID UNKNOWN));
GO


-- Clean up test data for customer 1 related to enterprise performance test tickets
-- DELETE FROM dbo.SupportTickets
-- WHERE CustomerID = 1
--   AND Title LIKE N'Enterprise performance test ticket %';
-- GO


-- Check the ticket count for customers 1 and 3 after cleanup
SELECT
    CustomerID,
    COUNT(*) AS TicketCount
FROM dbo.SupportTickets
WHERE CustomerID IN (1, 3)
GROUP BY CustomerID
ORDER BY CustomerID;
GO


-- Drop the stored procedure after testing
DROP PROCEDURE dbo.GetTicketsByCustomer;
GO


-- Check if the stored procedure still exists after dropping it
SELECT OBJECT_ID(N'dbo.GetTicketsByCustomer') AS ObjectID;
GO