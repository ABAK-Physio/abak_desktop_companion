@echo off
setlocal enabledelayedexpansion

echo === ABAK Desktop Companion - Build Windows Installer ===

echo.
echo [0/4] Lecture de la version dans pubspec.yaml...

for /f "tokens=2 delims=: " %%A in ('findstr /b "version:" pubspec.yaml') do (
  set APP_VERSION=%%A
)

if "%APP_VERSION%"=="" (
  echo ERREUR: version introuvable dans pubspec.yaml
  pause
  exit /b 1
)

echo Version detectee : %APP_VERSION%

echo.
echo [1/4] Nettoyage Flutter...
call flutter clean
if errorlevel 1 (
  echo ERREUR pendant flutter clean
  pause
  exit /b 1
)

echo.
echo [2/4] Recuperation des dependances...
call flutter pub get
if errorlevel 1 (
  echo ERREUR pendant flutter pub get
  pause
  exit /b 1
)

echo.
echo [3/4] Build Windows Release...
call flutter build windows --release
if errorlevel 1 (
  echo ERREUR pendant flutter build windows --release
  pause
  exit /b 1
)

echo.
echo [4/4] Creation de l'installateur Inno Setup...

set "ISCC=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"

if not exist "%ISCC%" (
  echo ERREUR: ISCC.exe introuvable.
  echo Verifie le chemin de Inno Setup.
  pause
  exit /b 1
)

call "%ISCC%" /DMyAppVersion=%APP_VERSION% installer\windows\abak_desktop_companion.iss
if errorlevel 1 (
  echo ERREUR pendant la creation de l'installateur
  pause
  exit /b 1
)

echo.
echo === Build termine avec succes ===
echo Version : %APP_VERSION%
echo Installateur genere dans build\installer\
pause