param(
    [Parameter(Mandatory = $true)]
    [string]$CodexSourcePath,
    [string]$BuildRoot = "D:\codex-build-themes",
    [ValidateSet("Debug", "Release", "debug", "release")]
    [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$patchPath = Join-Path $repoRoot "patches\codex-chat-themes.patch"
$resolvedSource = (Resolve-Path -LiteralPath $CodexSourcePath).Path
$resolvedBuildRoot = $BuildRoot
$tempDir = Join-Path $resolvedBuildRoot "temp"
$vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
$configLower = $Configuration.ToLowerInvariant()
$cargoArgs = @("build", "-p", "codex-cli", "--bin", "codex")

if (Test-Path -LiteralPath (Join-Path $resolvedSource "Cargo.toml")) {
    $cargoWorkspace = $resolvedSource
}
elseif (Test-Path -LiteralPath (Join-Path $resolvedSource "codex-rs\Cargo.toml")) {
    $cargoWorkspace = Join-Path $resolvedSource "codex-rs"
}
else {
    throw "Could not find Cargo.toml in $resolvedSource or $resolvedSource\\codex-rs"
}

if ($configLower -eq "release") {
    $cargoArgs += "--release"
}

if (-not (Test-Path -LiteralPath $patchPath)) {
    throw "Patch not found: $patchPath"
}

if (-not (Test-Path -LiteralPath $vswhere)) {
    throw "vswhere.exe not found. Install Visual Studio 2022 or Build Tools."
}

$installPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (-not $installPath) {
    throw "MSVC build tools not found."
}

$vcvars = Join-Path $installPath "VC\Auxiliary\Build\vcvars64.bat"
if (-not (Test-Path -LiteralPath $vcvars)) {
    throw "vcvars64.bat not found at $vcvars"
}

Push-Location $resolvedSource
try {
    git apply --reverse --check $patchPath 2>$null
    $alreadyApplied = ($LASTEXITCODE -eq 0)

    if (-not $alreadyApplied) {
        git apply --check $patchPath
        if ($LASTEXITCODE -ne 0) {
            throw "Patch does not apply cleanly."
        }
        git apply $patchPath
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to apply patch."
        }
    }

    New-Item -ItemType Directory -Force -Path $resolvedBuildRoot | Out-Null
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

    $cargoBin = Join-Path $env:USERPROFILE ".cargo\bin"
    $cargoCommand = $cargoArgs -join ' '
    $cmd = "call `"$vcvars`" && set PATH=$cargoBin;%PATH% && set `"CARGO_TARGET_DIR=$resolvedBuildRoot`" && set `"TEMP=$tempDir`" && set `"TMP=$tempDir`" && cd /d `"$cargoWorkspace`" && cargo $cargoCommand"
    cmd.exe /d /s /c $cmd
    if ($LASTEXITCODE -ne 0) {
        throw "cargo build failed with exit code $LASTEXITCODE"
    }

    Write-Host "Built: $(Join-Path $resolvedBuildRoot "$configLower\codex.exe")"
}
finally {
    Pop-Location
}
