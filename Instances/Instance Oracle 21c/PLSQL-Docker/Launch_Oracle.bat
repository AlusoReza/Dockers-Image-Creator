@echo off
setlocal enabledelayedexpansion
:: Asegura que el script se ejecute en la carpeta donde está guardado el archivo .bat
:: Esto evita errores de rutas relativas si se ejecuta como Administrador.
cd /d "%~dp0"

:: =======================================================================================
:: 1. EXTRACCIÓN DE CONFIGURACIÓN DINÁMICA DESDE EL ARCHIVO .ENV
:: =======================================================================================

:: Definimos el nombre del archivo de configuración y valores por defecto (fallback)
set "ENV_FILE=.env"
set "DETECTED_PORT=1521"
set "DETECTED_PASS=Oracle123"

:: Verificación de seguridad: Si el archivo .env no existe, detenemos el script con un aviso
if not exist %ENV_FILE% (
    echo [ERROR] No se encuentra el archivo %ENV_FILE% en esta carpeta.
    pause
    exit
)

:: --- LÓGICA DE LIMPIEZA DE VARIABLES ---
:: Buscamos la variable PUERTO_HOST en el .env para sincronizar el mapeo de puertos.
for /f "tokens=2 delims==" %%a in ('findstr "PUERTO_HOST" %ENV_FILE%') do (
    set "DETECTED_PORT=%%a"
    :: Limpiamos posibles espacios en blanco o comillas dobles del valor extraído.
    set "DETECTED_PORT=!DETECTED_PORT: =!"
    set "DETECTED_PORT=!DETECTED_PORT:"=!"
)

:: Buscamos la variable ORACLE_PASS en el .env para usar la misma clave en SQL*Plus.
for /f "tokens=2 delims==" %%a in ('findstr "ORACLE_PASS" %ENV_FILE%') do (
    set "DETECTED_PASS=%%a"
    set "DETECTED_PASS=!DETECTED_PASS: =!"
    set "DETECTED_PASS=!DETECTED_PASS:"=!"
)

:: =======================================================================================
:: 2. GESTIÓN DE CONTENEDORES DOCKER (ARRANQUE Y LIMPIEZA)
:: =======================================================================================

:: Cambiamos el título de la ventana para identificar el proceso y el puerto activo.
title Lanzador de Oracle Docker [%DETECTED_PORT%]

echo [1/3] Verificando login en Oracle Registry...
:: Intentamos loguearnos. Si ya hay credenciales guardadas, Docker las usará automáticamente.
call docker login container-registry.oracle.com

echo.
echo [2/3] Levantando infraestructura con Docker Compose...

:: 1. Intentamos arrancar el contenedor por si ya existe pero está apagado.
:: Redirigimos posibles errores a 'nul' para mantener la consola limpia.
call docker start oracle-xe-%DETECTED_PORT% 2>nul

:: 2. Si el contenedor tiene conflictos de red o nombre, lo eliminamos para recrearlo limpio.
:: Esto asegura que Docker Compose aplique los cambios del .env correctamente.
call docker rm -f oracle-xe-%DETECTED_PORT% 2>nul

:: 3. Ejecutamos Docker Compose. Usamos 'call' para que el script no se cierre al terminar.
:: El flag '-d' lanza el proceso en segundo plano (detached mode).
call docker-compose up -d
if %errorlevel% neq 0 (
    echo [ERROR] Hubo un problema al levantar el contenedor de Oracle.
    pause
    exit
)

echo.
echo [3/3] Configurando base de datos (Fase Critica)...
echo Sincronizando con el proceso interno de Oracle XE 21c...
echo ESPERANDO A QUE APAREZCA: "DATABASE IS READY TO USE!"
echo (Este proceso lee los logs internos para asegurar que los archivos .dbf estan creados)

:: =======================================================================================
:: 3. BUCLE DE ESPERA INTELIGENTE (LECTURA DE LOGS EN TIEMPO REAL)
:: =======================================================================================

:wait_ready
:: 'docker logs' nos muestra la salida de consola interna del contenedor.
:: Filtramos buscando la frase exacta que Oracle escribe al finalizar la instalacion inicial.
docker logs oracle-xe-%DETECTED_PORT% 2>&1 | findstr /C:"DATABASE IS READY TO USE" >nul

:: Si 'findstr' no encuentra la frase (errorlevel != 0), Oracle sigue trabajando internamente.
if %errorlevel% neq 0 (
    :: Imprime un punto de progreso en la misma linea para mostrar actividad.
    <nul set /p=.
    :: Esperamos 10 segundos antes de volver a consultar los logs (Oracle es pesado al arrancar).
    ping -n 10 127.0.0.1 > nul
    goto :wait_ready
)

echo.
echo [OK] Confirmacion recibida: La base de datos esta operativa al 100%%.
echo Aplicando margen de seguridad de 15 segundos para estabilidad del Listener...
:: Pausa extra necesaria para que el servicio de red de Oracle acepte conexiones externas.
ping -n 15 127.0.0.1 > nul

echo.
echo Enviando comandos SQL finales de configuracion...

:: =======================================================================================
:: 4. CONFIGURACIÓN SQL FINAL (SQL*PLUS MEDIANTE ARCHIVO TEMPORAL)
:: =======================================================================================

:: Creamos un archivo SQL temporal. Este método es el más estable y evita cierres inesperados.
set "TEMP_ORACLE=temp_oracle.sql"

:: A. Abrimos la base de datos conectable (PDB) para que acepte operaciones de lectura/escritura.
echo ALTER PLUGGABLE DATABASE XEPDB1 OPEN READ WRITE; > %TEMP_ORACLE%

:: B. Activamos el modo script para permitir cambios de usuarios sin prefijos C## (Compatibilidad 21c).
echo ALTER SESSION SET "_ORACLE_SCRIPT"=true; >> %TEMP_ORACLE%

:: C. Sincronizamos la contraseña del usuario SYSTEM en el contenedor raiz (CDB).
echo ALTER USER system IDENTIFIED BY %DETECTED_PASS%; >> %TEMP_ORACLE%

:: D. Cambiamos el contexto de la sesión a la base de datos XEPDB1 para configurarla por dentro.
echo ALTER SESSION SET CONTAINER = XEPDB1; >> %TEMP_ORACLE%

:: E. Sincronizamos la contraseña de SYSTEM tambien dentro de la PDB para acceso via Service Name.
echo ALTER USER system IDENTIFIED BY %DETECTED_PASS%; >> %TEMP_ORACLE%

:: F. Cerramos la sesion de SQL*Plus de forma limpia.
echo EXIT; >> %TEMP_ORACLE%

:: Enviamos el archivo temporal al contenedor usando SQL*Plus en modo silencioso (-S).
type %TEMP_ORACLE% | docker exec -i oracle-xe-%DETECTED_PORT% sqlplus -S / as sysdba

:: Limpieza: Borramos el archivo temporal SQL.
del %TEMP_ORACLE%

echo.
echo ============================================================
echo    SISTEMA LISTO! La base de datos esta configurada.
echo ============================================================
echo    Host: localhost  ^| Puerto: %DETECTED_PORT%
echo    Service Name: XEPDB1 (Para conexiones externas)
echo    Usuario: system  ^| Clave: %DETECTED_PASS%
echo.
echo    Nota: Los datos estan seguros en la carpeta oracle_data.
echo ============================================================

:: Mantiene la ventana abierta para que el usuario pueda copiar las credenciales.
pause