param(
    [string]$NpmBinDir = "$env:APPDATA\npm",
    [string]$ThemeBinDir = "$env:USERPROFILE\.codex\tools"
)

$launcherPath = Join-Path $ThemeBinDir "codex.cmd"
$themeCmdTarget = Join-Path $ThemeBinDir "codex-theme.cmd"
$customExeTarget = Join-Path $ThemeBinDir "codex-themed.exe"
$fallbackLauncherPath = Join-Path $NpmBinDir "codex.cmd"

if (Test-Path -LiteralPath $launcherPath) {
    Remove-Item -LiteralPath $launcherPath -Force
}

if (Test-Path -LiteralPath $themeCmdTarget) {
    Remove-Item -LiteralPath $themeCmdTarget -Force
}

if (Test-Path -LiteralPath $customExeTarget) {
    Remove-Item -LiteralPath $customExeTarget -Force
}

if (-not (Test-Path -LiteralPath $fallbackLauncherPath)) {
    throw "Fallback launcher not found at $fallbackLauncherPath"
}

Write-Host "Removed custom wrapper from $ThemeBinDir"
Write-Host "codex now falls back to $fallbackLauncherPath"
