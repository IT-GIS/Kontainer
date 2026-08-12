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
$datasetId = "UAT-REAL-CASE-2026-08"
$objectPrefix = "uat/$datasetId"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$goRuntimeRoot = Join-Path $repoRoot "tmp\go-runtime\uat-real-case"
$env:GOCACHE = Join-Path $goRuntimeRoot "cache"
$env:APPDATA = Join-Path $goRuntimeRoot "appdata"
$env:LOCALAPPDATA = Join-Path $goRuntimeRoot "localappdata"
New-Item -ItemType Directory -Force -Path $env:GOCACHE,$env:APPDATA,$env:LOCALAPPDATA | Out-Null

if (-not $DatabaseName.EndsWith("_uat", [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Target database wajib berakhiran _uat."
}
if ($DatabaseName -eq $SourceDatabaseName) {
    throw "Source dan target database tidak boleh sama."
}

$mysqlRoot = "C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin"
$mysql = Join-Path $mysqlRoot "mysql.exe"
$mysqldump = Join-Path $mysqlRoot "mysqldump.exe"
if (-not (Test-Path -LiteralPath $mysql) -or -not (Test-Path -LiteralPath $mysqldump)) {
    throw "MySQL Laragon tidak ditemukan di $mysqlRoot."
}

$targetExists = & $mysql -uroot -N -e "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name='$DatabaseName'"
if ([int]$targetExists -eq 0) {
    $sourceExists = & $mysql -uroot -N -e "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name='$SourceDatabaseName'"
    if ([int]$sourceExists -ne 1) {
        throw "Source database $SourceDatabaseName tidak tersedia; clone dihentikan tanpa fallback."
    }
    & $mysql -uroot -e "CREATE DATABASE $DatabaseName CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    if ($LASTEXITCODE -ne 0) { throw "Gagal membuat target database." }
    & $mysqldump -uroot --single-transaction --routines --triggers $SourceDatabaseName |
        & $mysql -uroot $DatabaseName
    if ($LASTEXITCODE -ne 0) { throw "Clone database UAT gagal." }
    Write-Host "PASS database_clone source=$SourceDatabaseName target=$DatabaseName"
} else {
    Write-Host "PASS database_target_exists target=$DatabaseName (idempotent)"
}

$migrationMarkers = @(
    @{ File = "0013_iso_cedex_decision_rules.up.sql"; Query = "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DatabaseName' AND table_name='cedex_damage_decision_rules'" },
    @{ File = "0014_iso_cedex_governance.up.sql"; Query = "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema='$DatabaseName' AND table_name='cedex_locations' AND column_name='input_mode'" },
    @{ File = "0015_interactive_survey_sheet.up.sql"; Query = "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema='$DatabaseName' AND table_name='survey_damages' AND column_name='location_selection_snapshot'" },
    @{ File = "0016_survey_workflow_integrity.up.sql"; Query = "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DatabaseName' AND table_name='survey_revisions'" },
    @{ File = "0017_workflow_operational_closure.up.sql"; Query = "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DatabaseName' AND table_name='object_deletion_queue'" },
    @{ File = "0018_final_repository_hardening.up.sql"; Query = "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema='$DatabaseName' AND table_name='object_deletion_queue' AND column_name='retry_count'" }
)
foreach ($marker in $migrationMarkers) {
    $present = & $mysql -uroot -N -e $marker.Query
    if ([int]$present -eq 0) {
        $migrationPath = Join-Path $repoRoot "services\api\migrations\$($marker.File)"
        Get-Content -Raw -LiteralPath $migrationPath | & $mysql -uroot $DatabaseName
        if ($LASTEXITCODE -ne 0) {
            throw "Migration $($marker.File) gagal. Target mungkin parsial; seed dihentikan terbuka."
        }
        Write-Host "PASS migration_applied file=$($marker.File)"
    }
}

Push-Location (Join-Path $repoRoot "services\api")
try {
    go run ./cmd/uat-real-case -action bootstrap -database-name $DatabaseName `
        -source-database-name $SourceDatabaseName -master-source-customer-code $MasterSourceCustomerCode -mode $Mode
    if ($LASTEXITCODE -ne 0) { throw "Bootstrap helper gagal." }
    go run ./cmd/uat-real-case -action images -output-dir (Join-Path $repoRoot "tmp\uat-real-case")
    if ($LASTEXITCODE -ne 0) { throw "Pembuatan gambar sintetis gagal." }
} finally {
    Pop-Location
}

$structuredCount = & $mysql -uroot -N -e "SELECT COUNT(*) FROM $DatabaseName.cedex_locations WHERE status='active' AND input_mode='structured'"
if ([int]$structuredCount -eq 0) {
    Write-Host "INFO structured_location_mapping=0; fixture memakai CEDEX Location manual aktif milik Customer tanpa mengarang mapping structured."
}

try {
    $null = Invoke-WebRequest -UseBasicParsing -Uri ($ApiBaseUrl -replace "/api/v1$", "/health") -TimeoutSec 3
    Write-Host "PASS api_reachable base=$ApiBaseUrl"
} catch {
    Write-Host "INFO api_unavailable base=$ApiBaseUrl; fixture domain database sudah siap dan UAT HTTP dijalankan setelah service dinyalakan."
}

if ($SkipPhotos) {
    Write-Host "SKIPPED photos reason=-SkipPhotos"
} else {
    try {
        $null = Invoke-WebRequest -UseBasicParsing -Uri ($MinioEndpoint.TrimEnd("/") + "/minio/health/live") -TimeoutSec 3
        Write-Host "PASS storage_reachable endpoint=$MinioEndpoint bucket=$MinioBucket prefix=$objectPrefix"
    } catch {
        Write-Host "SKIPPED_STORAGE_UNAVAILABLE endpoint=$MinioEndpoint; metadata foto tidak diinsert."
    }
}

Write-Host "Dataset $datasetId selesai pada tahap aman yang didukung master aktif. Jalankan verify-real-case.ps1 untuk 17 pemeriksaan, kemudian jalankan Playwright operational terhadap database UAT ini."
