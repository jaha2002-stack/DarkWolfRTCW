# DarkWolf RTCW DXR Playable TDR-safe Release Kit

Этот kit переводит DXR-ветку из диагностического режима в играбельный стабильный preset.

## Что исправлено

1. BAT-файлы больше не передают десятки `+set` подряд. Теперь они запускают один `+exec`, а все cvar лежат в `main/*.cfg`. Это исправляет проблему, когда параметры склеивались в одну строку вроде `r_dxrDispatchEveryNFrames 1 +set ...`.

2. Добавлен patch 10:

   `patches/10-dxr-playable-detail-composite-defaults.patch`

   Он меняет low-resolution composite для mode 4 full lighting. Раньше один low-res RT пиксель заливал большой блок на экране, из-за чего картинка становилась квадратной/пиксельной. Теперь full-res albedo/texture detail сохраняется, а low-res DXR используется как lighting/shadow multiplier.

3. Safe DXR defaults ужесточены:

   - `r_dxrFreezeScene 1`
   - `r_dxrForceSafeFullLighting 1`
   - `r_dxrDispatchWidth 128`
   - `r_dxrDispatchHeight 72`
   - `r_dxrMaxDispatchPixels 9216`
   - `r_dxrSafeFullMaxPixels 9216`
   - `r_dxrBuildInterval 9999`
   - `r_dxrMaxWorldMeshes 128`
   - `r_dxrMaxLights 1`
   - `r_dxrShadowSamples 1`
   - `r_dxrAOSamples 0`
   - `r_dxrSkySamples 0`

4. Встроен NoRadiant/MFC build fix для GitHub Actions.

## Как применить

Скопируй содержимое папки `dxr_playable_tdrsafe_release_kit` в корень репозитория и сделай commit.

Через GitHub сайт: Upload files -> Commit changes.

Через Git:

```powershell
git add .
git commit -m "DXR playable TDR-safe release"
git push
```

## Как собрать

Запусти workflow:

`DarkWolf DXR Playable TDRSafe Release`

Artifact:

`DarkWolf-DXR-Playable-TDRSafe-Release`

## Как запускать после установки artifact

1. Сначала один раз:

   `RUN_RESET_SAFE_NO_DXR.bat`

2. Закрыть игру полностью.

3. Основной режим:

   `RUN_PLAY_DXR_TDRSAFE_SMOOTH.bat`

Дополнительно:

- `RUN_PLAY_DXR_TDRSAFE_FAST.bat` — быстрее, мягче, 96x54.
- `RUN_PLAY_ENHANCED_NO_RT_SHADOWS.bat` — гладкий fallback без RT hit-shader shadows.

## Будут ли тени и ray tracing эффекты?

В основном режиме `RUN_PLAY_DXR_TDRSAFE_SMOOTH.bat` используется `r_dxrDispatchMode 4`, то есть полный lighting shader с TraceRay/hit shader включен, но в безопасном ограниченном режиме. Поэтому ожидаются ограниченные RT-lighting/contact-shadow эффекты от малого числа активных lights.

Это не полноценный path tracing и не RTX Remix. Ради стабильности отключены дорогие AO/sky rays, сцена замораживается после первого TLAS, а количество lights и resolution жёстко ограничены.

Если нужен максимально гладкий режим без квадратов и без риска — `RUN_PLAY_ENHANCED_NO_RT_SHADOWS.bat`, но там RT-теней от hit shader нет.
