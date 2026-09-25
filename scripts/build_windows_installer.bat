@echo off
setlocal enabledelayedexpansion

echo === ABAK Desktop Companion - Build Windows Installer ===

echo.
echo [0/3] Lecture de la version et du build dans pubspec.yaml...

REM Exemple attendu dans pubspec.yaml :
REM version: 1.1.0+3

for /f "tokens=2 delims=: " %%A in ('findstr /b "version:" pubspec.yaml') do (
  set PACKAGE_VERSION=%%A
)

if "%PACKAGE_VERSION%"=="" (
  echo ERREUR: version introuvable dans pubspec.yaml
  pause
  exit /b 1
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
  pause
  exit /b 1
)

if "%BUILD_NUMBER%"=="" (
  echo ERREUR: numero de build invalide
  pause
  exit /b 1
)

echo.
echo ==========================================
echo ABAK Desktop Companion
echo Version : %APP_VERSION%
echo Build   : %BUILD_NUMBER%
echo ==========================================

echo.
echo [1/3] Recuperation des dependances...
call flutter pub get
if errorlevel 1 (
  echo ERREUR pendant flutter pub get
  pause
  exit /b 1
)

echo.
echo [2/3] Build Windows Release...
call flutter build windows --release
if errorlevel 1 (
  echo ERREUR pendant flutter build windows --release
  pause
  exit /b 1
)

echo.
echo [3/3] Creation de l'installateur Inno Setup...

set "ISCC=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"

if not exist "%ISCC%" (
  echo ERREUR: ISCC.exe introuvable.
  echo Verifie le chemin de Inno Setup.
  pause
  exit /b 1
)

call "%ISCC%" /DMyAppVersion=%APP_VERSION% /DMyBuildNumber=%BUILD_NUMBER% installer\windows\abak_desktop_companion.iss
if errorlevel 1 (
  echo ERREUR pendant la creation de l'installateur
  pause
  exit /b 1
)

echo.
echo === Build termine avec succes ===
echo Version : %APP_VERSION%
echo Build   : %BUILD_NUMBER%
echo Installateur genere dans build\installer\
pause