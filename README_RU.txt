DarkWolfRTCW DXR HalfRes BuildFix - Skip Radiant/MFC
====================================================

Что исправляет:
  Ошибка сборки:
    error MSB8041: MFC libraries are required for this project
    src\tools\radiant\Radiant.vcxproj

Причина:
  Runtime-релиз WolfSP.exe случайно тянет project reference на tools\radiant\Radiant.vcxproj.
  Radiant - это редактор уровней на MFC. Для игрового релиза он не нужен.
  GitHub Actions runner не имеет MFC components, поэтому сборка падает.

Что делает hotfix:
  1) Удаляет ProjectReference на tools\radiant\Radiant.vcxproj из src\wolf.vcxproj.
  2) Обновляет scripts\build-windows-clean-release.ps1:
     - не трогает Radiant при конвертации toolset;
     - перед сборкой повторно удаляет Radiant reference из wolf.vcxproj как страховку.

Как применить:
  Вариант A - просто скопировать файлы:
    Скопируй содержимое этой папки в корень репозитория поверх существующих файлов.
    Commit changes.
    Запусти workflow DarkWolf DXR HalfRes Cache Build заново.

  Вариант B - через patch:
    Скопируй папку patches и scripts в корень репозитория.
    Выполни:
      powershell -ExecutionPolicy Bypass -File scripts\apply-buildfix-no-radiant.ps1
    Commit changes.
    Запусти workflow заново.

Ожидаемый результат:
  В логе больше не должно быть сборки src\tools\radiant\Radiant.vcxproj.
  Ошибка MSB8041 по MFC должна исчезнуть.
