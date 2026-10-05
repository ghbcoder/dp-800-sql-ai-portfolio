param(
    [string]$ResourceGroup = "rg-dp800-lab",
    [string]$IdentityName = "id-dp800-deploy",
    [string]$CredentialName = "github-main",
    [string]$GitHubOwner = "ghbcoder",
    [string]$GitHubOwnerId = "36971292",
    [string]$GitHubRepository = "dp-800-sql-ai-portfolio",
    [string]$GitHubRepositoryId = "1369554725",
    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"

$subject = "repo:$GitHubOwner@$GitHubOwnerId/$GitHubRepository@$GitHubRepositoryId`:ref:refs/heads/$Branch"

$issuer = "https://token.actions.githubusercontent.com"
$audience = "api://AzureADTokenExchange"

Write-Host "Checking federated credential: $CredentialName"

$existingCredential = az identity federated-credential list `
    --resource-group $ResourceGroup `
    --identity-name $IdentityName `
    --query "[?name=='$CredentialName'] | [0]" `
    --output json

if ($LASTEXITCODE -ne 0) {
    throw "Failed to query federated credentials."
}

if ($existingCredential -and $existingCredential -ne "null") {
    Write-Host "Federated credential already exists."
}
else {
    Write-Host "Creating federated credential..."

    az identity federated-credential create `
        --resource-group $ResourceGroup `
        --identity-name $IdentityName `
        --name $CredentialName `
        --issuer $issuer `
        --subject $subject `
        --audiences $audience `
        --output none

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create federated credential."
    }

    Write-Host "Federated credential created."
}

Write-Host "Federated credential details:"

az identity federated-credential show `
    --resource-group $ResourceGroup `
    --identity-name $IdentityName `
    --name $CredentialName `
    --query "{Name:name,Issuer:issuer,Subject:subject,Audiences:audiences}" `
    --output json

if ($LASTEXITCODE -ne 0) {
    throw "Failed to retrieve federated credential."
}