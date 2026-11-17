# Offline only: compile Java, validate path configuration and framed CLOSE.
# No Cryptolib load, no PIN, no card, no network, no registry changes.
[CmdletBinding()]
param([string]$Bundle = (Join-Path $env:USERPROFILE 'ABAK_build_tools\DmpTools\x64'))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repo = Split-Path -Parent $PSScriptRoot
$java = Join-Path $Bundle 'java\bin\java.exe'
$test = Join-Path $repo 'tools\java\DmpWindowsOfflineTests.java'
$worker = Join-Path $repo 'assets\dmp_native\DmpNativeBridge.java'
foreach ($path in @($java,$test,$worker)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Fichier requis absent : $path" }
}
$temp = Join-Path $env:TEMP ('abak-dv1-offline-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temp | Out-Null
$process = [Diagnostics.Process]::new()
try {
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $java
    $info.WorkingDirectory = $temp
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    foreach ($key in @('JAVA_TOOL_OPTIONS','_JAVA_OPTIONS','JDK_JAVA_OPTIONS','CLASSPATH')) {
        $info.EnvironmentVariables.Remove($key)
    }
    $arguments = @('-Dfile.encoding=UTF-8',$test,$worker)
    $quoted = foreach ($value in $arguments) {
        if ($value.Contains('"') -or $value.Contains([char]0) -or $value.EndsWith('\')) {
            throw 'Argument de test Java invalide.'
        }
        '"' + $value + '"'
    }
    $info.Arguments = $quoted -join ' '
    $process.StartInfo = $info
    if (-not $process.Start()) { throw 'Java de test non demarre.' }
    $output = $process.StandardOutput.ReadToEndAsync()
    $errors = $process.StandardError.ReadToEndAsync()
    if (-not $process.WaitForExit(60000)) {
        $process.Kill()
        $process.WaitForExit()
        throw 'Delai du test Java DV1 depasse.'
    }
    $stdout = $output.Result
    $stderr = $errors.Result
    if ($process.ExitCode -ne 0 -or
        $stdout -notmatch 'ABAK_DV1_WINDOWS_OFFLINE_OK checks=35 CARD_ACCESSED=false NETWORK_ACCESSED=false') {
        throw "Test Java DV1 en echec. $stdout $stderr"
    }
    Write-Host $stdout.Trim()
    Write-Host 'TESTS JAVA DV1 HORS CONNEXION REUSSIS. Aucune carte utilisee et aucun acces reseau.'
} finally {
    $process.Dispose()
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
