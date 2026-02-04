$zip  = Join-Path $env:TEMP 'AEG.zip'
$dest = 'C:\Program Files\WindowsPowerShell\Modules\AEGFunctions'
$repoRootName = 'AEG-main'

if (-not (Test-Path $dest)) {
    New-Item -Path $dest -ItemType Directory -Force | Out-Null
}

Invoke-WebRequest `
    -Uri 'https://github.com/jonathan-spring/AEG/archive/refs/heads/main.zip' `
    -OutFile $zip `
    -UseBasicParsing `
    -ErrorAction Stop


$tempExtract = Join-Path $env:TEMP "AEGExtract"

if (Test-Path $tempExtract) {
    Remove-Item $tempExtract -Recurse -Force
}

Expand-Archive -Path $zip -DestinationPath $tempExtract -Force

$repoPath = Join-Path $tempExtract $repoRootName

if (-not (Test-Path $repoPath)) {
    throw "Repository root folder not found."
}


Get-ChildItem $repoPath -Force | ForEach-Object {
    Move-Item $_.FullName -Destination $dest -Force
}

# Cleanup
Remove-Item $tempExtract -Recurse -Force
Remove-Item $zip -Force

Write-Host "AEGFunctions module updated successfully."