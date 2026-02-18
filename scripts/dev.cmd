@echo off
setlocal

:: Verify requirements
powershell -ExecutionPolicy Bypass -File "%~dp0doctor.ps1"
if errorlevel 1 exit /b 1

:: Check for admin rights 
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' - Verb RunAs"
    exit /b
)

echo Running with Administrator privileges...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0dev.ps1"

if errorlevel 1 (
    echo.
    echo ERROR: dev bootstrap failed.
    echo Tip: Right-Click this file and choose "Run as administrator".
    exit /b 1
)

echo.
echo DONE.
echo    https://api.localhost/docs
echo    https://api.localhost/health
echo    https://traefik.localhost
exit /b 0