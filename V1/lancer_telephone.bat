@echo off
rem Lance l'application pour la tester sur un TELEPHONE connecte au meme
rem reseau Wi-Fi que ce PC. Le telephone ouvre l'adresse affichee ci-dessous.
rem Tout est aussi enregistre dans lancement_telephone.log.
rem Fermer cette fenetre pour arreter.
chcp 65001 >nul
cd /d "%~dp0"
set "LOG=%~dp0lancement_telephone.log"
echo === Lancement telephone %date% %time% === > "%LOG%"

netstat -ano | findstr /R /C:":8080 .*LISTENING" >nul
if not errorlevel 1 (
  echo.
  echo  [!] Le port 8080 est deja utilise : ferme la fenetre "lancer_web"
  echo      ou "lancer_telephone" deja ouverte, puis relance ce fichier.
  echo PORT 8080 DEJA UTILISE >> "%LOG%"
  pause
  exit /b 1
)

echo.
echo  ============================================================
echo   Sur le telephone (connecte au MEME Wi-Fi que ce PC), ouvre :
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' -and $_.PrefixOrigin -ne 'WellKnown' } | ForEach-Object { $_.IPAddress }"`) do (
  echo      http://%%A:8080
  echo ADRESSE http://%%A:8080 >> "%LOG%"
)
echo.
echo   Attends la ligne "is being served at" ci-dessous (20 a 60 s).
echo   Si Windows demande d'autoriser l'acces reseau : coche
echo   "Reseaux prives" puis "Autoriser l'acces".
echo  ============================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080 2>&1 | Tee-Object -FilePath '%LOG%' -Append"

echo.
echo  Le serveur s'est arrete. Detail dans lancement_telephone.log
pause
