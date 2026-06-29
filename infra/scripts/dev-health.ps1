$ErrorActionPreference = "Stop"

$api = Invoke-RestMethod -Uri "http://localhost:8080/health" -Method Get
Write-Host "API:" ($api | ConvertTo-Json -Compress)

$web = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing
Write-Host "Web:" $web.StatusCode
