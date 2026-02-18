@echo off
setlocal

REM Runs the Powershell dev bootstrap (hosts + TLS + terraform apply)
REM Note : Editing hosts requires Administrator.
echo === Production-Grade Dev Environment ===
echo If this fails on hosts file: re-run this CMD as Administrator.

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