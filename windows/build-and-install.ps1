$ErrorActionPreference = "Stop"

param(
    [string]$CodexSourcePath,
    [string]$BuildRoot = "D:\codex-build-themes",
    [string]$NpmBinDir = "$env:APPDATA\npm",
    [string]$CodexHome = "$env:USERPROFILE\.codex"
)

$repoRoot = Split-Path -Parent $PSScriptRoot
$defaultSourcePath = Join-Path (Split-Path -Parent $repoRoot) "codex-src"

if (-not $CodexSourcePath) {
    $CodexSourcePath = $defaultSourcePath
}

if (-not (Test-Path -LiteralPath $CodexSourcePath)) {
    Write-Host "Upstream Codex source not found. Cloning to $CodexSourcePath ..."
    git clone https://github.com/openai/codex.git $CodexSourcePath
    if ($LASTEXITCODE -ne 0) {
        throw "git clone failed with exit code $LASTEXITCODE"
    }
}

$resolvedSource = (Resolve-Path -LiteralPath $CodexSourcePath).Path
$buildScript = Join-Path $PSScriptRoot "build.ps1"
$installScript = Join-Path $PSScriptRoot "install.ps1"
$builtExe = Join-Path $BuildRoot "debug\codex.exe"

& $buildScript -CodexSourcePath $resolvedSource -BuildRoot $BuildRoot

if (-not (Test-Path -LiteralPath $builtExe)) {
    throw "Built codex.exe not found at $builtExe"
}

& $installScript -BuiltCodexExePath $builtExe -NpmBinDir $NpmBinDir -CodexHome $CodexHome

Write-Host ""
Write-Host "One-click setup completed."
Write-Host "Open a new shell and run: codex"
Write-Host "Available themes: codex-theme list"
