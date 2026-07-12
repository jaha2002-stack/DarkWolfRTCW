@echo off
cd /d "%~dp0"
echo DXR init only: no BLAS, no TLAS, no DispatchRays
echo.
echo This requires the DXR Dispatch Guard build.
echo Close the game completely before running the next test.
echo.
WolfSP.exe +set developer 1 +set logfile 2 +set cg_drawFPS 1 +set r_dxrSafeMode 1 +set r_dxrErrorLimit 1 +set r_dxrPerfPreset 0 +set r_dxrMaxLights 0 +set r_dxrShadowSamples 1 +set r_dxrAOSamples 0 +set r_dxrSkySamples 0 +set r_dxrSync 0 +set r_dxrFallbackLight 0 +set r_dxrSunEnable 0 +set r_dxrDebug 0 +set r_dxrDebugMode 0 +set r_dxrValidateSBT 1 +set r_dxrValidateUAV 1 +set r_dxrMaxWorldMeshes 0 +set r_dxrNoBuildBLAS 1 +set r_dxrNoBuildTLAS 1 +set r_dxrNoDispatch 1 +set r_dxrDispatchMode 0 +set r_dxrDispatchWidth 0 +set r_dxrDispatchHeight 0 +set r_dxrDispatchScale 1.0 +set r_dxr 1 +spdevmap escape1
pause
