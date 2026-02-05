@{
 
###################  
#####Software#####  
##################
  Software = @{

    Weave = @{
      Url = 'https://releases.getweave.com/download/flavor/stable/latest/windows_64'
      exeName = 'Weave.exe'
    }

    Roboform = @{
      Url = 'https://www.roboform.com/dist/RoboForm-v9-Setup.exe'
      exeName = 'RoboForm-v9-Setup.exe'
    }

    ReVue = @{
      LicensePath = 'C:\OptoVue\LicenseKeys.lic'
    }

    OpticonUsbDriver = @{
      Url      = 'https://opticon.shop/index.php?dispatch=attachments.getfile&attachment_id=71'
      ZipFolder  = 'ABB-Opticon-USB-Drivers.zip'
      ExtractedFolder = 'ABB-Opticon-USB-Drivers'
      Dpinst64 = 'dpinst_x64.exe'
    }

    OfficeMate = @{
      BaseUrl = 'https://officemate-prod.s3.us-west-2.amazonaws.com/AutoUpdate/omsuite/release/downloads/WorkstationInstallers'
      exeName = 'OfficeMate_Suite.exe'
      iniPath = 'C:\ProgramData\Eyefinity\OfficeMate\Settings'
      iniName = 'Omate32.ini'
    }

    MSOffice = @{
      DeploymentToolUrl = 'https://download.microsoft.com/download/6c1eeb25-cf8b-41d9-8d0d-cc1dbc032140/officedeploymenttool_19628-20046.exe'
      ConfigXml = @"
<Configuration>
  <Add OfficeClientEdition="64" Channel="MonthlyEnterprise">

    <Product ID="O365ProPlusRetail">
      <Language ID="en-us" />
    </Product>

  </Add>

  <Updates Enabled="TRUE" />

  <Display Level="None" AcceptEULA="TRUE" />

</Configuration>
"@
  }
    
    Forum = @{
      xmPath = 'C:\Program Files\CZM\FORUM Viewer\settings'
      settings = 'internal.settings.xml'
    }

    Firefox = @{
      Url = 'https://download.mozilla.org/?product=firefox-esr-msi-latest-ssl&os=win64&lang=en-US'
      path32 = 'C:\Program Files (x86)\Mozilla Firefox'
      path64 = 'C:\Program Files\Mozilla Firefox'
      policy = 'policies.json'
      msiName = 'FirefoxInstaller.msi'
      exeName = 'firefox.exe'
      Args = '/qn'
    }

    Epson = @{
      TMS1000 = @{
        Url = 'https://ftp.epson.com/drivers/pos/TMS1000DRV108.exe'
        WrapperName = 'TMS1000DRV108.exe'
        iss = @"
[{8421B211-0841-44DD-8B61-CC3A0C2D46D0}-DlgOrder]
Dlg0={8421B211-0841-44DD-8B61-CC3A0C2D46D0}-SdWelcome-0
Count=6
Dlg1={8421B211-0841-44DD-8B61-CC3A0C2D46D0}-SdLicense2Rtf-0
Dlg2={8421B211-0841-44DD-8B61-CC3A0C2D46D0}-SdAskDestPath-0
Dlg3={8421B211-0841-44DD-8B61-CC3A0C2D46D0}-SdStartCopy-0
Dlg4={8421B211-0841-44DD-8B61-CC3A0C2D46D0}-InstallCompornents-0
Dlg5={8421B211-0841-44DD-8B61-CC3A0C2D46D0}-SdFinish-0
[{8421B211-0841-44DD-8B61-CC3A0C2D46D0}-SdWelcome-0]
Result=1
[{8421B211-0841-44DD-8B61-CC3A0C2D46D0}-SdLicense2Rtf-0]
Result=1
[{8421B211-0841-44DD-8B61-CC3A0C2D46D0}-SdAskDestPath-0]
szDir=C:\Program Files (x86)\EPSON\BankDriver\
Result=1
[{8421B211-0841-44DD-8B61-CC3A0C2D46D0}-SdStartCopy-0]
Result=1
[{8421B211-0841-44DD-8B61-CC3A0C2D46D0}-InstallCompornents-0]
INSTALLDIR=C:\Program Files (x86)\EPSON\BankDriver\
Runtime=1
Runtime\TMUSB=1
Runtime\DotNetRT=1
Runtime\Trace=0
[{8421B211-0841-44DD-8B61-CC3A0C2D46D0}-SdFinish-0]
Result=1
bOpt1=0
bOpt2=0
"@
      }	
      TMS1000ii = @{
        Url = 'https://ftp.epson.com/drivers/pos/TMS9000S2000S1000IIDRV410.exe'
        exeName = 'TMS9000S2000S1000IIDRV410.exe'
      }
    }

    Egnyte = @{
      Url = 'https://egnyte-cdn.egnyte.com/egnytedrive/win/en-us/latest/EgnyteConnectWin.msi?_ga=2.153040060.481670427.1759958537-49825622.1756227746'
      msiName = 'EgnyteConnectWin.msi'
      Log = 'EgnyteInstall.log'
    }
    
    dotNETDesktopRuntime = @{
      Url = 'https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/8.0.23/windowsdesktop-runtime-8.0.23-win-x64.exe'
    }

    DellCommand = @{
      Url = 'https://dl.dell.com/FOLDER13922605M/1/Dell-Command-Update-Application_5CR1Y_WIN64_5.6.0_A00.EXE'
      Url2 = 'https://dl.dell.com/FOLDER13309588M/3/Dell-Command-Update-Windows-Universal-Application_C8JXV_WIN64_5.5.0_A00_02.EXE'
      exeName = 'Dell-Command-Update-Application_5CR1Y_WIN64_5.6.0_A00.exe'
    }

    Crystal = @{
      Url = ''
      iniPath = ''
    }

    Cirrus = @{
      Mode = 'C:\Program Files\CZM\Cirrus HD-OCT\Bin\SdoctApp.exe'
    }

    Chrome = @{
      Url = 'https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi'
      Path32 = 'C:\Program Files (x86)\Google\Chrome\Application'
      Path64 = 'C:\Program Files\Google\Chrome\Application'
      msiName = 'googlechromestandaloneenterprise64.msi'
      exeName = 'chrome.exe'
      popupsregistry = 'HKLM:\Software\Policies\Google\Chrome\PopupsAllowedForUrls'
      Args = @()
    }
    
    # CppRedist = @{
    #   Args = @(
    #     '/quiet'
    #     '/norestart'
    #   )
    #   x86_2008 = @{
    #     Url = 'https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe'
    #     WrapperName = 'vcredist2008_x86.exe'
    #   }
    #   x64latest = @{
    #     Url = 'https://aka.ms/vc14/vc_redist.x64.exe'
    #     WrapperName = 'vcredistlatest_x64.exe'
    #   }
    #   x64_2010SP1 = @{
    #     Url = 'https://download.microsoft.com/download/1/6/5/165255e7-1014-4d0a-b094-b6a430a6bffc/vcredist_x64.exe'
    #     WrapperName = 'vcredist2010_x64.exe'
    #   }
    # } 

    Ambir830ix = @{
      Url = 'https://ambirfileshare.s3.us-west-2.amazonaws.com/DS830ix_V6001_B1001.exe'
      exeName = 'DS830ix_V6001_B1001.exe'
      issInstaller = 'Ambir830ix_install.iss'
      issUninstaller = 'Ambir830ix_uninstall.iss'
      iss=@"
[InstallShield Silent]
Version=v7.00
File=Response File
[File Transfer]
OverwrittenReadOnly=NoToAll
[{6AC39839-3E2D-4A8A-ABED-A2AB4DCF2833}-DlgOrder]
Dlg0={6AC39839-3E2D-4A8A-ABED-A2AB4DCF2833}-SdWelcome-0
Count=4
Dlg1={6AC39839-3E2D-4A8A-ABED-A2AB4DCF2833}-SdAskDestPath-0
Dlg2={6AC39839-3E2D-4A8A-ABED-A2AB4DCF2833}-AskOptions-0
Dlg3={6AC39839-3E2D-4A8A-ABED-A2AB4DCF2833}-SdFinish-0
[{6AC39839-3E2D-4A8A-ABED-A2AB4DCF2833}-SdWelcome-0]
Result=1
[{6AC39839-3E2D-4A8A-ABED-A2AB4DCF2833}-SdAskDestPath-0]
szDir=C:\Program Files (x86)\Ambir\Ambir ImageScan Pro 830ix
Result=1
[{6AC39839-3E2D-4A8A-ABED-A2AB4DCF2833}-AskOptions-0]
Result=1
Sel-0=1
Sel-1=1
[Application]
Name=Ambir ImageScan Pro 830ix
Version= 
Company=Ambir Technology
Lang=0009
[{6AC39839-3E2D-4A8A-ABED-A2AB4DCF2833}-SdFinish-0]
Result=1
bOpt1=0
bOpt2=0
"@

    }

    Acrobat = @{
      Url = 'https://trials.adobe.com/AdobeProducts/APRO/Acrobat_HelpX/win32/Acrobat_DC_Web_x64_WWMUI.zip'
    }

    sevenzip = @{
      Path = 'C:\Program Files\7-Zip\7z.exe'
      Url = 'https://www.7-zip.org/a/7z2501-x64.msi'
      msiName = '7z2501-x64.msi'
      Args = @(
            '/q'
            'INSTALLDIR="C:\Program Files\7-Zip"'
        )
    }
  }


################
#####Icons######
################
  Icons = @{
    AcuityLogic = @{
      Url = 'https://eyecare.aegvision.com'
      lnk = 'Acuity Logic.lnk'
    }

    ARC = @{
      Url = 'https://arc.aegvision.com'
      lnk = 'ARC.lnk'
    }

    AEGU = @{
      Url = 'https://aeg.acuityeyecaregroup.com'
      lnk = 'AEG Universal.lnk'
    }
    
    EEHR = @{
      Url = 'https://acuityeyecaregroup.eyefinityehr.com'
      lnk = 'EEHR.lnk'
    }

    Helpdesk = @{
      Url = 'https://helpdesk.aegvision.com'
      lnk = 'Helpdesk.lnk'
    }
    OptosLocal = @{
      Url = 'http://optosadvance'
      lnk = 'Optos Advance.lnk'
    }

    OptosCloud = @{
      Url = 'https://cloud.optos.com'
      lnk = 'OptosAdvance.lnk'
    }
  }


###############  
#####Paths#####  
###############
  Paths = @{
    WifiProfile = 'C:\Wifi'
    Registry = @{
      FirefoxVersion = 'HKLM:\SOFTWARE\mozilla.org\Mozilla' 
      #Get-ItemProperty $FirefoxVersion -ErrorAction SilentlyContinue).'CurrentVersion'

    }
  }
}









