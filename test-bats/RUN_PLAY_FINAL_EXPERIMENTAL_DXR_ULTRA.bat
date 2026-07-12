@echo off
setlocal
cd /d "%~dp0"
echo Starting DarkWolf RTCW EXPERIMENTAL DXR ULTRA preset...
echo Uses main\dxr_final_experimental_dxr_ultra.cfg
echo If this mode hangs or crashes, use RUN_RESET_SAFE.bat and return to HIGH QUALITY.
WolfSP.exe +exec dxr_final_experimental_dxr_ultra.cfg
