@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\compile_story.ps1"
if errorlevel 1 (echo Compilation failed.)
pause
