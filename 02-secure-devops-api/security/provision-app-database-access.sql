/*
    provision-app-database-access.sql

    Purpose:
    Provision the application identity in Azure SQL and grant
    least-privilege access to approved database interfaces.

    Environment-specific identity:
    id-dp800-app

    Security model:
    - Microsoft Entra authentication
    - Contained database principal
    - No db_owner membership
    - No db_datareader membership
    - No db_datawriter membership
    - Object-level permissions granted explicitly
*/

DECLARE @AppIdentity sysname = N'id-dp800-app';
DECLARE @Sql nvarchar(max);

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_principals
    WHERE name = @AppIdentity
)
BEGIN
    SET @Sql =
        N'CREATE USER ' +
        QUOTENAME(@AppIdentity) +
        N' FROM EXTERNAL PROVIDER;';

    EXEC sys.sp_executesql @Sql;
END;

/*
    Authorization is assigned through the stable database role.
    The environment-specific Entra identity is mapped to that role
    after the database project has deployed the role and its permissions.
*/

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_role_members AS drm
    INNER JOIN sys.database_principals AS role_principal
        ON drm.role_principal_id = role_principal.principal_id
    INNER JOIN sys.database_principals AS member_principal
        ON drm.member_principal_id = member_principal.principal_id
    WHERE role_principal.name = N'SupportAppRuntime'
      AND member_principal.name = @AppIdentity
)
BEGIN
    SET @Sql =
        N'ALTER ROLE [SupportAppRuntime] ADD MEMBER ' +
        QUOTENAME(@AppIdentity) +
        N';';

    PRINT @Sql;

    EXEC sys.sp_executesql @Sql;
END;