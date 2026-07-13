[CmdletBinding()]
param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$sourcePath = Join-Path $RepoRoot 'src/opengl/gl_d3d12raylight.cpp'
if (!(Test-Path -LiteralPath $sourcePath)) {
    throw "Source file not found: $sourcePath"
}

$text = [IO.File]::ReadAllText($sourcePath)
$marker = 'static const char* g_glRaytracingLightingHlsl = R"('
$start = $text.IndexOf($marker, [StringComparison]::Ordinal)
if ($start -lt 0) { throw 'Embedded HLSL start marker not found.' }
$start += $marker.Length
$end = $text.IndexOf(')";', $start, [StringComparison]::Ordinal)
if ($end -lt 0) { throw 'Embedded HLSL end marker not found.' }
$hlsl = $text.Substring($start, $end - $start)

$tempRoot = if ($env:RUNNER_TEMP) { $env:RUNNER_TEMP } else { [IO.Path]::GetTempPath() }
$hlslPath = Join-Path $tempRoot 'darkwolf_dxr_effects_lab.hlsl'
$dxilPath = Join-Path $tempRoot 'darkwolf_dxr_effects_lab.dxil'
[IO.File]::WriteAllText($hlslPath, $hlsl, [Text.UTF8Encoding]::new($false))

$dxc = Get-Command dxc.exe -ErrorAction SilentlyContinue
if (!$dxc) {
    $sdkRoot = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits\10\bin'
    if (Test-Path -LiteralPath $sdkRoot) {
        $candidate = Get-ChildItem -Path $sdkRoot -Recurse -Filter dxc.exe -File -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -match '\\x64\\dxc\.exe$' } |
            Sort-Object FullName -Descending |
            Select-Object -First 1
        if ($candidate) { $dxc = Get-Command $candidate.FullName -ErrorAction Stop }
    }
}
if (!$dxc) {
    throw 'dxc.exe was not found on the Windows runner; embedded HLSL cannot be validated.'
}

$dxcPath = $dxc.Source
Write-Host "Validating embedded HLSL with: $dxcPath"
& $dxcPath -T lib_6_3 -Zi -Qembed_debug -O3 -all_resources_bound -Fo $dxilPath $hlslPath
$code = $LASTEXITCODE
$global:LASTEXITCODE = 0
if ($code -ne 0) {
    throw "DXC validation failed with exit code $code"
}
if (!(Test-Path -LiteralPath $dxilPath)) {
    throw 'DXC returned success but did not create the expected DXIL output.'
}

Write-Host "Embedded DXR Effects Lab HLSL validation passed. DXIL size: $((Get-Item $dxilPath).Length) bytes."
exit 0
