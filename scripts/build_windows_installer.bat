@echo off
setlocal enabledelayedexpansion

REM Always resolve paths relative to this script, including when launched elsewhere.
set "PACKAGE_VERSION="
set "APP_VERSION="
set "BUILD_NUMBER="
pushd "%~dp0.."
if errorlevel 1 exit /b 1

set "ISCC=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
if not exist "%ISCC%" (
  echo ERREUR: ISCC.exe introuvable.
  goto :failure
)
if not exist "tools\build_windows_release.ps1" (
  echo ERREUR: tools\build_windows_release.ps1 introuvable.
  goto :failure
)
if not exist "installer\windows\abak_desktop_companion.iss" (
  echo ERREUR: script Inno Setup introuvable.
  goto :failure
)

echo === ABAK Desktop Companion - Build Windows Installer ===

echo.
echo [0/2] Lecture de la version et du build dans pubspec.yaml...

REM Exemple attendu dans pubspec.yaml :
REM version: 1.1.0+3

for /f "tokens=2 delims=: " %%A in ('findstr /b "version:" pubspec.yaml') do (
  set PACKAGE_VERSION=%%A
)

if "%PACKAGE_VERSION%"=="" (
  echo ERREUR: version introuvable dans pubspec.yaml
  goto :failure
)

REM Separation de 1.1.0+3 en :
REM APP_VERSION=1.1.0
REM BUILD_NUMBER=3

for /f "tokens=1,2 delims=+" %%A in ("%PACKAGE_VERSION%") do (
  set APP_VERSION=%%A
  set BUILD_NUMBER=%%B
)

if "%APP_VERSION%"=="" (
  echo ERREUR: numero de version invalide
  goto :failure
)

if "%BUILD_NUMBER%"=="" (
  echo ERREUR: numero de build invalide
  goto :failure
)

echo.
echo ==========================================
echo ABAK Desktop Companion
echo Version : %APP_VERSION%
echo Build   : %BUILD_NUMBER%
echo ==========================================

echo.
echo [1/2] Preparation de la distribution Release verifiee...
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%CD%\tools\build_windows_release.ps1"
if errorlevel 1 (
  echo ERREUR pendant la preparation Release. Aucun installateur cree.
  goto :failure
)

set "DIST_DIR=%CD%\build\staging\ABAK_Desktop_Companion_%APP_VERSION%_%BUILD_NUMBER%_Windows"
if not exist "%DIST_DIR%\abak_desktop_companion.exe" (
  echo ERREUR: distribution preparee introuvable.
  goto :failure
)

echo.
echo [2/2] Creation de l'installateur depuis la distribution preparee...
"%ISCC%" "/DMyAppVersion=%APP_VERSION%" "/DMyBuildNumber=%BUILD_NUMBER%" "/DMySourceDir=%DIST_DIR%" "installer\windows\abak_desktop_companion.iss"
if errorlevel 1 (
  echo ERREUR pendant la creation de l'installateur.
  goto :failure
)

echo.
echo === Build termine avec succes ===
echo Version : %APP_VERSION%
echo Build   : %BUILD_NUMBER%
echo Installateur genere dans build\installer\
popd
pause
exit /b 0

:failure
popd
pause
exit /b 1