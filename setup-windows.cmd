@echo off
REM Double-click this file to set up the TenantCloud connector on Windows.
REM It runs setup.ps1 once with script blocking bypassed for this run only (no system settings change).
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -LiteralPath '%~dp0' -Recurse | Unblock-File; & '%~dp0setup.ps1'"
