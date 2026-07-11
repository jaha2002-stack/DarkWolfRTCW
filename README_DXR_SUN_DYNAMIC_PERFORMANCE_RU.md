# DarkWolfRTCW DXR Sun + Dynamic Lights + Performance Kit

Этот kit накатывает полный рабочий стек исправлений и добавляет пятый патч:

1. `00-build-fix-Com_Printf.patch`
2. `02-dxr-stable-mode.patch`
3. `03-pvs-decompressvis-x64.patch`
4. `04-dxr-visibility-debug.patch`
5. `05-dxr-sun-dynamic-performance.patch`

## Что нового в 05-патче

- Ограничение числа активных DXR lights около камеры.
- Сортировка lights по расстоянию/силе, чтобы ближайшие факелы/вспышки попадали в DXR первыми.
- Сильно уменьшенное число shadow rays в играбельных режимах.
- Отключаемые AO/sky visibility rays для FPS.
- Асинхронный DXR dispatch по умолчанию (`r_dxrSync 0`), чтобы не блокировать CPU каждый кадр.
- Ручной directional sun light с ray traced shadow:
  - `r_dxrSunEnable`
  - `r_dxrSunIntensity`
  - `r_dxrSunPitch`
  - `r_dxrSunYaw`
  - `r_dxrSunColor`
  - `r_dxrSunShadowStrength`
- Защита от спама `R_AddMDCSurfaces: no such frame...` в developer/logfile режиме.

## Как применить

Залей содержимое этого архива в корень репозитория и запусти workflow:

`DarkWolf DXR Sun Dynamic Performance Build`

Artifact должен называться примерно:

`DarkWolf-DXR-Sun-Dynamic-Performance-Release`

Скопируй содержимое artifact в папку игры поверх текущего runtime.

## Играбельный FPS-пресет

```cfg
\seta developer 0
\seta logfile 0
\seta r_dxr 1
\seta r_dxrDebug 0
\seta r_dxrDebugMode 0
\seta r_dxrPerfPreset 1
\seta r_dxrFallbackLight 0
\seta r_dxrAmbientIntensity 1.45
\seta r_dxrLegacyBlend 0.78
\seta r_dxrExposure 1.20
\seta r_dxrShadowBias 0.03
\seta r_dxrSunEnable 1
\seta r_dxrSunIntensity 0.45
\seta r_dxrSunPitch 42
\seta r_dxrSunYaw 135
\seta r_dxrSunColor "1.0 0.92 0.78"
\seta r_dxrSunShadowStrength 0.55
\vid_restart
\spdevmap escape1
```

## Более красивая, но тяжелее

```cfg
\seta r_dxrPerfPreset 2
\seta r_dxrSunIntensity 0.65
\seta r_dxrSunShadowStrength 0.65
\vid_restart
```

## Скриншотный режим

```cfg
\seta r_dxrPerfPreset 3
\seta r_dxrFallbackLight 1
\seta r_dxrFallbackLightRadius 650
\seta r_dxrFallbackLightIntensity 3
\vid_restart
```

## Custom режим

Если хочешь ручную настройку:

```cfg
\seta r_dxrPerfPreset 0
\seta r_dxrMaxLights 8
\seta r_dxrShadowSamples 1
\seta r_dxrAOSamples 0
\seta r_dxrSkySamples 0
\seta r_dxrSync 0
\vid_restart
```

Для сравнения качества можно временно включить:

```cfg
\seta r_dxrDebug 1
```

Но для игры держи `developer 0`, `logfile 0`, `r_dxrDebug 0`, иначе логирование само по себе может создавать лаги.
