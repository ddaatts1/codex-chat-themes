param(
    [Parameter(Mandatory = $true)]
    [string]$BuiltCodexExePath,
    [string]$Version = "dev",
    [string]$OutputDir
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not $OutputDir) {
    $OutputDir = Join-Path $repoRoot "dist"
}

$builtExe = (Resolve-Path -LiteralPath $BuiltCodexExePath).Path
$bundleName = "codex-chat-themes-$Version-windows-x64"
$bundleRoot = Join-Path $OutputDir $bundleName
$zipPath = Join-Path $OutputDir "$bundleName.zip"
$releaseReadme = Join-Path $bundleRoot "README-RELEASE.txt"

if (Test-Path -LiteralPath $bundleRoot) {
    Remove-Item -LiteralPath $bundleRoot -Recurse -Force
}

if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}

New-Item -ItemType Directory -Force -Path $bundleRoot | Out-Null

Copy-Item -LiteralPath $builtExe -Destination (Join-Path $bundleRoot "codex.exe") -Force
Copy-Item -LiteralPath (Join-Path $PSScriptRoot "install.ps1") -Destination (Join-Path $bundleRoot "install.ps1") -Force
Copy-Item -LiteralPath (Join-Path $PSScriptRoot "install.cmd") -Destination (Join-Path $bundleRoot "install.cmd") -Force
Copy-Item -LiteralPath (Join-Path $PSScriptRoot "rollback.ps1") -Destination (Join-Path $bundleRoot "rollback.ps1") -Force
Copy-Item -LiteralPath (Join-Path $PSScriptRoot "rollback.cmd") -Destination (Join-Path $bundleRoot "rollback.cmd") -Force
Copy-Item -LiteralPath (Join-Path $PSScriptRoot "codex-theme.cmd") -Destination (Join-Path $bundleRoot "codex-theme.cmd") -Force
Copy-Item -LiteralPath (Join-Path $repoRoot "README.md") -Destination (Join-Path $bundleRoot "README.md") -Force

@"
Codex Chat Themes for Windows
=============================

Quick install:
1. Make sure Codex is already installed with npm.
2. Double-click install.cmd or run .\install.ps1.
3. Open a new shell and run: codex
4. Switch themes with: codex-theme list

Rollback:
- Double-click rollback.cmd or run .\rollback.ps1
"@ | Set-Content -LiteralPath $releaseReadme -Encoding ascii

Compress-Archive -Path (Join-Path $bundleRoot '*') -DestinationPath $zipPath -Force

Write-Host "Release bundle: $zipPath"
