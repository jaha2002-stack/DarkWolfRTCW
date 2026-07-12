DarkWolf RTCW DXR Half-Resolution Full Lighting + Performance Cache tests

Copy these .bat files next to WolfSP.exe.
Close the game completely between tests.

Recommended order:

1. RUN_00_SAFE_NO_DXR.bat
   Must be stable and high FPS.

2. RUN_50_HALFRES_128MESH_STABLE.bat
   First real target. Full lighting is traced at half resolution and expanded into the full output texture.

3. RUN_51_QUARTERRES_128MESH_SAFE.bat
   Safest fallback if half-res is still slow or unstable.

4. RUN_52_HALFRES_512MESH.bat
   Run if 128 meshes is stable.

5. RUN_53_HALFRES_1024MESH.bat
   Run if 512 meshes is stable.

6. RUN_54_SCALE_075_128MESH_RISKY.bat
   Quality test. Run if half-res is stable and you want more detail.

7. RUN_55_FULLRES_128MESH_DANGER.bat
   Full-resolution danger test. Run last only; previous builds crashed here.

Optional visual tests after the no-sun baseline is stable:

  RUN_60_HALFRES_128MESH_WITH_SUN.bat
  RUN_61_HALFRES_128MESH_WITH_FALLBACK.bat

Report for each test:
  OK / crash / hang / approximate FPS / visual notes

After the first crash or device-removed event, send rtcwconsole.log.
