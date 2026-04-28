param(
    [string]$SolutionName = "AIOnboardingSNReferenceSolution",
    [string]$ZipPath = ".\solution.zip",
    [string]$UnpackFolder = ".\solution"
)

Write-Host "========================================"
Write-Host "Power Platform Solution Export Script"
Write-Host "========================================"
Write-Host "Solution Name: $SolutionName"
Write-Host "Zip Path: $ZipPath"
Write-Host "Unpack Folder: $UnpackFolder"

Write-Host "`nAuthenticating to Power Platform..."
pac auth create

# Validate solution exists
Write-Host "`nValidating solution existence..."
$solutions = pac solution list | Out-String

if ($solutions -notmatch $SolutionName) {
    Write-Error "Solution '$SolutionName' not found in current environment."
    Write-Host "`nAvailable solutions:"
    pac solution list
    exit 1
}

Write-Host "Solution found."

# Remove existing zip file if exists
Write-Host "`nChecking existing solution zip..."
if (Test-Path $ZipPath) {
    Write-Host "Existing solution.zip found. Removing..."
    Remove-Item $ZipPath -Force
}

# Export
Write-Host "`nExporting solution..."
pac solution export --name $SolutionName --path $ZipPath --managed false

if ($LASTEXITCODE -ne 0) {
    Write-Error "Solution export failed."
    exit 1
}

# Cleanup
Write-Host "`nCleaning existing unpack folder..."
if (Test-Path $UnpackFolder) {
    Remove-Item $UnpackFolder -Recurse -Force
}

# Unpack
Write-Host "`nUnpacking solution..."
pac solution unpack `
    --zipfile $ZipPath `
    --folder $UnpackFolder `
    --packagetype Unmanaged `
    --clobber

if ($LASTEXITCODE -ne 0) {
    Write-Error "Solution unpack failed."
    exit 1
}

Write-Host "`nExport and unpack completed successfully."