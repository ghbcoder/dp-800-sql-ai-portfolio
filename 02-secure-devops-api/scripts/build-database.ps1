param(
    [string]$ProjectPath = ".\01-db-design\SupportKnowledgePlatform\SupportKnowledgePlatform.sqlproj"
)

$ErrorActionPreference = "Stop"

Write-Host "Building database project:"
Write-Host $ProjectPath

dotnet build $ProjectPath

if ($LASTEXITCODE -ne 0) {
    throw "Database project build failed with exit code $LASTEXITCODE."
}

Write-Host "Database project build succeeded."