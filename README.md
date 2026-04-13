# Codex Chat Themes for Windows

Theme switcher for the open-source Codex CLI on Windows x64.

This repo adds a few user-message layouts to the Codex TUI and installs a small `codex-theme` command so you can switch between them from `cmd.exe` or PowerShell.

## Visual Reference

This screenshot shows the flatter, lower-border visual direction used while shaping these Windows chat themes. Treat it as a style reference rather than a pixel-exact preview of every theme in this repo.

![Codex chat theme reference](assets/codex-theme-reference.png)

Supported themes:

- `box`: framed user prompt with the `You` label
- `box-clean`: framed user prompt without the label
- `flat`: flat highlighted prompt bar
- `slate`: muted flat prompt bar

Tested against upstream Codex commit:

- `1de0085418340b3e7f7136cfb5e56b4bebafc584`

## What this repo contains

- `patches/codex-chat-themes.patch`: patch against the upstream `openai/codex` repo
- `windows/build.ps1`: applies the patch and builds `codex.exe`
- `windows/install.ps1`: installs the built binary into your existing npm Codex launcher
- `windows/rollback.ps1`: restores the original launcher
- `windows/codex-theme.cmd`: theme-switch command

## Requirements

- Windows x64
- Rust toolchain with `cargo`
- Visual Studio 2022 C++ build tools or Visual Studio Community with MSVC
- `codex` already installed via npm
- `git`

## Build

Clone the upstream Codex repo first:

```powershell
git clone https://github.com/openai/codex.git codex-src
```

Build the themed binary:

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\build.ps1 -CodexSourcePath C:\path\to\codex-src
```

By default it builds to:

```text
D:\codex-build-themes\debug\codex.exe
```

## Install

Install the built binary into your existing npm Codex launcher:

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\install.ps1 -BuiltCodexExePath D:\codex-build-themes\debug\codex.exe
```

That script:

- backs up `%APPDATA%\npm\codex.cmd` to `codex.cmd.orig`
- installs `codex-theme.cmd`
- creates `%USERPROFILE%\.codex\chat-theme.txt` if needed
- rewrites `codex.cmd` so it launches the custom binary first and falls back to the original launcher

## Usage

Open a new shell after installation.

```cmd
codex-theme list
codex-theme current
codex-theme box
codex-theme box-clean
codex-theme flat
codex-theme slate
codex-theme reset
```

Then start a new Codex session:

```cmd
codex
```

## Rollback

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\rollback.ps1
```

This restores the original `codex.cmd` and removes `codex-theme.cmd`.

## Notes

- This repo does not ship prebuilt binaries.
- The install path assumes the npm launcher is at `%APPDATA%\npm\codex.cmd`.
- The patch only changes the user-message presentation inside the Codex TUI. It does not require WezTerm.
