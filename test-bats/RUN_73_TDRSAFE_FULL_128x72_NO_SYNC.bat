@echo off
cd /d "%~dp0"
echo TDR-safe full lighting: 128x72, no sync, faster but riskier
echo.
echo Requires DXR TDR-safe Runtime Fix build.
echo Close the game completely before running another DXR test.
echo.
WolfSP.exe +set developer 1 +set logfile 2 +set cg_drawFPS 1 +set r_dxr 1 +set r_dxrSafeMode 1 +set r_dxrErrorLimit 1 +set r_dxrNoBuildBLAS 0 +set r_dxrNoBuildTLAS 0 +set r_dxrNoDispatch 0 +set r_dxrValidateSBT 1 +set r_dxrValidateUAV 1 +set r_dxrCompositeBlocks 1 +set r_dxrFreezeScene 1 +set r_dxrForceSafeFullLighting 1 +set r_dxrBuildInterval 9999 +set r_dxrAOSamples 0 +set r_dxrSkySamples 0 +set r_dxrShadowSamples 1 +set r_dxrFallbackLight 0 +set r_dxrSunEnable 0 +set r_dxrAmbientIntensity 1.55 +set r_dxrLegacyBlend 0.85 +set r_dxrExposure 1.25 +set r_dxrShadowBias 0.04 +set r_dxrDispatchMode 4 +set r_dxrDispatchWidth 128 +set r_dxrDispatchHeight 72 +set r_dxrRenderScale 0.25 +set r_dxrMaxDispatchPixels 9216 +set r_dxrSafeFullMaxPixels 9216 +set r_dxrDispatchEveryNFrames 4 +set r_dxrMaxWorldMeshes 128 +set r_dxrMaxLights 1 +set r_dxrSync 0 +spdevmap escape1
pause
