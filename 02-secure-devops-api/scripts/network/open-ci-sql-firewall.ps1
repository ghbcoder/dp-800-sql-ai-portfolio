param(
    [string]$ResourceGroup = "rg-dp800-lab",
    [string]$SqlServerName = "sql-dp800-250354",
    [string]$RuleName = "Allow-GitHub-CI"
)

$ErrorActionPreference = "Stop"

Write-Host "Resolving runner public IP..."

$runnerIp = (Invoke-RestMethod -Uri "https://api.ipify.org").Trim()

if (-not $runnerIp) {
    throw "Failed to resolve runner public IP."
}

Write-Host "Runner public IP resolved."

Write-Host "Creating temporary Azure SQL firewall rule..."

az sql server firewall-rule create `
    --resource-group $ResourceGroup `
    --server $SqlServerName `
    --name $RuleName `
    --start-ip-address $runnerIp `
    --end-ip-address $runnerIp `
    --output none

if ($LASTEXITCODE -ne 0) {
    throw "Failed to create temporary SQL firewall rule."
}

Write-Host "Temporary SQL firewall rule created."