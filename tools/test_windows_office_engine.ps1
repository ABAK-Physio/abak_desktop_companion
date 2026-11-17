# Native engine verification only. Run as an ordinary Windows user.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repo = Split-Path -Parent $PSScriptRoot
$cmake = 'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe'
$ctest = Join-Path (Split-Path -Parent $cmake) 'ctest.exe'
$source = Join-Path $repo 'windows\document_controls_office_engine_tests'
$build = Join-Path $repo 'build\office_engine_tests'
foreach ($file in @($cmake, $ctest, (Join-Path $source 'CMakeLists.txt'))) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        throw "Fichier de test absent : $file"
    }
}
& $cmake -S $source -B $build -G 'Visual Studio 17 2022' -A x64
if ($LASTEXITCODE -ne 0) { throw 'Configuration des tests moteur en echec.' }
& $cmake --build $build --config Release
if ($LASTEXITCODE -ne 0) { throw 'Compilation des tests moteur en echec.' }
& $ctest --test-dir $build -C Release --output-on-failure -V
if ($LASTEXITCODE -ne 0) { throw 'Verification native LibreOffice en echec.' }
Write-Host 'Verification native du moteur reussie.' -ForegroundColor Green
