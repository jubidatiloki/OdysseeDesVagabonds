@echo off
rem Construit l'application Android (APK) a installer sur un telephone :
rem   ..\livraison\odyssee_vagabonds.apk
rem Utilise le JDK 17 (le Java 25 installe est trop recent pour Android).
rem La premiere fois, Gradle telecharge ses outils : 5 a 15 minutes.
rem Tout est enregistre dans construction_apk.log.
chcp 65001 >nul
cd /d "%~dp0"
set "LOG=%~dp0construction_apk.log"
set "SORTIE=%~dp0..\livraison"
set "APK=build\app\outputs\flutter-apk\app-release.apk"

echo Construction de l'APK Android en cours (5 a 15 minutes la premiere fois)...
echo === Construction APK %date% %time% === > "%LOG%"

rem 1. Choix d'un Java compatible (17 a 24)
set "JDK="
for /d %%D in ("C:\Program Files\Eclipse Adoptium\jdk-17*") do set "JDK=%%~D"
if not defined JDK if exist "C:\Program Files\Android\Android Studio\jbr\bin\java.exe" set "JDK=C:\Program Files\Android\Android Studio\jbr"
if defined JDK goto jdk_ok
echo AUCUN JDK 17 TROUVE >> "%LOG%"
echo.
echo  [!] Aucun Java 17 trouve. Installe "Eclipse Temurin 17" (adoptium.net).
goto echec
:jdk_ok
echo JDK utilise : %JDK% >> "%LOG%"
set "JAVA_HOME=%JDK%"
call flutter config --jdk-dir="%JDK%" >> "%LOG%" 2>&1

rem 2. Etat de l'installation Android
echo === flutter doctor === >> "%LOG%"
call flutter doctor -v >> "%LOG%" 2>&1

rem 3. Compilation
echo === flutter build apk === >> "%LOG%"
call flutter pub get >> "%LOG%" 2>&1
call flutter build apk --release >> "%LOG%" 2>&1
if errorlevel 1 goto echec
if not exist "%APK%" goto echec

if not exist "%SORTIE%" mkdir "%SORTIE%"
copy /y "%APK%" "%SORTIE%\odyssee_vagabonds.apk" >> "%LOG%"
echo === OK === >> "%LOG%"
echo.
echo Termine : livraison\odyssee_vagabonds.apk
echo Copie ce fichier sur le telephone (cable USB, Google Drive, mail...)
echo puis ouvre-le pour l'installer.
pause
exit /b 0

:echec
echo === ECHEC === >> "%LOG%"
echo.
echo ECHEC de la construction : voir construction_apk.log
pause
exit /b 1
