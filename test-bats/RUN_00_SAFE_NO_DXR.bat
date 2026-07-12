@echo off
cd /d "%~dp0"
echo Safe baseline: DXR forced OFF
echo.
echo Requires DXR TDR-safe Runtime Fix build.
echo Close the game completely before running another DXR test.
echo.
WolfSP.exe +set developer 1 +set logfile 2 +set cg_drawFPS 1 +set r_dxr 0 +set r_dxrDebug 0 +set r_dxrDebugMode 0 +set r_dxrFallbackLight 0 +set r_dxrSunEnable 0 +spdevmap escape1
pause
