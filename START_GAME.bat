@echo off
setlocal

set "GODOT_EXE=H:\Godot\Godot_v4.7-stable\Godot_v4.7-stable_win64.exe"
set "PROJECT_DIR=%~dp0"

if not exist "%GODOT_EXE%" (
  echo Godot executable was not found:
  echo %GODOT_EXE%
  echo.
  echo Update GODOT_EXE in this file or install Godot 4.7.
  pause
  exit /b 1
)

start "" "%GODOT_EXE%" --path "%PROJECT_DIR%"
