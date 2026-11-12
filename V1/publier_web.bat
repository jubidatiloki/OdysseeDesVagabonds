@echo off
rem Met la version web en ligne (Firebase Hosting) :
rem   https://odyssee-vagabonds.web.app
rem Sur iPhone : ouvrir l'adresse dans Safari, puis Partager >
rem "Sur l'ecran d'accueil" pour l'installer comme une application.
rem Il faut l'outil Firebase installe et connecte (firebase login), comme pour
rem le deploiement des regles. Tout est enregistre dans publication_web.log.
chcp 65001 >nul
cd /d "%~dp0"
set "LOG=%~dp0publication_web.log"

echo Construction de la version web (1 a 3 minutes)...
echo === Publication web %date% %time% === > "%LOG%"
call flutter pub get >> "%LOG%" 2>&1
if exist ".dart_tool\flutter_build" rmdir /s /q ".dart_tool\flutter_build"
call flutter build web --release --no-web-resources-cdn --pwa-strategy=none >> "%LOG%" 2>&1
if errorlevel 1 goto echec
findstr /m "firebasejs" "build\web\main.dart.js" >nul
if errorlevel 1 (
  echo FIREBASE ABSENT DE LA VERSION WEB >> "%LOG%"
  goto echec
)
if exist "build\web\main.dart.js.map" del "build\web\main.dart.js.map"

echo Envoi sur Firebase Hosting...
call firebase deploy --only hosting >> "%LOG%" 2>&1
if errorlevel 1 goto echec

echo === OK === >> "%LOG%"
echo.
echo En ligne : https://odyssee-vagabonds.web.app
echo Sur iPhone : Safari, puis Partager ^> "Sur l'ecran d'accueil".
pause
exit /b 0

:echec
echo === ECHEC === >> "%LOG%"
echo.
echo ECHEC de la publication : voir publication_web.log
echo (Si Firebase demande de se connecter : lancer "firebase login" puis
echo relancer ce script.)
pause
exit /b 1
