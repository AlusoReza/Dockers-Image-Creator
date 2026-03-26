@echo off
title Lanzador IA Local - Serie 9000
setlocal enabledelayedexpansion

:: --- PREPARACIÓN DE CARPETAS ---
set "FOLDER=%~dp0"
cd /d "%FOLDER%"
if not exist "ollama_data" mkdir "ollama_data"
if not exist "webui_data" mkdir "webui_data"

echo ==========================================
echo    PASO 1: COMPROBANDO DOCKER DESKTOP
echo ==========================================

:: --- TU BLOQUE DE COMPROBACIÓN (EL QUE FUNCIONA) ---
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Docker no esta iniciado. Arrancando el motor...
    :: Intentamos abrir Docker Desktop (ruta estándar de Windows)
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    
    echo [?] Esperando respuesta del servicio...
    :wait_docker
    docker info >nul 2>&1
    if %errorlevel% neq 0 (
        <nul set /p=.
        timeout /t 2 >nul
        goto wait_docker
    )
    echo.
    echo [OK] Motor Docker listo.
) else (
    echo [OK] Docker ya esta en ejecucion.
)
timeout /t 1 >nul

echo.
echo ==========================================
echo    PASO 2: LANZANDO IA EN SERIE 9000
echo ==========================================

:: Levantamos los contenedores en segundo plano
docker compose up -d

:: Verificación final por si el .yml tiene algún error de sintaxis
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] No se pudieron levantar los contenedores.
    echo Revisa que el archivo docker-compose.yml este en esta carpeta.
    pause
    exit /b
)

echo.
echo [OK] IA activa. Abriendo interfaz visual...
timeout /t 3 /nobreak > nul
start http://localhost:3000

echo.
echo ==========================================
echo    SISTEMA LISTO - RX 9070 XT
echo ==========================================
pause
