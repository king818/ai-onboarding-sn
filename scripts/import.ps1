param(
    [string]$ZipPath = ".\solution.zip",
    [string]$UnpackFolder = ".\solution"
)

Write-Host "========================================"
Write-Host "Power Platform Solution Import Script"
Write-Host "========================================"
Write-Host "Zip Path: $ZipPath"
Write-Host "Unpack Folder: $UnpackFolder"

Write-Host "`nWARNING: This will import the solution into the current environment."

# Validate folder exists
if (-not (Test-Path $UnpackFolder)) {
    Write-Error "Unpack folder '$UnpackFolder' does not exist."
    exit 1
}

Write-Host "`nAuthenticating to Power Platform..."
pac auth create

# Pack
Write-Host "`nPacking solution..."
pac solution pack `
    --folder $UnpackFolder `
    --zipfile $ZipPath `
    --packagetype Unmanaged

if ($LASTEXITCODE -ne 0) {
    Write-Error "Solution pack failed."
    exit 1
}

# Import
Write-Host "`nImporting solution..."
pac solution import --path $ZipPath --publish-changes

if ($LASTEXITCODE -ne 0) {
    Write-Error "Solution import failed."
    exit 1
}

Write-Host "`nImport completed successfully."