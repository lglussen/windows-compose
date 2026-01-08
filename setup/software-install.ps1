$LIGHTBURN_VERSION="v2.0.05"

function Install-App {
    param(
        [string]$Name,
        [string]$Uri
    )
    $Installer="$env:USERPROFILE\Downloads\$Name.exe"
    Write-Host "Downloading and installing $Name"
    Invoke-WebRequest -Uri $Uri -OutFile $Installer
    return Start-Process -FilePath $Installer -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART", "/SP-" -NoNewWindow -PassThru
}

function LightBurn-Download-URI {
    foreach ($link in (Invoke-WebRequest -Uri https://release.lightburnsoftware.com/LightBurn/Release/latest/).links.href) {
        if ($link -match "\.exe$"){
            return "https://release.lightburnsoftware.com/$link"
        }
    }
}


$ff = Install-App -Name FireFox -Uri "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US"
$lb = Install-App -Name LightBurn -Uri "$( LightBurn-Download-Uri )"
$vsc = Install-App -Name VSCode -Uri "https://update.code.visualstudio.com/latest/win32-x64-user/stable"

$ff.WaitForExit()
$lb.WaitForExit()
$vsc.WaitForExit()
