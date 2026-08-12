[CmdletBinding()]
param(
    [string]$DatabaseName = "kontainer_db_uat",
    [string]$ApiBaseUrl = "http://127.0.0.1:8080/api/v1",
    [string]$MinioEndpoint = "http://127.0.0.1:9000",
    [string]$MinioBucket = "gift-survey-uat-real-case",
    [string]$ExpectedObjectPrefix = "uat/UAT-REAL-CASE-2026-08/",
    [string]$TargetContainerNo = "GFTU1234560",
    [string]$SourceSurveyId = "e2e00003-0000-4000-8000-000000000301",
    [string]$SurveyorEmail = "raka.pratama@uat-gift.test",
    [string]$SurveyorPassword = "Uat!Kontainer2026",
    [string]$PhotoPath = ""
)

$ErrorActionPreference = "Stop"
if (-not $DatabaseName.EndsWith("_uat", [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Target database wajib berakhiran _uat."
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$mysql = "C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe"
$mc = Join-Path $repoRoot "tmp\final-hardening\bin\mc.exe"
$env:MC_CONFIG_DIR = Join-Path $repoRoot "tmp\final-hardening\mc-config"
New-Item -ItemType Directory -Force -Path $env:MC_CONFIG_DIR | Out-Null
if (-not (Test-Path -LiteralPath $mysql) -or -not (Test-Path -LiteralPath $mc)) {
    throw "mysql.exe atau mc.exe tidak tersedia."
}
if (-not $PhotoPath) {
    $PhotoPath = Join-Path $repoRoot "tmp\uat-real-case\UAT-GFTU1234560-right-closeup.jpg"
}
$PhotoPath = (Resolve-Path -LiteralPath $PhotoPath).Path

function Invoke-UatApi {
    param(
        [string]$Method,
        [string]$Path,
        [string]$Token,
        [object]$Body = $null
    )
    $parameters = @{
        Method = $Method
        Uri = $ApiBaseUrl.TrimEnd("/") + $Path
        Headers = @{ Authorization = "Bearer $Token" }
    }
    if ($null -ne $Body) {
        $parameters.ContentType = "application/json"
        $parameters.Body = $Body | ConvertTo-Json -Depth 12 -Compress
    }
    Invoke-RestMethod @parameters
}

$login = Invoke-RestMethod -Method Post -Uri ($ApiBaseUrl.TrimEnd("/") + "/auth/login") `
    -ContentType "application/json" -Body (@{ email = $SurveyorEmail; password = $SurveyorPassword } | ConvertTo-Json -Compress)
$token = $login.data.access_token
if (-not $token) { throw "Login Surveyor UAT gagal." }
Write-Host "PASS storage_login role=surveyor credential=REDACTED"

$surveyId = (& $mysql -uroot -N -B -D $DatabaseName -e "SELECT s.id FROM surveys s JOIN job_containers jc ON jc.id=s.job_container_id WHERE jc.container_no='$TargetContainerNo' AND s.is_active=1 AND s.status='draft' LIMIT 1").Trim()
if (-not $surveyId) { throw "Survey draft untuk $TargetContainerNo tidak ditemukan." }

$checklist = Invoke-UatApi -Method Get -Path "/surveys/$surveyId/checklist" -Token $token
$checklistItem = @($checklist.data)[0]
if (-not $checklistItem) { throw "Checklist target tidak tersedia." }
$null = Invoke-UatApi -Method Put -Path "/surveys/$surveyId/checklist" -Token $token -Body @{
    items = @(@{ item_key = $checklistItem.item_key; value = "no"; note = "UAT lifecycle Foto Evidence Temuan" })
}
Write-Host "PASS checklist_negative survey_id=$surveyId item=$($checklistItem.item_key)"

$source = Invoke-UatApi -Method Get -Path "/surveys/$SourceSurveyId/preview" -Token $token
$sourceDamage = @($source.data.damages)[0]
if (-not $sourceDamage) { throw "Temuan sumber UAT tidak tersedia." }
$damageResponse = Invoke-UatApi -Method Post -Path "/surveys/$surveyId/damages" -Token $token -Body @{
    checklist_response_id = $checklistItem.id
    cedex_location_id = $sourceDamage.cedex_location_id
    component_code_id = $sourceDamage.component_id
    damage_code_id = $sourceDamage.damage_code_id
    repair_code_id = $sourceDamage.repair_code_id
    material_code_id = $sourceDamage.material_code_id
    responsibility_code_id = $sourceDamage.responsibility_code_id
    severity = $sourceDamage.severity
    quantity = 1
    quantity_unit = "pc"
    unit = "cm"
    is_repair_required = $true
    is_cargo_worthy_impact = $false
    is_photo_only = $false
    remark = "UAT storage lifecycle"
}
$damageId = $damageResponse.data.id
if (-not $damageId) { throw "Pembuatan Temuan UAT gagal." }
Write-Host "PASS finding_created survey_id=$surveyId damage_id=$damageId"

$options = Invoke-UatApi -Method Get -Path "/surveys/$surveyId/master-options" -Token $token
$findingCategory = @($options.data.photo_categories | Where-Object { $_.applies_to -eq "finding" })[0].code
if (-not $findingCategory) { throw "Kategori foto Temuan aktif tidak tersedia." }
$uploadOutput = & curl.exe -sS -H "Authorization: Bearer $token" `
    -F "photo_category=$findingCategory" -F "caption=UAT Foto Evidence Temuan lifecycle" `
    -F "file=@$PhotoPath;type=image/jpeg" "$($ApiBaseUrl.TrimEnd('/'))/survey-damages/$damageId/photos"
if ($LASTEXITCODE -ne 0) { throw "curl upload Foto Temuan gagal." }
$upload = ($uploadOutput -join "`n") | ConvertFrom-Json
if (-not $upload.success) { throw "Upload Foto Temuan ditolak: $($upload.message)" }
$photoId = $upload.data.id
$originalKey = $upload.data.object_key
$watermarkedKey = $upload.data.watermarked_object_key
foreach ($key in @($originalKey, $watermarkedKey)) {
    if (-not $key.StartsWith($ExpectedObjectPrefix, [System.StringComparison]::Ordinal)) {
        throw "Object key keluar prefix UAT: $key"
    }
}
Write-Host "PASS finding_photo_uploaded photo_id=$photoId category=$findingCategory"

foreach ($variant in @("watermarked", "original")) {
    $suffix = if ($variant -eq "original") { "?variant=original" } else { "" }
    $content = Invoke-WebRequest -UseBasicParsing -Headers @{ Authorization = "Bearer $token" } `
        -Uri "$($ApiBaseUrl.TrimEnd('/'))/survey-photos/$photoId/content$suffix"
    if ($content.StatusCode -ne 200 -or $content.Headers["Content-Type"] -notlike "image/*" -or $content.RawContentLength -le 0) {
        throw "Private content $variant tidak valid."
    }
    Write-Host "PASS private_content variant=$variant bytes=$($content.RawContentLength)"
}

$null = Invoke-UatApi -Method Delete -Path "/survey-photos/$photoId" -Token $token
$pending = [int](& $mysql -uroot -N -B -D $DatabaseName -e "SELECT COUNT(*) FROM object_deletion_queue WHERE bucket_name='$MinioBucket' AND object_key IN ('$originalKey','$watermarkedKey') AND status='pending'")
if ($pending -ne 2) { throw "Soft delete tidak membuat dua queue pending; ditemukan $pending." }
Write-Host "PASS soft_delete_queue pending=$pending"

$null = Invoke-UatApi -Method Post -Path "/survey-photos/$photoId/restore" -Token $token
$cancelled = [int](& $mysql -uroot -N -B -D $DatabaseName -e "SELECT COUNT(*) FROM object_deletion_queue WHERE bucket_name='$MinioBucket' AND object_key IN ('$originalKey','$watermarkedKey') AND status='cancelled'")
if ($cancelled -ne 2) { throw "Restore tidak membatalkan dua queue; ditemukan $cancelled." }
Write-Host "PASS restore_queue_cancelled cancelled=$cancelled"

$aliasName = "uat-lifecycle"
& $mc alias set $aliasName $MinioEndpoint minioadmin minioadmin | Out-Null
foreach ($key in @($originalKey, $watermarkedKey)) {
    & $mc stat "$aliasName/$MinioBucket/$key" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Object hilang sebelum eligible: $key" }
}
Write-Host "PASS restore_objects_retained count=2"

$null = Invoke-UatApi -Method Delete -Path "/survey-photos/$photoId" -Token $token
& $mysql -uroot -D $DatabaseName -e "UPDATE object_deletion_queue SET eligible_after=DATE_SUB(NOW(6),INTERVAL 1 SECOND),next_retry_at=NULL,locked_at=NULL,locked_by=NULL WHERE bucket_name='$MinioBucket' AND object_key IN ('$originalKey','$watermarkedKey') AND status='pending'"
if ($LASTEXITCODE -ne 0) { throw "Gagal memajukan eligible_after pada database UAT." }

$processed = 0
for ($attempt = 0; $attempt -lt 20 -and $processed -ne 2; $attempt++) {
    Start-Sleep -Milliseconds 500
    $processed = [int](& $mysql -uroot -N -B -D $DatabaseName -e "SELECT COUNT(*) FROM object_deletion_queue WHERE bucket_name='$MinioBucket' AND object_key IN ('$originalKey','$watermarkedKey') AND status='processed' AND processed_at IS NOT NULL AND error_message IS NULL")
}
if ($processed -ne 2) { throw "Worker tidak memproses dua queue dalam batas waktu." }
Write-Host "PASS worker_queue_processed processed=$processed"

foreach ($key in @($originalKey, $watermarkedKey)) {
    $previousErrorPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    & $mc stat "$aliasName/$MinioBucket/$key" 2>$null | Out-Null
    $statExitCode = $LASTEXITCODE
    $ErrorActionPreference = $previousErrorPreference
    if ($statExitCode -eq 0) { throw "Object masih ada setelah queue processed: $key" }
}
Write-Host "PASS objects_removed count=2"

$auditCount = [int](& $mysql -uroot -N -B -D $DatabaseName -e "SELECT COUNT(DISTINCT action) FROM audit_logs WHERE entity_id='$photoId' AND action IN ('survey_photos.upload','survey_photos.delete','survey_photos.restore')")
if ($auditCount -ne 3) { throw "Audit lifecycle foto tidak lengkap; action berbeda=$auditCount." }
Write-Host "PASS storage_audit actions=3"
Write-Host "PASS storage_lifecycle_complete survey_id=$surveyId photo_id=$photoId bucket=$MinioBucket"
