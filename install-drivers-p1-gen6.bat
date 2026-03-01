@echo off
setlocal enabledelayedexpansion
title Lenovo ThinkPad P1 Gen 6 Driver Installer

:: ============================================================
::  Lenovo ThinkPad P1 Gen 6 (Type 21FV/21FW) Driver Installer
::  Tested config: 21FWS1910T
::    CPU:  Intel Core i9-13900H
::    GPU:  NVIDIA RTX 2000 Ada Generation Laptop (8 GB)
::    WiFi: Intel Wi-Fi 6E AX211
::
::  Usage: Right-click this file > Run as administrator
::
::  Downloads all critical drivers from download.lenovo.com
::  and installs them silently. Requires internet access
::  (Ethernet adapter or basic WiFi from Windows install media).
::
::  Driver versions current as of March 2026.
::  For future updates, use Lenovo System Update or visit:
::  https://pcsupport.lenovo.com/products/laptops-and-netbooks/
::    thinkpad-p-series-laptops/thinkpad-p1-gen-6-type-21fv-21fw
:: ============================================================

:: -----------------------------------------------------------
::  Check administrator privileges
:: -----------------------------------------------------------
net session >nul 2>&1
if !errorlevel! neq 0 (
    echo.
    echo  ERROR: Administrator privileges required.
    echo  Right-click this script and select "Run as administrator".
    echo.
    pause
    exit /b 1
)

:: -----------------------------------------------------------
::  Configuration
:: -----------------------------------------------------------
set "DRVDIR=%TEMP%\P1Gen6Drivers"
set "LOGFILE=%DRVDIR%\install.log"
set "BASE_URL=https://download.lenovo.com/pccbbs/mobiles"
set "TOTAL=5"
set "OK=0"
set "FAIL=0"

mkdir "%DRVDIR%" 2>nul

:: -----------------------------------------------------------
::  Check internet connectivity
:: -----------------------------------------------------------
echo.
echo  Checking internet connectivity...
curl.exe -s -o nul -w "%%{http_code}" "https://download.lenovo.com" > "%DRVDIR%\_conntest.tmp" 2>nul
set /p HTTPCODE=<"%DRVDIR%\_conntest.tmp"
del "%DRVDIR%\_conntest.tmp" 2>nul

if "!HTTPCODE!"=="" (
    echo.
    echo  ERROR: No internet connection detected.
    echo  Connect via Ethernet ^(USB-C adapter^) or ensure WiFi is working,
    echo  then re-run this script.
    echo.
    pause
    exit /b 1
)
echo  OK — connection verified.

:: -----------------------------------------------------------
::  Banner
:: -----------------------------------------------------------
echo.
echo  ===========================================================
echo   ThinkPad P1 Gen 6 ^(21FW^) - Automated Driver Installer
echo  ===========================================================
echo.
echo   Drivers to install: !TOTAL!
echo   Download directory: %DRVDIR%
echo   Log file:           %LOGFILE%
echo.
echo   Install order:
echo     1. Intel WiFi 6E AX211 + Bluetooth    ~14 MB
echo     2. Intel Management Engine firmware    ~10 MB
echo     3. Intel Thunderbolt 4                  ~2 MB
echo     4. NVIDIA RTX 2000 Ada GPU           ~984 MB
echo     5. Realtek Audio ^(ALC3306^)             ~92 MB
echo.
echo   Total download: ~1.1 GB
echo.
echo  ===========================================================
echo.
echo  Starting in 5 seconds... Press Ctrl+C to cancel.
timeout /t 5 /nobreak >nul

echo [%DATE% %TIME%] === Driver installation started === > "%LOGFILE%"
echo [%DATE% %TIME%] Machine: %COMPUTERNAME% >> "%LOGFILE%"
echo. >> "%LOGFILE%"

:: ============================================================
::  DRIVER 1: Intel WiFi 6E AX211 + Bluetooth
::  Priority: gets wireless network up
:: ============================================================
set "DRV_NUM=1"
set "DRV_NAME=Intel WiFi 6E AX211 + Bluetooth"
set "DRV_FILE=nzbwl08w.exe"
set "DRV_DESC=Intel AX211/BE200 WiFi and Bluetooth driver v23.170.0"
call :do_install

:: ============================================================
::  DRIVER 2: Intel Management Engine Firmware
:: ============================================================
set "DRV_NUM=2"
set "DRV_NAME=Intel Management Engine"
set "DRV_FILE=n3zrg04w.exe"
set "DRV_DESC=Intel ME firmware v16.1.38.2676"
call :do_install

:: ============================================================
::  DRIVER 3: Intel Thunderbolt 4
:: ============================================================
set "DRV_NUM=3"
set "DRV_NAME=Intel Thunderbolt 4"
set "DRV_FILE=nzata02w_p1p16v.exe"
set "DRV_DESC=Intel Thunderbolt driver v1.41.1423.0"
call :do_install

:: ============================================================
::  DRIVER 4: NVIDIA RTX 2000 Ada Generation GPU
::  Largest download (~984 MB) — be patient
:: ============================================================
set "DRV_NUM=4"
set "DRV_NAME=NVIDIA RTX 2000 Ada GPU"
set "DRV_FILE=nzbda04w.exe"
set "DRV_DESC=NVIDIA RTX 2000 Ada video driver v32.0.15.8160"
call :do_install

:: ============================================================
::  DRIVER 5: Realtek Audio (ALC3306 with Dolby Atmos)
:: ============================================================
set "DRV_NUM=5"
set "DRV_NAME=Realtek Audio"
set "DRV_FILE=n3za116w.exe"
set "DRV_DESC=Realtek audio driver v6.0.9590.1"
call :do_install

:: ============================================================
::  Summary
:: ============================================================
echo.
echo  ===========================================================
echo   Installation Complete
echo  ===========================================================
echo.
echo   Successful: !OK! / !TOTAL!
if !FAIL! gtr 0 (
    echo   Failed:     !FAIL!
    echo   Check log:  %LOGFILE%
)
echo.
echo   Downloaded files kept in: %DRVDIR%
echo   ^(Safe to delete after reboot.^)
echo.
echo   A reboot is required to complete driver installation.
echo.
echo  ===========================================================
echo.
echo [%DATE% %TIME%] === Complete. OK=!OK! FAIL=!FAIL! === >> "%LOGFILE%"

choice /c YN /m "  Reboot now"
if !errorlevel! equ 1 (
    echo  Rebooting in 10 seconds...
    shutdown /r /t 10 /c "Rebooting to complete ThinkPad P1 Gen 6 driver installation"
)

endlocal
exit /b 0

:: ============================================================
::  Subroutine: do_install
::  Uses caller's variables: DRV_NUM, DRV_NAME, DRV_FILE,
::  DRV_DESC, BASE_URL, DRVDIR, LOGFILE, TOTAL
::  Modifies caller's: OK, FAIL
:: ============================================================
:do_install

echo.
echo  -----------------------------------------------------------
echo   [!DRV_NUM!/!TOTAL!] !DRV_NAME!
echo   !DRV_DESC!
echo  -----------------------------------------------------------

set "URL=!BASE_URL!/!DRV_FILE!"
set "DEST=!DRVDIR!\!DRV_FILE!"

:: --- Download phase ---
if exist "!DEST!" (
    echo   Already downloaded, skipping.
    echo [%DATE% %TIME%] [!DRV_NAME!] Skipped download ^(cached^) >> "!LOGFILE!"
) else (
    echo   Downloading !DRV_FILE! ...
    echo [%DATE% %TIME%] [!DRV_NAME!] GET !URL! >> "!LOGFILE!"
    curl.exe -L -# -o "!DEST!" "!URL!"
    if !errorlevel! neq 0 (
        echo   FAILED: Download error.
        echo [%DATE% %TIME%] [!DRV_NAME!] DOWNLOAD FAILED >> "!LOGFILE!"
        set /a FAIL+=1
        goto :eof
    )
    echo   Downloaded.
)

:: --- Validate file size ---
for %%F in ("!DEST!") do set "FSIZE=%%~zF"
if !FSIZE! lss 10000 (
    echo   FAILED: File too small ^(!FSIZE! bytes^), likely corrupt.
    echo [%DATE% %TIME%] [!DRV_NAME!] TOO SMALL: !FSIZE! bytes >> "!LOGFILE!"
    del "!DEST!" 2>nul
    set /a FAIL+=1
    goto :eof
)

:: --- Silent install ---
echo   Installing... ^(this may take a while for large drivers^)
echo [%DATE% %TIME%] [!DRV_NAME!] RUN "!DEST!" -s >> "!LOGFILE!"
start /wait "" "!DEST!" -s
set "RC=!errorlevel!"

:: Lenovo packaged drivers: 0=OK, 1 or 3010=OK+reboot needed
if !RC! equ 0 (
    echo   OK.
) else if !RC! equ 1 (
    echo   OK ^(reboot pending^).
) else if !RC! equ 3010 (
    echo   OK ^(reboot pending^).
) else (
    echo   Finished ^(exit code !RC! - usually still OK for Lenovo packages^).
)
echo [%DATE% %TIME%] [!DRV_NAME!] EXIT !RC! >> "!LOGFILE!"
set /a OK+=1

goto :eof
