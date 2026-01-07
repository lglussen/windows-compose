@echo off

REM Download LightBurn Application ############################################
SET URL="https://release.lightburnsoftware.com/LightBurn/Release/LightBurn-v2.0.05/LightBurn-v2.0.05.exe"
SET Destination="%UserProfile%\Downloads\lightburn.exe"

IF NOT EXIST "%Destination%" (
  PowerShell -Command "Invoke-WebRequest" -Uri %URL% -OutFile "%Destination%"
)


REM Enable File Extensions ####################################################
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f

REM Remove OneDrive ###########################################################
call %~dp0RemoveOneDrive.bat
