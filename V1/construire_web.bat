@echo off
rem Construit la version web "a emporter" de l'application :
rem   ..\livraison\odyssee_vagabonds_web_<version>.zip (ex. _0.15.0)
rem La version est lue dans pubspec.yaml (sans le numero de build).
rem A dezipper sur n'importe quel PC Windows puis lancer "lancer.bat"
rem (aucune installation). Tout est enregistre dans construction_web.log.
chcp 65001 >nul
cd /d "%~dp0"
set "LOG=%~dp0construction_web.log"
set "SORTIE=%~dp0..\livraison"
for /f "tokens=2" %%v in ('findstr /b "version:" pubspec.yaml') do set "VERSION=%%v"
for /f "tokens=1 delims=+" %%a in ("%VERSION%") do set "VERSION=%%a"
set "ZIP=odyssee_vagabonds_web_%VERSION%.zip"

echo Construction de la version web %VERSION% en cours (1 a 3 minutes)...
echo === Construction web %VERSION% %date% %time% === > "%LOG%"
call flutter pub get >> "%LOG%" 2>&1
rem Fichiers generes de la derniere construction : ils peuvent etre perimes
rem (liste des modules web) et faire disparaitre Firebase de la version web.
if exist ".dart_tool\flutter_build" rmdir /s /q ".dart_tool\flutter_build"
call flutter build web --release --no-web-resources-cdn --pwa-strategy=none >> "%LOG%" 2>&1
if errorlevel 1 goto echec
rem Sans Firebase, la connexion au compte serait impossible.
findstr /m "firebasejs" "build\web\main.dart.js" >nul
if errorlevel 1 (
  echo FIREBASE ABSENT DE LA VERSION WEB >> "%LOG%"
  goto echec
)

if exist "%SORTIE%\web" rmdir /s /q "%SORTIE%\web"
mkdir "%SORTIE%\web\site"
xcopy /e /i /q /y "build\web" "%SORTIE%\web\site" >> "%LOG%" 2>&1
copy /y "distribution\web\lancer.bat" "%SORTIE%\web\" >> "%LOG%"
copy /y "distribution\web\serveur.ps1" "%SORTIE%\web\" >> "%LOG%"
copy /y "distribution\web\LISEZMOI.txt" "%SORTIE%\web\" >> "%LOG%"
if exist "%SORTIE%\%ZIP%" del "%SORTIE%\%ZIP%"
powershell -NoProfile -Command "Compress-Archive -Path '%SORTIE%\web\*' -DestinationPath '%SORTIE%\%ZIP%'" >> "%LOG%" 2>&1
if errorlevel 1 goto echec

echo === OK : %ZIP% === >> "%LOG%"
echo.
echo Termine : livraison\%ZIP%
echo (pour tester ici : livraison\web\lancer.bat)
pause
exit /b 0

:echec
echo === ECHEC === >> "%LOG%"
echo.
echo ECHEC de la construction : voir construction_web.log
pause
exit /b 1
