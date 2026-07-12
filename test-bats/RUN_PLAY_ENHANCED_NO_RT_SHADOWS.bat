@echo off
cd /d "%~dp0"
echo DarkWolf RTCW - Smooth enhanced fallback, no RT hit-shader shadows
echo.
echo Uses main\dxr_play_enhanced_no_rt_shadows.cfg
echo Close the game before switching presets.
echo.
WolfSP.exe +exec dxr_play_enhanced_no_rt_shadows.cfg
pause
