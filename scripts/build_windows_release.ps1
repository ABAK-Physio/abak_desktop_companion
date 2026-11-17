# ABAK Desktop Companion - Windows Release
# PowerShell 5.1
# No flutter clean, installation, signing or publication.

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repo = Split-Path -Parent $PSScriptRoot
$releaseDir = Join-Path $repo 'build\windows\x64\runner\Release'
$outputDir = Join-Path $repo 'build\releases\windows'
$embedScript = Join-Path $PSScriptRoot 'embed_windows_dmp_tools.ps1'
$validateScript = Join-Path $PSScriptRoot 'validate_windows_dmp_tools.ps1'
$cdaEmbedScript = Join-Path $PSScriptRoot 'embed_windows_cda_references.ps1'
$dmpSource = Join-Path $env:USERPROFILE 'ABAK_build_tools\DmpTools\x64'
$cdaSource = Join-Path $env:USERPROFILE 'ABAK_build_tools\CDA_ANS_b10ff7b0'
$debugInfoRoot = Join-Path $repo 'build\obfuscation\windows'
$symbolsArchiveRoot = Join-Path $env:USERPROFILE 'ABAK_build_tools\obfuscation'

Write-Host ''
Write-Host '=== ABAK Desktop Companion ==='
Write-Host 'Build Windows Release Obfuscated'
Write-Host ''

# Identify the application version and build number.
$versionText = Get-Content (Join-Path $repo 'pubspec.yaml') -Raw
$versionMatch = [regex]::Match(
    $versionText,
    '(?m)^\s*version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$'
)

if (-not $versionMatch.Success) {
    throw 'Version ou numero de build introuvable dans pubspec.yaml.'
}

$appVersion = $versionMatch.Groups[1].Value
$buildNumber = $versionMatch.Groups[2].Value

$artifactName = "ABAK_Desktop_Companion_${appVersion}_${buildNumber}_Windows"
$stagingDir = Join-Path $repo "build\staging\$artifactName"
$zipPath = Join-Path $outputDir "$artifactName.zip"
$debugInfoDir = Join-Path $debugInfoRoot $artifactName
$symbolsArchive = Join-Path $symbolsArchiveRoot $artifactName

Write-Host "Version : $appVersion"
Write-Host "Build   : $buildNumber"

# Never overwrite an existing artifact or symbol archive.
foreach ($path in @(
    $stagingDir,
    $zipPath,
    $debugInfoDir,
    $symbolsArchive
)) {
    if (Test-Path -LiteralPath $path) {
        throw "Distribution ou symboles deja presents : $path"
    }
}

foreach ($script in @($embedScript, $validateScript, $cdaEmbedScript)) {
    if (-not (Test-Path -LiteralPath $script -PathType Leaf)) {
        throw "Script de preparation DMP/CDA introuvable : $script"
    }
}

if (-not (Test-Path -LiteralPath $dmpSource -PathType Container)) {
    throw "Ressources Java/veraPDF absentes : $dmpSource"
}

if (-not (Test-Path -LiteralPath (
    Join-Path $dmpSource 'manifest.json'
) -PathType Leaf)) {
    throw 'Manifeste Java/veraPDF absent.'
}

if (-not (Test-Path -LiteralPath $cdaSource -PathType Container)) {
    throw "Referentiel CDA absent : $cdaSource"
}

if (-not (Test-Path -LiteralPath (
    Join-Path $cdaSource 'manifest.json'
) -PathType Leaf)) {
    throw 'Manifeste CDA absent.'
}

Set-Location $repo

# 1. Validate the private Java/veraPDF bundle before compilation.
Write-Host '[1/10] Validation Java/veraPDF...'

& powershell.exe -NoProfile -NonInteractive `
    -ExecutionPolicy Bypass `
    -File $validateScript `
    -Bundle $dmpSource

if ($LASTEXITCODE -ne 0) {
    throw 'Echec validation Java/veraPDF.'
}

# 2. Validate the CDA source by embedding into a disposable test directory.
# The embed script checks all manifest hashes before and after copying.
Write-Host '[2/10] Validation du referentiel CDA...'

$cdaValidationRoot = Join-Path $env:TEMP (
    'abak-cda-preflight-' + [guid]::NewGuid().ToString('N')
)
$cdaValidationDestination = Join-Path $cdaValidationRoot 'CdaReferences\x64'

try {
    & powershell.exe -NoProfile -NonInteractive `
        -ExecutionPolicy Bypass `
        -File $cdaEmbedScript `
        -Source $cdaSource `
        -Destination $cdaValidationDestination

    if ($LASTEXITCODE -ne 0) {
        throw 'Echec validation du referentiel CDA.'
    }
}
finally {
    if (Test-Path -LiteralPath $cdaValidationRoot) {
        Remove-Item -LiteralPath $cdaValidationRoot `
            -Recurse -Force -ErrorAction Stop
    }
}

# 3. Resolve Flutter dependencies without cleaning.
Write-Host '[3/10] Dependencies...'

& flutter pub get
if ($LASTEXITCODE -ne 0) {
    throw 'Echec flutter pub get.'
}

# 4. Build the obfuscated Windows application.
Write-Host '[4/10] Flutter Windows Release...'

& flutter build windows `
    --release `
    --obfuscate `
    --split-debug-info="$debugInfoDir"

if ($LASTEXITCODE -ne 0) {
    throw 'Echec compilation Windows.'
}

$exePath = Join-Path $releaseDir 'abak_desktop_companion.exe'

if (-not (Test-Path -LiteralPath $exePath -PathType Leaf)) {
    throw 'Executable Windows absent apres compilation.'
}

$symbolFiles = @(
    Get-ChildItem -LiteralPath $debugInfoDir -Recurse -File `
        -ErrorAction Stop
)

if ($symbolFiles.Count -eq 0) {
    throw 'Aucun fichier de symboles d obfuscation genere.'
}

# 5. Back up obfuscation symbols outside build/.
Write-Host '[5/10] Sauvegarde des symboles...'

if (-not (Test-Path -LiteralPath $symbolsArchiveRoot)) {
    New-Item -ItemType Directory -Path $symbolsArchiveRoot |
        Out-Null
}

Copy-Item -LiteralPath $debugInfoDir `
    -Destination $symbolsArchive `
    -Recurse -ErrorAction Stop

$sourceRoot = (Resolve-Path -LiteralPath $debugInfoDir).Path
$backupRoot = (Resolve-Path -LiteralPath $symbolsArchive).Path

$verifiedSymbols = 0

foreach ($file in $symbolFiles) {
    $relative = $file.FullName.Substring($sourceRoot.Length + 1)
    $copy = Join-Path $backupRoot $relative

    if (-not (Test-Path -LiteralPath $copy -PathType Leaf)) {
        throw "Symbole absent : $relative"
    }

    $sourceHash = (Get-FileHash -LiteralPath $file.FullName `
        -Algorithm SHA256).Hash

    $backupHash = (Get-FileHash -LiteralPath $copy `
        -Algorithm SHA256).Hash

    if ($sourceHash -ne $backupHash) {
        throw "Symbole modifie : $relative"
    }

    $verifiedSymbols++
}

if ($verifiedSymbols -ne $symbolFiles.Count) {
    throw 'Sauvegarde des symboles incomplete.'
}

Write-Host "Symboles sauvegardes : $verifiedSymbols fichier(s)."

# 6. Stage the Flutter distribution.
Write-Host '[6/10] Preparation de la distribution...'

New-Item -ItemType Directory -Path $stagingDir |
    Out-Null

Copy-Item -Path (Join-Path $releaseDir '*') `
    -Destination $stagingDir `
    -Recurse -ErrorAction Stop

# 7. Embed the verified private Java/veraPDF tools.
Write-Host '[7/10] Integration Java/veraPDF...'

$dmpDestination = Join-Path $stagingDir 'data\DmpTools\x64'

& powershell.exe -NoProfile -NonInteractive `
    -ExecutionPolicy Bypass `
    -File $embedScript `
    -Source $dmpSource `
    -Destination $dmpDestination

if ($LASTEXITCODE -ne 0) {
    throw 'Echec integration Java/veraPDF.'
}

# 8. Embed the CDA references in a separate integrity domain.
Write-Host '[8/10] Integration des references CDA...'

$cdaDestination = Join-Path $stagingDir 'data\CdaReferences\x64'

& powershell.exe -NoProfile -NonInteractive `
    -ExecutionPolicy Bypass `
    -File $cdaEmbedScript `
    -Source $cdaSource `
    -Destination $cdaDestination

if ($LASTEXITCODE -ne 0) {
    throw 'Echec integration des references CDA.'
}

$requiredFiles = @(
    'abak_desktop_companion.exe',
    'flutter_windows.dll',
    'data\icudtl.dat',
    'data\app.so',
    'data\DmpTools\x64\manifest.json',
    'data\DmpTools\x64\java\bin\java.exe',
    'data\DmpTools\x64\vera\cli.jar',
    'data\DmpTools\x64\NOTICE.txt',
    'data\CdaReferences\x64\manifest.json',
    'data\CdaReferences\x64\infrastructure\cda\CDA_extended.xsd',
    'data\CdaReferences\x64\schematrons\moteur\saxon9he.jar',
    'data\CdaReferences\x64\schematrons\profils\IHE.sch'
)

foreach ($relative in $requiredFiles) {
    if (-not (Test-Path -LiteralPath (
        Join-Path $stagingDir $relative
    ) -PathType Leaf)) {
        throw "Fichier de distribution absent : $relative"
    }
}

if (-not (Test-Path -LiteralPath (
    Join-Path $stagingDir 'data\flutter_assets'
) -PathType Container)) {
    throw 'Ressources Flutter absentes.'
}

# 9. Create ZIP without overwriting previous archives.
Write-Host '[9/10] Creation du ZIP...'

if (-not (Test-Path -LiteralPath $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir |
        Out-Null
}

Compress-Archive `
    -Path (Join-Path $stagingDir '*') `
    -DestinationPath $zipPath `
    -CompressionLevel Optimal `
    -ErrorAction Stop

# 10. Compare every ZIP file against staging using SHA-256.
Write-Host '[10/10] Verification SHA-256 du ZIP...'

Add-Type -AssemblyName System.IO.Compression.FileSystem

$archive = [System.IO.Compression.ZipFile]::OpenRead($zipPath)

try {
    $stagedFiles = @(
        Get-ChildItem -LiteralPath $stagingDir -Recurse -File
    )

    $expected = @{}

    foreach ($file in $stagedFiles) {
        $relative = $file.FullName.Substring(
            $stagingDir.Length + 1
        ).Replace('\', '/').ToLowerInvariant()

        if ($expected.ContainsKey($relative)) {
            throw "Chemin de distribution duplique : $relative"
        }

        $expected[$relative] = $file.FullName
    }

    $seen = @{}
    $verified = 0

    foreach ($entry in $archive.Entries) {
        $relative = $entry.FullName.Replace('\', '/').ToLowerInvariant()

        if ($relative.EndsWith('/')) {
            continue
        }

        if ($seen.ContainsKey($relative)) {
            throw "Entree ZIP dupliquee : $relative"
        }

        if (-not $expected.ContainsKey($relative)) {
            throw "Fichier ZIP inattendu : $relative"
        }

        $seen[$relative] = $true

        $stream = $entry.Open()

        try {
            $sha = [System.Security.Cryptography.SHA256]::Create()

            try {
                $zipHash = [BitConverter]::ToString(
                    $sha.ComputeHash($stream)
                ).Replace('-', '')
            }
            finally {
                $sha.Dispose()
            }
        }
        finally {
            $stream.Dispose()
        }

        $diskHash = (Get-FileHash `
            -LiteralPath $expected[$relative] `
            -Algorithm SHA256).Hash

        if ($zipHash -ne $diskHash) {
            throw "Empreinte ZIP incorrecte : $relative"
        }

        $verified++
    }

    if ($verified -ne $expected.Count) {
        throw "ZIP incomplet : $verified / $($expected.Count) fichiers."
    }

    Write-Host "ZIP verifie : $verified fichiers." `
        -ForegroundColor Green
}
finally {
    $archive.Dispose()
}

Write-Host ''
Write-Host '=== BUILD WINDOWS TERMINE ===' -ForegroundColor Green
Write-Host "Archive : $zipPath"
Write-Host "Symboles sauvegardes : $symbolsArchive"
Write-Host 'Aucune installation ni publication effectuee.'
