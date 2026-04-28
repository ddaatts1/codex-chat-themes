param(
    [string]$BuiltCodexExePath,
    [string]$NpmBinDir = "$env:APPDATA\npm",
    [string]$CodexHome = "$env:USERPROFILE\.codex",
    [string]$ThemeBinDir = "$env:USERPROFILE\.codex\tools"
)

if (-not $BuiltCodexExePath) {
    $BuiltCodexExePath = Join-Path $PSScriptRoot "codex.exe"
}

if (-not (Test-Path -LiteralPath $BuiltCodexExePath)) {
    throw "Built codex.exe not found at $BuiltCodexExePath"
}

$builtExe = (Resolve-Path -LiteralPath $BuiltCodexExePath).Path
$launcherPath = Join-Path $ThemeBinDir "codex.cmd"
$fallbackLauncherPath = Join-Path $NpmBinDir "codex.cmd"
$themeCmdSource = Join-Path $PSScriptRoot "codex-theme.cmd"
$themeCmdTarget = Join-Path $ThemeBinDir "codex-theme.cmd"
$customExeTarget = Join-Path $ThemeBinDir "codex-themed.exe"
$themeFile = Join-Path $CodexHome "chat-theme.txt"

if (-not (Test-Path -LiteralPath $fallbackLauncherPath)) {
    throw "codex.cmd not found at $fallbackLauncherPath"
}

function Set-UserPathPriority {
    param(
        [string]$PriorityPath
    )

    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $parts = @()
    if ($userPath) {
        $parts = $userPath -split ';' | Where-Object { $_ -and $_.Trim() }
    }

    $normalizedPriority = [System.IO.Path]::GetFullPath($PriorityPath.TrimEnd('\'))
    $filtered = New-Object System.Collections.Generic.List[string]
    foreach ($part in $parts) {
        try {
            $normalizedPart = [System.IO.Path]::GetFullPath($part.TrimEnd('\'))
        }
        catch {
            $normalizedPart = $part
        }

        if ($normalizedPart -ieq $normalizedPriority) {
            continue
        }
        [void]$filtered.Add($part)
    }

    $newParts = @($PriorityPath) + $filtered.ToArray()
    $newUserPath = ($newParts -join ';')
    [Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")
    $env:Path = $newUserPath
}

New-Item -ItemType Directory -Force -Path $CodexHome | Out-Null
New-Item -ItemType Directory -Force -Path $ThemeBinDir | Out-Null

Copy-Item -LiteralPath $builtExe -Destination $customExeTarget -Force
Copy-Item -LiteralPath $themeCmdSource -Destination $themeCmdTarget -Force

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

SET "_custom=$customExeTarget"
IF EXIST "%_custom%" (
  "%_custom%" %*
  EXIT /b %ERRORLEVEL%
)

SET "_fallback=$fallbackLauncherPath"
IF EXIST "%_fallback%" (
  CALL "%_fallback%" %*
  EXIT /b %ERRORLEVEL%
)

ECHO codex custom binary not found: %_custom%
EXIT /b 1
"@

Set-Content -LiteralPath $launcherPath -Value $wrapper -Encoding ascii
Set-UserPathPriority -PriorityPath $ThemeBinDir

Write-Host "Installed custom Codex launcher."
Write-Host "Binary: $customExeTarget"
Write-Host "Wrapper: $launcherPath"
Write-Host "Fallback: $fallbackLauncherPath"
Write-Host "Theme file: $themeFile"
Write-Host "Command: codex-theme"
