-- Query the deployment database principal for the CI/CD identity
SELECT
    name,
    type_desc,
    authentication_type_desc
FROM sys.database_principals
WHERE name = N'id-dp800-deploy';
GO


-- Query the roles for the CI/CD deployment identity
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