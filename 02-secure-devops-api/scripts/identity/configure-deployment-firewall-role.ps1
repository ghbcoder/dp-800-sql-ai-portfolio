param(
    [string]$ResourceGroup = "rg-dp800-lab",
    [string]$SqlServerName = "sql-dp800-250354",
    [string]$IdentityName = "id-dp800-deploy",
    [string]$RoleName = "DP800 SQL Firewall Manager"
)

$ErrorActionPreference = "Stop"

Write-Host "Resolving deployment identity..."

$principalId = az identity show `
    --resource-group $ResourceGroup `
    --name $IdentityName `
    --query principalId `
    --output tsv

if ($LASTEXITCODE -ne 0 -or -not $principalId) {
    throw "Failed to resolve deployment identity principal ID."
}

Write-Host "Resolving SQL server resource ID..."

$sqlServerId = az sql server show `
    --resource-group $ResourceGroup `
    --name $SqlServerName `
    --query id `
    --output tsv

if ($LASTEXITCODE -ne 0 -or -not $sqlServerId) {
    throw "Failed to resolve SQL server resource ID."
}

$roleDefinition = @{
    Name = $RoleName
    IsCustom = $true
    Description = "Manage Azure SQL logical server firewall rules for CI/CD validation."
    Actions = @(
        "Microsoft.Sql/servers/firewallRules/read"
        "Microsoft.Sql/servers/firewallRules/write"
        "Microsoft.Sql/servers/firewallRules/delete"
    )
    NotActions = @()
    AssignableScopes = @(
        $sqlServerId
    )
}

$tempFile = Join-Path $env:TEMP "dp800-sql-firewall-role.json"

$roleDefinition |
    ConvertTo-Json -Depth 5 |
    Set-Content -Path $tempFile -Encoding utf8

Write-Host "Checking custom role..."

$existingRole = az role definition list `
    --name $RoleName `
    --query "[0].name" `
    --output tsv

if ($LASTEXITCODE -ne 0) {
    throw "Failed to query custom role definitions."
}

if (-not $existingRole) {
    Write-Host "Creating custom role..."

    az role definition create `
        --role-definition $tempFile `
        --output none

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create custom firewall-management role."
    }
}
else {
    Write-Host "Custom role already exists."
}

Write-Host "Checking role assignment..."

$existingAssignment = az role assignment list `
    --assignee-object-id $principalId `
    --scope $sqlServerId `
    --role $RoleName `
    --query "[0].id" `
    --output tsv

if ($LASTEXITCODE -ne 0) {
    throw "Failed to query role assignments."
}

if (-not $existingAssignment) {
    Write-Host "Assigning custom role to deployment identity..."

    az role assignment create `
        --assignee-object-id $principalId `
        --assignee-principal-type ServicePrincipal `
        --role $RoleName `
        --scope $sqlServerId `
        --output none

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to assign firewall-management role."
    }
}
else {
    Write-Host "Role assignment already exists."
}

Remove-Item $tempFile -ErrorAction SilentlyContinue

Write-Host "Deployment firewall-management RBAC configured."