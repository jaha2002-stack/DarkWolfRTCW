DarkWolf RTCW DXR Dispatch Guard BAT tests
==========================================

Copy all .bat files next to WolfSP.exe.
Run tests by double-clicking the .bat files. Close the game completely between tests.

Recommended order:

1) RUN_00_SAFE_NO_DXR.bat
   Baseline. Must be stable and high FPS.

2) RUN_01_DXR_INIT_ONLY_NO_BLAS.bat
   Checks DXR init only. No BLAS, no TLAS, no DispatchRays.

3) RUN_02_DXR_TLAS_NO_DISPATCH_128.bat
   Builds BLAS+TLAS for up to 128 world meshes but skips DispatchRays.
   This should be stable if the previous Safe Mode diagnosis is still correct.

4) RUN_10_DISPATCH_MODE0_SKIP_128.bat
   Uses r_dxrDispatchMode 0. Descriptors are prepared, DispatchRays skipped.

5) RUN_11_DISPATCH_CONSTANT_1x1.bat
   First real DispatchRays call. Raygen writes constant magenta and does not call TraceRay.
   If this crashes: problem is pipeline/SBT/UAV/DispatchRays itself.

Then continue in this order only while the previous test is stable:

   RUN_12_DISPATCH_CONSTANT_16x16.bat
   RUN_13_DISPATCH_CONSTANT_128x72.bat
   RUN_14_DISPATCH_CONSTANT_FULLSCREEN.bat

   RUN_21_DISPATCH_GBUFFER_1x1.bat
   RUN_22_DISPATCH_GBUFFER_128x72.bat
   RUN_23_DISPATCH_GBUFFER_FULLSCREEN.bat

   RUN_31_DISPATCH_MISSONLY_1x1.bat
   RUN_32_DISPATCH_MISSONLY_128x72.bat
   RUN_33_DISPATCH_MISSONLY_FULLSCREEN.bat

   RUN_41_DISPATCH_FULL_1x1.bat
   RUN_42_DISPATCH_FULL_16x16.bat
   RUN_43_DISPATCH_FULL_128x72.bat
   RUN_44_DISPATCH_FULL_FULLSCREEN_128MESH.bat
   RUN_45_DISPATCH_FULL_FULLSCREEN_512MESH.bat

How to interpret:

- CONSTANT 1x1 fails:
  DispatchRays/SBT/UAV/pipeline state is broken before any TraceRay.

- CONSTANT works but GBUFFER fails:
  G-buffer SRV descriptors or texture states are suspect.

- GBUFFER works but MISSONLY fails:
  TraceRay or miss shader table is suspect.

- MISSONLY works but FULL fails:
  hit group / closest-hit / actual lighting shader is suspect.

- small sizes work but fullscreen fails:
  dispatch dimensions or shader runtime cost triggers device removed.

After the first crash, send rtcwconsole.log.
