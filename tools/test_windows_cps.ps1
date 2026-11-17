[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repo = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repo 'windows\cps_tests'
$build = Join-Path $repo 'build\windows_cps_tests'
& cmake -S $source -B $build -A x64
if ($LASTEXITCODE -ne 0) { throw 'Configuration des tests CPS en echec.' }
& cmake --build $build --config Release
if ($LASTEXITCODE -ne 0) { throw 'Compilation des tests CPS en echec.' }
& ctest --test-dir $build -C Release --output-on-failure
if ($LASTEXITCODE -ne 0) { throw 'Tests CPS en echec.' }
Write-Host 'TESTS CPS REUSSIS. Fournisseur factice uniquement ; aucune carte lue.'
