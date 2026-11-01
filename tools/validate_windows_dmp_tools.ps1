
# ABAK Desktop Companion - Validate Windows DMP tools
# PowerShell 5.1
# No compilation, installation, download or DMP access.

param(
    [Parameter(Mandatory = $true)]
    [string]$Bundle
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repo = Split-Path -Parent $PSScriptRoot
$bundlePath = [IO.Path]::GetFullPath($Bundle)

$embedScript = Join-Path $PSScriptRoot 'embed_windows_dmp_tools.ps1'
$testScript = Join-Path $PSScriptRoot 'test_windows_verapdf.ps1'

Write-Host ''
Write-Host '=== ABAK - Validation des outils DMP Windows ==='
Write-Host "Paquet : $bundlePath"

# Check prerequisites.
if (-not (Test-Path -LiteralPath $bundlePath -PathType Container)) {
    throw "Paquet Java/veraPDF absent."
}

foreach ($script in @($embedScript, $testScript)) {
    if (-not (Test-Path -LiteralPath $script -PathType Leaf)) {
        throw "Script de verification absent : $script"
    }
}

# Validate the complete manifest without modifying the source.
# The embedding script checks the source before copying.
# Use a disposable destination, then remove only that new copy.
$tempRoot = Join-Path $env:TEMP (
    'abak-dmp-validation-' + [guid]::NewGuid().ToString('N')
)

$destination = Join-Path $tempRoot 'DmpTools\x64'

if (Test-Path -LiteralPath $tempRoot) {
    throw "Dossier temporaire deja present."
}

try {
    Write-Host '[1/2] Verification SHA-256 du paquet...'

    & powershell.exe -NoProfile -NonInteractive `
        -ExecutionPolicy Bypass `
        -File $embedScript `
        -Source $bundlePath `
        -Destination $destination

    if ($LASTEXITCODE -ne 0) {
        throw "Echec du controle d'integrite Java/veraPDF."
    }

    Write-Host '[2/2] Tests fonctionnels PDF/A-1b...'

    & powershell.exe -NoProfile -NonInteractive `
        -ExecutionPolicy Bypass `
        -File $testScript `
        -Bundle $destination

    if ($LASTEXITCODE -ne 0) {
        throw "Echec des tests fonctionnels PDF/A-1b."
    }

    Write-Host ''
    Write-Host 'Validation complete : integrite et PDF/A-1b conformes.' `
        -ForegroundColor Green
}
finally {
    # Only remove the uniquely named temporary directory.
    # Never remove the original bundle or the release artifacts.
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
