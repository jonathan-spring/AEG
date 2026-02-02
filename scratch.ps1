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