
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
    Write-Host "Downloading and installing $Name"
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
            return "https://release.lightburnsoftware.com/$link"
        }
    }
}

Install-App -Name FireFox -Uri "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US"
Install-App -Name LightBurn -Uri "$( LightBurn-Download-Uri )"
Install-App -Name VSCode -Uri "https://update.code.visualstudio.com/latest/win32-x64-user/stable"

