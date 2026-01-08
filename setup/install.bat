@echo off

echo Download and Install Software ===========================================
PowerShell.exe -ExecutionPolicy Bypass -File %~dp0software-install.ps1

echo Configure Prefered General Windows Settings ==============================
PowerShell.exe -ExecutionPolicy Bypass -File %~dp0Configure.ps1
rundll32.exe user32.dll, UpdatePerUserSystemParameters

echo Remove OneDrive ==========================================================
call %~dp0RemoveOneDrive.bat

echo Reboot ===================================================================
shutdown -r
