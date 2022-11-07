@echo off  
Echo Upgrade all Windows packages
REM Upgrade all windows packages  
winget upgrade --accept-source-agreements --accept-package-agreements --all --silent;
if %ERRORLEVEL% EQU 0 Echo Powertoys installed successfully.  
REM Upgrade WSL
wsl --user root --exec apt-get update
wsl --user root --exec apt-get upgrade --yes
if %ERRORLEVEL% EQU 0 Echo WSL packages for default distro updated successfully.   %ERRORLEVEL%