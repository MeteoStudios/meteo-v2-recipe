@echo off
REM  Meteo v2 Rename - double-click to start.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0meteo-rename.ps1" %*
