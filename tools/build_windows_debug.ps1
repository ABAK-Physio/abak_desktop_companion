Write-Host ""
Write-Host "=== ABAK Desktop Companion ==="
Write-Host "Build Windows Debug"
Write-Host ""

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

flutter build windows --debug
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Build Debug terminé."
Write-Host ""
Write-Host "Exécutable disponible dans :"
Write-Host "build\windows\x64\runner\Debug"
Write-Host ""