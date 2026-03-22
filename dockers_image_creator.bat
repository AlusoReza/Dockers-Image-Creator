@echo off
setlocal enabledelayedexpansion
title Dockers-Image-Creator Menu
:: 0 = Negro, B = Azul claro (Estética Docker)
color 0B

:: --- COMPROBACIÓN DE DOCKER DESKTOP ---
echo [*] Comprobando estado de Docker Desktop...
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

:: --- BUCLE PRINCIPAL DEL MENÚ ---
:menu
cls
:: Reforzamos el color por si algun script hijo lo cambio
color 0B
echo ===================================================
echo               DOCKERS-IMAGE-CREATOR
echo                  Por Alonso Reza
echo ===================================================
echo.
echo Selecciona la instancia Docker que deseas lanzar:
echo.
echo  [1] Instancia MySQL 8.4
echo  [2] Instancia Oracle 21c
echo.
echo  [0] Salir y Cerrar Terminal
echo.
echo ===================================================
set /p opcion="Seleccion (0-2): "

:: Control de navegación
if "%opcion%"=="1" goto run_mysql
if "%opcion%"=="2" goto run_oracle
if "%opcion%"=="0" goto end_script

:: Manejo de errores (opción no válida)
echo.
echo [ERROR] "%opcion%" no es una opcion valida.
pause
goto menu

:: --- BLOQUES DE EJECUCIÓN ---

:run_mysql
echo.
echo [+] Ejecutando: Launch_MySQL.bat...
:: IMPORTANTE: Usamos comillas por los espacios en la ruta
call ".\Instances\Instance MySQL 8.4\Launch_MySQL.bat"
color 0B
echo.
echo [INFO] Proceso de MySQL finalizado. Volviendo al menu...
pause
goto menu

:run_oracle
echo.
echo [+] Ejecutando: Launch_Oracle.bat...
:: IMPORTANTE: Usamos comillas por los espacios en la ruta
call ".\Instances\Instance Oracle 21c\PLSQL-Docker\Launch_Oracle.bat"
color 0B
echo.
echo [INFO] Proceso de Oracle finalizado. Volviendo al menu...
pause
goto menu

:: --- SALIDA DEL SCRIPT ---

:end_script
cls
:: Devolvemos el color original a la consola de Windows (Gris/Blanco)
color 07
echo.
echo Gracias por usar Dockers-Image-Creator.
echo Desarrollado por Alonso Reza.
echo.
echo Cerrando en 2 segundos...
timeout /t 2 >nul
exit