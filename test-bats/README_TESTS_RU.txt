DXR TDR-safe Runtime Fix BAT tests

Copy all .bat files next to WolfSP.exe.

Why this kit exists:
  Your last log showed quarter-res full lighting still reached DEVICE_HUNG:
  DXR HALFRES: DispatchRays mode=4 size=213x120 output=853x480 scale=0.25
  DXR DEVICE LOST: CreateCommittedResource failed 0x887A0005, removedReason=0x887A0006

So this fix does NOT try larger half-res again. It makes mode 4 much safer:
  - freezes BLAS/TLAS after the first valid TLAS
  - caps full lighting to 64x36, 96x54, or 128x72
  - dispatches full lighting only once every N frames
  - optionally uses r_dxrSync 1 for safer failure detection
  - keeps G-buffer fullscreen fallback available

Recommended order:
  1. RUN_00_SAFE_NO_DXR.bat
  2. RUN_70_TDRSAFE_FULL_64x36_ULTRASAFE.bat

If RUN_70 survives for a few minutes:
  3. RUN_71_TDRSAFE_FULL_96x54_SAFE.bat
  4. RUN_72_TDRSAFE_FULL_128x72_CAUTIOUS.bat

If any full-lighting mode still hangs/crashes:
  RUN_80_TDRSAFE_GBUFFER_FULLSCREEN_STABLE.bat

Interpretation:
  RUN_70 crash/hang means the current full lighting closest-hit shader is still not safe on this GPU/driver even at very low resolution.
  RUN_70 stable but RUN_72 crash means 128x72 is too high; keep 64x36 or 96x54.
  RUN_80 stable means the wrapper/composition path is alive and only full lighting mode 4 must remain disabled.
