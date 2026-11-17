# Build and test the pure native DOCX command planner. No service or WFP change.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repo = Split-Path -Parent $PSScriptRoot
$cmake = 'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe'
$ctest = Join-Path (Split-Path -Parent $cmake) 'ctest.exe'
foreach ($program in @($cmake, $ctest)) {
    if (-not (Test-Path -LiteralPath $program -PathType Leaf)) {
        throw "Outil de test absent : $program"
    }
}
$source = Join-Path $repo 'windows\document_controls_docx_plan_tests'
$build = Join-Path $repo 'build\docx_plan_tests'
& $cmake -S $source -B $build -G 'Visual Studio 17 2022' -A x64
if ($LASTEXITCODE -ne 0) { throw 'Configuration des tests C++ en echec.' }
& $cmake --build $build --config Release
if ($LASTEXITCODE -ne 0) { throw 'Compilation des tests C++ en echec.' }
& $ctest --test-dir $build -C Release --output-on-failure
if ($LASTEXITCODE -ne 0) { throw 'Tests C++ DOCX en echec.' }
Write-Host 'Tests natifs DOCX reussis. Aucun processus Office/Java execute.' -ForegroundColor Green
