$zip = Join-Path $env:TEMP 'AEG.zip'
$dest = Join-Path $env:TEMP 'AEG'

Invoke-WebRequest `
    -Uri 'https://github.com/jonathan-spring/AEG/archive/refs/heads/main.zip' `
    -OutFile $zip `
    -UseBasicParsing `
    -ErrorAction Stop

Expand-Archive -Path $zip -DestinationPath $dest -Force