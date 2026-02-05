# Needs work


# function Add-FirefoxPolicy {
#     $Firefox = $Software.Firefox
#     $FirefoxPath = (Get-FirefoxInfo).Path
#     $distributionPath = Join-Path $FirefoxPath 'distribution'

#     if (-not (Test-Path $distributionPath)) {
#         Write-Host "Creating distribution directory..."
#         New-Item -Path $distributionPath -ItemType Directory
#     }

#     $policiesPath = Join-Path

# }


function New-AcuityLogicIcon{
    
}

function Install-Officemate {
     param (
        $version 
    )
    $Officemate = $Software.OfficeMate
    # Validate version
    if ([string]::IsNullOrWhiteSpace($version)) {
        throw "No version specified. Please provide a valid version number (e.g., Install-OMate -version '15.3.0.4578')."
    }

    $baseUrl = $Officemate.BaseUrl

    $fileName = $Officemate.exeName
    $downloadUrl = "$baseUrl/OmWorkstationInstaller$version/$fileName"

    # Install-PackageFromURL
    
    

    # Create output directory if it doesn't exist
    if (-not (Test-Path $outputFolder)) {
        New-Item -ItemType Directory -Path $outputFolder | Out-Null
    }

    
    # Creates the directory for the .ini file
    $targetPath = "C:\ProgramData\Eyefinity\OfficeMate\Settings"

    # Check if the path exists
    if (Test-Path $targetPath) {
        Write-Host "Path already exists: $targetPath"
    } else {
        try {
            # Create the full directory structure if it doesn't exist
            New-Item -Path $targetPath -ItemType Directory -Force | Out-Null
            Write-Host "Created path: $targetPath"
        } catch {
            Write-Host "Failed to create path: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    if (Test-Path $outputFile) {
    Write-Host "Starting installation..."
    Start-Process -FilePath $outputFile -Wait
    Write-Host "Installation completed (or installer closed)."
    }

}


function Install-PackageFromUrl {

}


function Install-CrystalPM {

}


function Install-DynamsoftDriver {

}


function Install-CheckScannerDriver {

}


function Install-MicrosoftOffice {
    
}


function Install-MSOfficeODT {
    [CmdletBinding()]
    param(
        # Either pass the already-imported config object or a path to the psd1
        [Parameter(ParameterSetName='ByPath', Mandatory)]
        [string]$ConfigPsd1Path,

        [Parameter(ParameterSetName='ByObject', Mandatory)]
        [hashtable]$Config,

        # If set, runs /download first (recommended if you want to avoid re-downloading on retries)
        [switch]$DownloadFirst,

        # Where to stage everything (default: %TEMP%\OfficeODT)
        [string]$StageRoot = (Join-Path $env:TEMP 'OfficeODT'),

        # Keep the staging folder for troubleshooting
        [switch]$KeepStage
    )

    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'

    # Load config
    if ($PSCmdlet.ParameterSetName -eq 'ByPath') {
        if (-not (Test-Path $ConfigPsd1Path)) { throw "Config psd1 not found: $ConfigPsd1Path" }
        $Config = Import-PowerShellDataFile -Path $ConfigPsd1Path
    }

    if (-not $Config.MSOffice) { throw "Config missing key: MSOffice" }
    if (-not $Config.MSOffice.DeploymentToolUrl) { throw "Config missing: MSOffice.DeploymentToolUrl" }
    if (-not $Config.MSOffice.ConfigXml) { throw "Config missing: MSOffice.ConfigXml (the XML here-string)" }

    # Prep folders
    New-Item -Path $StageRoot -ItemType Directory -Force | Out-Null

    $odtExe     = Join-Path $StageRoot 'officedeploymenttool.exe'
    $odtExtract = Join-Path $StageRoot 'odt'
    $setupExe   = Join-Path $odtExtract 'setup.exe'
    $xmlPath    = Join-Path $StageRoot 'config.xml'
    $logPath    = Join-Path $StageRoot 'Install-OfficeODT.log'

    # Helper logger
    function Write-Log([string]$msg) {
        $line = "{0} {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $msg
        $line | Tee-Object -FilePath $logPath -Append
    }

    try {
        Write-Log "StageRoot: $StageRoot"

        # Download ODT
        Write-Log "Downloading ODT: $($Config.MSOffice.DeploymentToolUrl)"
        Invoke-WebRequest -Uri $Config.MSOffice.DeploymentToolUrl -OutFile $odtExe -UseBasicParsing

        if (-not (Test-Path $odtExe)) { throw "ODT download failed: $odtExe" }

        # Extract ODT
        New-Item -Path $odtExtract -ItemType Directory -Force | Out-Null
        Write-Log "Extracting ODT to: $odtExtract"
        $p = Start-Process -FilePath $odtExe -ArgumentList "/quiet /extract:`"$odtExtract`"" -Wait -PassThru

        Write-Log "ODT extract exit code: $($p.ExitCode)"
        if ($p.ExitCode -ne 0) { throw "ODT extract failed with exit code $($p.ExitCode)" }
        if (-not (Test-Path $setupExe)) { throw "setup.exe not found after extract: $setupExe" }

        # Write XML from psd1 -> config.xml
        Write-Log "Writing config XML to: $xmlPath"
        $Config.MSOffice.ConfigXml | Out-File -FilePath $xmlPath -Encoding UTF8 -Force

        # Optional: download payload first
        if ($DownloadFirst) {
            Write-Log "Running: setup.exe /download config.xml"
            $p = Start-Process -FilePath $setupExe -ArgumentList "/download `"$xmlPath`"" -Wait -PassThru
            Write-Log "/download exit code: $($p.ExitCode)"
            if ($p.ExitCode -ne 0) { throw "Office /download failed with exit code $($p.ExitCode)" }
        }

        # Configure/install
        Write-Log "Running: setup.exe /configure config.xml"
        $p = Start-Process -FilePath $setupExe -ArgumentList "/configure `"$xmlPath`"" -Wait -PassThru
        Write-Log "/configure exit code: $($p.ExitCode)"
        if ($p.ExitCode -ne 0) { throw "Office /configure failed with exit code $($p.ExitCode)" }

        # Quick signal check (non-fatal)
        $ctr = Get-Process -Name OfficeClickToRun -ErrorAction SilentlyContinue
        Write-Log ("OfficeClickToRun running: {0}" -f ([bool]$ctr))

        # Return useful info
        [pscustomobject]@{
            Success     = $true
            StageRoot   = $StageRoot
            SetupExe    = $setupExe
            ConfigXml   = $xmlPath
            Log         = $logPath
            ExitCode    = 0
        }
    }
    catch {
        Write-Log "ERROR: $($_.Exception.Message)"
        [pscustomobject]@{
            Success     = $false
            StageRoot   = $StageRoot
            SetupExe    = $setupExe
            ConfigXml   = $xmlPath
            Log         = $logPath
            ExitCode    = 1
            Error       = $_.Exception.Message
        }
    }
    finally {
        if (-not $KeepStage) {
            # Keep a short delay so file handles close cleanly
            Start-Sleep -Seconds 1
            # Comment this out if you always want to keep staging
            # Remove-Item -Path $StageRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}


function Install-AmbirScannerDrivers {
    $Ambir830ix = $Software.Ambir830ix
    $downloadPath = Join-Path $env:TEMP $Ambir830ix.exeName
    $downloadURL = $Ambir830ix.Url

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $downloadURL -OutFile $downloadPath

    #extracts the installshield exe from the ambir installer
    $extractedPath = Join-Path $env:TEMP "AmbirDriver"
    New-Item -ItemType Directory -Path $extractedPath -Force | Out-Null

    $sevenZip = $Software.sevenzip.Path
    Start-Process -FilePath $sevenZip `
        -ArgumentList @(
            "x",                
            "`"$downloadPath`"",
            "-o`"$extractedPath`"",
            "-y"                
        ) `
        -Wait -NoNewWindow

    $installerPath = Join-Path $extractedPath "setup.exe"


    $issInstallerPath = "$env:PUBLIC\Ambir830ix_install.iss"
   
    $ilog = "$env:PUBLIC\Ambir830ix_install_record.log"
    $issInstallerNormalized = ($issInstaller -replace "`r?`n", "`r`n")

    [System.IO.File]::WriteAllText(
        $issInstallerPath,
        $issInstallerNormalized,
        [System.Text.Encoding]::Default
    )

    $arguments = '/s /f1"{0}" /f2"{1}"' -f $issInstallerPath, $ilog
    Start-Process -FilePath $installerPath -ArgumentList $arguments
}