@echo off
cd /d "%~dp0"
echo Baseline: DXR forced OFF
echo.
echo This requires the DXR Dispatch Guard build.
echo Close the game completely before running the next test.
echo.
WolfSP.exe +set r_dxr 0 +set r_dxrDebug 0 +set r_dxrDebugMode 0 +set r_dxrFallbackLight 0 +set r_dxrSunEnable 0 +set r_dxrPerfPreset 0 +set r_dxrSync 0 +set developer 1 +set logfile 2 +set cg_drawFPS 1 +spdevmap escape1
pause
