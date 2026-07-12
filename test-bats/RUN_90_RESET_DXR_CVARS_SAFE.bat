@echo off
cd /d "%~dp0"
echo Reset saved DXR cvars to safe OFF state
echo.
echo Requires DXR TDR-safe Runtime Fix build.
echo Close the game completely before running another DXR test.
echo.
WolfSP.exe +set developer 0 +set logfile 0 +set r_dxr 0 +set r_dxrSafeMode 1 +set r_dxrDispatchMode 2 +set r_dxrNoDispatch 0 +set r_dxrNoBuildBLAS 0 +set r_dxrNoBuildTLAS 0 +set r_dxrFreezeScene 1 +set r_dxrForceSafeFullLighting 1 +set r_dxrDispatchEveryNFrames 8 +set r_dxrSafeFullMaxPixels 2304 +set r_dxrMaxDispatchPixels 2304 +set r_dxrMaxWorldMeshes 64 +set r_dxrMaxLights 1 +set r_dxrFallbackLight 0 +set r_dxrSunEnable 0 +spdevmap escape1
pause
