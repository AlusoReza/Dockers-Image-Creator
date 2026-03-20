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

:: Puerto del Host (el que abres en Windows)
for /f "tokens=2 delims==" %%a in ('findstr "PUERTO_HOST" %ENV_FILE%') do (
    set "DETECTED_PORT=%%a"
    set "DETECTED_PORT=!DETECTED_PORT: =!"
    set "DETECTED_PORT=!DETECTED_PORT:"=!"
)

:: Nombre de la Base de Datos a gestionar
for /f "tokens=2 delims==" %%a in ('findstr "NOMBRE_DB" %ENV_FILE%') do (
    set "DETECTED_DB=%%a"
    set "DETECTED_DB=!DETECTED_DB: =!"
    set "DETECTED_DB=!DETECTED_DB:"=!"
)

:: Usuario personalizado del .env
for /f "tokens=2 delims==" %%a in ('findstr "MYSQL_USER" %ENV_FILE%') do (
    set "USER_DB=%%a"
    set "USER_DB=!USER_DB: =!"
    set "USER_DB=!USER_DB:"=!"
)

:: Contraseña personalizada del .env
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

echo [1/2] Gestionando contenedor MySQL...

:: 1. Intentamos arrancar el contenedor si ya existe pero estaba apagado
docker start mysql-workbench-server-%DETECTED_PORT% 2>nul

:: 2. Eliminamos el contenedor actual para forzar una recreación limpia con los datos del .env
:: Esto evita el error "Conflict. Name already in use".
docker rm -f mysql-workbench-server-%DETECTED_PORT% 2>nul

:: 3. Levantamos el servicio usando Docker Compose en segundo plano (-d)
:: Usamos 'call' para asegurar que el script continúe tras la ejecución de docker-compose
call docker-compose up -d
if %errorlevel% neq 0 (
    echo [ERROR] Fallo al ejecutar docker-compose. Revisa tu archivo YAML.
    pause
    exit
)

echo.
echo [2/2] Configurando base de datos...
echo Esperando la señal definitiva: "port: 3306  MySQL Community Server"...
echo (Este proceso lee los logs internos de MySQL para evitar errores de conexion)

:: =======================================================================================
:: 3. BUCLE DE ESPERA INTELIGENTE (LOGS EN TIEMPO REAL)
:: =======================================================================================

:wait_mysql
:: Buscamos la frase que indica que el servidor REAL (no el temporal de inicio) está listo.
docker logs mysql-workbench-server-%DETECTED_PORT% 2>&1 | findstr /C:"port: 3306  MySQL Community Server" >nul

:: Si el comando findstr no encuentra la frase (errorlevel != 0), seguimos esperando.
if %errorlevel% neq 0 (
    :: Feedback visual: un punto cada 5 segundos
    <nul set /p=.
    :: Pausa controlada usando PING (más fiable que TIMEOUT en terminales integradas)
    ping -n 5 127.0.0.1 > nul
    goto :wait_mysql
)

echo.
echo [OK] Servidor MySQL (Version Moderna) detectado y listo.
echo Aplicando permisos y sincronizando credenciales...

:: Margen de seguridad para que los hilos de red de Docker se asienten totalmente
ping -n 15 127.0.0.1 > nul

:: =======================================================================================
:: 4. INYECCIÓN DE COMANDOS SQL (MÉTODO SEGURO POR ARCHIVO TEMPORAL)
:: =======================================================================================

:: Creamos un archivo SQL temporal. Esto evita que el .bat "pete" por conflictos de paréntesis.
set "TEMP_SQL=temp_init.sql"

:: A. Aseguramos la existencia de la base de datos definida en el .env
echo CREATE DATABASE IF NOT EXISTS %DETECTED_DB%; > %TEMP_SQL%

:: B. Gestión del usuario personalizado (si no es root)
:: Usamos 'caching_sha2_password' para compatibilidad con MySQL 8.0 y 9.0+
if /i "%USER_DB%" NEQ "root" (
    echo CREATE USER IF NOT EXISTS '%USER_DB%'@'%%' IDENTIFIED BY '%PASS_DB%'; >> %TEMP_SQL%
    echo ALTER USER '%USER_DB%'@'%%' IDENTIFIED WITH caching_sha2_password BY '%PASS_DB%'; >> %TEMP_SQL%
    echo GRANT ALL PRIVILEGES ON *.* TO '%USER_DB%'@'%%' WITH GRANT OPTION; >> %TEMP_SQL%
)

:: C. Aseguramos que el usuario ROOT sea accesible externamente y use el plugin moderno
:: Bloqueamos específicamente root en todas sus formas posibles para que pida clave 'root'
echo ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'root'; >> %TEMP_SQL%
echo ALTER USER 'root'@'127.0.0.1' IDENTIFIED WITH caching_sha2_password BY 'root'; >> %TEMP_SQL%
echo ALTER USER 'root'@'%%' IDENTIFIED WITH caching_sha2_password BY 'root'; >> %TEMP_SQL%

:: D. Recarga de la tabla de privilegios para aplicar los cambios de inmediato
echo FLUSH PRIVILEGES; >> %TEMP_SQL%

:: --- EJECUCIÓN DOBLE (CIERRE DE BRECHA) ---
:: 1. Intentamos inyectar asumiendo que root NO tiene clave (según tus logs)
type %TEMP_SQL% | docker exec -i mysql-workbench-server-%DETECTED_PORT% mysql -u root 2>nul

:: 2. Si falló porque ya tenía clave, intentamos con 'root'
if %errorlevel% neq 0 (
    type %TEMP_SQL% | docker exec -i mysql-workbench-server-%DETECTED_PORT% mysql -u root -proot 2>nul
)

:: Limpieza: Borramos el archivo temporal para no dejar basura en el proyecto
if exist %TEMP_SQL% del %TEMP_SQL%

echo.
echo ============================================================
echo    SISTEMA LISTO! Datos de conexion actualizados:
echo ============================================================
echo    Host: localhost      ^|  Puerto: %DETECTED_PORT%
echo    Base de Datos: %DETECTED_DB%
echo    Usuario: %USER_DB%   ^|  Clave: %PASS_DB%
echo    (Metodo: caching_sha2_password habilitado)
echo ============================================================

:: Mantiene la ventana abierta para leer el resumen de conexión
pause