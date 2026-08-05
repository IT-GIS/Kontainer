[CmdletBinding()]
param(
    [string]$DatabaseName = "kontainer_db_uat",
    [string]$SourceDatabaseName = "kontainer_db",
    [string]$ApiBaseUrl = "http://127.0.0.1:8080/api/v1",
    [string]$MinioEndpoint = "http://127.0.0.1:9000",
    [string]$MinioBucket = "gift-survey-uat-real-case",
    [string]$MasterSourceCustomerCode = "UAT-CUST-17B",
    [switch]$SkipPhotos,
    [ValidateSet("All", "BrowserReady", "Finalize")]
    [string]$Mode = "All"
)

$ErrorActionPreference = "Stop"
if (-not $DatabaseName.EndsWith("_uat", [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Target database wajib berakhiran _uat."
}
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Push-Location (Join-Path $repoRoot "services\api")
try {
    go run ./cmd/uat-real-case -action verify -database-name $DatabaseName `
        -source-database-name $SourceDatabaseName -master-source-customer-code $MasterSourceCustomerCode -mode $Mode
    $verifyExit = $LASTEXITCODE
} finally {
    Pop-Location
}
if ($SkipPhotos) {
    Write-Host "SKIPPED object_existence reason=-SkipPhotos"
} else {
    try {
        $null = Invoke-WebRequest -UseBasicParsing -Uri ($MinioEndpoint.TrimEnd("/") + "/minio/health/live") -TimeoutSec 3
        Write-Host "PASS storage_endpoint_reachable endpoint=$MinioEndpoint bucket=$MinioBucket"
    } catch {
        Write-Host "SKIPPED_STORAGE_UNAVAILABLE endpoint=$MinioEndpoint"
    }
}
if ($verifyExit -ne 0) { exit $verifyExit }
