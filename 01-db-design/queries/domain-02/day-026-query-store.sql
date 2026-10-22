-- Query to check the current Query Store options for the database
SELECT
    actual_state_desc,
    desired_state_desc,
    query_capture_mode_desc,
    readonly_reason,
    current_storage_size_mb,
    max_storage_size_mb
FROM sys.database_query_store_options;
GO


-- Query to retrieve the top 10 queries by total duration from the Query Store
SELECT TOP (10)
    q.query_id AS QueryId,
    p.plan_id AS PlanId,
    SUM(rs.count_executions) AS ExecutionCount,

    CAST(
        SUM(rs.avg_duration * rs.count_executions)
        / NULLIF(SUM(rs.count_executions), 0)
        / 1000.0 AS decimal(18,2)
    ) AS AvgDurationMs,

    CAST(
        SUM(rs.avg_duration * rs.count_executions)
        / 1000.0 AS decimal(18,2)
    ) AS TotalDurationMs,

    LEFT(qt.query_sql_text, 300) AS QueryText

FROM sys.query_store_query_text AS qt
INNER JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id
INNER JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id
INNER JOIN sys.query_store_runtime_stats AS rs
    ON p.plan_id = rs.plan_id

WHERE rs.execution_type = 0

GROUP BY
    q.query_id,
    p.plan_id,
    qt.query_sql_text

ORDER BY TotalDurationMs DESC;
GO


-- Query to retrieve the top 20 queries related to specific tables from the Query Store
SELECT TOP (20)
    q.query_id AS QueryId,
    p.plan_id AS PlanId,
    SUM(rs.count_executions) AS ExecutionCount,

    CAST(
        SUM(rs.avg_duration * rs.count_executions)
        / NULLIF(SUM(rs.count_executions), 0)
        / 1000.0 AS decimal(18,2)
    ) AS AvgDurationMs,

    CAST(
        SUM(rs.avg_duration * rs.count_executions)
        / 1000.0 AS decimal(18,2)
    ) AS TotalDurationMs,

    LEFT(qt.query_sql_text, 500) AS QueryText

FROM sys.query_store_query_text AS qt

JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id

JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id

JOIN sys.query_store_runtime_stats AS rs
    ON p.plan_id = rs.plan_id

WHERE rs.execution_type = 0
  AND (
       qt.query_sql_text LIKE '%SupportTickets%'
    OR qt.query_sql_text LIKE '%KnowledgeArticles%'
    OR qt.query_sql_text LIKE '%TicketMessages%'
  )

GROUP BY
    q.query_id,
    p.plan_id,
    qt.query_sql_text

ORDER BY TotalDurationMs DESC;
GO


-- Query to retrieve detailed information about specific queries from the Query Store
SELECT
    q.query_id AS QueryId,
    q.query_hash AS QueryHash,
    q.context_settings_id AS ContextSettingsId,
    q.object_id AS ObjectId,
    CASE
        WHEN q.object_id = 0 THEN N'Ad hoc / dynamic SQL'
        ELSE
            OBJECT_SCHEMA_NAME(q.object_id)
            + N'.'
            + OBJECT_NAME(q.object_id)
    END AS ParentObject,
    q.query_parameterization_type_desc AS ParameterizationType,
    p.plan_id AS PlanId,
    p.is_forced_plan AS IsForcedPlan,
    q.query_text_id AS QueryTextId
FROM sys.query_store_query AS q
INNER JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id
WHERE q.query_id IN (332, 347)
ORDER BY q.query_id, p.plan_id;
GO


-- Query to retrieve KnowledgeArticles containing 'Azure' in the title
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.KnowledgeArticles
WHERE Title LIKE N'%Azure%';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO