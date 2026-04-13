param(
    [Parameter(Mandatory = $true)]
    [string]$BuiltCodexExePath,
    [string]$NpmBinDir = "$env:APPDATA\npm",
    [string]$CodexHome = "$env:USERPROFILE\.codex"
)

$builtExe = (Resolve-Path -LiteralPath $BuiltCodexExePath).Path
$launcherPath = Join-Path $NpmBinDir "codex.cmd"
$backupPath = Join-Path $NpmBinDir "codex.cmd.orig"
$themeCmdSource = Join-Path $PSScriptRoot "codex-theme.cmd"
$themeCmdTarget = Join-Path $NpmBinDir "codex-theme.cmd"
$themeFile = Join-Path $CodexHome "chat-theme.txt"

if (-not (Test-Path -LiteralPath $launcherPath)) {
    throw "codex.cmd not found at $launcherPath"
}

if (-not (Test-Path -LiteralPath $backupPath)) {
    Copy-Item -LiteralPath $launcherPath -Destination $backupPath -Force
}

Copy-Item -LiteralPath $themeCmdSource -Destination $themeCmdTarget -Force

New-Item -ItemType Directory -Force -Path $CodexHome | Out-Null
if (-not (Test-Path -LiteralPath $themeFile)) {
    Set-Content -LiteralPath $themeFile -Value "box" -Encoding ascii
}

$wrapper = @"
@ECHO off
SETLOCAL
SET "CODEX_CHAT_THEME=box"
SET "_theme_file=%USERPROFILE%\.codex\chat-theme.txt"
IF EXIST "%_theme_file%" (
  SET /P CODEX_CHAT_THEME=<"%_theme_file%"
)

SET "_custom=$builtExe"
IF EXIST "%_custom%" (
  "%_custom%" %*
  EXIT /b %ERRORLEVEL%
)

IF EXIST "%~dp0codex.cmd.orig" (
  CALL "%~dp0codex.cmd.orig" %*
  EXIT /b %ERRORLEVEL%
)

ECHO codex custom binary not found: %_custom%
EXIT /b 1
"@

Set-Content -LiteralPath $launcherPath -Value $wrapper -Encoding ascii

Write-Host "Installed custom Codex launcher."
Write-Host "Binary: $builtExe"
Write-Host "Theme file: $themeFile"
Write-Host "Command: codex-theme"
