# DarkWolfRTCW PVS Hotfix Kit

Этот kit добавляет отдельный патч для исправления крашей в `DecompressVis` / area visibility на x64.

## Что исправляет патч

Файл: `src/botlib/be_aas_route.cpp`

Патч делает три вещи:

1. Исправляет x64-ошибку pointer arithmetic в `AAS_DecompressVis`, где конец буфера считался через `(int)decompressed + numareas`.
2. Добавляет защиту от битых VIS-рядов (`0 repeat` и overflow repeat) без фатального падения игры.
3. Поднимает `RCVERSION` с 15 до 16, чтобы старые route cache (`*.rcd`) автоматически считались устаревшими и были пересозданы.

## Как использовать

Загрузи содержимое этого архива в корень репозитория так, чтобы появились:

- `patches/03-pvs-decompressvis-x64.patch`
- `scripts/apply-pvs-hotfix.ps1`
- `scripts/apply-pvs-hotfix.sh`
- `.github/workflows/darkwolf-pvs-hotfix-build.yml`
- `README_PVS_HOTFIX_RU.md`

После этого открой GitHub Actions и запусти workflow:

`DarkWolf PVS Hotfix Build`

Параметры:

- `configuration = Release`

## Что тестировать после сборки

### 1. Проверка стабильности без DXR

```cfg
\vid_restart
\spdevmap escape1
\seta r_novis 0
\seta r_dxr 0
```

Если карта больше не падает, значит PVS hotfix сработал.

### 2. Проверка DXR отдельно

```cfg
\seta r_dxr 1
\seta r_dxrFallbackLight 0
\seta r_dxrShadowBias 0.02
\vid_restart
\spdevmap escape1
```

### 3. Если DXR стартует, проверить тени с мягким fallback light

```cfg
\seta r_dxr 1
\seta r_dxrFallbackLight 1
\seta r_dxrFallbackLightRadius 400
\seta r_dxrFallbackLightIntensity 2
\seta r_dxrShadowBias 0.02
\vid_restart
\spdevmap escape1
```

## Что прислать дальше

Если после этого патча:

- игра перестанет падать при `r_dxr 0`, но всё ещё будет падать при `r_dxr 1` — нужен уже отдельный DXR stability patch;
- игра всё ещё будет падать при `r_dxr 0` — пришли новый `qconsole.log`, это значит что кроме PVS есть ещё один независимый краш.
