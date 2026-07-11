# DarkWolfRTCW DXR Safe Mode / Device Removed Hotfix Kit

Этот kit создан после лога, где минимальный DXR-тест зависал и лог разрастался из-за миллионов строк:

- `CreateCommittedResource failed 0x887A0005`
- `Map failed 0x887A0005`

`0x887A0005` — это D3D12/DXGI device removed/hung/reset. Главная цель этого kit: не сделать картинку красивее, а не дать игре зависать намертво и разделить проблему на этапы:

1. resource creation / BLAS,
2. TLAS,
3. DispatchRays / raygen shader,
4. слишком большое число BSP world meshes.

## Что добавляет patch 06

Новые cvars:

```cfg
r_dxrSafeMode 1
r_dxrNoBuildBLAS 0
r_dxrNoBuildTLAS 0
r_dxrNoDispatch 0
r_dxrMaxWorldMeshes 0
r_dxrErrorLimit 8
```

Поведение:

- при первом `DXGI_ERROR_DEVICE_REMOVED`, `DXGI_ERROR_DEVICE_RESET` или `DXGI_ERROR_DEVICE_HUNG` DXR ставит внутренний флаг `device lost`;
- дальнейшие `CreateCommittedResource`, `Map`, BLAS/TLAS и DispatchRays не повторяются бесконечно;
- renderer принудительно выставляет `r_dxr 0`, чтобы не виснуть каждый кадр;
- лог ограничивается, вместо миллионов строк;
- fence wait в safe mode имеет timeout, чтобы не висеть бесконечно;
- `r_dxrNoBuildBLAS`, `r_dxrNoBuildTLAS`, `r_dxrNoDispatch` позволяют выяснить точку падения;
- `r_dxrMaxWorldMeshes` ограничивает число BSP RT meshes, например до 512/2048.

Также `r_dxr` теперь по умолчанию `0`, чтобы новый build не уходил в boot-loop после запуска.

## Как применить через GitHub

Залей содержимое архива в корень репозитория и сделай Commit changes. Скрипт применения умеет два режима: если предыдущий Sun/Dynamic/Performance stack уже есть в ветке, он применит только patch 06; если ветка чистая, он применит полный stack 00-06.

Потом запусти workflow:

```text
DarkWolf DXR Safe Mode Hotfix Build
```

Artifact должен называться примерно:

```text
DarkWolf-DXR-Safe-Mode-Hotfix-Release
```

Содержимое artifact скопируй в папку игры поверх текущего runtime.

## Как тестировать

Скопируй файлы из папки `cfg/` в папку игры:

```text
D:\DarkWolf\main\
```

Сначала проверь стабильный режим:

```cfg
\exec dxr_test_reset_stable.cfg
```

Потом выполняй тесты строго по порядку. После каждого зависания/вылета пришли `rtcwconsole.log` и `qconsole.log`.

### Test 01: no BLAS

```cfg
\exec dxr_test_01_noblas.cfg
```

Если стабильно — DXR init и CPU BSP mesh registration живы.
Если зависает даже тут — проблема раньше BLAS, в DXR init или renderer restart path.

### Test 02: no TLAS

```cfg
\exec dxr_test_02_notlas.cfg
```

Если зависает тут — проблема вероятно в BLAS/resource creation/BLAS command execution.

### Test 03: no DispatchRays

```cfg
\exec dxr_test_03_nodispatch.cfg
```

Если Test 02 стабилен, а Test 03 зависает — проблема вероятно в TLAS build или descriptor/resource setup.

### Test 04: DispatchRays with 512 meshes

```cfg
\exec dxr_test_04_dispatch_512.cfg
```

Если Test 03 стабилен, а Test 04 зависает — проблема почти наверняка в DispatchRays/raygen shader path.

### Test 05: DispatchRays with 2048 meshes

```cfg
\exec dxr_test_05_dispatch_2048.cfg
```

Запускать только если Test 04 стабилен. Если 512 стабильно, а 2048 нет — главный фактор количество BSP RT geometry.

## Важно

После device removed этот build должен не зависать бесконечно, а записать строку вида:

```text
DXR DEVICE LOST: ... removedReason=0x........
DXR SAFE: D3D12 device was lost; forcing r_dxr 0
```

После такой ошибки перед следующим DXR-тестом лучше перезапустить игру, потому что D3D12 device после device removed считается потерянным.
