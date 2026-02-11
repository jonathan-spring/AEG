function Test-VJRedistInstalled {
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($path in $paths) {
        $apps = Get-ItemProperty $path -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like "*Visual J# 2.0*" }

        if ($apps) {
            return $true
        }
    }

    return $false
}


function Install-7zip {
    
}


function Install-VJRedist {
    [CmdletBinding()]
    param()

    $downloadPath = Join-Path $env:TEMP 'vjredist.exe'
    $ProgressPreference = 'SilentlyContinue'

    try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

    Invoke-WebRequest -Uri 'https://download.microsoft.com/download/9/a/0/9a01eb1e-fe80-41af-a3f8-ea41220918f7/vjredist.exe' -OutFile $downloadPath -ErrorAction Stop

    if (-not (Test-Path $downloadPath)) {
        throw "VJRedist download failed: $downloadPath not found."
    }



    $p = Start-Process -FilePath $downloadPath -ArgumentList '/Q' -Wait -PassThru
    if ($p.ExitCode -ne 0) {
        throw "VJRedist installer failed with exit code $($p.ExitCode)."
    }
}


function Invoke-CrystalPM {
    $downloadPath = Join-Path $env:TEMP 'CrystalPM.zip'
    $expandedPath = Join-Path $env:TEMP 'CrystalPM'
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri 'http://www.crystalpm.com/clientvista.zip' -OutFile $downloadPath
    Expand-Archive -Path $downloadPath -DestinationPath $expandedPath
}



function Install-CrystalPM {
    [CmdletBinding()]
    param(
        [string]$serverName
    )

    if (-not (Test-VJRedistInstalled)) {
        Write-Host "Installing Visual J# 2.0 Redistributable..."
        Install-VJRedist
    }

    $iniPath      = 'C:\Program Files (x86)\CrystalPM\insight.ini'
    $expandedPath = Join-Path $env:TEMP 'CrystalPM'
    $clientPath   = Join-Path $expandedPath 'Client'
    $msiPath      = Join-Path $clientPath 'Crystal PM Client.msi'

    if (-not (Test-Path $msiPath)) {
        Invoke-CrystalPM
    }

    if (-not (Test-Path $msiPath)) {
        throw "CrystalPM MSI not found at: $msiPath"
    }

    $logPath = Join-Path $env:TEMP 'CrystalPM_install.log'
    $arguments = @(
        '/i', "`"$msiPath`"",
        '/passive',
        '/norestart',
        '/l*v', "`"$logPath`""
    )

    $p = Start-Process -FilePath 'msiexec.exe' -ArgumentList $arguments -Wait -PassThru
    if ($p.ExitCode -ne 0) {
        throw "CrystalPM MSI install failed with exit code $($p.ExitCode). Log: $logPath"
    }

    if ($serverName) {
        if (-not (Test-Path $iniPath)) {
            throw "Expected INI not found at: $iniPath"
        }

        $content = Get-Content -Path $iniPath -ErrorAction Stop

        $updated = $false
        for ($i = 0; $i -lt $content.Length; $i++) {
            if ($content[$i] -match '^\s*DataSource=') {
                $content[$i] = "DataSource=$serverName"
                $updated = $true
                break
            }
        }

        if (-not $updated) {
            $content += "DataSource=$serverName"
        }

        Set-Content -Path $iniPath -Value $content -Encoding UTF8
    }

    $exePath = Join-Path 'C:\Program Files (x86)\CrystalPM' 'CrystalPM.exe'
    if (-not (Test-Path $exePath)) {
        throw "CrystalPM.exe not found at: $exePath"
    }

    $shortcutPath = Join-Path $env:PUBLIC 'Desktop\CrystalPM.lnk'
    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $exePath
    $shortcut.WorkingDirectory = Split-Path $exePath
    $shortcut.Save()

}