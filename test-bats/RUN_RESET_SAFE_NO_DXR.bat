@echo off
setlocal
cd /d "%~dp0"
echo Resetting DarkWolf RTCW to safe non-DXR mode...
WolfSP.exe +exec dxr_reset_safe.cfg
