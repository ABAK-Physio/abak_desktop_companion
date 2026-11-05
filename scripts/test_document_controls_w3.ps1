# Development tests only. Compiles but NEVER runs the standalone SCM host.
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$abakW3Repo = Split-Path -Parent $PSScriptRoot
if (-not (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
    $abakW3Vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (-not (Test-Path -LiteralPath $abakW3Vswhere)) { throw 'Outil de localisation Visual C++ introuvable.' }
    $abakW3Vs = & $abakW3Vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if ($LASTEXITCODE -ne 0 -or -not $abakW3Vs) { throw 'Installation Visual C++ introuvable.' }
    & (Join-Path $abakW3Vs 'Common7\Tools\Launch-VsDevShell.ps1') -Arch amd64 -HostArch amd64 -SkipAutomaticLocation
}
$abakW3Compiler = Get-Command cl.exe -ErrorAction Stop
$abakW3Build = Join-Path ([IO.Path]::GetTempPath()) ('ABAK-W3-test-' + [guid]::NewGuid())
[void](New-Item -ItemType Directory -Path $abakW3Build)
$abakW3Runner = Join-Path $abakW3Repo 'windows\runner'
$abakW3Common = @(
    '/nologo', '/std:c++17', '/EHsc', '/W4', '/WX', '/DUNICODE', '/D_UNICODE',
    '/DNOMINMAX', "/I$abakW3Runner",
    (Join-Path $abakW3Runner 'document_controls_protocol.cpp'),
    (Join-Path $abakW3Runner 'document_controls_service_core.cpp')
)
Push-Location $abakW3Build
try {
    $abakW3CoreExe = Join-Path $abakW3Build 'service_core_test.exe'
    $abakW3Args = $abakW3Common + @(
        (Join-Path $abakW3Runner 'document_controls_pipe_client.cpp'),
        (Join-Path $abakW3Repo 'tests\windows_document_controls\service_core_test.cpp'),
        "/Fe$abakW3CoreExe"
    )
    & $abakW3Compiler.Source @abakW3Args
    if ($LASTEXITCODE -ne 0) { throw 'Compilation des tests du socle W3 en echec.' }
    & $abakW3CoreExe (Join-Path $abakW3Repo 'test\fixtures\windows_controls_w1_refusal.bin')
    if ($LASTEXITCODE -ne 0) { throw 'Tests du socle W3 en echec.' }

    $abakW3HostExe = Join-Path $abakW3Build 'ABAKDocumentControls.exe'
    $abakW3Args = $abakW3Common + @(
        (Join-Path $abakW3Repo 'windows\document_controls_service\service_main.cpp'),
        "/Fe$abakW3HostExe"
    )
    & $abakW3Compiler.Source @abakW3Args
    if ($LASTEXITCODE -ne 0) { throw 'Compilation de l hote SCM W3 en echec.' }
    # Do not invoke $abakW3HostExe. No service registration/start is attempted.
    Write-Host 'Hote SCM W3 compile uniquement ; executable non lance.'
} finally {
    Pop-Location
}
& (Join-Path $PSScriptRoot 'test_document_controls_w2.ps1')
Write-Host 'Tests W3 OK ; verrous W1/W2bis maintenus ; aucun service ou validateur lance.'
