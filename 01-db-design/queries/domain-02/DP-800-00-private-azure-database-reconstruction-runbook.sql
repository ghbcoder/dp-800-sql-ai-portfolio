/****************************************************************
 * Recreate new lab environment on private Azure Subscription
 ****************************************************************/

-- List all tables with their schema and temporal type description
SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    t.temporal_type_desc
FROM sys.tables AS t
JOIN sys.schemas AS s
    ON s.schema_id = t.schema_id
ORDER BY s.name, t.name;
GO


-- List all user-defined objects in the database
SELECT
    name,
    type_desc
FROM sys.objects
WHERE is_ms_shipped = 0
ORDER BY type_desc, name;
GO


-- List all temporal tables with their history tables
SELECT
    t.name AS TableName,
    t.temporal_type_desc,
    h.name AS HistoryTableName
FROM sys.tables AS t
LEFT JOIN sys.tables AS h
    ON t.history_table_id = h.object_id
WHERE t.name = N'SupportTickets';
GO


-- Get row counts for all main tables
SELECT 'Customers' AS TableName, COUNT(*) AS RowCnt
FROM dbo.Customers

UNION ALL

SELECT 'SupportTickets', COUNT(*)
FROM dbo.SupportTickets

UNION ALL

SELECT 'TicketMessages', COUNT(*)
FROM dbo.TicketMessages

UNION ALL

SELECT 'KnowledgeArticles', COUNT(*)
FROM dbo.KnowledgeArticles;
GO


-- Get column details for the Customers table
SELECT
    c.column_id,
    c.name AS ColumnName,
    TYPE_NAME(c.user_type_id) AS DataType,
    c.max_length,
    c.is_nullable,
    c.is_identity
FROM sys.columns AS c
WHERE c.object_id = OBJECT_ID(N'dbo.Customers')
ORDER BY c.column_id;
GO


-- Select all rows from the Customers table
SELECT
    CustomerID,
    FullName,
    Email,
    CreatedAt
FROM dbo.Customers
ORDER BY CustomerID;
GO


-- Get column details for the SupportTickets table
SELECT
    c.column_id,
    c.name AS ColumnName,
    TYPE_NAME(c.user_type_id) AS DataType,
    c.max_length,
    c.is_nullable,
    c.is_identity,
    dc.definition AS DefaultDefinition
FROM sys.columns AS c
LEFT JOIN sys.default_constraints AS dc
    ON c.default_object_id = dc.object_id
WHERE c.object_id = OBJECT_ID(N'dbo.SupportTickets')
ORDER BY c.column_id;
GO


-- Select all rows from the SupportTickets table with customer details
SELECT
    t.TicketID,
    c.FullName,
    t.Title,
    t.Status,
    t.AIMetadata,
    t.CreatedAt
FROM dbo.SupportTickets AS t
JOIN dbo.Customers AS c
    ON c.CustomerID = t.CustomerID
ORDER BY t.TicketID;
GO


-- Get column details for the TicketMessages table
SELECT
    c.column_id,
    c.name AS ColumnName,
    TYPE_NAME(c.user_type_id) AS DataType,
    c.max_length,
    c.is_nullable,
    c.is_identity,
    dc.definition AS DefaultDefinition
FROM sys.columns AS c
LEFT JOIN sys.default_constraints AS dc
    ON c.default_object_id = dc.object_id
WHERE c.object_id = OBJECT_ID(N'dbo.TicketMessages')
ORDER BY c.column_id;
GO


-- Select all rows from the TicketMessages table with support ticket details
SELECT
    tm.MessageID,
    st.Title,
    tm.MessageText,
    tm.CreatedAt
FROM dbo.TicketMessages AS tm
INNER JOIN dbo.SupportTickets AS st
    ON st.TicketID = tm.TicketID
ORDER BY tm.MessageID;
GO


-- Get column details for the KnowledgeArticles table
SELECT
    c.column_id,
    c.name AS ColumnName,
    TYPE_NAME(c.user_type_id) AS DataType,
    c.max_length,
    c.is_nullable,
    c.is_identity,
    dc.definition AS DefaultDefinition
FROM sys.columns AS c
LEFT JOIN sys.default_constraints AS dc
    ON c.default_object_id = dc.object_id
WHERE c.object_id = OBJECT_ID(N'dbo.KnowledgeArticles')
ORDER BY c.column_id;
GO


-- Get row counts for all tables
SELECT N'Customers' AS TableName, COUNT(*) AS RowCnt
FROM dbo.Customers

UNION ALL

SELECT N'SupportTickets', COUNT(*)
FROM dbo.SupportTickets

UNION ALL

SELECT N'TicketMessages', COUNT(*)
FROM dbo.TicketMessages

UNION ALL

SELECT N'KnowledgeArticles', COUNT(*)
FROM dbo.KnowledgeArticles;
GO