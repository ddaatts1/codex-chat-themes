@ECHO OFF
SETLOCAL
PowerShell -ExecutionPolicy Bypass -File "%~dp0rollback.ps1" %*
EXIT /b %ERRORLEVEL%
