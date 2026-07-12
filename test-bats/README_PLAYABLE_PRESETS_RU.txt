DarkWolf RTCW DXR Playable TDR-safe presets
===========================================

Запускай только эти BAT-файлы, не старые диагностические RUN_70/RUN_80.
Новые BAT используют main/*.cfg, поэтому параметры больше не склеиваются в одну cvar-строку.

1) RUN_PLAY_DXR_TDRSAFE_SMOOTH.bat
   Основной рекомендуемый режим.
   DXR включен, mode 4 full lighting ограничен 128x72, сцена заморожена после первого TLAS.
   В patch 10 добавлен detail-preserving composite: текстуры остаются full-res, низкое RT-разрешение используется как lighting/shadow multiplier.

2) RUN_PLAY_DXR_TDRSAFE_FAST.bat
   Более быстрый режим 96x54, dispatch раз в 6 кадров, no sync.

3) RUN_PLAY_ENHANCED_NO_RT_SHADOWS.bat
   Полностью smooth fallback без full lighting / hit shader shadows.
   Используй, если хочешь максимальную стабильность и отсутствие любых RT артефактов.

4) RUN_RESET_SAFE_NO_DXR.bat
   Сброс в стабильный режим r_dxr 0.

Рекомендованный первый запуск:
   RUN_RESET_SAFE_NO_DXR.bat
   потом полностью закрыть игру
   RUN_PLAY_DXR_TDRSAFE_SMOOTH.bat
