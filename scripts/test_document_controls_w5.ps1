# Development only: no installation, service start, validators or ACL changes.
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$abakW5Repo = Split-Path -Parent $PSScriptRoot
if (-not (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
    $abakW5Vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (-not (Test-Path -LiteralPath $abakW5Vswhere)) { throw 'Outil de localisation Visual C++ introuvable.' }
    $abakW5Vs = & $abakW5Vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if ($LASTEXITCODE -ne 0 -or -not $abakW5Vs) { throw 'Installation Visual C++ introuvable.' }
    & (Join-Path $abakW5Vs 'Common7\Tools\Launch-VsDevShell.ps1') -Arch amd64 -HostArch amd64 -SkipAutomaticLocation
}
$abakW5Compiler = Get-Command cl.exe -ErrorAction Stop
$abakW5Build = Join-Path ([IO.Path]::GetTempPath()) ('ABAK-W5-test-' + [guid]::NewGuid())
[void](New-Item -ItemType Directory -Path $abakW5Build)
$abakW5Runner = Join-Path $abakW5Repo 'windows\runner'
$abakW5Common = @(
    '/nologo', '/std:c++17', '/EHsc', '/W4', '/WX', '/DUNICODE', '/D_UNICODE',
    '/DNOMINMAX', "/I$abakW5Runner",
    (Join-Path $abakW5Runner 'document_controls_protocol.cpp'),
    (Join-Path $abakW5Runner 'document_controls_pipe_client.cpp'),
    (Join-Path $abakW5Runner 'document_controls_service_core.cpp'),
    (Join-Path $abakW5Runner 'document_controls_refusal_session.cpp')
)
Push-Location $abakW5Build
try {
    $abakW5ModelExe = Join-Path $abakW5Build 'refusal_session_test.exe'
    $abakW5Args = $abakW5Common + @(
        (Join-Path $abakW5Repo 'tests\windows_document_controls\refusal_session_test.cpp'),
        "/Fe$abakW5ModelExe"
    )
    & $abakW5Compiler.Source @abakW5Args
    if ($LASTEXITCODE -ne 0) { throw 'Compilation des tests d orchestration W5 en echec.' }
    & $abakW5ModelExe
    if ($LASTEXITCODE -ne 0) { throw 'Tests d orchestration W5 en echec.' }

    # TEST main only, named like the service to exercise W4 rejection in TEMP.
    # service_main.cpp is NOT linked here; this is NOT an SCM service host.
    $abakW5PipeExe = Join-Path $abakW5Build 'ABAKDocumentControls.exe'
    $abakW5Args = $abakW5Common + @(
        (Join-Path $abakW5Runner 'document_controls_refusal_pipe_session.cpp'),
        (Join-Path $abakW5Runner 'document_controls_peer_policy.cpp'),
        (Join-Path $abakW5Runner 'document_controls_pipe_transport.cpp'),
        (Join-Path $abakW5Runner 'document_controls_peer_identity.cpp'),
        (Join-Path $abakW5Runner 'document_controls_installation_security.cpp'),
        (Join-Path $abakW5Runner 'document_controls_installation_manifest.cpp'),
        (Join-Path $abakW5Runner 'document_controls_installation_loader.cpp'),
        (Join-Path $abakW5Repo 'tests\windows_document_controls\refusal_pipe_session_test.cpp'),
        "/Fe$abakW5PipeExe"
    )
    & $abakW5Compiler.Source @abakW5Args
    if ($LASTEXITCODE -ne 0) { throw 'Compilation des tests de session pipe W5 en echec.' }
    & $abakW5PipeExe
    if ($LASTEXITCODE -ne 0) { throw 'Tests de session pipe W5 en echec.' }
} finally {
    Pop-Location
}
& (Join-Path $PSScriptRoot 'test_document_controls_w4.ps1')
Write-Host 'Tests W5 OK ; refus systematique ; verrous W1/W2bis/W3/W4 maintenus.'
