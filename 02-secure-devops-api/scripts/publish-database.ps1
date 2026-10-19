param(
    [string]$DacpacPath,
    [string]$Server = $env:AZURE_SQL_SERVER,
    [string]$Database = $env:AZURE_SQL_DATABASE
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path

if (-not $DacpacPath) {
    $DacpacPath = Join-Path `
        $RepoRoot `
        "01-db-design\SupportKnowledgePlatform\bin\Debug\SupportKnowledgePlatform.dacpac"
}

$ErrorActionPreference = "Stop"

if (-not $Server) {
    throw "AZURE_SQL_SERVER is not set."
}

if (-not $Database) {
    throw "AZURE_SQL_DATABASE is not set."
}

if (-not (Test-Path $DacpacPath)) {
    throw "DACPAC not found: $DacpacPath"
}

Write-Host "Acquiring Azure SQL access token..."

$AccessToken = az account get-access-token `
    --resource https://database.windows.net/ `
    --query accessToken `
    --output tsv

if (-not $AccessToken) {
    throw "Failed to acquire Azure SQL access token."
}

Write-Host "Publishing DACPAC to $Server / $Database ..."

sqlpackage `
    /Action:Publish `
    /SourceFile:$DacpacPath `
    /TargetServerName:$Server `
    /TargetDatabaseName:$Database `
    /AccessToken:$AccessToken `
    /p:ScriptDatabaseOptions=False

if ($LASTEXITCODE -ne 0) {
    throw "SqlPackage publish failed with exit code $LASTEXITCODE."
}

Write-Host "Database publish completed successfully."