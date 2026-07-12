DarkWolf RTCW DXR Final HighQuality Stable presets
==================================================

Recommended order after copying the artifact into D:\DarkWolf:

1. RUN_RESET_SAFE.bat
2. Close the game completely.
3. RUN_PLAY_FINAL_HIGH_QUALITY.bat

Preset summary:

RUN_PLAY_FINAL_STABLE.bat
  Safest playable DXR preset. Uses 128x72 full-lighting pass, frozen TLAS,
  limited lights, safe sun shadow contribution, and smooth detail composite.

RUN_PLAY_FINAL_HIGH_QUALITY.bat
  Main recommended mode. Uses 160x90 full-lighting pass, stronger RT lighting
  multiplier, low sun/contact-shadow contribution, no full-res dispatch, and
  no runtime BLAS/TLAS rebuild.

RUN_PLAY_FINAL_EXPERIMENTAL_DXR_ULTRA.bat
  Experimental only. Uses 192x108, more meshes/lights and stronger RT settings.
  It is intentionally not the main launch mode.

RUN_RESET_SAFE.bat
  Resets to stable non-DXR renderer and safe archived DXR values.

This kit avoids the old pixel-square look by using RT as a smooth lighting
multiplier over full-resolution raster detail, rather than replacing the screen
with low-resolution DXR blocks.
