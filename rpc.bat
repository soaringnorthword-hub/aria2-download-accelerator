@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"
if not exist "aria2c.exe" goto needinstall
if not exist "downloads" mkdir "downloads"
title aria2 RPC server
echo.
echo   aria2 RPC is running.
echo   Endpoint : http://127.0.0.1:6800/jsonrpc
echo   Secret   : workbuddy6800
echo.
echo   Keep this window open. Close it to stop the server.
echo.
aria2c.exe --conf-path="%~dp0aria2.conf"
echo.
echo   Server stopped.
pause
exit /b
:needinstall
echo.
echo   aria2c.exe not found. Run install.bat first.
echo.
pause
exit /b 2
