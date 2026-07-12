# DarkWolf RTCW DXR Half-Resolution Full Lighting + Performance Cache Kit

Этот kit основан на предыдущем `DXR DispatchRays Isolation / Raygen Guard` и добавляет следующий слой оптимизации после твоих тестов.

Твои результаты показали:

- DXR init работает.
- BLAS работает, но дорогой.
- TLAS работает, но дорогой.
- DispatchRays работает в constant / gbuffer / miss-only / small full modes.
- Full lighting fullscreen падает или становится неприемлемо тяжёлым.

Поэтому этот kit делает две вещи:

1. **Half-resolution full lighting**: полный DXR lighting shader запускается не на весь fullscreen, а на уменьшенное разрешение (`r_dxrRenderScale`).
2. **Block composite**: каждый низкоразрешённый DXR ray заполняет соответствующий блок полного output texture, чтобы картинка не была чёрной/маленькой как в диагностических тестах.
3. **TLAS/BLAS cache interval**: valid TLAS можно переиспользовать несколько кадров (`r_dxrBuildInterval`), чтобы уменьшить лаги даже в no-dispatch/TLAS режимах.
4. **Dispatch pixel cap**: `r_dxrMaxDispatchPixels` ограничивает максимум пикселей для `DispatchRays`, чтобы не уйти обратно в fullscreen crash/TDR.

## Новые cvars

```cfg
r_dxrRenderScale 0.50
```
Внутренний масштаб full lighting pass. Рекомендуемые значения:

- `0.25` — safest / quarter-res
- `0.50` — рекомендуемый первый режим
- `0.75` — качество выше, риск выше
- `1.00` — full-res, на текущих тестах риск crash

```cfg
r_dxrMaxDispatchPixels 240000
```
Жёсткий лимит размера DispatchRays. Если рассчитанный dispatch больше лимита, он автоматически уменьшается.

```cfg
r_dxrCompositeBlocks 1
```
Заполняет весь full output texture блоками из low-res DXR rays. Без этого half-res будет виден только в левом верхнем углу.

```cfg
r_dxrBuildInterval 2
```
Переиспользует уже построенный TLAS несколько кадров, если он валиден. `1` отключает кэширование.

## Как применить

Скопируй содержимое папки `dxr_halfres_cache_kit` в корень репозитория и сделай commit.

Затем запусти workflow:

```text
DarkWolf DXR HalfRes Cache Build
```

Artifact:

```text
DarkWolf-DXR-HalfRes-Cache-Release
```

## Как тестировать

После сборки BAT-файлы попадут в artifact рядом с `WolfSP.exe`.

Запускай в таком порядке:

```text
RUN_00_SAFE_NO_DXR.bat
RUN_50_HALFRES_128MESH_STABLE.bat
RUN_51_QUARTERRES_128MESH_SAFE.bat
RUN_52_HALFRES_512MESH.bat
RUN_53_HALFRES_1024MESH.bat
RUN_54_SCALE_075_128MESH_RISKY.bat
RUN_55_FULLRES_128MESH_DANGER.bat
```

Дополнительные визуальные тесты:

```text
RUN_60_HALFRES_128MESH_WITH_SUN.bat
RUN_61_HALFRES_128MESH_WITH_FALLBACK.bat
```

Между тестами полностью закрывай игру.

## Главная цель этого kit

Первый успешный целевой режим:

```cfg
r_dxrRenderScale 0.50
r_dxrMaxDispatchPixels 240000
r_dxrCompositeBlocks 1
r_dxrBuildInterval 2
r_dxrMaxWorldMeshes 128
r_dxrMaxLights 4
r_dxrShadowSamples 1
r_dxrAOSamples 0
r_dxrSkySamples 0
```

Если он стабилен, можно увеличивать `r_dxrMaxWorldMeshes` до 512/1024 и потом пробовать `r_dxrRenderScale 0.75`.

Если даже `0.25` / 128 meshes слишком медленно, значит следующий шаг — уже не half-res, а более радикальный path: temporal checkerboard, async dispatch, delayed build queue или отключение static BSP mesh tracing в пользу screen-space contact shadows.
