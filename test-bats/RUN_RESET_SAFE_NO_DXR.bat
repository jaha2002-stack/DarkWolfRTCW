@echo off
cd /d "%~dp0"
echo DarkWolf RTCW - Reset to safe no-DXR mode
echo.
echo Uses main\dxr_reset_safe.cfg
echo.
WolfSP.exe +exec dxr_reset_safe.cfg
pause
