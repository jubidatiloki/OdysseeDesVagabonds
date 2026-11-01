@echo off
rem Construit l'application Windows (.exe) :
rem   ..\livraison\odyssee_vagabonds_windows.zip
rem Prerequis sur CE PC : Visual Studio 2022 (gratuit, edition Community)
rem avec la charge de travail "Developpement Desktop en C++".
rem Tout est enregistre dans construction_windows.log.
chcp 65001 >nul
cd /d "%~dp0"
set "LOG=%~dp0construction_windows.log"
set "SORTIE=%~dp0..\livraison"
set "RELEASE=build\windows\x64\runner\Release"

echo Construction de l'application Windows en cours (2 a 5 minutes)...
echo === Construction Windows %date% %time% === > "%LOG%"

rem 1. Ajoute la plateforme Windows au projet si elle manque
if not exist "windows" (
  echo === flutter create --platforms=windows === >> "%LOG%"
  call flutter create --platforms=windows --project-name odyssee_vagabonds . >> "%LOG%" 2>&1
)

rem 2. Verifie la chaine de compilation (Visual Studio)
echo === flutter doctor === >> "%LOG%"
call flutter doctor -v >> "%LOG%" 2>&1

rem 3. Compilation
echo === flutter build windows === >> "%LOG%"
call flutter pub get >> "%LOG%" 2>&1
call flutter build windows --release >> "%LOG%" 2>&1
if errorlevel 1 goto echec
if not exist "%RELEASE%\odyssee_vagabonds.exe" goto echec

rem 4. Paquet a emporter
if exist "%SORTIE%\windows" rmdir /s /q "%SORTIE%\windows"
mkdir "%SORTIE%\windows"
xcopy /e /i /q /y "%RELEASE%" "%SORTIE%\windows" >> "%LOG%" 2>&1
copy /y "distribution\windows\LISEZMOI.txt" "%SORTIE%\windows\" >> "%LOG%"
if exist "%SORTIE%\odyssee_vagabonds_windows.zip" del "%SORTIE%\odyssee_vagabonds_windows.zip"
powershell -NoProfile -Command "Compress-Archive -Path '%SORTIE%\windows\*' -DestinationPath '%SORTIE%\odyssee_vagabonds_windows.zip'" >> "%LOG%" 2>&1
if errorlevel 1 goto echec

echo === OK === >> "%LOG%"
echo.
echo Termine : livraison\odyssee_vagabonds_windows.zip
echo (pour tester ici : livraison\windows\odyssee_vagabonds.exe)
pause
exit /b 0

:echec
echo === ECHEC === >> "%LOG%"
echo.
echo ECHEC de la construction : voir construction_windows.log
echo (cause la plus frequente : Visual Studio 2022 avec "Developpement
echo  Desktop en C++" n'est pas installe)
pause
exit /b 1
