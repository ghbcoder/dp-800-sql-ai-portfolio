param(
    [string]$ResourceGroup = "rg-dp800-lab",
    [string]$IdentityName = "id-dp800-deploy",
    [string]$Location = "germanywestcentral"
)

$ErrorActionPreference = "Stop"

Write-Host "Checking deployment identity: $IdentityName"

$existingIdentity = az identity list `
    --resource-group $ResourceGroup `
    --query "[?name=='$IdentityName'] | [0]" `
    --output json

if ($LASTEXITCODE -ne 0) {
    throw "Failed to query managed identities."
}

if ($existingIdentity -and $existingIdentity -ne "null") {
    Write-Host "Deployment identity already exists."
}
else {
    Write-Host "Creating deployment identity..."

    az identity create `
        --resource-group $ResourceGroup `
        --name $IdentityName `
        --location $Location `
        --output none

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create deployment identity."
    }

    Write-Host "Deployment identity created."
}

Write-Host "Deployment identity details:"

az identity show `
    --resource-group $ResourceGroup `
    --name $IdentityName `
    --query "{Name:name,ClientId:clientId,PrincipalId:principalId,TenantId:tenantId}" `
    --output table

if ($LASTEXITCODE -ne 0) {
    throw "Failed to retrieve deployment identity."
}