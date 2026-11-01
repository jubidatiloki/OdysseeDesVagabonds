@echo off
rem Initialisation du projet Flutter (a lancer une seule fois).
rem Tout le resultat est ecrit dans initialisation.log pour que Claude puisse le lire.
chcp 65001 >nul
cd /d "%~dp0"
set "LOG=%~dp0initialisation.log"

echo Initialisation en cours, patiente quelques minutes...
echo === flutter --version === > "%LOG%"
call flutter --version >> "%LOG%" 2>&1

echo === flutter create === >> "%LOG%"
call flutter create . --project-name odyssee_vagabonds --org com.odysseevagabonds --platforms=android,ios,web >> "%LOG%" 2>&1

echo === flutter pub get === >> "%LOG%"
call flutter pub get >> "%LOG%" 2>&1

echo === flutter analyze === >> "%LOG%"
call flutter analyze >> "%LOG%" 2>&1

echo === flutter test === >> "%LOG%"
call flutter test >> "%LOG%" 2>&1

echo === FIN === >> "%LOG%"
type "%LOG%"
echo.
echo Termine. Resultat enregistre dans initialisation.log
pause
