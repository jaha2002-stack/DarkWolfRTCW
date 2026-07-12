@echo off
setlocal
cd /d "%~dp0"
echo Resetting DarkWolf RTCW to safe non-DXR mode...
echo Uses main\dxr_reset_safe.cfg
WolfSP.exe +exec dxr_reset_safe.cfg
