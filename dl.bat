@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"
if not exist "aria2c.exe" goto needinstall
if not exist "downloads" mkdir "downloads"
set "URL=%~1"
if "%URL%"=="" goto askurl
goto run
:askurl
echo.
echo   Paste the download URL below, then press Enter:
set /p "URL=  > "
if "%URL%"=="" goto nourl
:run
echo.
echo   URL  : %URL%
echo   Save : %~dp0downloads
echo   Mode : 16 connections / resume / unlimited retry
echo.
aria2c.exe --conf-path="%~dp0aria2.conf" --enable-rpc=false -x16 -s16 -k1M -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36" "%URL%"
echo.
echo   Exit code %ERRORLEVEL%
pause
exit /b
:nourl
echo   No URL. Aborted.
pause
exit /b 1
:needinstall
echo.
echo   aria2c.exe not found. Run install.bat first.
echo.
pause
exit /b 2
