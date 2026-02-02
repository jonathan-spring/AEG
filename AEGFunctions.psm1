$ConfigPath = Join-Path $PSScriptRoot 'AEGScripts.Config.psd1'
$config = Import-PowerShellDataFile -Path $ConfigPath

$Icons = $config.Icons
$Software = $config.Software
$Paths = $config.Paths


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


function Install-Egnyte {
    $Egnyte = $Software.Egnyte
    $Result = Show-YesNoBox `
    -MessageBody "Do you want to Install Egnyte?" `
    -MessageTitle "Egnyte Installater"

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
 

function Install-7zip {
    $7zip = $Software.sevenzip
    $7zipPath = Join-Path $env:TEMP $7zip.msiName

    Install-MsiFromUrl `
        -Url $7zip.Url `
        -Destination $7zipPath `
        -Arguments $7zip.Args
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


function Show-YesNoBox {
    param (
        [string] $MessageBody,
        [string] $MessageTitle
    )

    Add-Type -AssemblyName System.Windows.Forms

    # Show the message box and store the result
    $Answer = [System.Windows.Forms.MessageBox]::Show(
        $MessageBody,
        $MessageTitle,
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
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

