@echo off
cd /d "%~dp0"
echo Stable baseline, DXR off
echo.
echo Close the game completely before running the next test.
echo.
WolfSP.exe +set r_dxr 0 +set r_dxrFallbackLight 0 +set r_dxrSunEnable 0 +set developer 1 +set logfile 2 +set cg_drawFPS 1 +spdevmap escape1
pause
