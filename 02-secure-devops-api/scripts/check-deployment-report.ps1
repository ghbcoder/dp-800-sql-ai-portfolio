param(
    [string]$ReportPath = ".\01-db-design\SupportKnowledgePlatform\bin\Debug\deployment-report.xml"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ReportPath)) {
    throw "Deployment report not found: $ReportPath"
}

[xml]$report = Get-Content $ReportPath

$namespace = New-Object System.Xml.XmlNamespaceManager($report.NameTable)
$namespace.AddNamespace(
    "dac",
    "http://schemas.microsoft.com/sqlserver/dac/DeployReport/2012/02"
)

$dropOperations = $report.SelectNodes(
    "//dac:Operation[@Name='Drop']/dac:Item",
    $namespace
)

if ($dropOperations.Count -gt 0) {
    Write-Host "Potentially destructive deployment operations detected:"

    foreach ($item in $dropOperations) {
        Write-Host " - $($item.Value) [$($item.Type)]"
    }

    throw "Deployment report contains DROP operations. Manual review required."
}

Write-Host "Deployment report passed: no DROP operations detected."