@echo off
rem Lance l'application web sur une adresse FIXE : http://localhost:8080
rem Toujours utiliser cette adresse, dans le meme navigateur : c'est la que
rem les personnages sont sauvegardes (stockage local du navigateur).
rem Tout ce qui s'affiche est aussi enregistre dans lancement_web.log.
rem Fermer cette fenetre pour arreter le serveur.
chcp 65001 >nul
cd /d "%~dp0"
set "LOG=%~dp0lancement_web.log"
echo === Lancement %date% %time% === > "%LOG%"

rem 1. Le port 8080 est-il deja pris (ancienne fenetre encore ouverte) ?
netstat -ano | findstr /R /C:":8080 .*LISTENING" >nul
if not errorlevel 1 (
  echo.
  echo  [!] Le port 8080 est deja utilise.
  echo      Une ancienne fenetre "lancer_web" est sans doute encore ouverte :
  echo      ferme-la, puis relance ce fichier.
  echo      Si l'application tourne deja, ouvre simplement http://localhost:8080
  echo.
  echo PORT 8080 DEJA UTILISE >> "%LOG%"
  netstat -ano | findstr /R /C:":8080 .*LISTENING" >> "%LOG%"
  pause
  exit /b 1
)

echo.
echo  L'application va s'ouvrir dans ton navigateur : http://localhost:8080
echo  (compilation : 20 a 60 secondes ; si la page est vide, attends la ligne
echo   "is being served at" ci-dessous puis actualise avec F5)
echo.
start "" cmd /c "timeout /t 40 /nobreak >nul && start http://localhost:8080"

rem 2. Lancement, avec copie de toute la sortie dans lancement_web.log
powershell -NoProfile -ExecutionPolicy Bypass -Command "flutter run -d web-server --web-hostname=localhost --web-port=8080 2>&1 | Tee-Object -FilePath '%LOG%' -Append"

echo.
echo  Le serveur s'est arrete. Detail dans lancement_web.log
pause
