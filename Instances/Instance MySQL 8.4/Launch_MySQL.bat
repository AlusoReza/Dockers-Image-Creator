@echo off
setlocal enabledelayedexpansion
:: Asegura que el script se ejecute en la carpeta donde está guardado el archivo .bat
:: Esto evita errores de rutas relativas si se ejecuta como Administrador.
cd /d "%~dp0"

:: =======================================================================================
:: 1. EXTRACCIÓN DE CONFIGURACIÓN DINÁMICA DESDE EL ARCHIVO .ENV
:: =======================================================================================

:: Definimos el archivo fuente y valores por defecto (fallback) en caso de error
set "ENV_FILE=.env"
set "DETECTED_PORT=3306"
set "DETECTED_DB=mi_base_datos"
set "USER_DB=root"
set "PASS_DB=root"

:: Verificación de seguridad: Si el archivo .env no existe, detenemos el script con un aviso
if not exist %ENV_FILE% (
    echo [ERROR] No se encuentra el archivo %ENV_FILE% en esta carpeta.
    pause
    exit
)

:: --- LÓGICA DE LIMPIEZA DE VARIABLES ---
:: Buscamos cada variable, separamos por el "=" y eliminamos espacios o comillas accidentales.

:: Puerto del Host (el que abres en Windows para mapear al 3306 interno)
for /f "tokens=2 delims==" %%a in ('findstr "PUERTO_HOST" %ENV_FILE%') do (
    set "DETECTED_PORT=%%a"
    set "DETECTED_PORT=!DETECTED_PORT: =!"
    set "DETECTED_PORT=!DETECTED_PORT:"=!"
)

:: Nombre de la Base de Datos que se creara al inicio
for /f "tokens=2 delims==" %%a in ('findstr "NOMBRE_DB" %ENV_FILE%') do (
    set "DETECTED_DB=%%a"
    set "DETECTED_DB=!DETECTED_DB: =!"
    set "DETECTED_DB=!DETECTED_DB:"=!"
)

:: Usuario personalizado definido en el entorno .env
for /f "tokens=2 delims==" %%a in ('findstr "MYSQL_USER" %ENV_FILE%') do (
    set "USER_DB=%%a"
    set "USER_DB=!USER_DB: =!"
    set "USER_DB=!USER_DB:"=!"
)

:: Contraseña para el usuario personalizado del .env
for /f "tokens=2 delims==" %%a in ('findstr "MYSQL_PASS" %ENV_FILE%') do (
    set "PASS_DB=%%a"
    set "PASS_DB=!PASS_DB: =!"
    set "PASS_DB=!PASS_DB:"=!"
)

:: =======================================================================================
:: 2. GESTIÓN DEL CONTENEDOR DOCKER (ARRANQUE Y LIMPIEZA)
:: =======================================================================================

:: Cambiamos el título de la terminal para identificar el puerto y usuario activos
title Lanzador de MySQL [%USER_DB%@localhost:%DETECTED_PORT%]

echo [1/3] Gestionando contenedor MySQL...

:: 1. Eliminamos el contenedor actual para forzar una recreacion limpia.
:: Esto asegura que Docker aplique cualquier cambio nuevo en el archivo YAML.
docker rm -f mysql-workbench-server-%DETECTED_PORT% 2>nul

:: 2. Levantamos el servicio usando Docker Compose en segundo plano (-d)
:: Se asume que el archivo se llama docker-compose.yml por defecto.
call docker-compose up -d
if %errorlevel% neq 0 (
    echo [ERROR] Fallo al ejecutar docker-compose. Revisa tu archivo YAML.
    pause
    exit
)

echo.
echo [2/3] Configurando base de datos...
echo Esperando la señal definitiva: "port: 3306  MySQL Community Server"...
echo (Este proceso lee los logs internos de MySQL para confirmar el arranque)

:: =======================================================================================
:: 3. BUCLE DE ESPERA INTELIGENTE Y ASIGNACIÓN DE PRIVILEGIOS TOTALES
:: =======================================================================================

:wait_mysql
:: Buscamos la frase exacta en los logs que confirma que MySQL esta listo para trabajar.
docker logs mysql-workbench-server-%DETECTED_PORT% 2>&1 | findstr /C:"port: 3306  MySQL Community Server" >nul

:: Si el comando findstr no encuentra la frase (errorlevel != 0), seguimos esperando.
if %errorlevel% neq 0 (
    :: Feedback visual para el usuario (puntos de progreso)
    <nul set /p=.
    :: Pausa de 5 segundos antes de reintentar la lectura de logs
    ping -n 5 127.0.0.1 > nul
    goto :wait_mysql
)

echo.
echo [OK] Servidor detectado. Aplicando parche de seguridad y privilegios...

:: --- PARCHE DE SEGURIDAD Y PERMISOS DE ADMINISTRADOR ---
:: 1. Ponemos clave a root para cerrar la brecha de seguridad inicial (empty password).
:: 2. Creamos/Actualizamos tu usuario y le damos permisos de superusuario (GRANT ALL).
:: Esto permite que tu usuario vea esquemas del sistema como 'sys' con GRANT OPTION.
docker exec -i mysql-workbench-server-%DETECTED_PORT% mysql -u root --password="" -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'root'; ALTER USER 'root'@'%%' IDENTIFIED WITH caching_sha2_password BY 'root'; CREATE USER IF NOT EXISTS '%USER_DB%'@'%%' IDENTIFIED BY '%PASS_DB%'; GRANT ALL PRIVILEGES ON *.* TO '%USER_DB%'@'%%' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>nul

:: ================= : 4. RESUMEN FINAL DE CONEXIÓN =======================================

echo.
echo ============================================================
echo    ¡SISTEMA LISTO Y PROTEGIDO!
echo ============================================================
echo    Host: localhost      ^|  Puerto: %DETECTED_PORT%
echo    Base de Datos: %DETECTED_DB%
echo    Usuario: %USER_DB%   ^|  Clave: %PASS_DB%
echo    (Nota: Tanto 'root' como '%USER_DB%' estan activos)
echo ============================================================

:: Mantiene la ventana abierta para leer el resumen de conexion o posibles errores
pause