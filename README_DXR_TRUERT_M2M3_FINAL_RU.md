# DarkWolf RTCW DXR TrueRT M2/M3 Final Visual Restore Kit

Цель kit-а: вернуть заметный DXR-look из старого Clean Release, но оставить TDRSafe-стабильность новых релизов.

Это не очередной safe preset. Главный новый patch:

```text
patches/13-dxr-truert-m2m3-material-temporal-visual-restore.patch
```

## Что добавляет patch 13

- M2 Visual Restore: сильнее RT contribution, specular, reflection, contact shadows.
- M2 Material Buffer: per-mesh material-lite table, материал привязан к InstanceID в TLAS.
- M2 Radiance closest-hit shader: reflection/GI rays теперь используют отдельный closest-hit, а не только shadow/miss visibility.
- M3 History texture: отдельная D3D12 history texture для temporal accumulation.
- M3 Temporal accumulation: сглаживает RT shimmer/noise по истории кадра.
- M3 Spatial denoise: лёгкое 3x3 сглаживание RT/composite без грубого замыливания full-res текстур.
- M3 Sky/GI rays: дополнительный visibility/material bounce вклад.
- Более агрессивный, но bounded composite: сохраняет резкость raster-текстур и усиливает RT-свет/тени без старых больших квадратов.

## Новые cvars

```text
r_dxrRTStrength
r_dxrSpecularStrength
r_dxrReflectionStrength
r_dxrShadowStrength
r_dxrDenoiseStrength
r_dxrTemporalStrength
r_dxrGIStrength
```

## Режимы запуска

Основной режим:

```text
RUN_PLAY_FINAL_HIGH_QUALITY.bat
```

Безопасный режим:

```text
RUN_PLAY_FINAL_STABLE.bat
```

Сильный экспериментальный режим:

```text
RUN_PLAY_FINAL_EXPERIMENTAL_DXR_ULTRA.bat
```

Сброс:

```text
RUN_RESET_SAFE.bat
```

## Как применять

1. Распаковать kit.
2. Скопировать содержимое папки `dxr_truert_m2m3_final_kit` в корень репозитория.
3. Сделать commit.
4. Запустить workflow:

```text
DarkWolf DXR TrueRT M2M3 Final
```

Artifact:

```text
DarkWolf-DXR-TrueRT-M2M3-Final-Release
```

## Важное честное ограничение

Material Buffer в M2 — это material-lite таблица, привязанная к RT mesh/InstanceID. Она уже даёт radiance closest-hit response для отражений/GI, но это ещё не полноценный texture descriptor table со чтением всех оригинальных RTCW shader textures внутри closest-hit. Для настоящего per-triangle texture fetch понадобится отдельный M4/M5 этап: экспорт surface shader/texture IDs, bindless descriptor heap или atlas, UV/material indirection table.

Но этот kit должен вернуть то, чего не хватало после TDRSafe/M1: видимые RT тени, specular, reflection/GI вклад и более похожую на ray tracing картинку.

## BuildFix 14

В эту версию добавлен `patches/14-dxr-m2m3-material-constant-buildfix.patch`.
Он исправляет ошибку компиляции `GL_RAYTRACING_MAX_MATERIALS: undeclared identifier` в `gl_d3d12raylight.cpp`.
