param(
    [string]$ResourceGroup = "rg-dp800-lab",
    [string]$IdentityName = "id-dp800-deploy",
    [string]$CredentialName = "github-main"
)

$ErrorActionPreference = "Stop"

Write-Host "Verifying deployment identity..."

$identity = az identity show `
    --resource-group $ResourceGroup `
    --name $IdentityName `
    --query "{Name:name,ClientId:clientId,PrincipalId:principalId,TenantId:tenantId}" `
    --output json

if ($LASTEXITCODE -ne 0 -or -not $identity) {
    throw "Deployment identity verification failed."
}

$identityObject = $identity | ConvertFrom-Json

Write-Host "Identity: $($identityObject.Name)"
Write-Host "Client ID present: $([bool]$identityObject.ClientId)"
Write-Host "Principal ID present: $([bool]$identityObject.PrincipalId)"
Write-Host "Tenant ID present: $([bool]$identityObject.TenantId)"

Write-Host "`nVerifying GitHub federated credential..."

$credential = az identity federated-credential show `
    --resource-group $ResourceGroup `
    --identity-name $IdentityName `
    --name $CredentialName `
    --output json

if ($LASTEXITCODE -ne 0 -or -not $credential) {
    throw "Federated credential verification failed."
}

$credentialObject = $credential | ConvertFrom-Json

Write-Host "Credential: $($credentialObject.name)"
Write-Host "Issuer: $($credentialObject.issuer)"
Write-Host "Subject: $($credentialObject.subject)"
Write-Host "Audience: $($credentialObject.audiences -join ', ')"

if ($credentialObject.issuer -ne "https://token.actions.githubusercontent.com") {
    throw "Unexpected federated credential issuer."
}

if ($credentialObject.audiences -notcontains "api://AzureADTokenExchange") {
    throw "Required Azure AD token exchange audience is missing."
}

Write-Host "`nGitHub OIDC configuration verified."