# DarkWolf RTCW DXR TDR-safe Runtime Fix Kit

Этот kit сделан после твоего последнего лога, где даже quarter-res full lighting упал:

```text
DXR HALFRES: DispatchRays mode=4 size=213x120 output=853x480 scale=0.25
DXR DEVICE LOST: CreateCommittedResource failed 0x887A0005, removedReason=0x887A0006
```

`removedReason=0x887A0006` означает DEVICE_HUNG: GPU завис на предыдущей DXR-работе, а следующий D3D12 resource creation только первым увидел уже потерянное устройство.

## Что исправляет patch 09

Главный патч:

```text
patches/09-dxr-tdr-safe-runtime-freeze.patch
```

Он добавляет TDR-safe режим:

```cfg
r_dxrFreezeScene
r_dxrDispatchEveryNFrames
r_dxrForceSafeFullLighting
r_dxrSafeFullMaxPixels
```

Практически:

1. После первого валидного TLAS сцена замораживается:
   BLAS/TLAS больше не пересобираются каждый кадр и не создают новые D3D12 resources во время игры.

2. Full lighting mode 4 жёстко ограничивается по пикселям:
   старые значения `r_dxrMaxDispatchPixels 120000/240000` больше не могут случайно запустить опасный 213x120 или fullscreen pass.

3. Full lighting вызывается не каждый кадр:
   `r_dxrDispatchEveryNFrames 4/8` снижает риск TDR и нагрузку.

4. В test-bats есть ультрабезопасный запуск:
   `RUN_70_TDRSAFE_FULL_64x36_ULTRASAFE.bat`

## Как применить

Скопируй содержимое папки kit в корень репозитория.

Потом:
```powershell
git add .
git commit -m "DXR TDR-safe runtime fix"
```

Запусти workflow:

```text
DarkWolf DXR TDRSafe Runtime Build
```

Artifact:

```text
DarkWolf-DXR-TDRSafe-Runtime-Release
```

## С чего начинать тест

После установки релиза запускай только:

```text
RUN_70_TDRSAFE_FULL_64x36_ULTRASAFE.bat
```

Если он стабилен несколько минут, тогда:
```text
RUN_71_TDRSAFE_FULL_96x54_SAFE.bat
RUN_72_TDRSAFE_FULL_128x72_CAUTIOUS.bat
```

Если даже RUN_70 виснет/падает, запускай:
```text
RUN_80_TDRSAFE_GBUFFER_FULLSCREEN_STABLE.bat
```

Тогда вывод будет честный: текущий full lighting closest-hit shader непригоден для твоего GPU/драйвера и его надо переписывать, а не просто уменьшать resolution.
