param(
    [string]$ReportPath
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path

if (-not $ReportPath) {
    $ReportPath = Join-Path `
        $RepoRoot `
        "01-db-design\SupportKnowledgePlatform\bin\Debug\post-publish-deployment-report.xml"
}

Write-Host "Generating post-publish deployment report..."

& (Join-Path $PSScriptRoot "generate-deployment-report.ps1") `
    -ReportPath $ReportPath

if ($LASTEXITCODE -ne 0) {
    throw "Failed to generate post-publish deployment report."
}

[xml]$report = Get-Content $ReportPath

$namespace = New-Object System.Xml.XmlNamespaceManager($report.NameTable)
$namespace.AddNamespace(
    "dac",
    "http://schemas.microsoft.com/sqlserver/dac/DeployReport/2012/02"
)

$operations = $report.SelectNodes(
    "//dac:Operations/dac:Operation",
    $namespace
)

if ($operations.Count -gt 0) {
    Write-Host "Unexpected post-publish operations detected:"

    foreach ($operation in $operations) {
        $items = $operation.SelectNodes("dac:Item", $namespace)

        if ($items.Count -eq 0) {
            Write-Host " - $($operation.Name)"
            continue
        }

        foreach ($item in $items) {
            Write-Host " - $($operation.Name): $($item.Value) [$($item.Type)]"
        }
    }
    throw "Database did not converge to the DACPAC model."
}

Write-Host "Post-publish convergence verified: no remaining deployment operations."