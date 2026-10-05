param(
    [string]$DacpacPath = ".\01-db-design\SupportKnowledgePlatform\bin\Debug\SupportKnowledgePlatform.dacpac",
    [string]$OutputPath = ".\01-db-design\SupportKnowledgePlatform\bin\Debug\deployment-report.xml"
)

$ErrorActionPreference = "Stop"

if (-not $env:AZURE_SQL_SERVER) {
    throw "AZURE_SQL_SERVER is not set."
}

if (-not $env:AZURE_SQL_DATABASE) {
    throw "AZURE_SQL_DATABASE is not set."
}

if (-not (Test-Path $DacpacPath)) {
    throw "DACPAC not found: $DacpacPath"
}

Write-Host "Acquiring Azure SQL access token..."

$accessToken = az account get-access-token `
    --resource https://database.windows.net/ `
    --query accessToken `
    --output tsv

if ($LASTEXITCODE -ne 0 -or -not $accessToken) {
    throw "Failed to acquire Azure SQL access token."
}

Write-Host "Generating deployment report..."

sqlpackage `
    /Action:DeployReport `
    /SourceFile:$DacpacPath `
    /TargetConnectionString:"Server=tcp:$env:AZURE_SQL_SERVER,1433;Database=$env:AZURE_SQL_DATABASE;Encrypt=True;TrustServerCertificate=False;" `
    /AccessToken:$accessToken `
    /OutputPath:$OutputPath

if ($LASTEXITCODE -ne 0) {
    throw "SqlPackage deployment report failed with exit code $LASTEXITCODE."
}

Write-Host "Deployment report created:"
Write-Host $OutputPath