/*
    provision-deployment-database-access.sql

    Purpose:
    Provision the CI/CD deployment identity in Azure SQL.

    Design:
    - Microsoft Entra contained database user
    - idempotent
    - no db_owner
    - no db_datareader / db_datawriter by default
    - permissions granted explicitly later
*/

DECLARE @DeploymentIdentity sysname = N'id-dp800-deploy';
DECLARE @DeploymentRole sysname = N'DatabaseDeploymentValidator';
DECLARE @Sql nvarchar(max);

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_principals
    WHERE name = @DeploymentIdentity
)
BEGIN
    SET @Sql =
        N'CREATE USER ' +
        QUOTENAME(@DeploymentIdentity) +
        N' FROM EXTERNAL PROVIDER;';

    EXEC sys.sp_executesql @Sql;
END;

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_role_members AS drm
    INNER JOIN sys.database_principals AS role_principal
        ON drm.role_principal_id = role_principal.principal_id
    INNER JOIN sys.database_principals AS member_principal
        ON drm.member_principal_id = member_principal.principal_id
    WHERE role_principal.name = @DeploymentRole
      AND member_principal.name = @DeploymentIdentity
)
BEGIN
    SET @Sql =
        N'ALTER ROLE ' +
        QUOTENAME(@DeploymentRole) +
        N' ADD MEMBER ' +
        QUOTENAME(@DeploymentIdentity) +
        N';';

    EXEC sys.sp_executesql @Sql;
END;
GO