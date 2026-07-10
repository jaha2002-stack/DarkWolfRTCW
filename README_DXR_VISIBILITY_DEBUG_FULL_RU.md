# DarkWolf RTCW DXR Visibility Debug Full Kit

Этот kit исправляет ошибку применения прошлого visibility/debug патча.

Причина прошлой ошибки: `04-dxr-visibility-debug.patch` был **инкрементальным** и ожидал, что в исходниках уже есть:
- build hotfix для `Com_Printf`
- DXR stable patch
- PVS hotfix

Этот full kit сам применяет весь стек в правильном порядке:
1. `00-build-fix-Com_Printf.patch`
2. `02-dxr-stable-mode.patch`
3. `03-pvs-decompressvis-x64.patch`
4. `04-dxr-visibility-debug.patch`

## Как использовать

Залей содержимое архива в корень репозитория и запусти workflow:

`DarkWolf DXR Visibility Debug Full Build`

## Базовые команды после сборки

```cfg
\seta r_dxr 1
\seta r_dxrFallbackLight 1
\seta r_dxrFallbackLightRadius 900
\seta r_dxrFallbackLightIntensity 6
\seta r_dxrAmbientIntensity 1.35
\seta r_dxrLegacyBlend 0.65
\seta r_dxrExposure 1.15
\seta r_dxrShadowBias 0.02
\seta r_dxrDebug 1
\seta r_dxrDebugMode 0
\vid_restart
\spdevmap escape1
```
