[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$DatabaseName = "kontainer_db_uat",
    [string]$SourceDatabaseName = "kontainer_db",
    [string]$ApiBaseUrl = "http://127.0.0.1:8080/api/v1",
    [string]$MinioEndpoint = "http://127.0.0.1:9000",
    [string]$MinioBucket = "gift-survey-uat-real-case",
    [string]$MasterSourceCustomerCode = "UAT-CUST-17B",
    [switch]$SkipPhotos,
    [ValidateSet("All", "BrowserReady", "Finalize")]
    [string]$Mode = "All",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
if (-not $DatabaseName.EndsWith("_uat", [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Cleanup ditolak: database wajib berakhiran _uat."
}
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$datasetId = "UAT-REAL-CASE-2026-08"
$goRuntimeRoot = Join-Path $repoRoot "tmp\go-runtime\uat-real-case"
$env:GOCACHE = Join-Path $goRuntimeRoot "cache"
$env:APPDATA = Join-Path $goRuntimeRoot "appdata"
$env:LOCALAPPDATA = Join-Path $goRuntimeRoot "localappdata"
New-Item -ItemType Directory -Force -Path $env:GOCACHE,$env:APPDATA,$env:LOCALAPPDATA | Out-Null
Push-Location (Join-Path $repoRoot "services\api")
try {
    $arguments = @("run", "./cmd/uat-real-case", "-action", "cleanup", "-database-name", $DatabaseName)
    if ($DryRun) { $arguments += "-dry-run" }
    & go @arguments
    $cleanupExit = $LASTEXITCODE
} finally {
    Pop-Location
}
if (-not $SkipPhotos) {
    Write-Host "Object cleanup dibatasi prefix uat/$datasetId/ pada bucket $MinioBucket."
    Write-Host "SKIPPED object_delete: helper menolak menghapus bucket/object tanpa client MinIO dan manifest object eksplisit."
}
if ($cleanupExit -ne 0) { exit $cleanupExit }
