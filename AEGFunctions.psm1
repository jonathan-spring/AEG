$ConfigPath = Join-Path $PSScriptRoot 'AEGScripts.Config.psd1'
$config = Import-PowerShellDataFile -Path $ConfigPath

$Icons = $config.Icons
$Software = $config.Software
$Paths = $config.Paths

$WifiPath = Join-Path $PSScriptRoot 'Wifi'

function Get-AEGFunctions {
    [CmdletBinding()]
    param()

    $module = Get-Module $MyInvocation.MyCommand.Module
    if (-not $module) { throw "Could not resolve current module." }

    $names = @(
        $module.Invoke({
            Get-Command -CommandType Function |
                Where-Object { $_.ModuleName -eq $module.Name } |
                Select-Object -ExpandProperty Name
        })
    ) | Sort-Object -Unique

    foreach ($name in $names) {
        $help = Get-Help $name -Full -ErrorAction SilentlyContinue

        $synopsis = if ($help -and $help.Synopsis) {
            ($help.Synopsis -replace '\s+', ' ').Trim()
        } else { '' }

        $description = if ($help -and $help.Description) {
            (($help.Description | ForEach-Object { $_.Text }) -join ' ' -replace '\s+', ' ').Trim()
        } else { '' }

        $parameters = if ($help -and $help.Parameters -and $help.Parameters.Parameter) {
            @(
                foreach ($p in $help.Parameters.Parameter) {
                    $pDesc = if ($p.Description) {
                        (($p.Description | ForEach-Object { $_.Text }) -join ' ' -replace '\s+', ' ').Trim()
                    } else { '' }

                    [pscustomobject]@{
                        Name        = $p.Name
                        Required    = [bool]$p.Required
                        Type        = $p.Type.Name
                        Description = $pDesc
                    }
                }
            )
        } else { @() }

        $examples = if ($help -and $help.Examples -and $help.Examples.Example) {
            @(
                foreach ($ex in $help.Examples.Example) {
                    [pscustomobject]@{
                        Title       = $ex.Title
                        Code        = ($ex.Code -join "`n").Trim()
                        Remarks     = (($ex.Remarks | ForEach-Object { $_.Text }) -join ' ' -replace '\s+', ' ').Trim()
                    }
                }
            )
        } else { @() }

        $notes = if ($help -and $help.AlertSet -and $help.AlertSet.Alert) {
            (($help.AlertSet.Alert | ForEach-Object { $_.Text }) -join "`n").Trim()
        } else {
            # Fallback: some help renderers expose Notes differently
            try { ($help.Notes | Out-String).Trim() } catch { '' }
        }

        [pscustomobject]@{
            Name        = $name
            Synopsis    = $synopsis
            Description = $description
            Parameters  = $parameters
            Examples    = $examples
            Notes       = $notes
        }
    }
}


function New-BrowserIcon {
    param(
        [Parameter(Mandatory)][string]$Url,
        [Parameter(Mandatory)][string]$Destination,
        [switch]$Firefox,
        [switch]$Chrome
    )

    if(-not ($Firefox -or $Chrome)) {
        $Firefox = $true
    }

    if($Firefox -and $Chrome) {
        throw "Specify Firefox or Chrome"
    }

    if ($Firefox) {
        $FirefoxPath = (Get-FirefoxInfo).Path
        $iconPath = Join-Path "$env:PUBLIC\Desktop" $Destination
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($iconPath)
        $Shortcut.TargetPath = $FirefoxPath
        $Shortcut.Arguments = $Url
        $Shortcut.Save()
    }

    if ($Chrome) {
        $ChromePath = (Get-FirefoxInfo).Path
        $iconPath = Join-Path "$env:PUBLIC\Desktop" $Destination
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($iconPath)
        $Shortcut.TargetPath = $ChromePath
        $Shortcut.Arguments = $Url
        $Shortcut.Save()
    }
}


function Enable-AlePopups {
<#
.SYNOPSIS
Fixes the issue where the receipt popup is blocked in ALE in Chrome and Firefox.
#>
    Enable-ChromePopupsForSite -Url $Icons.AcuityLogic.Url
}


function Enable-ChromePopupsForSite {
    [CmdletBinding()]
    param (
        [string]$Url
    )
    $Chrome = $Software.Chrome
    $regPath = $Chrome.popupsregistry

    if(-not (Test-Path $regPath)){
        New-Item -Path $regPath -Force | Out-Null
    }

    $index = (Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue |
              Get-Member -MemberType NoteProperty |
              Measure-Object).Count + 1

    New-ItemProperty -Path $regPath -Name $index -Value $Url -PropertyType String -Force
}


function Disable-IPv6 {
<#
.SYNOPSIS
Disables IPv6 on all network interfaces.
#>

    Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6
}


function Disable-PingInbound {
<#
.SYNOPSIS
Creates a firewall rule blocking inbound ICMP traffic.
#>

     New-NetFirewallRule -DisplayName "Block ICMPv4-In" 
    -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Action Block    
}


function Enable-PingInbound {
<#
.SYNOPSIS
Creates a firewall rule allowing inbound ICMP traffic.
#>

    New-NetFirewallRule -DisplayName "Allow ICMPv4-In" 
    -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Action Allow
}


function Export-WifiProfile {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Name
    )
    $Wifidir = $Paths.WifiProfile

    if (-not (Test-Path $Wifidir)){
        New-Item $Wifidir -ItemType Directory
    }
    netsh wlan export profile name=$Name key=clear folder=$Wifidir
}


function Expand-sevenzip {
        [CmdletBinding()]
        param (
            [Parameter()]
            [string]$Archive,
            [string]$Destination
        )
    $7zipPath = "C:\Program Files\7-Zip\7z.exe"
    # -o specifies the output directory, no space between -o and the path
    & $7zipPath x $Archive "-o$Destination" -y
}


function Get-ChromeInfo {
    $Chrome = $Software.Chrome
    $paths = @(
        @{ Arch = 'x64'; Path = Join-Path $Chrome.path64 $Chrome.exeName}
        @{ Arch = 'x32'; Path = Join-Path $Chrome.path32 $Chrome.exeName}
    )

    Get-SoftwareInfo -Name Chrome -Paths $paths
}


function Get-FirefoxInfo {
    $Firefox = $Software.Firefox
    $paths = @(
        @{ Arch = 'x64'; Path = Join-Path $Firefox.path64 $Firefox.exeName}
        @{ Arch = 'x32'; Path = Join-Path $Firefox.path32 $Firefox.exeName}
    )

    Get-SoftwareInfo -Name Firefox -Paths $paths
}


function Get-SoftwareInfo {

    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [pscustomobject[]]$Paths
    )

    $detected = $Paths | Where-Object { Test-Path $_.Path } | Select-Object -First 1
    if (-not $detected) { return $null }

    $ver = $null
    try {
        $ver = (Get-Item $detected.Path).VersionInfo.ProductVersion
        if ($ver) { $ver = [version]$ver }
    } catch {}

    return [pscustomobject]@{
        Name         = $Name
        Version      = $ver
        Architecture = $detected.Arch
        Path         = $detected.Path
    }
}
 

function Import-WifiProfile {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$XMLName
    )
    $Wifidir = $Paths.WifiProfile
    $fileName = Join-Path $Wifidir $XMLName
    netsh wlan add profile filename=$fileName
}


function Install-AdobeAcrobat {
    winget install --id Adobe.Acrobat.Reader.64-bit -e --silent
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

    $issInstaller = $Ambir830ix.iss
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


function Invoke-CatoClient {
    $Cato = $Software.Cato
    $downloadPath = Join-Path $env:TEMP $Cato.exeName
    $downloadRUL = $Cato.Url

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $downloadRUL -OutFile $downloadPath
}


function Install-CatoClient {
    Show-YesNoBox -MessageBody "Install Cato VPN?" -MessageTitle "Cato Installer"
    $Cato = $Software.Cato
    $downloadPath = Join-Path $env:TEMP $Cato.exeName

    if (-not (Test-Path $downloadPath)){
        Invoke-CatoClient
    }

    Start-Process -FilePath $downloadPath -ArgumentList "/s" -Wait
}

function Invoke-CheckScannerDriver {
    $Epson = $Software.Epson
    $TMS1000 = $Epson.TMS1000
    $downloadPath = Join-Path $env:TEMP $TMS1000.WrapperName
    $downloadURL = $TMS1000.Url
 

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $downloadURL -OutFile $downloadPath

    Start-Process -FilePath $downloadPath 
}


function Invoke-CrystalPM {
    $Crystal = $Software.Crystal
    $downloadPath = Join-Path $env:TEMP 'CrystalPM.zip'
    $expandedPath = Join-Path $env:TEMP 'CrystalPM'
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $Crystal.Url -OutFile $downloadPath
    Expand-Archive -Path $downloadPath -DestinationPath $expandedPath
}


function Install-CrystalPM {
    [CmdletBinding()]
    param (
        [string]$serverName
    )

    $Crystal = $Software.Crystal
    $expandedPath = Join-Path $env:TEMP 'CrystalPM'
    $clientPath = Join-Path $expandedPath 'Client'
    $msiPath = Join-path $clientPath 'Crystal PM Client.msi'
    if (-not(Test-Path $expandedPath)) {
        Invoke-CrystalPM 
    }

    Start-Process msiexec /i $msiPath  /qb

    if ($serverName) {
        $iniPath = $Crystal.iniPath
        $content = Get-Content -Path $iniPath

        for ($i = 0; $i -lt $content.Length; $i++) {
            if ($content[$i] -match '^DataSource=') {
                $content[$i] = "DataSource=$serverName"
                break
            }
        }
    }

    $exePath = Join-Path $Crystal.x86Path $Crystal.exeName
    $shortcutPath = Join-Path "$env:PUBLIC\Desktop" $Crystal.lnk
    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $exePath
    $shortcut.Save()

    Set-Content -Path $iniPath -Value $content -Encoding UTF8

    Start-Process -FilePath $Crystal.x86Path $Crystal.exeName


}


function Install-CheckScannerDriver {
    $Epson = $Software.Epson
    $TMS1000 = $Epson.TMS1000
    $downloadPath = Join-Path $env:TEMP $TMS1000.WrapperName

    if (-not (Test-Path $downloadPath)){
        Invoke-CheckScannerDriver
    }

    
    $extractedPath = Join-Path $env:TEMP 'TMS1000DRV108_\Driver\setup.exe'
    $issInstaller = $TMS1000.iss
    $issInstallerPath = "$env:PUBLIC\TMS1000_install.iss"

    $issInstallerNormalized = ($issInstaller -replace "`r?`n", "`r`n")

    [System.IO.File]::WriteAllText(
        $issInstallerPath,
        $issInstallerNormalized,
        [System.Text.Encoding]::Default
    )
    $arguments = '/s /f1"{0}"' -f $issInstallerPath
    Start-Process -FilePath $extractedPath -ArgumentList $arguments -Wait
}


function Invoke-Chrome {
    $msiPath = Join-Path $env:TEMP $Software.Chrome.msiName
    Invoke-WebRequest -Uri $Software.Chrome.Url -OutFile $msiPath 
}


function Install-Chrome {
<#
.SYNOPSIS
Installs Chrome for Enterprise without requiring user interaction.
#>

    $msiPath = Join-Path $env:TEMP $Software.Chrome.msiName
    Install-MsiFromUrl `
    -Url $Software.Chrome.Url `
    -Destination $msiPath `
    -Arguments $Software.Chrome.Args
}


function Install-CPPRedists {
    winget install -e --id Microsoft.VCRedist.2008.x86
    winget install -e --id Microsoft.VCRedist.2010.x64
    winget install -e --id Microsoft.VCRedist.2015+.x64
}


function Install-Egnyte {
    $Egnyte = $Software.Egnyte
    $Result = Show-MessageBox `
    -MessageBody "Do you want to Install Egnyte?" `
    -MessageTitle "Egnyte Installater" `
    -YesNoBox

    # Act on the result
    if ($Result -eq [System.Windows.Forms.DialogResult]::Yes) {
        $msiPath = Join-Path $env:TEMP $Egnyte.msiName
        Install-MsiFromUrl `
        -Url $Egnyte.Url `
        -Destination $msiPath
    } else {
        Write-Host 'Skipping Egnyte installation...'
    }
}


function Install-Firefox {
<#
.SYNOPSIS
Installs Firefox ESR silently.
#>
    $Firefox = $Software.Firefox
    $msiPath = Join-Path $env:TEMP $Firefox.msiName
    Install-MsiFromUrl `
    -Url $Firefox.Url `
    -Destination $msiPath `
    -Arguments $Firefox.Args
}


function Install-MSOffice {

}


function Install-MsiFromUrl {
    param(
        [Parameter(Mandatory)][string]$Url,
        [Parameter(Mandatory)][string]$Destination,
        [string[]]$Arguments = @('/qn','/norestart')
    )

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing

    $argumentList = @(
        '/i'
        "`"$Destination`""
    )
    $argumentList += $Arguments
    #@() in the call to pass no arguments
    Start-Process msiexec.exe `
        -ArgumentList $argumentList `
        -Wait -PassThru
}


function Install-7zip {
    $7zip = $Software.sevenzip
    $7zipPath = Join-Path $env:TEMP $7zip.msiName

    Install-MsiFromUrl `
        -Url $7zip.Url `
        -Destination $7zipPath `
        -Arguments $7zip.Args
}


function Join-AEHDomain {

    Add-Type -AssemblyName System.Windows.Forms

    $Result = Show-MessageBox `
        -MessageBody "Do you want to Join the AEH.lcl domain?" `
        -MessageTitle "Domain Join" `
        -YesNoBox

    if ($Result -ne [System.Windows.Forms.DialogResult]::Yes) {
        return
    }

    # Ensure Cato installed
    if (-not (Test-Path $Software.Cato.Path32)){
        Install-CatoClient
    }

    $CatoProcess = Join-Path $Software.Cato.Path32 $Software.Cato.exeName
    Start-Process -FilePath $CatoProcess

    # ---- LOOP UNTIL CONNECTED ----
    while ($true) {

        $Result = [System.Windows.Forms.MessageBox]::Show(
            "Please connect to the Cato VPN and press 'OK' to continue.",
            "VPN Connection Required",
            [System.Windows.Forms.MessageBoxButtons]::OKCancel,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )

        if ($Result -eq [System.Windows.Forms.DialogResult]::Cancel) {
            return
        }

        # Check connection
        $CatoConnected = Get-NetIPAddress |
            Where-Object {
                $_.InterfaceAlias -eq "CatoNetworks" -and
                $_.AddressState -eq "Preferred"
            }

        if ($CatoConnected) {
            break
        }

        # Optional small pause to avoid hammering system
        Start-Sleep -Seconds 1
    }

    # If we get here, Cato is connected
    $Creds = Get-Credential -Message "Enter domain administrator credentials"
    Add-Computer -DomainName "AEH.lcl" -Credential $Creds -Force -Restart
}


function New-ALEIcon {
    New-BrowserIcon `
    -Firefox `
    -Url $Icons.AcuityLogic.Url `
    -Destination $Icons.AcuityLogic.lnk
}


function New-AEGUIcon {
    New-BrowserIcon `
    -Firefox `
    -Url $Icons.AEGU.Url `
    -Destination $Icons.AEGU.lnk
}


function New-ARCIcon {
    New-BrowserIcon `
    -Firefox `
    -Url $Icons.ARC.Url `
    -Destination $Icons.ARC.lnk
}


function New-EEHRIcon {
    New-BrowserIcon `
    -Firefox `
    -Url $Icons.EEHR.Url `
    -Destination $Icons.EEHR.lnk
}


function New-HelpdeskIcon {
    New-BrowserIcon `
    -Firefox `
    -Url $Icons.Helpdesk.Url `
    -Destination $Icons.Helpdesk.lnk
}


function New-OptosIcon {
<#
.SYNOPSIS
Adds a Firefox icon for Optos Advance to the desktop.

.EXAMPLE
Add-OptosIcon -Cloud
Creates the cloud Firefox icon.

.EXAMPLE
Add-OptosIcon -Local
Creates the local Firefox icon.
#>
    [CmdletBinding()]
    param(
        [switch]$Cloud,
        [switch]$Local
    )

    if (-not ($Cloud -xor $Local)) {
        throw [System.ArgumentException]::new(
            'The syntax for this command is: Add-OptosIcon -Cloud | -Local'
        )
    }

    if ($Cloud) {
        $url = $Icons.OptosCloud.Url
        $lnk = $Icons.OptosCloud.lnk
    }
    else {
        $url = $Icons.OptosLocal.Url
        $lnk = $Icons.OptosLocal.lnk
    }

    New-BrowserIcon `
    -Firefox `
    -Url $url `
    -Destination $lnk
}


function Remove-SCInstalls {
<#
.SYNOPSIS
Removes all except for most recently updated SC installations.
#>

    if (-not (Get-Command Get-Package -ErrorAction SilentlyContinue)) {
        Write-Warning "Get-Package is not available on this system. Possibly an older Windows install."
        return
    }

    try {
        $SC = Get-Package -Name "ScreenConnect*" -ErrorAction Stop | Sort-Object Version -Descending
    }
    catch {
        Write-Warning "Unable to retrieve ScreenConnect packages: $($_.Exception.Message)"
        return
    }
    if ($SC.Count -gt 1) {
        Write-Host "Multiple ScreenConnect versions detected. Removing old versions..."

        $SC |
            Select-Object -Skip 1 |
            ForEach-Object {
                Write-Host "Uninstalling $($_.Name) version $($_.Version) ..."
                Uninstall-Package -Name $_.Name -Force
            }
    }
    else {
        Write-Host "Only one ScreenConnect version installed. No action needed."
    }
}
 

function Set-LocalUserPasswordExpiration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Username,

        [Parameter()]
        [bool]$PasswordExpires = $true
    )

    # Ensure we are running elevated
    if (-not ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "This function must be run as Administrator."
    }

    # Verify user exists
    $user = Get-LocalUser -Name $Username -ErrorAction SilentlyContinue
    if (-not $user) {
        throw "Local user '$Username' not found."
    }

    # Apply setting
    Set-LocalUser -Name $Username -PasswordExpires $PasswordExpires

    # Return updated state
    Get-LocalUser -Name $Username |
        Select-Object Name, Enabled, PasswordExpires
}


function Set-LocalUsersNeverExpire {
    Set-LocalUserPasswordExpiration -Username 'AEG.User' -PasswordExpires $false
    Set-LocalUserPasswordExpiration -Username 'Acuity.local' -PasswordExpires $false
}


function Show-MessageBox {
<#
.SYNOPSIS
Creates a Yes/No context menu. Logic for behavior upon button press is written in the calling function.

.EXAMPLE
Show-YesNoBox -MessageBody "Would you like to install softwareX?" -MessageTitle "SoftwareXInstallation"
#>

    param (
        [string] $MessageBody,
        [string] $MessageTitle,
        [switch] $YesNoBox
    )

    Add-Type -AssemblyName System.Windows.Forms

    if ($YesNoBox){
        # Show the message box and store the result
        $Answer = [System.Windows.Forms.MessageBox]::Show(
            $MessageBody,
            $MessageTitle,
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )
    } else {
        $Answer = [System.Windows.Forms.MessageBox]::Show(
            $MessageBody,
            $MessageTitle,
            [System.Windows.Forms.MessageBoxButtons]::OKCancel,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )
    }
    return $Answer
}


function Sync-Time {
    w32tm /config /syncfromflags:manual "/manualpeerlist:0.pool.ntp.org,0x1 1.pool.ntp.org,0x1 2.pool.ntp.org,0x1 3.pool.ntp.org,0x1" /reliable:yes

    w32tm /config /update
    net stop w32time 
    net start w32time
    w32tm /resync /force
    w32tm /query /source
}

