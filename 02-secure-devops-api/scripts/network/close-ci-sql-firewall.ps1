param(
    [string]$ResourceGroup = "rg-dp800-lab",
    [string]$SqlServerName = "sql-dp800-250354",
    [string]$RuleName = "Allow-GitHub-CI"
)

$ErrorActionPreference = "Stop"

Write-Host "Removing temporary Azure SQL firewall rule..."

$existingRule = az sql server firewall-rule list `
    --resource-group $ResourceGroup `
    --server $SqlServerName `
    --query "[?name=='$RuleName'] | [0].name" `
    --output tsv

if ($LASTEXITCODE -ne 0) {
    throw "Failed to query SQL firewall rules."
}

if ($existingRule) {
    az sql server firewall-rule delete `
        --resource-group $ResourceGroup `
        --server $SqlServerName `
        --name $RuleName `

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to remove temporary SQL firewall rule."
    }

    Write-Host "Temporary SQL firewall rule removed."
}
else {
    Write-Host "Temporary SQL firewall rule does not exist."
}