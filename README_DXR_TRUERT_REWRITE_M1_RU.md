# DarkWolf RTCW DXR TrueRT Renderer Rewrite M1 Kit

Это первый глубокий шаг от TDRSafe/имитационного режима к настоящему RT-runtime.

Важно: это **не финальная полная RTX Remix/path tracing реализация**. Полный closest-hit material shader с настоящими texture descriptors, material table, dynamic-only TLAS и temporal denoiser требует отдельного большого этапа M2/M3. M1 делает безопасный базис, который можно реально собрать и проверить сейчас.

## Что реально добавляет M1

- Более видимый RT-вклад без опасного full-res DispatchRays.
- Real TLAS reflection/GI visibility ray: shader трассирует отражённый луч через TLAS и добавляет отражённый/sky GI вклад.
- Более сильные RT contact shadows и sun shadow contribution.
- Более заметные AO/sky rays через cfg preset.
- Сглаженный full-resolution composite: low-res RT не должен грубо заменять текстуру пиксельными блоками.
- Основной режим HIGH_QUALITY работает без full-res dangerous dispatch.

## BAT-файлы после сборки

- `RUN_PLAY_FINAL_STABLE.bat` — самый безопасный RT-режим.
- `RUN_PLAY_FINAL_HIGH_QUALITY.bat` — основной рекомендуемый режим.
- `RUN_PLAY_FINAL_EXPERIMENTAL_DXR_ULTRA.bat` — более тяжёлый режим для проверки качества.
- `RUN_RESET_SAFE.bat` — сброс в безопасный non-DXR режим.

## Как применять

Скопировать содержимое папки `dxr_truert_rewrite_m1_kit` в корень репозитория, сделать commit и запустить workflow:

`DarkWolf DXR TrueRT Rewrite M1`

Artifact:

`DarkWolf-DXR-TrueRT-Rewrite-M1-Release`

## Что тестировать

1. `RUN_RESET_SAFE.bat`, закрыть игру.
2. `RUN_PLAY_FINAL_HIGH_QUALITY.bat`.
3. Если стабильно 15 минут — попробовать `RUN_PLAY_FINAL_EXPERIMENTAL_DXR_ULTRA.bat`.

## Честное ограничение M1

M1 ещё не содержит полноценный per-hit material/texture lookup. Он добавляет настоящий reflection/GI visibility ray и усиливает RT-вклад, но full material closest-hit shader с отдельным triangle/material buffer будет следующим большим этапом.
