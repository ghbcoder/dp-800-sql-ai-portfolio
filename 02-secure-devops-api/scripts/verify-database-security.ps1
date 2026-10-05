param(
    [string]$TestScript = ".\02-secure-devops-api\tests\verify-app-least-privilege.sql"
)

$ErrorActionPreference = "Stop"

if (-not $env:AZURE_SQL_SERVER) {
    throw "AZURE_SQL_SERVER is not set."
}

if (-not $env:AZURE_SQL_DATABASE) {
    throw "AZURE_SQL_DATABASE is not set."
}

if (-not (Test-Path $TestScript)) {
    throw "Security test script not found: $TestScript"
}

Write-Host "Running database authorization security contract..."

sqlcmd `
    -S "$env:AZURE_SQL_SERVER" `
    -d "$env:AZURE_SQL_DATABASE" `
    --authentication-method ActiveDirectoryAzCli `
    -b `
    -i $TestScript

if ($LASTEXITCODE -ne 0) {
    throw "Database security verification failed with exit code $LASTEXITCODE."
}

Write-Host "Database security verification passed."