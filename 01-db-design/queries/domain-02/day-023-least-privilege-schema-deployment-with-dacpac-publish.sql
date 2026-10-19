
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