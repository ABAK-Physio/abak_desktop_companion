# Development tests only. Automatically reuses the installed Visual C++ tools.
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$abakW2Repo = Split-Path -Parent $PSScriptRoot
if (-not (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
    $abakW2Vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (-not (Test-Path -LiteralPath $abakW2Vswhere)) { throw 'Outil de localisation Visual C++ introuvable.' }
    $abakW2Vs = & $abakW2Vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if ($LASTEXITCODE -ne 0 -or -not $abakW2Vs) { throw 'Installation Visual C++ introuvable.' }
    $abakW2Shell = Join-Path $abakW2Vs 'Common7\Tools\Launch-VsDevShell.ps1'
    & $abakW2Shell -Arch amd64 -HostArch amd64 -SkipAutomaticLocation
}
$abakW2Compiler = Get-Command cl.exe -ErrorAction Stop
$abakW2Build = Join-Path ([IO.Path]::GetTempPath()) ('ABAK-W2-test-' + [guid]::NewGuid())
[void](New-Item -ItemType Directory -Path $abakW2Build)
$abakW2Runner = Join-Path $abakW2Repo 'windows\runner'
$abakW2Tests = Join-Path $abakW2Repo 'tests\windows_document_controls'
$abakW2Common = @(
    '/nologo', '/std:c++17', '/EHsc', '/W4', '/WX', '/DUNICODE', '/D_UNICODE',
    '/DNOMINMAX', "/I$abakW2Runner",
    (Join-Path $abakW2Runner 'document_controls_protocol.cpp'),
    (Join-Path $abakW2Runner 'document_controls_pipe_client.cpp'),
    (Join-Path $abakW2Runner 'document_controls_peer_policy.cpp')
)
Push-Location $abakW2Build
try {
    $abakW2PolicyExe = Join-Path $abakW2Build 'peer_policy_test.exe'
    $abakW2Args = $abakW2Common + @((Join-Path $abakW2Tests 'peer_policy_test.cpp'), "/Fe$abakW2PolicyExe")
    & $abakW2Compiler.Source @abakW2Args
    if ($LASTEXITCODE -ne 0) { throw 'Compilation des tests de politique W2 en echec.' }
    & $abakW2PolicyExe
    if ($LASTEXITCODE -ne 0) { throw 'Tests de politique W2 en echec.' }

    $abakW2InstallationExe = Join-Path $abakW2Build 'installation_security_test.exe'
    $abakW2Args = $abakW2Common + @(
        (Join-Path $abakW2Runner 'document_controls_pipe_transport.cpp'),
        (Join-Path $abakW2Runner 'document_controls_installation_security.cpp'),
        (Join-Path $abakW2Tests 'installation_security_test.cpp'), "/Fe$abakW2InstallationExe"
    )
    & $abakW2Compiler.Source @abakW2Args
    if ($LASTEXITCODE -ne 0) { throw 'Compilation des tests de protection W2 en echec.' }
    & $abakW2InstallationExe
    if ($LASTEXITCODE -ne 0) { throw 'Tests de protection W2 en echec.' }

    $abakW2PipeExe = Join-Path $abakW2Build 'pipe_transport_test.exe'
    $abakW2Args = $abakW2Common + @(
        (Join-Path $abakW2Runner 'document_controls_pipe_transport.cpp'),
        (Join-Path $abakW2Runner 'document_controls_peer_identity.cpp'),
        (Join-Path $abakW2Runner 'document_controls_installation_security.cpp'),
        (Join-Path $abakW2Tests 'pipe_transport_test.cpp'), "/Fe$abakW2PipeExe"
    )
    & $abakW2Compiler.Source @abakW2Args
    if ($LASTEXITCODE -ne 0) { throw 'Compilation des tests Named Pipe W2 en echec.' }
    & $abakW2PipeExe
    if ($LASTEXITCODE -ne 0) { throw 'Tests Named Pipe W2 en echec.' }
} finally {
    Pop-Location
}
# Real W1 executor/launcher must still refuse after adding these transport APIs.
& (Join-Path $PSScriptRoot 'test_document_controls_w1.ps1')
Write-Host 'Tests W2 OK ; verrou W1 maintenu ; aucun validateur execute.'
