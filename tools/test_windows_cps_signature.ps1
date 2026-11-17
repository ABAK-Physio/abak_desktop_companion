# Signature tests only: fake PKCS11 and synthetic public crypto vectors. No card or PIN requested.
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repo 'windows\cps_signature_tests'
$build = Join-Path $repo 'build\windows_cps_signature_tests'
cmake -S $source -B $build -A x64
if ($LASTEXITCODE -ne 0) { throw 'Configuration des tests de signature en echec.' }
cmake --build $build --config Release
if ($LASTEXITCODE -ne 0) { throw 'Compilation des tests de signature en echec.' }
ctest --test-dir $build -C Release --output-on-failure
if ($LASTEXITCODE -ne 0) { throw 'Tests de signature CPS en echec.' }
Write-Host 'TESTS SIGNATURE CPS REUSSIS. Fournisseur factice et certificats synthetiques uniquement ; aucune carte utilisee.'
