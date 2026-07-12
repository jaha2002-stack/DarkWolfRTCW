[CmdletBinding()]
param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'
Push-Location $RepoRoot
try {
    $patch = Join-Path $RepoRoot 'patches\09-build-skip-radiant-mfc.patch'
    if (Test-Path -LiteralPath $patch) {
        git apply --check $patch
        git apply $patch
        Write-Host 'Applied 09-build-skip-radiant-mfc.patch'
    } else {
        throw "Patch not found: $patch"
    }
} finally {
    Pop-Location
}
