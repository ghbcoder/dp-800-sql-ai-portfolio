SELECT *
FROM dbo.SupportTickets
WHERE CreatedAt >= '2026-01-01';
GO

-- Inspect partitioning
SELECT
    ps.name AS PartitionScheme,
    pf.name AS PartitionFunction
FROM sys.partition_schemes AS ps
JOIN sys.partition_functions AS pf
    ON ps.function_id = pf.function_id;
GO

SELECT *
FROM sys.partitions;
GO

-- inspect partition boundaries
SELECT
    pf.name AS PartitionFunction,
    pf.boundary_value_on_right AS BoundaryOnRight,
    prv.boundary_id,
    CONVERT(datetime2, prv.value) AS BoundaryValue
FROM sys.partition_functions AS pf
JOIN sys.partition_range_values AS prv
    ON pf.function_id = prv.function_id
WHERE pf.name = N'SupportTicketsByYearPartitionFunction'
ORDER BY prv.boundary_id;
GO