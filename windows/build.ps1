param(
    [Parameter(Mandatory = $true)]
    [string]$CodexSourcePath,
    [string]$BuildRoot = "D:\codex-build-themes"
)

$repoRoot = Split-Path -Parent $PSScriptRoot
$patchPath = Join-Path $repoRoot "patches\codex-chat-themes.patch"
$resolvedSource = (Resolve-Path -LiteralPath $CodexSourcePath).Path
$resolvedBuildRoot = $BuildRoot
$tempDir = Join-Path $resolvedBuildRoot "temp"
$vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"

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
    $cmd = "call `"$vcvars`" && set PATH=$cargoBin;%PATH% && set `"CARGO_TARGET_DIR=$resolvedBuildRoot`" && set `"TEMP=$tempDir`" && set `"TMP=$tempDir`" && cargo build -p codex-cli --bin codex"
    cmd.exe /d /s /c $cmd
    if ($LASTEXITCODE -ne 0) {
        throw "cargo build failed with exit code $LASTEXITCODE"
    }

    Write-Host "Built: $(Join-Path $resolvedBuildRoot 'debug\codex.exe')"
}
finally {
    Pop-Location
}
