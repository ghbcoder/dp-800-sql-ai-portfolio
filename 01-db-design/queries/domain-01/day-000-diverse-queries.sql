SELECT
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_unique AS IsUnique,
    c.name AS ColumnName,
    ic.key_ordinal AS KeyPosition
FROM sys.indexes AS i
INNER JOIN sys.index_columns AS ic
    ON i.object_id = ic.object_id
    AND i.index_id = ic.index_id
INNER JOIN sys.columns AS c
    ON ic.object_id = c.object_id
    AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID(N'dbo.SupportTickets')
ORDER BY i.index_id, ic.key_ordinal;



SELECT
    COUNT(*) AS TicketCount
FROM dbo.SupportTickets;


SELECT COUNT(*) AS CustomerCount
FROM dbo.Customers;


WITH Numbers AS
(
    SELECT TOP (100)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
)
INSERT INTO dbo.Customers
(
    FullName,
    Email
)
SELECT
    CONCAT(N'Performance Customer ', n),
    CONCAT(N'perf-', n, N'@dp800.test')
FROM Numbers;


WITH Numbers AS
(
    SELECT TOP (20000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects AS a
    CROSS JOIN sys.all_objects AS b
),
TestCustomers AS
(
    SELECT
        CustomerID,
        ROW_NUMBER() OVER (ORDER BY CustomerID) AS rn
    FROM dbo.Customers
    WHERE Email LIKE N'perf-%@dp800.test'
)
INSERT INTO dbo.SupportTickets
(
    CustomerID,
    Title,
    Status
)
SELECT
    c.CustomerID,
    CONCAT(N'Performance test ticket ', n),
    CASE n % 4
        WHEN 0 THEN N'Open'
        WHEN 1 THEN N'In Progress'
        WHEN 2 THEN N'Resolved'
        ELSE N'Closed'
    END
FROM Numbers
INNER JOIN TestCustomers AS c
    ON c.rn = ((n - 1) % 100) + 1;
;


SELECT
    name AS ConstraintName,
    definition AS CheckDefinition
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID(N'dbo.SupportTickets');


CREATE INDEX IX_SupportTickets_CustomerID_Status
ON dbo.SupportTickets (CustomerID, Status);


CREATE NONCLUSTERED INDEX [IX_SupportTickets_CustomerID_Status]
ON [dbo].[SupportTickets]
(
    [CustomerID],
    [Status]
)
INCLUDE
(
    [Title],
    [CreatedAt]
);

SELECT
    SERVERPROPERTY('EngineEdition') AS EngineEdition,
    SERVERPROPERTY('ProductVersion') AS ProductVersion,
    DATABASEPROPERTYEX(DB_NAME(), 'CompatibilityLevel') AS CompatibilityLevel;

----

DECLARE @AIMetadata NVARCHAR(MAX) = N'
{
  "language": "en",
  "sentiment": "negative",
  "confidence": 0.94,
  "intent": "technical_support",
  "entities": ["AI search", "HTTP 500"]
}';

SELECT
    JSON_VALUE(@AIMetadata, '$.sentiment') AS Sentiment,
    JSON_QUERY(@AIMetadata, '$.entities') AS Entities;

SELECT
    [key],
    [value],
    [type]
FROM OPENJSON(
    JSON_QUERY(@AIMetadata, '$.entities')
)
GO

----
DECLARE @AIEntities NVARCHAR(MAX) = N'
{
  "entities": ["AI search", "HTTP 500"]
}';

SELECT
    ISJSON(N'{"sentiment": "negative", "confidence": 0.94}') AS IsValidJSON,
    ISJSON(N'This definitely is not JSON') AS IsInvalidJSON;

----
UPDATE dbo.SupportTickets
SET AIMetadata = N'{
  "language": "en",
  "sentiment": "negative",
  "confidence": 0.94,
  "model": "support-classifier-v2",
  "intent": "technical_support",
  "entities": ["AI search", "HTTP 500"]
}'
WHERE TicketID = 2;
go

----------------

UPDATE dbo.SupportTickets
SET AIMetadata = N'this definitely is not json'
WHERE TicketID = 2;
GO

------------------
SELECT 
    TicketID,
    Title,
    Status,
    JSON_VALUE(AIMetadata, '$.sentiment') AS Sentiment,
    JSON_VALUE(AIMetadata, '$.confidence') AS Confidence,
    JSON_QUERY(AIMetadata, '$.entities') AS Entities
FROM dbo.SupportTickets
WHERE TicketID = 2;

--------------------
SELECT 
    TicketID,
    Title,
    entity.[key] AS EntityPosition,
    entity.[value] AS Entity
FROM dbo.SupportTickets AS st
    CROSS APPLY OPENJSON(
        JSON_QUERY(st.AIMetadata, '$.entities')
     ) AS entity
WHERE TicketID = 2;
GO

--------------------
SELECT
    st.TicketID,
    st.Title,
    entity.[value] AS Entity
FROM dbo.SupportTickets AS st
OUTER APPLY OPENJSON(
    JSON_QUERY(st.AIMetadata, '$.entities')
) AS entity
WHERE st.TicketID IN (2, 20)
ORDER BY
    st.TicketID,
    entity.[key];
GO

------------------

SELECT
    st.TicketID,
    ai.Language,
    ai.Sentiment,
    ai.Confidence,
    ai.Intent
FROM dbo.SupportTickets AS st
CROSS APPLY OPENJSON(st.AIMetadata)
WITH
(
    Language   NVARCHAR(10)  '$.language',
    Sentiment  NVARCHAR(30)  '$.sentiment',
    Confidence DECIMAL(5,4)  '$.confidence',
    Intent     NVARCHAR(100) '$.intent'
) AS ai
WHERE st.TicketID = 2;
GO

--------------------
SELECT
    t.name AS TableName,
    t.temporal_type_desc AS TemporalType,
    OBJECT_NAME(t.history_table_id) AS HistoryTable
FROM sys.tables AS t
WHERE t.object_id = OBJECT_ID(N'dbo.SupportTickets');
GO

-------------------------------------
SET SHOWPLAN_XML ON;
GO

SELECT
    TicketID,
    CustomerID,
    Title,
    Status,
    CreatedAt
FROM dbo.SupportTickets
WHERE CustomerID = 3
  AND Status = N'In Progress';
GO

SET SHOWPLAN_XML OFF;
GO


SET STATISTICS IO ON;

SELECT
    TicketID,
    CustomerID,
    Title,
    Status,
    CreatedAt
FROM dbo.SupportTickets
WHERE CustomerID = 3
  AND Status = N'In Progress';

SET STATISTICS IO OFF;
GO
---------------------------------