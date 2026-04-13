@ECHO OFF
SETLOCAL
PowerShell -ExecutionPolicy Bypass -File "%~dp0build-and-install.ps1" %*
EXIT /b %ERRORLEVEL%
