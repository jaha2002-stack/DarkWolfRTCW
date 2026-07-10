# DarkWolf DXR Visibility + Debug patch kit

Этот kit рассчитан на репозиторий, в котором уже есть:
- DXR stable patch
- PVS / DecompressVis hotfix

## Что меняет патч

- делает DXR-картинку заметно светлее за счёт сохранения части оригинального RTCW lighting
- добавляет управляемый blend между исходной картинкой и ray traced lighting
- добавляет post exposure для DXR-прохода
- делает fallback light всегда активным, когда `r_dxrFallbackLight 1`
- усиливает fallback light по умолчанию
- ослабляет чрезмерно тёмный cavity / AO вклад
- добавляет debug mode для проверки, что DXR реально участвует в кадре
- добавляет периодический лог DXR-состояния в консоль

## Новые cvar

- `r_dxrAmbientIntensity` — общий ambient lift для DXR, default `1.35`
- `r_dxrLegacyBlend` — сколько оригинального RTCW shading сохранить, default `0.65`
  - `0.0` = почти чистый DXR lighting
  - `1.0` = почти исходная RTCW картинка
- `r_dxrExposure` — пост-экспозиция DXR-результата, default `1.15`
- `r_dxrDebug` — писать DXR-состояние в консоль раз в секунду
- `r_dxrDebugMode`
  - `0` normal
  - `1` lighting only
  - `2` occlusion / visibility
  - `3` original albedo / scene color
  - `4` lighting heatmap

## Рекомендуемый первый тест

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

## Если всё ещё слишком темно

```cfg
\seta r_dxrAmbientIntensity 1.8
\seta r_dxrLegacyBlend 0.75
\seta r_dxrExposure 1.35
\seta r_dxrFallbackLightIntensity 8
\vid_restart
```

## Для проверки, что трассировка реально работает

```cfg
\seta r_dxrDebugMode 1
\vid_restart
```

Если видишь отдельную «lighting only» картину, значит DXR path реально участвует в кадре.

## Как собрать через GitHub Actions

1. Залей содержимое этого архива в корень репозитория.
2. Сделай Commit changes.
3. Открой вкладку Actions.
4. Запусти workflow `DarkWolf DXR Visibility Debug Build`.
5. Выбери `Release`.
