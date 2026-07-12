@echo off
setlocal
cd /d "%~dp0"
echo Starting DarkWolf RTCW FINAL HIGH QUALITY DXR preset...
echo Uses main\dxr_final_high_quality.cfg
WolfSP.exe +exec dxr_final_high_quality.cfg
