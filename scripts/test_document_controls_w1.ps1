# Run from a Visual Studio Developer PowerShell. Does not start a service or Java.
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$abakW1Repo = Split-Path -Parent $PSScriptRoot
$abakW1Compiler = Get-Command cl.exe -ErrorAction SilentlyContinue
if (-not $abakW1Compiler) {
    throw 'cl.exe absent : utiliser Developer PowerShell de Visual Studio pour ce test natif.'
}
$abakW1Build = Join-Path ([IO.Path]::GetTempPath()) ('ABAK-W1-test-' + [guid]::NewGuid())
[void](New-Item -ItemType Directory -Path $abakW1Build)
$abakW1Runner = Join-Path $abakW1Repo 'windows\runner'
$abakW1Exe = Join-Path $abakW1Build 'protocol_test.exe'
$abakW1Fixture = Join-Path $abakW1Build 'refusal.bin'
$abakW1Args = @(
    '/nologo', '/std:c++17', '/EHsc', '/W4', '/WX', '/wd4505',
    '/DUNICODE', '/D_UNICODE', '/DNOMINMAX', "/I$abakW1Runner",
    (Join-Path $abakW1Runner 'document_controls_protocol.cpp'),
    (Join-Path $abakW1Runner 'document_controls_pipe_client.cpp'),
    (Join-Path $abakW1Runner 'document_controls_launcher.cpp'),
    (Join-Path $abakW1Runner 'document_controls_executor.cpp'),
    (Join-Path $abakW1Repo 'tests\windows_document_controls\protocol_test.cpp'),
    "/Fe$abakW1Exe"
)
Push-Location $abakW1Build
try {
    & $abakW1Compiler.Source @abakW1Args
    if ($LASTEXITCODE -ne 0) { throw 'Compilation des tests W1 en echec.' }
    & $abakW1Exe $abakW1Fixture
    if ($LASTEXITCODE -ne 0) { throw 'Tests natifs W1 en echec.' }
    $abakW1Reference = Join-Path $abakW1Repo 'test\fixtures\windows_controls_w1_refusal.bin'
    if ((Get-FileHash $abakW1Fixture).Hash -ne (Get-FileHash $abakW1Reference).Hash) {
        throw 'La trame C++ ne correspond pas a la fixture Dart.'
    }
    Write-Host 'Tests natifs W1 OK ; aucun validateur execute.'
} finally {
    Pop-Location
}
# Build output is retained in TEMP for diagnosis. No repository files are removed.
