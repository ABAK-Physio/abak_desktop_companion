
# ABAK Desktop Companion - Windows DMP tools embedding
# PowerShell 5.1
# No download, installation, cleanup or overwrite.

param(
    [Parameter(Mandatory = $true)]
    [string]$Source,

    [Parameter(Mandatory = $true)]
    [string]$Destination
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-BundleIntegrity {
    param([string]$Root)

    $rootPath = [System.IO.Path]::GetFullPath($Root).
        TrimEnd([char[]]@('\', '/'))

    if (-not (Test-Path -LiteralPath $rootPath -PathType Container)) {
        throw "Dossier des outils absent : $rootPath"
    }

    # Reject reparse points, including junctions and symbolic links.
    $rootItem = Get-Item -LiteralPath $rootPath -Force
    if (($rootItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "Lien ou jonction interdit : $rootPath"
    }

    $items = @(
        Get-ChildItem -LiteralPath $rootPath -Recurse -Force
    )

    foreach ($item in $items) {
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "Lien ou jonction interdit : $($item.FullName)"
        }
    }

    $manifestPath = Join-Path $rootPath 'manifest.json'

    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
        throw "Manifeste absent."
    }

    $manifest = Get-Content -LiteralPath $manifestPath -Raw |
        ConvertFrom-Json

    if ($manifest.protocol -ne 1 -or
        $manifest.profile -ne 'PDF/A-1b' -or
        $manifest.arch -ne 'x64') {
        throw "Manifeste non pris en charge."
    }

    $entries = @($manifest.files.PSObject.Properties)

    if ($entries.Count -eq 0) {
        throw "Manifeste vide."
    }

    $required = @(
        'java/bin/java.exe',
        'java/release',
        'vera/cli.jar',
        'NOTICE.txt'
    )

    $expected = @{}

    foreach ($entry in $entries) {
        $relative = [string]$entry.Name

        if ($relative -notmatch '^[A-Za-z0-9_.+/-]+$' -or
            $relative.StartsWith('/') -or
            $relative.Contains('//') -or
            $relative -match '(^|/)\.\.?(/|$)') {
            throw "Chemin invalide dans le manifeste : $relative"
        }

        $key = $relative.ToLowerInvariant()

        if ($expected.ContainsKey($key)) {
            throw "Chemin dupliqué : $relative"
        }

        $expected[$key] = $true

        $filePath = Join-Path $rootPath ($relative.Replace('/', '\'))

        if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
            throw "Fichier absent : $relative"
        }

        $hash = (Get-FileHash -LiteralPath $filePath `
            -Algorithm SHA256).Hash

        if ($hash -ne [string]$entry.Value) {
            throw "Empreinte incorrecte : $relative"
        }
    }

    foreach ($name in $required) {
        if (-not $expected.ContainsKey($name.ToLowerInvariant())) {
            throw "Composant obligatoire absent : $name"
        }
    }

    $actualFiles = @(
        $items | Where-Object { -not $_.PSIsContainer }
    )

    $actualNames = @{}

    foreach ($file in $actualFiles) {
        $relative = $file.FullName.Substring($rootPath.Length + 1).
            Replace('\', '/')

        if ($relative -eq 'manifest.json') {
            continue
        }

        $key = $relative.ToLowerInvariant()

        if (-not $expected.ContainsKey($key)) {
            throw "Fichier supplémentaire : $relative"
        }

        $actualNames[$key] = $true
    }

    if ($actualNames.Count -ne $entries.Count) {
        throw "Nombre de fichiers incohérent."
    }

    Write-Host "Integrite verifiee : $($entries.Count) fichiers." `
        -ForegroundColor Green
}

$sourcePath = [System.IO.Path]::GetFullPath($Source)
$destinationPath = [System.IO.Path]::GetFullPath($Destination)

if ($sourcePath -eq $destinationPath) {
    throw "Source et destination identiques."
}

if (Test-Path -LiteralPath $destinationPath) {
    throw "Destination deja presente : aucun ecrasement autorise."
}

# Validate the source before copying anything.
Assert-BundleIntegrity -Root $sourcePath

# Reject reparse points in existing destination ancestors.
$parent = [System.IO.DirectoryInfo](
    [System.IO.Path]::GetDirectoryName($destinationPath)
)

while ($null -ne $parent) {
    if ($parent.Exists -and
        ($parent.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "Jonction ou lien dans la destination : $($parent.FullName)"
    }
    $parent = $parent.Parent
}

# Prevent copying a source directory into one of its descendants.
$separator = [string][System.IO.Path]::DirectorySeparatorChar

if ($destinationPath.StartsWith(
    $sourcePath.TrimEnd('\') + $separator,
    [StringComparison]::OrdinalIgnoreCase
)) {
    throw "Destination situee dans le dossier source."
}

$destinationParent = Split-Path -Parent $destinationPath

if (-not (Test-Path -LiteralPath $destinationParent)) {
    New-Item -ItemType Directory -Path $destinationParent `
        -Force | Out-Null
}

Write-Host "Copie des ressources DMP Windows..."

Copy-Item -LiteralPath $sourcePath `
    -Destination $destinationPath -Recurse -ErrorAction Stop

# Validate every copied file.
Assert-BundleIntegrity -Root $destinationPath

Write-Host "Integration terminee : $destinationPath" `
    -ForegroundColor Green
