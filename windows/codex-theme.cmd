@ECHO off
SETLOCAL

SET "_theme_file=%USERPROFILE%\.codex\chat-theme.txt"
SET "_theme_dir=%USERPROFILE%\.codex"
SET "_current=box"

IF EXIST "%_theme_file%" (
  SET /P _current=<"%_theme_file%"
)

IF "%~1"=="" GOTO usage

IF /I "%~1"=="list" (
  ECHO Available themes:
  ECHO   box       - framed user prompt with the You label
  ECHO   box-clean - framed user prompt without the label
  ECHO   flat      - flat highlighted prompt bar
  ECHO   slate     - muted flat prompt bar
  EXIT /B 0
)

IF /I "%~1"=="current" (
  ECHO Current theme: %_current%
  EXIT /B 0
)

IF /I "%~1"=="reset" (
  SET "_requested=box"
  GOTO set_theme
)

SET "_requested=%~1"
IF /I "%_requested%"=="box" GOTO set_theme
IF /I "%_requested%"=="box-clean" GOTO set_theme
IF /I "%_requested%"=="flat" GOTO set_theme
IF /I "%_requested%"=="slate" GOTO set_theme

ECHO Unknown theme: %_requested%
ECHO.
GOTO usage

:set_theme
IF NOT EXIST "%_theme_dir%" MKDIR "%_theme_dir%"
>"%_theme_file%" ECHO %_requested%
ECHO Active theme: %_requested%
ECHO Open a new codex session to see the change.
EXIT /B 0

:usage
ECHO Usage:
ECHO   codex-theme list
ECHO   codex-theme current
ECHO   codex-theme box
ECHO   codex-theme box-clean
ECHO   codex-theme flat
ECHO   codex-theme slate
ECHO   codex-theme reset
EXIT /B 1
