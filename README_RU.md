# DarkWolf RTCW DXR Patch Kit

Набор подготовлен под текущую структуру репозитория `DarkWolfRTCW-main` из загруженного архива. Внутри два независимых патча, скрипты применения и отдельный GitHub Actions workflow для сборки на Windows runner.

## Что внутри

```text
patches/
  01-dxr-minimal-visibility.patch
  02-dxr-stable-mode.patch
scripts/
  apply-selected.ps1
  apply-minimal.ps1
  apply-stable.ps1
  build-windows.ps1
  apply-minimal.sh
  apply-stable.sh
.github/workflows/
  darkwolf-dxr-build.yml
README_RU.md
```

## Какой патч выбрать

`01-dxr-minimal-visibility.patch` — минимальный hotfix. Он не добавляет новых cvar-переключателей и старается меньше менять поведение игры. Исправляет основные причины, из-за которых DXR-результат мог не появляться в кадре: пустые fence wait-функции, преждевременное копирование результата прямо в backbuffer, неверное состояние lighting texture, слишком большой shadow bias, отсутствие нормалей/UV у динамических DXR-мешей, а также добавляет гарантированный DXR pass в конце 3D-вида, если в кадре не было transparent batch.

`02-dxr-stable-mode.patch` — стабильный диагностический вариант. Он включает всё из минимального патча, плюс добавляет проверку DXR tier, синхронное ожидание DXR dispatch, cvar-переключатель `r_dxr`, cvar `r_dxrShadowBias`, и опциональный тестовый camera-side light через `r_dxrFallbackLight`. Этот вариант лучше для первого теста на реальном ПК.

Патчи независимые. На чистый checkout применяй **либо 01, либо 02**, не оба подряд. В GitHub Actions workflow это уже учтено через параметр `patch_variant`.

## Быстрый путь через GitHub Actions

1. Распакуй содержимое этого zip **в корень репозитория** `DarkWolfRTCW`.
2. Закоммить и отправь файлы kit-а в GitHub:

```powershell
git add patches scripts .github/workflows/darkwolf-dxr-build.yml README_RU.md
git commit -m "Add DXR patch kit"
git push
```

3. Открой GitHub → вкладка **Actions** → workflow **DarkWolf DXR Patch Build**.
4. Нажми **Run workflow**.
5. Выбери:
   - `patch_variant: stable` для стабильной версии;
   - `patch_variant: minimal` для минимального hotfix;
   - `configuration: Release`.
6. После сборки скачай artifact вида `DarkWolf-DXR-stable-Release`.

Workflow делает следующее: применяет выбранный patch к checkout, конвертирует toolset `v145` → `v143`, собирает нужные `.vcxproj` через MSBuild, не собирает Radiant, и складывает результат в `dist/`.

## Ручное применение локально

Из корня репозитория:

```powershell
pwsh scripts/apply-stable.ps1
pwsh scripts/build-windows.ps1 -Configuration Release
```

Для минимального варианта:

```powershell
pwsh scripts/apply-minimal.ps1
pwsh scripts/build-windows.ps1 -Configuration Release
```

Через Git Bash только применить patch:

```bash
./scripts/apply-stable.sh
# или
./scripts/apply-minimal.sh
```

## Как проверить, что ray tracing реально виден

Для стабильного патча рекомендую первый запуск с тестовым fallback light. В консоли игры:

```text
\seta r_dxr 1
\seta r_dxrFallbackLight 1
\seta r_dxrFallbackLightRadius 500
\seta r_dxrFallbackLightIntensity 3
\seta r_dxrShadowBias 0.05
\vid_restart
```

Этот свет специально добавляется только если в текущем кадре нет других DXR lights. Он нужен для диагностики: рядом со стенами, колоннами, лестницами и NPC/моделями должны появиться заметные мягкие тени. После проверки можно вернуть:

```text
\seta r_dxrFallbackLight 0
\vid_restart
```

## Что именно исправлено в коде

Основные изменения:

- `glRaytracingWaitFenceValue()` и `glRaytracingWaitIdle()` теперь реально ждут GPU fence.
- BLAS/TLAS build больше не считается готовым до завершения fence.
- `glRaytracingLightingExecute()` больше не копирует DXR output напрямую в swap-chain backbuffer. Результат остаётся в lighting texture, а shim композитит его штатно.
- `glLightScene()` сначала flush-ит queued OpenGL/D3D12 batches, потом строит scene AS, чтобы TLAS видел актуальную геометрию.
- Состояние `g_lightingTextureState` после DXR dispatch исправлено на `D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE`.
- `shadowBias` снижен с `1.5f` до `0.05f`, иначе тени легко “отрываются” или исчезают.
- В `RB_UpdateDXRMesh()` добавлены normal/UV, включены `allowUpdate` и `opaque`, убран общий `cachedFrame`, который мог пропускать несколько surfaces одного entity в одном кадре.
- Добавлен fallback DXR pass в конце 3D-render list, если старый hook перед transparent pass не сработал.
- В stable-патче добавлены cvars и синхронный режим выполнения DXR dispatch для валидации.

## Важное ограничение

Я проверил, что оба patch-файла чисто применяются к загруженному исходнику. Полную MSVC/D3D12-сборку в этой среде я не запускал, потому что здесь нет Windows/MSBuild/D3D12 SDK runtime. Поэтому workflow сделан так, чтобы сборка выполнялась уже в GitHub Actions на `windows-2022`.

## Если patch уже применён

Скрипт `apply-selected.ps1` умеет распознавать уже применённый patch. В workflow можно также выбрать `patch_variant: none`, если ты заранее закоммитишь изменённый исходный код, а не только patch kit.

Для отката вручную:

```powershell
git apply --reverse patches/02-dxr-stable-mode.patch
# или
git apply --reverse patches/01-dxr-minimal-visibility.patch
```
