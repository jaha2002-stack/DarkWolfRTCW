DarkWolfRTCW DXR TrueRT M2/M3 Final BuildFix

Что исправлено:
- Ошибка компиляции gl_d3d12raylight.cpp:
  GL_RAYTRACING_MAX_MATERIALS undeclared identifier
  glRaytracingClamp: expects 3 arguments - 2 provided

Причина:
- В patch 13 лимит material table был объявлен ниже функции glRaytracingBuildInstanceDesc(),
  а эта функция уже использовала GL_RAYTRACING_MAX_MATERIALS для InstanceID/material lookup.

Исправление:
- patch 14 переносит static const uint32_t GL_RAYTRACING_MAX_MATERIALS = 8192u;
  выше glRaytracingBuildInstanceDesc() и удаляет поздний дубликат.

Как применять:
1. Распакуй этот kit.
2. Скопируй содержимое папки dxr_truert_m2m3_final_buildfix_kit в корень репозитория.
3. Подтверди замену scripts/apply-dxr-truert-m2m3-final.ps1 и .sh.
4. Commit changes.
5. Запусти workflow: DarkWolf DXR TrueRT M2M3 Final.

Важно:
- Это compile hotfix. Графические настройки M2/M3 не урезались.
- После сборки тестировать сначала RUN_PLAY_FINAL_HIGH_QUALITY.bat,
  затем RUN_PLAY_FINAL_EXPERIMENTAL_DXR_ULTRA.bat.
