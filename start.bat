@echo off
title AUDIRA MAIL OS - Startup
echo ==============================================
echo       AUDIRA MAIL OS - STARTUP SCRIPT
echo ==============================================
echo.
echo Starting all microservices and databases via Docker Compose...
docker compose up -d --build
echo.
echo ==============================================
echo All components are now running in the background!
echo ==============================================
echo - Backend API: http://localhost:3311
echo - Frontend Web: http://localhost:3310
echo - Mail Engine: http://localhost:3312
echo - AI Engine: http://localhost:3313
echo - Worker Engine: http://localhost:3314
echo - Notification Engine: http://localhost:3315
echo.
pause
