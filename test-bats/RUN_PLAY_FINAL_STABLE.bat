@echo off
setlocal
cd /d "%~dp0"
echo Starting DarkWolf RTCW FINAL STABLE DXR preset...
echo Uses main\dxr_final_stable.cfg
WolfSP.exe +exec dxr_final_stable.cfg
