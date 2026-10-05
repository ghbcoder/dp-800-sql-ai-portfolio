$ErrorActionPreference = "Stop"

Write-Host "=== DATABASE PIPELINE START ==="

Write-Host "`n[1/4] Build database project"
& ".\02-secure-devops-api\scripts\build-database.ps1"

Write-Host "`n[2/4] Generate deployment report"
& ".\02-secure-devops-api\scripts\generate-deployment-report.ps1"

Write-Host "`n[3/4] Check deployment report"
& ".\02-secure-devops-api\scripts\check-deployment-report.ps1"

Write-Host "`n[4/4] Verify database security"
& ".\02-secure-devops-api\scripts\verify-database-security.ps1"

Write-Host "`n=== DATABASE PIPELINE PASSED ==="