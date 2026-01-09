
function Log([string]$msg){
  Write-Host "$msg"
  Add-Content -Path "$env:USERPROFILE/Desktop/install-log.txt" -Value $msg
}

function Install-App {
    param(
        [string]$Name,
        [string]$Uri
    )
    $Installer="$env:USERPROFILE\Downloads\$Name.exe"
    Log "Downloading and installing $Name"
    try {
	Log "  Downloading $Uri ..."
        Invoke-WebRequest -Uri $Uri -OutFile "$Installer"
	Log "  Installing $Name ..."
        $process = Start-Process -FilePath "$Installer" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART", "/SP-" -NoNewWindow -PassThru
	$minute = 60
        if (-not $process.WaitForExit($minute * 10)) {
            Log "  Process taking too long to complete. Moving on without waiting ..."
            #$proc.Kill() # Terminate the process if it times out
        } else {
	    Log "  Install Complete!"
	    rm "$Installer"
	}
    } catch {
        Log "[ERROR] There was a problem with the $Name download/install process"
	    Log "Error details: $_"
    }
}

function LightBurn-Download-URI {
    foreach ($link in (Invoke-WebRequest -Uri https://release.lightburnsoftware.com/LightBurn/Release/latest/).links.href) {
        if ($link -match "\.exe$"){
            return "https://release.lightburnsoftware.com$link"
        }
    }
}

function Remove([string]$path) {
    try {
        Remove-Item -Path $path -Recurse -Force
    } catch {
        Log "[Error] Remove-Item  $path : $_"
    }
}

function Remove-OneDrive {
    $x86="$env:SystemRoot\System32\OneDriveSetup.exe"
    $x64="$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    
    try {
        Log "Closing OneDrive process."
        Stop-Process -Name OneDrive -Force > $null
        Test-Connection 127.0.0.1 -Count 5 > $null
        try {
            Log "Uninstalling OneDrive."
            if (Test-Path -Path $x64 -PathType Leaf) {
                Log "$x64 /uninstall"
                & "$x64" /uninstall
            }
            if (Test-Path -Path $x64 -PathType Leaf) {
                Log "$x86 /uninstall"
                & "$x86" /uninstall
            }
            Test-Connection 127.0.0.1 -Count 5 > $null
        } catch {
            Log "OneDriveSetup /uninstall Error Details: $_"
        }
    } catch {
        Log "Stop-Process(OneDrive) Error Details: $_"
    }
   
    Log  "Removing OneDrive leftovers."
    Remove -Path "$env:USERPROFILE\OneDrive"
    Remove -Path "C:\OneDriveTemp"
    Remove -Path "$env:LOCALAPPDATA\Microsoft\OneDrive"
    Remove -Path "$env:PROGRAMDATA\Microsoft OneDrive"
    
    Log "Removeing OneDrive from the Explorer Side Panel."
    Remove -Path "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
    Remove -Path  "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
}

function Windows-Config-General {

    Log "Don't Hide File Extensions"
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -PropertyType DWORD -Force
    
    Log "Align Taskbar Left"
    Set-ItemProperty -Path "HKCU:\software\microsoft\windows\currentversion\explorer\advanced" -Name "TaskbarAl" -Type "DWord" -Value 0
    
    Log "Remove Search from Taskbar"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type "DWord" -Value 0
    
    
    Log "Set Wallpaper"
    Invoke-WebRequest -Uri "https://www.publicdomainpictures.net/pictures/230000/velka/night-landscape-15010066769pV.jpg" -OutFile "C:\wallpaper.jpg"
    Set-ItemProperty -Path "HKCU:Control Panel\Desktop" -name "WallPaper" -value "C:\wallpaper.jpg"
    Start-Sleep -s 10

    Unpin-App("Microsoft Edge")
    Unpin-App("Microsoft Store")

    Log "Remove Widgets from TaskBar"
    Get-AppxPackage *WebExperience* | Remove-AppxPackage
        
    Log "Remove Microsoft Edge Shortcut from Desktop"
    rm  "C:\Users\Public\Desktop\Microsoft Edge.lnk"
}

function Unpin-App([string]$appname) {
    Log "Unpin $appname from TaskBar"
    ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object {$_.Name -eq $appname}).Verbs() | Where-Object {$_.Name.replace('&','') -match 'Unpin from taskbar'} | ForEach-Object {$_.DoIt()}
}

# Main ------------------------------------------------------------------------
Log "Install Software ========================================================="
Install-App -Name FireFox -Uri "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US"
Install-App -Name LightBurn -Uri "$( LightBurn-Download-Uri )"
Install-App -Name VSCode -Uri "https://update.code.visualstudio.com/latest/win32-x64-user/stable"

Log "Configure Windows ========================================================"
Windows-General-Config

Log "Remove OneDrive =========================================================="
Remove-OneDrive

Log "Reboot System ============================================================"
Restart-Computer
