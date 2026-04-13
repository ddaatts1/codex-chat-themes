param(
    [string]$NpmBinDir = "$env:APPDATA\npm"
)

$launcherPath = Join-Path $NpmBinDir "codex.cmd"
$backupPath = Join-Path $NpmBinDir "codex.cmd.orig"
$themeCmdTarget = Join-Path $NpmBinDir "codex-theme.cmd"

if (-not (Test-Path -LiteralPath $backupPath)) {
    throw "Backup launcher not found at $backupPath"
}

Copy-Item -LiteralPath $backupPath -Destination $launcherPath -Force

if (Test-Path -LiteralPath $themeCmdTarget) {
    Remove-Item -LiteralPath $themeCmdTarget -Force
}

Write-Host "Restored original codex.cmd"
