@echo off
cd /d "%~dp0"
echo Half-res full lighting, 512 world meshes. Run if 128 mesh is stable.
echo.
echo Close the game completely before running the next test.
echo.
WolfSP.exe +set developer 1 +set logfile 2 +set cg_drawFPS 1 +set r_dxr 1 +set r_dxrSafeMode 1 +set r_dxrErrorLimit 1 +set r_dxrDispatchMode 4 +set r_dxrNoBuildBLAS 0 +set r_dxrNoBuildTLAS 0 +set r_dxrNoDispatch 0 +set r_dxrValidateSBT 1 +set r_dxrValidateUAV 1 +set r_dxrCompositeBlocks 1 +set r_dxrPerfPreset 0 +set r_dxrMaxLights 4 +set r_dxrShadowSamples 1 +set r_dxrAOSamples 0 +set r_dxrSkySamples 0 +set r_dxrSync 0 +set r_dxrFallbackLight 0 +set r_dxrSunEnable 0 +set r_dxrAmbientIntensity 1.45 +set r_dxrLegacyBlend 0.78 +set r_dxrExposure 1.20 +set r_dxrShadowBias 0.03 +set r_dxrRenderScale 0.50 +set r_dxrMaxDispatchPixels 240000 +set r_dxrBuildInterval 2 +set r_dxrMaxWorldMeshes 512 +spdevmap escape1
pause
