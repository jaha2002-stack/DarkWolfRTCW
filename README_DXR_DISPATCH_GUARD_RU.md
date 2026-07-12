# DarkWolfRTCW DXR DispatchRays Isolation / Raygen Guard Hotfix Kit

Этот kit продолжает Safe Mode / Device Removed Hotfix и изолирует точку падения `DispatchRays`.

Предыдущие тесты показали:

- `r_dxr 0` стабилен.
- DXR init без BLAS/TLAS/DispatchRays стабилен.
- BLAS + TLAS без DispatchRays стабилен, но медленный.
- Первый реальный `DispatchRays` сразу вызывает `0x887A0005`.

Значит этот kit добавляет диагностику именно вокруг raygen/SBT/UAV/DispatchRays.

## Что добавляет patch 07

Новые cvars:

```cfg
r_dxrDispatchMode
r_dxrDispatchWidth
r_dxrDispatchHeight
r_dxrDispatchScale
r_dxrValidateSBT
r_dxrValidateUAV
```

`r_dxrDispatchMode`:

```text
0 = подготовить descriptors, но не вызывать DispatchRays
1 = DispatchRays, raygen пишет constant color, TraceRay не вызывается
2 = DispatchRays, raygen копирует G-buffer albedo, TraceRay не вызывается
3 = DispatchRays + один miss-only TraceRay
4 = полный старый lighting shader
```

Также добавлен soft-path для `gl_d3d12shim.cpp`: если после DXR device lost обычный QD3D12 код получает `DXGI_ERROR_DEVICE_REMOVED`, он не должен сразу показывать fatal dialog; он пробует пометить DXR как device-lost и дать renderer продолжить без DXR.

## Как применить

Залей содержимое папки `dxr_dispatch_guard_kit` в корень репозитория.

Запусти workflow:

```text
DarkWolf DXR Dispatch Guard Build
```

Artifact:

```text
DarkWolf-DXR-Dispatch-Guard-Release
```

## BAT тесты

BAT файлы лежат в `test-bats/` и также копируются в `dist/` artifact рядом с `WolfSP.exe`.

Запускать двойным кликом. Между тестами полностью закрывать игру.

Порядок:

```text
RUN_00_SAFE_NO_DXR.bat
RUN_01_DXR_INIT_ONLY_NO_BLAS.bat
RUN_02_DXR_TLAS_NO_DISPATCH_128.bat
RUN_10_DISPATCH_MODE0_SKIP_128.bat
RUN_11_DISPATCH_CONSTANT_1x1.bat
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
```

Не надо доходить до конца, если один тест уже упал. После первого сбоя прислать `rtcwconsole.log`.

## Как интерпретировать

- `CONSTANT_1x1` падает: проблема в pipeline/SBT/UAV/самом `DispatchRays` до `TraceRay`.
- constant работает, gbuffer падает: проблема в SRV descriptors / texture states.
- gbuffer работает, miss-only падает: проблема в `TraceRay` или miss table.
- miss-only работает, full падает: проблема в hit group / closest-hit / полном lighting shader.
- маленькие размеры работают, fullscreen падает: проблема в размере dispatch или стоимости shader.

