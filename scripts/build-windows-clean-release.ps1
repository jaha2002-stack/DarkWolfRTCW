[CmdletBinding()]
param(
    [ValidateSet('Release', 'Debug')]
    [string]$Configuration = 'Release',

    [ValidateSet('x64')]
    [string]$Platform = 'x64',

    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Convert-ToolsetToVs2022 {
    Get-ChildItem -Path $RepoRoot -Recurse -Filter *.vcxproj |
        Where-Object { $_.FullName -notmatch '\\src\\tools\\radiant\\' } |
        ForEach-Object {
            $content = Get-Content -LiteralPath $_.FullName -Raw
            $updated = $content -replace 'v145', 'v143'
            if ($updated -ne $content) {
                Set-Content -LiteralPath $_.FullName -Value $updated -Encoding UTF8
                Write-Host "Converted toolset in $($_.FullName)"
            }
        }
}

function Disable-RadiantMfcProjectReference {
    $wolfProject = Join-Path $RepoRoot 'src\wolf.vcxproj'
    if (-not (Test-Path -LiteralPath $wolfProject)) { return }

    $content = Get-Content -LiteralPath $wolfProject -Raw
    $pattern = '(?s)\s*<ProjectReference Include="tools\\radiant\\Radiant\.vcxproj">.*?</ProjectReference>'
    $updated = [regex]::Replace($content, $pattern, '')
    if ($updated -ne $content) {
        Set-Content -LiteralPath $wolfProject -Value $updated -Encoding UTF8
        Write-Host 'Removed tools\radiant\Radiant.vcxproj project reference from src\wolf.vcxproj for runtime CI build.'
    }
}

function Find-MSBuild {
    $cmd = Get-Command msbuild.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (Test-Path -LiteralPath $vswhere) {
        $path = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe | Select-Object -First 1
        if ($path) { return $path }
    }

    throw 'msbuild.exe was not found.'
}

function Invoke-MSBuildProject {
    param(
        [string]$Project,
        [bool]$BuildProjectReferences = $true
    )

    $msbuild = Find-MSBuild
    $args = @(
        $Project,
        "/p:Configuration=$Configuration",
        "/p:Platform=$Platform",
        '/m',
        '/verbosity:minimal'
    )
    if (-not $BuildProjectReferences) {
        $args += '/p:BuildProjectReferences=false'
    }

    Write-Host "Building $Project"
    & $msbuild @args
    if ($LASTEXITCODE -ne 0) {
        throw "MSBuild failed for $Project with exit code $LASTEXITCODE"
    }
}

function Copy-IfExists {
    param([string]$Path, [string]$Destination)
    if (Test-Path -LiteralPath $Path) {
        Copy-Item -LiteralPath $Path -Destination $Destination -Force
        Write-Host "Copied $Path"
    }
}

Push-Location $RepoRoot
try {
    Convert-ToolsetToVs2022
    Disable-RadiantMfcProjectReference

    Invoke-MSBuildProject 'src\splines\Splines.vcxproj'
    Invoke-MSBuildProject 'src\botlib\botlib.vcxproj'
    Invoke-MSBuildProject 'src\opengl\opengl.vcxproj'
    Invoke-MSBuildProject 'src\renderer\renderer.vcxproj'
    Invoke-MSBuildProject 'src\cgame\cgame.vcxproj'
    Invoke-MSBuildProject 'src\ui\ui.vcxproj'
    Invoke-MSBuildProject 'src\game\game.vcxproj'
    Invoke-MSBuildProject 'src\wolf.vcxproj' $false

    $dist = Join-Path $RepoRoot 'dist'
    if (Test-Path -LiteralPath $dist) { Remove-Item -LiteralPath $dist -Recurse -Force }
    New-Item -ItemType Directory -Path $dist | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $dist 'main') | Out-Null

    # Main executable. The x64 Release target usually writes to repo root/WolfSP.exe.
    foreach ($candidate in @(
        'WolfSP.exe',
        'WolfSP_d.exe',
        'src\Release\WolfSP.exe',
        'src\Debug\WolfSP_d.exe',
        'src\x64\Release\WolfSP.exe',
        'src\x64\Debug\WolfSP_d.exe'
    )) {
        Copy-IfExists (Join-Path $RepoRoot $candidate) $dist
    }

    # Game VM DLLs produced by the x64 projects.
    foreach ($pattern in @('cgamex64*.dll', 'qagamex64*.dll', 'uix64*.dll')) {
        Get-ChildItem -Path (Join-Path $RepoRoot 'main') -Filter $pattern -File -ErrorAction SilentlyContinue | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $dist 'main') -Force
            Write-Host "Copied main/$($_.Name)"
        }
    }

    # Optional runtime DLLs if present in the repository.
    foreach ($pattern in @(
        'OpenAL32.dll',
        'dxcompiler.dll',
        'dxil.dll',
        'D3D12Core.dll',
        'd3d12SDKLayers.dll',
        'NvLowLatencyVk.dll',
        'nvngx_*.dll',
        'sl.*.dll'
    )) {
        Get-ChildItem -Path $RepoRoot -Filter $pattern -File -ErrorAction SilentlyContinue | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination $dist -Force
            Write-Host "Copied $($_.Name)"
        }
    }


    # Copy Final HighQuality DXR BAT files into the artifact root.
    $testBatDir = Join-Path $RepoRoot 'test-bats'
    if (Test-Path -LiteralPath $testBatDir) {
        Get-ChildItem -Path $testBatDir -Filter '*.bat' -File | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination $dist -Force
            Write-Host "Copied test BAT $($_.Name)"
        }
        if (Test-Path -LiteralPath (Join-Path $testBatDir 'README_FINAL_PRESETS_RU.txt')) {
            Copy-Item -LiteralPath (Join-Path $testBatDir 'README_FINAL_PRESETS_RU.txt') -Destination (Join-Path $dist 'README_DXR_FINAL_PRESETS_RU.txt') -Force
        }
    }

    # Copy Final HighQuality DXR CFG files into dist/main so +exec works reliably.
    $testCfgDir = Join-Path $RepoRoot 'test-cfgs'
    if (Test-Path -LiteralPath $testCfgDir) {
        Get-ChildItem -Path $testCfgDir -Filter '*.cfg' -File | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $dist 'main') -Force
            Write-Host "Copied preset CFG main/$($_.Name)"
        }
    }

    $launcher = @'
@echo off
setlocal
cd /d "%~dp0"
echo Starting DarkWolf RTCW Final HighQuality DXR Smooth preset...
echo Uses main\dxr_final_high_quality.cfg
WolfSP.exe +exec dxr_final_high_quality.cfg
'@
    Set-Content -LiteralPath (Join-Path $dist 'RUN_DARKWOLF_DXR.bat') -Value $launcher -Encoding ASCII

    $readme = @'
DarkWolf RTCW Final HighQuality DXR release artifact
===============================================

This artifact contains only runtime files produced by the GitHub Actions build.
It does NOT contain original Return to Castle Wolfenstein game data/pk3 files.

Copy these files into your existing RTCW/DarkWolf game folder:

  WolfSP.exe                 -> game root
  main\cgamex64.dll          -> game main folder
  main\qagamex64.dll         -> game main folder
  main\uix64.dll             -> game main folder
  main\dxr_final_*.cfg / main\dxr_reset_safe.cfg             -> game main folder
  RUN_*.bat                  -> game root

Recommended launch:

  1. RUN_RESET_SAFE.bat
  2. Close the game completely.
  3. RUN_PLAY_FINAL_HIGH_QUALITY.bat

Preset notes:

  RUN_PLAY_FINAL_HIGH_QUALITY.bat
    Main recommended mode. Uses DXR mode 4 full lighting at capped 160x90,
    frozen scene, safe sun/contact shadows, and final smooth composite.

  RUN_PLAY_FINAL_STABLE.bat
    Conservative 128x72 variant for maximum stability.

  RUN_PLAY_FINAL_EXPERIMENTAL_DXR_ULTRA.bat
    Experimental 192x108 mode with stronger lighting. Not the main launch mode.

  RUN_RESET_SAFE.bat
    Safe no-DXR reset.

Patch 11 adds the final smooth composite and high-quality safe presets. It keeps
full-resolution raster detail and uses the low-resolution DXR result as a
soft lighting multiplier, reducing the visible pixel-square grid.
'@
    Set-Content -LiteralPath (Join-Path $dist 'README_RUN_RU.txt') -Value $readme -Encoding UTF8

    Write-Host 'Clean runtime package prepared in dist:'
    Get-ChildItem -Path $dist -Recurse | ForEach-Object { Write-Host $_.FullName }
}
finally {
    Pop-Location
}
