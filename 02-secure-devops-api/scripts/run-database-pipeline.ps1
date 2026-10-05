$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path

Write-Host "=== DATABASE PIPELINE START ==="
Write-Host "Repository root: $RepoRoot"

Push-Location $RepoRoot

try {
    Write-Host "`n[1/4] Build database project"
    & (Join-Path $PSScriptRoot "build-database.ps1")

    Write-Host "`n[2/4] Generate deployment report"
    & (Join-Path $PSScriptRoot "generate-deployment-report.ps1")

    Write-Host "`n[3/4] Check deployment report"
    & (Join-Path $PSScriptRoot "check-deployment-report.ps1")

    Write-Host "`n[4/4] Verify database security"
    & (Join-Path $PSScriptRoot "verify-database-security.ps1")

    Write-Host "`n=== DATABASE PIPELINE PASSED ==="
}
finally {
    Pop-Location
}