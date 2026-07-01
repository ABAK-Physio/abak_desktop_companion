@echo off
setlocal

echo === ABAK Desktop Companion - Build Windows Installer ===

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

call "%ISCC%" installer\windows\abak_desktop_companion.iss
if errorlevel 1 (
  echo ERREUR pendant la creation de l'installateur
  pause
  exit /b 1
)

echo.
echo === Build termine avec succes ===
echo Installateur genere dans build\installer\
pause