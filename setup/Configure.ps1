Write-Host "Don't Hide File Extensions"
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -PropertyType DWORD -Force

Write-Host "Align Taskbar Left"
Set-ItemProperty -Path "HKCU:\software\microsoft\windows\currentversion\explorer\advanced" -Name "TaskbarAl" -Type "DWord" -Value 0

Write-Host "Remove Search from Taskbar"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type "DWord" -Value 0


Write-Host "Set Wallpaper"
Invoke-WebRequest -Uri "https://www.publicdomainpictures.net/pictures/230000/velka/night-landscape-15010066769pV.jpg" -OutFile "C:\wallpaper.jpg"
Set-ItemProperty -Path "HKCU:Control Panel\Desktop" -name "WallPaper" -value "C:\wallpaper.jpg"
Start-Sleep -s 10

function Unpin-App([string]$appname) {
    Write-Host "Unpin $appname from TaskBar"
    ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object {$_.Name -eq $appname}).Verbs() | Where-Object {$_.Name.replace('&','') -match 'Unpin from taskbar'} | ForEach-Object {$_.DoIt()}
}

Unpin-App("Microsoft Edge")
Unpin-App("Microsoft Store")

Write-Host "Remove Microsoft Edge Shortcut from Desktop"
rm  "C:\Users\Public\Desktop\Microsoft Edge.lnk"
