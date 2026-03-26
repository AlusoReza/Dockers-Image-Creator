@echo off
title Liberador de Recursos - Finalizar IA Local
setlocal enabledelayedexpansion

:: 1. SITUARSE EN LA CARPETA DEL SCRIPT
set "FOLDER=%~dp0"
cd /d "%FOLDER%"

echo ==========================================
echo    DETENIENDO SERVICIOS DE IA...
echo ==========================================

:: 2. DETENER CONTENEDORES (Libera VRAM inmediatamente)
docker compose stop

if %errorlevel% neq 0 (
    echo [!] No se pudieron detener los contenedores. ¿Docker esta abierto?
) else (
    echo [OK] Contenedores detenidos correctamente.
)

echo.
echo ==========================================
echo    LIBERANDO RECURSOS DEL SISTEMA
echo ==========================================

:: 3. OPCIONAL: CERRAR DOCKER DESKTOP POR COMPLETO
:: Esto libera la RAM que consume el motor de Docker en segundo plano.
set /p cerrar="¿Quieres cerrar Docker Desktop por completo para ganar mas RAM? (S/N): "
if /i "!cerrar!"=="S" (
    echo [INFO] Cerrando procesos de Docker...
    taskkill /F /IM "Docker Desktop.exe" /T >nul 2>&1
    taskkill /F /IM "com.docker.backend.exe" /T >nul 2>&1
    echo [OK] Docker Desktop cerrado.
)

echo.
echo ==========================================
echo    ESTADO: RX 9070 XT LIBRE PARA JUGAR
echo ==========================================
echo.
echo Presiona cualquier tecla para salir.
pause
