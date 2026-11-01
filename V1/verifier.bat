@echo off
rem Verification du code (analyse + tests). A relancer apres chaque modification.
rem Le resultat est ecrit dans verification.log pour que Claude puisse le lire.
chcp 65001 >nul
cd /d "%~dp0"
set "LOG=%~dp0verification.log"

echo Verification en cours...
echo === flutter pub get === > "%LOG%"
call flutter pub get >> "%LOG%" 2>&1

echo === flutter analyze === >> "%LOG%"
call flutter analyze >> "%LOG%" 2>&1

echo === flutter test === >> "%LOG%"
call flutter test >> "%LOG%" 2>&1

echo === FIN === >> "%LOG%"
type "%LOG%"
echo.
echo Termine. Resultat enregistre dans verification.log
pause
