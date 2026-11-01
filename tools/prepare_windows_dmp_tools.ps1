
# ABAK Desktop Companion - Prepare private PDF/A tools for Windows x64
# PowerShell 5.1
# No download, installation, overwrite or destructive cleanup.

param(
    [Parameter(Mandatory = $true)]
    [string]$JdkHome,

    [Parameter(Mandatory = $true)]
    [string]$VeraCli,

    [Parameter(Mandatory = $true)]
    [string]$Destination
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repo = Split-Path -Parent $PSScriptRoot
$lockPath = Join-Path $PSScriptRoot 'dmp_tools_windows.lock.json'

$modules = @(
    'java.base',
    'java.desktop',
    'java.logging',
    'java.xml',
    'java.management',
    'java.naming',
    'jdk.compiler',
    'jdk.zipfs',
    'jdk.crypto.cryptoki',
    'jdk.crypto.ec'
) -join ','

function Get-Sha256 {
    param([string]$Path)

    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).
        Hash.ToLowerInvariant()
}

function Assert-InputHash {
    param(
        [string]$Name,
        [string]$Path,
        [string]$Expected
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Entree absente : $Name"
    }

    if ($Expected -notmatch '^[0-9a-fA-F]{64}$') {
        throw "Empreinte attendue invalide : $Name"
    }

    if ((Get-Sha256 $Path) -ne $Expected) {
        throw "Empreinte incorrecte : $Name"
    }

    Write-Host "Entree verifiee : $Name"
}

# Validate input paths and lock file before creating any output.
$jdkPath = [IO.Path]::GetFullPath($JdkHome)
$veraPath = [IO.Path]::GetFullPath($VeraCli)
$destinationPath = [IO.Path]::GetFullPath($Destination)

if (-not (Test-Path -LiteralPath $jdkPath -PathType Container)) {
    throw "Dossier JDK absent."
}

if (Test-Path -LiteralPath $destinationPath) {
    throw "Destination deja presente : aucun ecrasement autorise."
}

if (-not (Test-Path -LiteralPath $lockPath -PathType Leaf)) {
    throw "Fichier de verrouillage absent."
}

$lock = Get-Content -LiteralPath $lockPath -Raw |
    ConvertFrom-Json

if ($null -eq $lock.x64) {
    throw "Verrou Windows x64 absent."
}

$javaExe = Join-Path $jdkPath 'bin\java.exe'
$jlinkExe = Join-Path $jdkPath 'bin\jlink.exe'
$releaseFile = Join-Path $jdkPath 'release'
$jmodsDir = Join-Path $jdkPath 'jmods'

Assert-InputHash 'Java' $javaExe $lock.x64.java
Assert-InputHash 'JDK release' $releaseFile $lock.x64.release
Assert-InputHash 'veraPDF CLI' $veraPath $lock.x64.vera

if (-not (Test-Path -LiteralPath $jlinkExe -PathType Leaf)) {
    throw "jlink.exe absent."
}

if (-not (Test-Path -LiteralPath $jmodsDir -PathType Container)) {
    throw "Modules Java absents."
}

# Reject reparse points in input trees.
foreach ($root in @($jdkPath, (Split-Path $veraPath -Parent))) {
    $items = @(
        Get-Item -LiteralPath $root -Force
        Get-ChildItem -LiteralPath $root -Recurse -Force
    )

    foreach ($item in $items) {
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "Lien ou jonction interdit : $($item.FullName)"
        }
    }
}


# Confirm JDK version and veraPDF CLI version.

# Prevent output inside the JDK source tree.
$jdkPrefix = $jdkPath.TrimEnd('\') + '\'

if ($destinationPath.StartsWith(
    $jdkPrefix,
    [StringComparison]::OrdinalIgnoreCase
)) {
    throw "Destination situee dans le dossier JDK source."
}

# The output must not be the veraPDF input file.
if ($destinationPath.Equals(
    $veraPath,
    [StringComparison]::OrdinalIgnoreCase
)) {
    throw "Destination identique au fichier veraPDF source."
}

# Verify Java 17 version.
# Java writes its version to stderr, even on success.
$versionStdout = Join-Path $env:TEMP (
    'abak-java-stdout-' + [guid]::NewGuid().ToString('N') + '.txt'
)
$versionStderr = Join-Path $env:TEMP (
    'abak-java-stderr-' + [guid]::NewGuid().ToString('N') + '.txt'
)

try {
    $process = Start-Process `
        -FilePath $javaExe `
        -ArgumentList '-version' `
        -RedirectStandardOutput $versionStdout `
        -RedirectStandardError $versionStderr `
        -Wait `
        -PassThru `
        -NoNewWindow

    $javaVersion = Get-Content -LiteralPath $versionStderr -Raw

    if ($process.ExitCode -ne 0 -or
        $javaVersion -notmatch '17\.0\.20\.1') {
        throw "Version Java inattendue."
    }
}
finally {
    Remove-Item -LiteralPath $versionStdout -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $versionStderr -ErrorAction SilentlyContinue
}

# Verify veraPDF CLI version.
$veraVersion = & $javaExe -cp $veraPath `
    org.verapdf.apps.GreenfieldCliWrapper --version 2>&1 |
    Out-String

if ($LASTEXITCODE -ne 0 -or
    $veraVersion -notmatch 'veraPDF 1\.30\.3') {
    throw "Version veraPDF inattendue."
}


# Check output ancestors for junctions or symbolic links.
$parent = [IO.DirectoryInfo](
    [IO.Path]::GetDirectoryName($destinationPath)
)

while ($null -ne $parent) {
    if ($parent.Exists -and
        ($parent.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "Jonction dans la destination : $($parent.FullName)"
    }
    $parent = $parent.Parent
}

# Create destination only after all input checks.
New-Item -ItemType Directory -Path $destinationPath |
    Out-Null

$javaOutput = Join-Path $destinationPath 'java'
$veraOutput = Join-Path $destinationPath 'vera'
$licensesOutput = Join-Path $destinationPath 'licenses'

Write-Host "Preparation du runtime Java prive..."

& $jlinkExe `
    --module-path $jmodsDir `
    --add-modules $modules `
    --strip-debug `
    --no-header-files `
    --no-man-pages `
    --output $javaOutput

if ($LASTEXITCODE -ne 0) {
    throw "Echec jlink."
}

if (-not (Test-Path -LiteralPath (
    Join-Path $javaOutput 'bin\java.exe'
) -PathType Leaf)) {
    throw "Runtime Java incomplet."
}

New-Item -ItemType Directory -Path $veraOutput |
    Out-Null

Copy-Item -LiteralPath $veraPath `
    -Destination (Join-Path $veraOutput 'cli.jar') `
    -ErrorAction Stop

if ((Get-Sha256 (Join-Path $veraOutput 'cli.jar')) -ne $lock.x64.vera) {
    throw "veraPDF modifie pendant la copie."
}

# Extract notices from the original CLI archive.
Add-Type -AssemblyName System.IO.Compression.FileSystem

New-Item -ItemType Directory -Path $licensesOutput |
    Out-Null

$noticeNames = @(
    'LICENSE.txt',
    'NOTICE.txt',
    'NOTICE-tools.txt',
    'LICENSE',
    'NOTICE',
    'LICENSE.md',
    'NOTICE.md'
)

$archive = [IO.Compression.ZipFile]::OpenRead($veraPath)

try {
    foreach ($name in $noticeNames) {
        $entry = $archive.GetEntry("META-INF/$name")

        if ($null -eq $entry) {
            throw "Notice veraPDF absente : $name"
        }

        $sourceStream = $entry.Open()

        try {
            $targetPath = Join-Path $licensesOutput $name
            $targetStream = [IO.File]::Create($targetPath)

            try {
                $sourceStream.CopyTo($targetStream)
            }
            finally {
                $targetStream.Dispose()
            }
        }
        finally {
            $sourceStream.Dispose()
        }
    }
}
finally {
    $archive.Dispose()
}

# General redistribution notice.
$noticeText = @'
ABAK Desktop Companion - Private PDF/A tools
Platform: Windows x64

Java:
Eclipse Temurin OpenJDK 17.0.20.1+1
Private runtime generated using jlink.
License: GPLv2 with Classpath Exception.
Module notices: java/legal/
Runtime metadata: java/release
Sources: https://github.com/adoptium/temurin17-binaries/releases

veraPDF:
veraPDF CLI 1.30.3
Extracted without modification from the official IzPack CLI pack.
License options: GPLv3 or Mozilla Public License 2.0 or later.
Notices: licenses/
Sources: https://github.com/veraPDF/veraPDF-apps/tree/v1.30.3

No system Java installation required.
No automatic download at application runtime.
'@

[IO.File]::WriteAllText(
    (Join-Path $destinationPath 'NOTICE.txt'),
    $noticeText,
    [Text.UTF8Encoding]::new($false)
)

# Generate SHA-256 manifest with portable "/" separators.
$files = [ordered]@{}

Get-ChildItem -LiteralPath $destinationPath -Recurse -File |
    Sort-Object FullName |
    ForEach-Object {
        $relative = $_.FullName.Substring(
            $destinationPath.Length + 1
        ).Replace('\', '/')

        $files[$relative] = Get-Sha256 $_.FullName
    }

$manifest = [ordered]@{
    protocol = 1
    profile = 'PDF/A-1b'
    arch = 'x64'
    files = $files
}

$manifestPath = Join-Path $destinationPath 'manifest.json'

[IO.File]::WriteAllText(
    $manifestPath,
    (ConvertTo-Json -InputObject $manifest -Depth 10),
    [Text.UTF8Encoding]::new($false)
)

Write-Host ""
Write-Host "Paquet Windows prepare : $destinationPath" `
    -ForegroundColor Green
Write-Host "Fichiers references : $($files.Count)"
Write-Host "Aucune installation ni publication effectuee."
