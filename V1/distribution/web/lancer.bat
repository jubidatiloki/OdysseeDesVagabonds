@echo off
rem Lance L'odyssee des vagabonds dans le navigateur (http://localhost:8088).
rem Aucune installation necessaire. Laisser la fenetre ouverte pendant le jeu.
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0serveur.ps1"
pause
