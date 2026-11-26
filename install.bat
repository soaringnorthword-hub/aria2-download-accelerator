@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"
if exist "aria2c.exe" goto already

set "VER=1.37.0"
set "PKG=aria2-%VER%-win-64bit-build1"
set "ZIP=%PKG%.zip"
set "URL=https://github.com/aria2/aria2/releases/download/release-%VER%/%ZIP%"

echo.
echo   Downloading aria2 %VER% from official GitHub releases ...
echo.
curl -L --fail --retry 3 -o "%ZIP%" "%URL%"
if errorlevel 1 goto fail

echo.
echo   Extracting ...
set "BSTAR=%SystemRoot%\System32\tar.exe"
if exist "%BSTAR%" goto usebsdtar
echo   System tar not found, falling back to PowerShell Expand-Archive ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath '%ZIP%' -DestinationPath '.' -Force"
if errorlevel 1 goto fail
goto extracted
:usebsdtar
"%BSTAR%" -xf "%ZIP%"
if errorlevel 1 goto fail
:extracted

if exist "%PKG%\aria2c.exe" move /y "%PKG%\aria2c.exe" "aria2c.exe" >nul
if exist "%PKG%\AUTHORS" copy /y "%PKG%\AUTHORS" "AUTHORS" >nul
if exist "%PKG%\COPYING" copy /y "%PKG%\COPYING" "COPYING" >nul
if exist "%PKG%" rmdir /s /q "%PKG%"
del /q "%ZIP%" 2>nul

if not exist "aria2c.exe" goto fail
echo.
echo   Installed: %~dp0aria2c.exe
aria2c.exe --version
echo.
echo   Now run dl.bat and paste your download link.
echo.
pause
exit /b 0

:already
echo.
echo   aria2c.exe already exists. Nothing to do.
aria2c.exe --version
echo.
pause
exit /b 0

:fail
echo.
echo   ERROR: download or extraction failed.
echo   Download the zip manually from:
echo   %URL%
echo   Put aria2c.exe next to this file, then run dl.bat.
echo.
pause
exit /b 1
