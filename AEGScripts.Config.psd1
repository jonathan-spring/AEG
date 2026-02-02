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

    Firefox = @{
      Url = 'https://www.firefox.com/en-US/download/all/desktop-esr/win64-msi/'
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
        exeName = 'TMS1000DRV108.exe'
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
    
    Ambir830ix = @{
      Url = 'https://ambirfileshare.s3.us-west-2.amazonaws.com/DS830ix_V6001_B1001.exe'
      exe = 'DS830ix_V6001_B1001.exe'
      issInstaller = 'Ambir830ix_install.iss'
      issUninstaller = 'Ambir830ix_uninstall.iss'
    }

    sevenzip = @{
      Url = 'https://www.7-zip.org/a/7z2501-x64.msi'
      msiName = '7z2501-x64.msi'
    }
  }


################
#####Icons######
################
  Icons = @{
    AcuityLogic = @{
      Url = 'https://eyecare.aegvision.com'
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









