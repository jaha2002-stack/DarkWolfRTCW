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


    # Copy DXR TDR-safe Runtime test BAT files into the artifact root.
    $testBatDir = Join-Path $RepoRoot 'test-bats'
    if (Test-Path -LiteralPath $testBatDir) {
        Get-ChildItem -Path $testBatDir -Filter '*.bat' -File | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination $dist -Force
            Write-Host "Copied test BAT $($_.Name)"
        }
        if (Test-Path -LiteralPath (Join-Path $testBatDir 'README_TESTS_RU.txt')) {
            Copy-Item -LiteralPath (Join-Path $testBatDir 'README_TESTS_RU.txt') -Destination (Join-Path $dist 'README_DXR_TDRSAFE_TESTS_RU.txt') -Force
        }
    }

    $launcher = @'
@echo off
setlocal
cd /d "%~dp0"
echo Starting DarkWolf RTCW DXR TDR-safe build...
WolfSP.exe +set r_dxr 1 +set r_dxrSafeMode 1 +set r_dxrDispatchMode 4 +set r_dxrDispatchWidth 64 +set r_dxrDispatchHeight 36 +set r_dxrRenderScale 0.25 +set r_dxrMaxDispatchPixels 2304 +set r_dxrSafeFullMaxPixels 2304 +set r_dxrForceSafeFullLighting 1 +set r_dxrFreezeScene 1 +set r_dxrDispatchEveryNFrames 8 +set r_dxrCompositeBlocks 1 +set r_dxrBuildInterval 9999 +set r_dxrMaxWorldMeshes 64 +set r_dxrMaxLights 1 +set r_dxrShadowSamples 1 +set r_dxrAOSamples 0 +set r_dxrSkySamples 0 +set r_dxrFallbackLight 0 +set r_dxrSunEnable 0 +set r_dxrSync 1 +set r_dxrAmbientIntensity 1.55 +set r_dxrLegacyBlend 0.85 +set r_dxrExposure 1.25 +set r_dxrShadowBias 0.04 +spdevmap escape1
'@
    Set-Content -LiteralPath (Join-Path $dist 'RUN_DARKWOLF_DXR.bat') -Value $launcher -Encoding ASCII

    $readme = @'
DarkWolf RTCW DXR TDR-safe Runtime Cache release artifact
========================================

This artifact contains only runtime files produced by the GitHub Actions build.
It does NOT contain original Return to Castle Wolfenstein game data/pk3 files.

Copy these files into your existing RTCW/DarkWolf game folder:

  WolfSP.exe                 -> game root
  main\cgamex64.dll          -> game main folder
  main\qagamex64.dll         -> game main folder
  main\uix64.dll             -> game main folder

Optional: run RUN_DARKWOLF_DXR.bat after copying the files.

Recommended in-game test preset:

  \seta r_dxr 1
  \seta r_dxrSafeMode 1
  \seta r_dxrDispatchMode 4
  \seta r_dxrRenderScale 0.25
  \seta r_dxrMaxDispatchPixels 2304
  \seta r_dxrSafeFullMaxPixels 2304
  \seta r_dxrForceSafeFullLighting 1
  \seta r_dxrFreezeScene 1
  \seta r_dxrDispatchEveryNFrames 8
  \seta r_dxrCompositeBlocks 1
  \seta r_dxrBuildInterval 9999
  \seta r_dxrMaxWorldMeshes 64
  \seta r_dxrMaxLights 1
  \seta r_dxrShadowSamples 1
  \seta r_dxrAOSamples 0
  \seta r_dxrSkySamples 0
  \seta r_dxrFallbackLight 0
  \seta r_dxrSunEnable 0
  \seta r_dxrAmbientIntensity 1.45
  \seta r_dxrLegacyBlend 0.78
  \seta r_dxrExposure 1.20
  \seta r_dxrShadowBias 0.03
  \vid_restart
  \spdevmap escape1
'@
    Set-Content -LiteralPath (Join-Path $dist 'README_RUN_RU.txt') -Value $readme -Encoding UTF8

    Write-Host 'Clean runtime package prepared in dist:'
    Get-ChildItem -Path $dist -Recurse | ForEach-Object { Write-Host $_.FullName }
}
finally {
    Pop-Location
}
