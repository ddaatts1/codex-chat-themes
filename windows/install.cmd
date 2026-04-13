@ECHO OFF
SETLOCAL
PowerShell -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
EXIT /b %ERRORLEVEL%
