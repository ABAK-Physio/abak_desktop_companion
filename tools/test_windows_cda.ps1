# PowerShell 5.1. Synthetic report transport only; no service or card access.
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repo = Split-Path -Parent $PSScriptRoot
$build = Join-Path $repo 'build\windows_cda_tests'
& cmake -S (Join-Path $repo 'windows\document_controls_cda_tests') -B $build -A x64
if ($LASTEXITCODE -ne 0) { throw 'Configuration des tests CDA impossible.' }
& cmake --build $build --config Release
if ($LASTEXITCODE -ne 0) { throw 'Compilation des tests CDA impossible.' }
& ctest --test-dir $build -C Release --output-on-failure
if ($LASTEXITCODE -ne 0) { throw 'Tests CDA en echec.' }
Write-Host 'TESTS CDA REUSSIS. Donnees synthetiques uniquement ; aucun document patient controle.'
