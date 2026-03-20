@echo off
setlocal enabledelayedexpansion
:: Asegura que el script se ejecute en la carpeta donde está guardado
cd /d "%~dp0"

:: --- LÓGICA DE DETECCIÓN AUTOMÁTICA DESDE EL .ENV ---
:: Buscamos las variables en el archivo .env para sincronizar todo el script
set "ENV_FILE=.env"
set "DETECTED_PORT=1521"
set "DETECTED_PASS=Oracle123"

:: Extraemos el Puerto del Host
for /f "tokens=2 delims==" %%a in ('findstr "PUERTO_HOST" %ENV_FILE%') do (
    set "DETECTED_PORT=%%a"
    :: Limpieza de espacios o comillas
    set "DETECTED_PORT=!DETECTED_PORT: =!"
    set "DETECTED_PORT=!DETECTED_PORT:"=!"
)

:: Extraemos la Contraseña de Oracle
for /f "tokens=2 delims==" %%a in ('findstr "ORACLE_PASS" %ENV_FILE%') do (
    set "DETECTED_PASS=%%a"
    set "DETECTED_PASS=!DETECTED_PASS: =!"
    set "DETECTED_PASS=!DETECTED_PASS:"=!"
)

:: =======================================================================================
:: LANZADOR Y CONFIGURADOR AUTOMÁTICO DE ORACLE XE (VERSIÓN AUTO-SINCRONIZADA CON .ENV)
:: Propósito: Levantar Docker y configurar privilegios/contraseñas de la base de datos.
:: =======================================================================================

title Lanzador de Oracle Docker [%DETECTED_PORT%]

echo [1/3] Verificando login...
:: Autenticación necesaria para bajar la imagen oficial de Oracle
docker login container-registry.oracle.com

echo.
echo [2/3] Gestionando contenedor...
:: 1. Intentamos arrancar si ya existe (Usando el puerto detectado en el nombre)
docker start oracle-xe-%DETECTED_PORT% 2>nul

:: 2. Si hay un conflicto de nombre (por carpetas movidas), lo quitamos.
:: Esto asegura que el contenedor se cree con el nombre correcto: oracle-xe-%DETECTED_PORT%
docker rm -f oracle-xe-%DETECTED_PORT% 2>nul

:: 3. Levantamos con la configuración del YAML actual (Docker Compose lee el .env solo)
:: Al estar el .bat y el .yml en la misma carpeta, usamos el comando estándar
docker-compose up -d

echo.
echo [3/3] Configurando base de datos...
echo Esperando 60 segundos a que el motor despierte en el puerto %DETECTED_PORT%...
:: Nota: Se usa PING porque 'timeout' a veces falla en terminales integradas como VS Code.
:: El flujo se pausa para dar tiempo a que los procesos internos de Oracle inicien.
ping -n 60 127.0.0.1 > nul

echo Enviando comandos SQL...
:: El siguiente bloque (entre paréntesis) agrupa comandos que se envían por "tubería" (pipe |)
:: al comando 'docker exec', el cual entra al contenedor y ejecuta SQL*Plus.
(
  :: Abre la base de datos conectable (PDB) para permitir lectura y escritura
  echo ALTER PLUGGABLE DATABASE XEPDB1 OPEN READ WRITE;
  
  :: Permite ejecutar scripts y cambios de usuarios de forma tradicional (Oracle 12c+ logic)
  echo ALTER SESSION SET "_ORACLE_SCRIPT"=true;
  
  :: Cambia/Asegura la contraseña del usuario SYSTEM en la raíz (CDB)
  echo ALTER USER system IDENTIFIED BY %DETECTED_PASS%;
  
  :: Cambia el contexto a la base de datos XEPDB1 (donde solemos trabajar)
  echo ALTER SESSION SET CONTAINER = XEPDB1;
  
  :: Cambia/Asegura la contraseña del usuario SYSTEM dentro de la PDB
  echo ALTER USER system IDENTIFIED BY %DETECTED_PASS%;
  
  :: Sale de SQL*Plus para finalizar el proceso
  echo EXIT;
) | docker exec -i oracle-xe-%DETECTED_PORT% sqlplus / as sysdba
:: NOTA: El nombre del contenedor se sincroniza automáticamente con el puerto detectado.

echo.
echo ==============================================
echo    SISTEMA LISTO! Datos de conexion:
echo ==============================================
echo    Host: localhost  ^| Puerto: %DETECTED_PORT%
echo    Service Name: XEPDB1
echo    Usuario: system  ^| Clave: %DETECTED_PASS%
echo    (Los datos persisten en la carpeta oracle_data)
echo ==============================================

:: Pausa final para que el usuario pueda leer los datos antes de cerrar la ventana
pause