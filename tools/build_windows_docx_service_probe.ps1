# Compile only. Does not install/start a service or change machine configuration.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repo = Split-Path -Parent $PSScriptRoot
$cmake = 'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe'
$source = Join-Path $repo 'windows\docx_conversion_probe'
$build = Join-Path $repo 'build\docx_service_probe_file_access_v12'
$ctest = Join-Path (Split-Path -Parent $cmake) 'ctest.exe'
foreach ($file in @($cmake, $ctest, (Join-Path $source 'CMakeLists.txt'))) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Fichier absent : $file" }
}
& $cmake -S $source -B $build -G 'Visual Studio 17 2022' -A x64
if ($LASTEXITCODE -ne 0) { throw 'Configuration du prototype de conversion en echec.' }
& $cmake --build $build --config Release
if ($LASTEXITCODE -ne 0) { throw 'Compilation du prototype de conversion en echec.' }
& $ctest --test-dir $build -C Release --output-on-failure
if ($LASTEXITCODE -ne 0) { throw 'Tests natifs du prototype en echec.' }
Write-Host 'PROTOTYPE COMPILE. Aucun service installe ou demarre, aucune regle WFP modifiee.' -ForegroundColor Green
Write-Host "Binaires : $build\Release"
