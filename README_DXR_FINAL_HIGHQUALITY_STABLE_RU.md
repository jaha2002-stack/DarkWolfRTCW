# DarkWolf RTCW DXR Final HighQuality Stable Kit

Этот kit является следующим шагом после `DarkWolfRTCW_DXR_Playable_TDRSafe_Release_Kit.zip`.
Он оставляет стабильную TDRSafe-архитектуру, но усиливает картинку и уменьшает заметные
пиксельные квадраты от low-res DXR pass.

## Что делает patch 11

Главный патч:

```text
patches/11-dxr-final-hq-smooth-safe-presets.patch
```

Он добавляет финальный smooth composite для `r_dxrDispatchMode 4`:

- low-res DXR больше не заменяет экран грубыми блоками;
- RT используется как мягкий lighting/contact-shadow multiplier поверх full-res raster картинки;
- вклад RT ослабляется на границах low-res блоков, чтобы убрать видимую сетку;
- цветовой вклад RT ограничен, чтобы не получать фиолетовые/синие/чёрные квадраты;
- default DXR-параметры переведены в более качественный, но всё ещё safe-профиль 160x90.

## Как применить

Скопируй содержимое папки:

```text
dxr_final_highquality_stable_kit
```

в корень репозитория, сделай commit и запусти workflow:

```text
DarkWolf DXR Final HighQuality Stable
```

Artifact должен называться:

```text
DarkWolf-DXR-Final-HighQuality-Stable-Release
```

## Как запускать после сборки

Сначала один раз:

```text
RUN_RESET_SAFE.bat
```

Закрой игру полностью.

Потом основной режим:

```text
RUN_PLAY_FINAL_HIGH_QUALITY.bat
```

Если картинка или FPS не нравятся, попробуй:

```text
RUN_PLAY_FINAL_STABLE.bat
```

Экспериментальный режим:

```text
RUN_PLAY_FINAL_EXPERIMENTAL_DXR_ULTRA.bat
```

Он не является основным. Если он зависает или даёт артефакты, возвращайся к `RUN_PLAY_FINAL_HIGH_QUALITY.bat`.

## Будут ли RT-эффекты

Да, в режимах `FINAL_STABLE`, `FINAL_HIGH_QUALITY` и `EXPERIMENTAL_DXR_ULTRA` используется:

```text
r_dxrDispatchMode 4
```

Это full lighting shader с TraceRay/hit shader, но в безопасном TDRSafe-варианте:

- frozen scene / TLAS reuse;
- no runtime BLAS/TLAS rebuild;
- capped dispatch resolution;
- limited lights;
- no AO/sky rays по умолчанию;
- sun/contact-shadow contribution включён осторожно.

Это не RTX Remix и не full path tracing. Эффекты должны быть видимее, чем в Playable TDRSafe, но всё ещё ограничены ради стабильности.
