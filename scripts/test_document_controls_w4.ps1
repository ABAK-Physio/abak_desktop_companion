# Development only: no service install/start, ACL changes or validator execution.
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$abakW4Repo = Split-Path -Parent $PSScriptRoot
if (-not (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
    $abakW4Vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (-not (Test-Path -LiteralPath $abakW4Vswhere)) { throw 'Outil de localisation Visual C++ introuvable.' }
    $abakW4Vs = & $abakW4Vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if ($LASTEXITCODE -ne 0 -or -not $abakW4Vs) { throw 'Installation Visual C++ introuvable.' }
    & (Join-Path $abakW4Vs 'Common7\Tools\Launch-VsDevShell.ps1') -Arch amd64 -HostArch amd64 -SkipAutomaticLocation
}
$abakW4Compiler = Get-Command cl.exe -ErrorAction Stop
$abakW4Build = Join-Path ([IO.Path]::GetTempPath()) ('ABAK-W4-test-' + [guid]::NewGuid())
[void](New-Item -ItemType Directory -Path $abakW4Build)
$abakW4Runner = Join-Path $abakW4Repo 'windows\runner'
$abakW4Common = @(
    '/nologo', '/std:c++17', '/EHsc', '/W4', '/WX', '/DUNICODE', '/D_UNICODE',
    '/DNOMINMAX', "/I$abakW4Runner",
    (Join-Path $abakW4Runner 'document_controls_protocol.cpp'),
    (Join-Path $abakW4Runner 'document_controls_pipe_client.cpp'),
    (Join-Path $abakW4Runner 'document_controls_service_core.cpp'),
    (Join-Path $abakW4Runner 'document_controls_installation_manifest.cpp')
)
Push-Location $abakW4Build
try {
    $abakW4ManifestExe = Join-Path $abakW4Build 'installation_manifest_test.exe'
    $abakW4Args = $abakW4Common + @(
        (Join-Path $abakW4Repo 'tests\windows_document_controls\installation_manifest_test.cpp'),
        "/Fe$abakW4ManifestExe"
    )
    & $abakW4Compiler.Source @abakW4Args
    if ($LASTEXITCODE -ne 0) { throw 'Compilation des tests du manifeste W4 en echec.' }
    & $abakW4ManifestExe
    if ($LASTEXITCODE -ne 0) { throw 'Tests du manifeste W4 en echec.' }

    # Test binary only, deliberately named like Companion to exercise the
    # installation-permission rejection in TEMP. This is NOT the Flutter app.
    $abakW4LoaderExe = Join-Path $abakW4Build 'abak_desktop_companion.exe'
    $abakW4Args = $abakW4Common + @(
        (Join-Path $abakW4Runner 'document_controls_peer_policy.cpp'),
        (Join-Path $abakW4Runner 'document_controls_pipe_transport.cpp'),
        (Join-Path $abakW4Runner 'document_controls_peer_identity.cpp'),
        (Join-Path $abakW4Runner 'document_controls_installation_security.cpp'),
        (Join-Path $abakW4Runner 'document_controls_installation_loader.cpp'),
        (Join-Path $abakW4Repo 'tests\windows_document_controls\installation_loader_test.cpp'),
        "/Fe$abakW4LoaderExe"
    )
    & $abakW4Compiler.Source @abakW4Args
    if ($LASTEXITCODE -ne 0) { throw 'Compilation des tests du chargeur W4 en echec.' }
    & $abakW4LoaderExe
    if ($LASTEXITCODE -ne 0) { throw 'Tests du chargeur W4 en echec.' }
} finally {
    Pop-Location
}
& (Join-Path $PSScriptRoot 'test_document_controls_w3.ps1')
Write-Host 'Tests W4 OK ; verrous W1/W2bis/W3 maintenus ; aucun service ou validateur lance.'
