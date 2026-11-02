
# ABAK Desktop Companion - Embed Windows CDA references
# PowerShell 5.1
# Source is read-only. No downloads, DMP or CPS access.

param(
    [Parameter(Mandatory = $true)]
    [string]$Source,

    [Parameter(Mandatory = $true)]
    [string]$Destination
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$expectedRevision = 'b10ff7b0bdcad0a0f9006d7054ca670d60d8720c'

function Get-CanonicalPath {
    param([string]$Path)

    return [IO.Path]::GetFullPath($Path).TrimEnd('\')
}

function Test-CdaBundle {
    param([string]$Root)

    $manifestPath = Join-Path $Root 'manifest.json'

    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
        throw "Manifeste CDA absent : $manifestPath"
    }

    $manifest = Get-Content -LiteralPath $manifestPath `
        -Raw -Encoding UTF8 | ConvertFrom-Json

    if ($manifest.protocol -ne 1 -or
        $manifest.profile -ne 'CDA' -or
        $manifest.source -ne 'ANS/TestContenuCDA-3-0' -or
        $manifest.revision -ne $expectedRevision) {
        throw 'Identification du referentiel CDA incorrecte.'
    }

    $entries = @($manifest.files.PSObject.Properties)

    if ($entries.Count -ne 2260) {
        throw "Nombre de fichiers CDA inattendu : $($entries.Count)"
    }

    $expected = @{}

    foreach ($entry in $entries) {
        $relative = [string]$entry.Name

        if ([IO.Path]::IsPathRooted($relative) -or
            $relative.Contains('\') -or
            $relative.StartsWith('/') -or
            $relative -match '(^|/)\.\.?(/|$)' -or
            $relative.Contains(':')) {
            throw "Chemin CDA invalide : $relative"
        }

        $key = $relative.ToLowerInvariant()

        if ($expected.ContainsKey($key)) {
            throw "Chemin CDA duplique : $relative"
        }

        $expected[$key] = [string]$entry.Value

        if ($expected[$key] -notmatch '^[0-9a-fA-F]{64}$') {
            throw "Empreinte CDA invalide : $relative"
        }
    }

    $actualFiles = @(
        Get-ChildItem -LiteralPath $Root -Recurse -File -Force
    )

    $checked = 0
    $seen = @{}

    foreach ($file in $actualFiles) {
        $relative = $file.FullName.Substring(
            $Root.Length + 1
        ).Replace('\', '/')

        if ($relative -eq 'manifest.json') {
            continue
        }

        $key = $relative.ToLowerInvariant()

        if (-not $expected.ContainsKey($key)) {
            throw "Fichier CDA non reference : $relative"
        }

        if ($seen.ContainsKey($key)) {
            throw "Fichier CDA duplique : $relative"
        }

        $seen[$key] = $true

        $hash = (Get-FileHash -LiteralPath $file.FullName `
            -Algorithm SHA256).Hash

        if ($hash -ine $expected[$key]) {
            throw "Empreinte CDA incorrecte : $relative"
        }

        $checked++
    }

    if ($checked -ne $entries.Count) {
        throw "Referentiel CDA incomplet : $checked / $($entries.Count)"
    }

    Write-Host "Integrite CDA verifiee : $checked fichiers."
}

$sourcePath = Get-CanonicalPath $Source
$destinationPath = Get-CanonicalPath $Destination

if (-not (Test-Path -LiteralPath $sourcePath -PathType Container)) {
    throw "Referentiel CDA source absent : $sourcePath"
}

if (Test-Path -LiteralPath $destinationPath) {
    throw "Destination CDA deja presente : $destinationPath"
}

if ($destinationPath.StartsWith(
    $sourcePath + '\',
    [StringComparison]::OrdinalIgnoreCase
)) {
    throw 'Destination situee dans le referentiel source.'
}

# Reject reparse points in the source tree.
$links = @(
    Get-ChildItem -LiteralPath $sourcePath -Recurse -Force |
        Where-Object {
            ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
        }
)

if ($links.Count -ne 0) {
    throw 'Lien ou jonction interdit dans le referentiel CDA.'
}

Write-Host 'Verification du referentiel CDA source...'
Test-CdaBundle $sourcePath

Write-Host 'Copie des references CDA Windows...'

New-Item -ItemType Directory -Path $destinationPath `
    -ErrorAction Stop | Out-Null

Copy-Item -Path (Join-Path $sourcePath '*') `
    -Destination $destinationPath `
    -Recurse -Force -ErrorAction Stop

Write-Host 'Verification de la copie CDA...'
Test-CdaBundle $destinationPath

Write-Host "Integration CDA terminee : $destinationPath" `
    -ForegroundColor Green
