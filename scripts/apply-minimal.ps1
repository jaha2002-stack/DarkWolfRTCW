[CmdletBinding()]
param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
& (Join-Path $PSScriptRoot 'apply-selected.ps1') -Variant minimal -RepoRoot $RepoRoot
