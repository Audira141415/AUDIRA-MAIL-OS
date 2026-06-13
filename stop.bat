@echo off
title AUDIRA MAIL OS - Shutdown
echo ==============================================
echo       AUDIRA MAIL OS - SHUTDOWN SCRIPT
echo ==============================================
echo.
echo Stopping and removing all microservices and databases...
docker compose down
echo.
echo ==============================================
echo All components have been stopped successfully!
echo ==============================================
echo.
pause
