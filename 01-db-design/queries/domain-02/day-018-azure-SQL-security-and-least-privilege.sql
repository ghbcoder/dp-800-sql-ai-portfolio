-- List all database principals excluding system and internal accounts
SELECT
    dp.name AS PrincipalName,
    dp.type_desc AS PrincipalType,
    dp.authentication_type_desc AS AuthenticationType
FROM sys.database_principals AS dp
WHERE dp.principal_id > 4
  AND dp.name NOT LIKE '##%'
ORDER BY dp.name;
GO


-- Get the definition of the CreateSupportTicket stored procedure
EXEC sys.sp_helptext N'dbo.CreateSupportTicket';
GO


-- Get information about the application identity 'id-dp800-app'
SELECT
    dp.name AS PrincipalName,
    dp.type_desc AS PrincipalType,
    dp.authentication_type_desc AS AuthenticationType
FROM sys.database_principals AS dp
WHERE dp.name = N'id-dp800-app';
GO


-- Get the permissions granted to the application identity 'id-dp800-app'
SELECT
    dp.name AS PrincipalName,
    perm.state_desc AS PermissionState,
    perm.permission_name AS PermissionName,
    OBJECT_SCHEMA_NAME(perm.major_id) AS SchemaName,
    OBJECT_NAME(perm.major_id) AS ObjectName
FROM sys.database_permissions AS perm
INNER JOIN sys.database_principals AS dp
    ON perm.grantee_principal_id = dp.principal_id
WHERE dp.name = N'id-dp800-app'
ORDER BY
    SchemaName,
    ObjectName,
    PermissionName;
GO


-- Test the least-privilege access of the application identity 'id-dp800-app' by attempting an unauthorized direct insert into the SupportTickets table
EXECUTE AS USER = N'id-dp800-app';

BEGIN TRY
    INSERT INTO dbo.SupportTickets
    (
        CustomerID,
        Title
    )
    VALUES
    (
        1,
        N'Unauthorized direct insert test'
    );

    SELECT N'UNEXPECTED: INSERT succeeded' AS TestResult;
END TRY
BEGIN CATCH
    SELECT
        N'EXPECTED: INSERT denied' AS TestResult,
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

REVERT;


-- Testing read access for the application identity 'id-dp800-app'
-- Finding a customer for testing read access
SELECT TOP (5)
    CustomerID,
    FullName
FROM dbo.Customers
ORDER BY CustomerID;
GO


-- Test the least-privilege access of the application identity 'id-dp800-app' by attempting to create a support ticket using the stored procedure
EXECUTE AS USER = N'id-dp800-app';

DECLARE @NewTicketID INT;

EXEC dbo.CreateSupportTicket
    @CustomerID = 1,
    @Title = N'Least-privilege stored procedure test',
    @TicketID = @NewTicketID OUTPUT;

SELECT @NewTicketID AS NewTicketID;

REVERT;
GO


-- Verify the support ticket created by the stored procedure
SELECT
    TicketID,
    CustomerID,
    Title,
    Status,
    CreatedAt
FROM dbo.SupportTickets
WHERE TicketID = 4;
GO


-- List the roles that the application identity 'id-dp800-app' is a member of
SELECT
    member_principal.name AS MemberName,
    role_principal.name AS RoleName
FROM sys.database_role_members AS drm
INNER JOIN sys.database_principals AS role_principal
    ON drm.role_principal_id = role_principal.principal_id
INNER JOIN sys.database_principals AS member_principal
    ON drm.member_principal_id = member_principal.principal_id
WHERE member_principal.name = N'id-dp800-app'
ORDER BY role_principal.name;
GO


-- List the permissions granted to the SupportAppRuntime role
SELECT
    dp.name AS PrincipalName,
    perm.state_desc AS PermissionState,
    perm.permission_name AS PermissionName,
    OBJECT_SCHEMA_NAME(perm.major_id) AS SchemaName,
    OBJECT_NAME(perm.major_id) AS ObjectName
FROM sys.database_permissions AS perm
INNER JOIN sys.database_principals AS dp
    ON perm.grantee_principal_id = dp.principal_id
WHERE dp.name = N'SupportAppRuntime'
ORDER BY
    SchemaName,
    ObjectName,
    PermissionName;
GO


-- List the roles that the application identity 'id-dp800-app' is a member of (duplicate check)
SELECT
    member_principal.name AS MemberName,
    role_principal.name AS RoleName
FROM sys.database_role_members AS drm
INNER JOIN sys.database_principals AS role_principal
    ON drm.role_principal_id = role_principal.principal_id
INNER JOIN sys.database_principals AS member_principal
    ON drm.member_principal_id = member_principal.principal_id
WHERE member_principal.name = N'id-dp800-app';
GO


-- Revoke execute permission for the application identity 'id-dp800-app' on the CreateSupportTicket stored procedure after Role assignment
REVOKE EXECUTE
    ON OBJECT::dbo.CreateSupportTicket
    FROM [id-dp800-app];
GO


-- List the permissions granted to the application identity 'id-dp800-app' after revoking execute permission
SELECT
    dp.name AS PrincipalName,
    perm.state_desc AS PermissionState,
    perm.permission_name AS PermissionName,
    OBJECT_SCHEMA_NAME(perm.major_id) AS SchemaName,
    OBJECT_NAME(perm.major_id) AS ObjectName
FROM sys.database_permissions AS perm
INNER JOIN sys.database_principals AS dp
    ON perm.grantee_principal_id = dp.principal_id
WHERE dp.name = N'id-dp800-app'
ORDER BY
    SchemaName,
    ObjectName,
    PermissionName;
GO


-- Test the execution of the CreateSupportTicket stored procedure as the application identity 'id-dp800-app' after revoking execute permission
EXECUTE AS USER = N'id-dp800-app';

DECLARE @NewTicketID INT;

EXEC dbo.CreateSupportTicket
    @CustomerID = 2,
    @Title = N'Role-based authorization test',
    @TicketID = @NewTicketID OUTPUT;

SELECT @NewTicketID AS NewTicketID;

REVERT;
GO


-- Retest the forbidden direct insert into the SupportTickets table as the application identity 'id-dp800-app'
EXECUTE AS USER = N'id-dp800-app';

BEGIN TRY
    INSERT INTO dbo.SupportTickets
    (
        CustomerID,
        Title
    )
    VALUES
    (
        2,
        N'Unauthorized role-based direct insert test'
    );

    SELECT N'UNEXPECTED: INSERT succeeded' AS TestResult;
END TRY
BEGIN CATCH
    SELECT
        N'EXPECTED: INSERT denied' AS TestResult,
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

REVERT;
GO