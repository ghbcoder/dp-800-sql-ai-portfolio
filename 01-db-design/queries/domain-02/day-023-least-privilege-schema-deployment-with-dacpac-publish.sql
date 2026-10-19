
-- Query the database permissions for the CI/CD deployment identity and the DatabaseDeploymentValidator
SELECT
    dp.name AS PrincipalName,
    perm.permission_name,
    perm.state_desc,
    perm.class_desc
FROM sys.database_permissions AS perm
JOIN sys.database_principals AS dp
    ON perm.grantee_principal_id = dp.principal_id
WHERE dp.name IN
(
    N'id-dp800-deploy',
    N'DatabaseDeploymentValidator'
)
ORDER BY
    dp.name,
    perm.permission_name;
GO


-- Query the database roles for the CI/CD deployment identity
SELECT
    member_principal.name AS MemberName,
    role_principal.name AS RoleName
FROM sys.database_role_members AS drm
JOIN sys.database_principals AS role_principal
    ON drm.role_principal_id = role_principal.principal_id
JOIN sys.database_principals AS member_principal
    ON drm.member_principal_id = member_principal.principal_id
WHERE member_principal.name = N'id-dp800-deploy';
GO


-- Test if the deployment identity can alter the dbo.KnowledgeArticles table
BEGIN TRY
    EXECUTE AS USER = N'id-dp800-deploy';

    ALTER TABLE dbo.KnowledgeArticles
        ADD __PermissionProbe bit NULL;

    ALTER TABLE dbo.KnowledgeArticles
        DROP COLUMN __PermissionProbe;

    REVERT;

    SELECT
        N'UNEXPECTED: deployment identity can alter dbo.KnowledgeArticles'
        AS Result;
END TRY
BEGIN CATCH
    DECLARE
        @ErrorNumber int = ERROR_NUMBER(),
        @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();

    IF USER_NAME() = N'id-dp800-deploy'
        REVERT;

    SELECT
        @ErrorNumber AS ErrorNumber,
        @ErrorMessage AS ErrorMessage;
END CATCH;
GO


-- Test the effective permissions of the deployment identity
EXECUTE AS USER = N'id-dp800-deploy';

SELECT
    USER_NAME() AS CurrentUser,
    HAS_PERMS_BY_NAME(DB_NAME(), 'DATABASE', 'CONNECT') AS CanConnect,
    HAS_PERMS_BY_NAME(DB_NAME(), 'DATABASE', 'VIEW DEFINITION') AS CanViewDefinition,
    HAS_PERMS_BY_NAME(N'dbo.KnowledgeArticles', 'OBJECT', 'SELECT') AS CanSelect,
    HAS_PERMS_BY_NAME(N'dbo.KnowledgeArticles', 'OBJECT', 'ALTER') AS CanAlterTable,
    HAS_PERMS_BY_NAME(N'dbo', 'SCHEMA', 'ALTER') AS CanAlterSchema;

REVERT;
GO


-- Test if the deployment identity can alter the dbo.KnowledgeArticles table (positive test)
BEGIN TRY
    EXECUTE AS USER = N'id-dp800-deploy';

    ALTER TABLE dbo.KnowledgeArticles
        ADD __PermissionProbe bit NULL;

    ALTER TABLE dbo.KnowledgeArticles
        DROP COLUMN __PermissionProbe;

    REVERT;

    SELECT
        N'SUCCESS: deployment identity can alter dbo.KnowledgeArticles'
        AS Result;
END TRY
BEGIN CATCH
    DECLARE
        @ErrorNumber int = ERROR_NUMBER(),
        @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();

    IF USER_NAME() = N'id-dp800-deploy'
        REVERT;

    SELECT
        @ErrorNumber AS ErrorNumber,
        @ErrorMessage AS ErrorMessage;
END CATCH;
GO


-- Inspect the LastReviewedAt column in the dbo.KnowledgeArticles table
SELECT
    c.name,
    TYPE_NAME(c.user_type_id) AS DataType,
    c.max_length,
    c.is_nullable
FROM sys.columns AS c
WHERE c.object_id = OBJECT_ID(N'dbo.KnowledgeArticles')
  AND c.name = N'LastReviewedAt';
GO


-- Inspect the effective permissions of the deployment identity
EXECUTE AS USER = N'id-dp800-deploy';

SELECT
    HAS_PERMS_BY_NAME(DB_NAME(), 'DATABASE', 'VIEW DEFINITION') AS CanViewDefinition,
    HAS_PERMS_BY_NAME(N'dbo.KnowledgeArticles', 'OBJECT', 'ALTER') AS CanAlterTable,
    HAS_PERMS_BY_NAME(DB_NAME(), 'DATABASE', 'ALTER') AS CanAlterDatabase,
    IS_ROLEMEMBER(N'db_ddladmin') AS IsDdlAdmin,
    IS_ROLEMEMBER(N'db_owner') AS IsDbOwner;

REVERT;
GO