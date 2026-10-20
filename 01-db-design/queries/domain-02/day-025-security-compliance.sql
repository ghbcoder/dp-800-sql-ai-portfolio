/*
Security control decision matrix

RLS:
- protects rows
- predicate-based
- context-aware

DDM:
- masks query output
- does not encrypt stored data
- privileged users can UNMASK

Always Encrypted:
- protects sensitive column values cryptographically
- encryption/decryption occurs outside the database engine
- useful when DB operators should not see plaintext

TDE:
- protects database files/backups at rest
- transparent to applications
- does not protect against authorized SQL queries
*/

/*
Audit design decision:
- Prefer server-level auditing for broad coverage across databases.
- Use database-level auditing when a database needs a distinct policy.
- Send audit records to a durable Azure destination such as Log Analytics,
  Storage, or Event Hub depending on operational/compliance needs.
*/

/*
RLS       -> proven hands-on
DDM       -> proven hands-on
Encryption -> threat-model decision matrix
Auditing   -> configuration inspection + design decision
*/

-- Set the session context for CustomerId to 1 and query visible support tickets for that customer.
EXEC sys.sp_set_session_context
    @key = N'CustomerID',
    @value = 1;
GO

SELECT
    COUNT(*) AS VisibleRows,
    MIN(CustomerID) AS MinCustomerID,
    MAX(CustomerID) AS MaxCustomerID
FROM dbo.SupportTickets;
GO


-- Set the session context for CustomerId to 2 and query visible support tickets for that customer.
EXEC sys.sp_set_session_context
    @key = N'CustomerID',
    @value = 2;
GO

SELECT
    COUNT(*) AS VisibleRows,
    MIN(CustomerID) AS MinCustomerID,
    MAX(CustomerID) AS MaxCustomerID
FROM dbo.SupportTickets;
GO


-- Clear the session context for CustomerId.
EXEC sys.sp_set_session_context
    @key = N'CustomerID',
    @value = NULL;
GO

-- Query visible support tickets after clearing the session context for CustomerId.
SELECT
    COUNT(*) AS VisibleRows,
    MIN(CustomerID) AS MinCustomerID,
    MAX(CustomerID) AS MaxCustomerID
FROM dbo.SupportTickets;
GO


-- Create the test user for Dynamic Data Masking and grant SELECT permission on the Customers table.
IF USER_ID(N'DdmTestUser') IS NULL
BEGIN
    CREATE USER [DdmTestUser] WITHOUT LOGIN;
END;
GO

GRANT SELECT ON dbo.Customers TO [DdmTestUser];
GO


-- Execute as the test user to verify Dynamic Data Masking on the Customers table.
EXECUTE AS USER = 'DdmTestUser';
GO

SELECT
    CustomerID,
    Email
FROM dbo.Customers
ORDER BY CustomerID;
GO

REVERT;
GO


