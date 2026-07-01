Write-Host ""
Write-Host "=== ABAK Desktop Companion ==="
Write-Host "Build Windows Release Obfuscated"
Write-Host ""

flutter clean
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

flutter build windows `
    --release `
    --obfuscate `
    --split-debug-info=build\obfuscation\windows

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$releaseDir = "build\windows\x64\runner\Release"
$outputDir = "build\releases\windows"

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

Compress-Archive `
    -Path "$releaseDir\*" `
    -DestinationPath "$outputDir\ABAK_Desktop_Companion_Windows.zip" `
    -Force

Write-Host ""
Write-Host "Build terminé."
Write-Host ""