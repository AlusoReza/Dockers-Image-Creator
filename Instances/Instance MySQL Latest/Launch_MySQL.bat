@echo off
setlocal enabledelayedexpansion
:: Asegura que el script se ejecute en la carpeta donde está guardado
cd /d "%~dp0"

:: --- LÓGICA DE DETECCIÓN AUTOMÁTICA DESDE EL .ENV ---
:: Buscamos las variables en el archivo .env para sincronizar todo el script
set "ENV_FILE=.env"
set "DETECTED_PORT=3306"
set "DETECTED_DB=Nombre_Base_de_Datos"

:: Extraemos el Puerto
for /f "tokens=2 delims==" %%a in ('findstr "PUERTO_HOST" %ENV_FILE%') do (
    set "DETECTED_PORT=%%a"
    :: Limpia posibles espacios o comillas
    set "DETECTED_PORT=!DETECTED_PORT: =!"
    set "DETECTED_PORT=!DETECTED_PORT:"=!"
)

:: Extraemos el Nombre de la Base de Datos
for /f "tokens=2 delims==" %%a in ('findstr "NOMBRE_DB" %ENV_FILE%') do (
    set "DETECTED_DB=%%a"
    set "DETECTED_DB=!DETECTED_DB: =!"
    set "DETECTED_DB=!DETECTED_DB:"=!"
)

:: =======================================================================================
:: LANZADOR Y CONFIGURADOR DE MYSQL (VERSIÓN AUTO-REPARABLE Y SINCRONIZADA CON .ENV)
:: Propósito: Levantar el contenedor, limpiar conflictos y configurar la DB.
:: =======================================================================================

title Lanzador de MySQL Docker [%DETECTED_PORT%]

echo [1/2] Gestionando contenedor MySQL...

:: 1. Intentamos arrancar si ya existe (Usando el puerto detectado en el nombre)
docker start mysql-workbench-server-%DETECTED_PORT% 2>nul

:: 2. Si hay un contenedor viejo con el mismo nombre que da error, lo quitamos.
:: Esto soluciona el error "Conflict. The container name is already in use".
docker rm -f mysql-workbench-server-%DETECTED_PORT% 2>nul

:: 3. Levantamos con la configuración del YAML actual (Docker Compose lee el .env solo)
:: Al estar el .bat y el .yml juntos, no hace falta especificar el nombre del archivo.
docker-compose up -d

echo.
echo [2/2] Configurando base de datos...
echo Esperando 60 segundos a que el servicio MySQL inicie correctamente...
:: MySQL necesita tiempo para inicializar los archivos en el volumen 'mysql_data'.
:: IMPORTANTE: Se usa PING porque 'timeout' suele fallar en la terminal de VS Code.
ping -n 60 127.0.0.1 > nul

echo Verificando base de datos [%DETECTED_DB%] y privilegios en puerto %DETECTED_PORT%...
:: El bloque entre paréntesis envía una ráfaga de comandos SQL al cliente interno de MySQL.
(
  :: Crea la base de datos si no existe (usando la variable del .env)
  echo CREATE DATABASE IF NOT EXISTS %DETECTED_DB%;
  
  :: Asegura que el usuario root pueda conectarse desde fuera del contenedor (host '%%')
  :: Se usa doble '%%' porque en archivos .bat un solo '%%' se confunde con una variable.
  echo ALTER USER 'root'@'%%' IDENTIFIED WITH mysql_native_password BY 'root';
  
  :: Refresca la tabla de permisos para aplicar los cambios de inmediato
  echo FLUSH PRIVILEGES;
  
  :: Muestra las bases de datos actuales para confirmar que todo está en orden
  echo SHOW DATABASES;
) | docker exec -i mysql-workbench-server-%DETECTED_PORT% mysql -u root -proot
:: NOTA: El nombre del contenedor se sincroniza automáticamente con el puerto detectado.

echo.
echo ======================================================
echo    SISTEMA LISTO! Datos de conexion MySQL:
echo ======================================================
echo    Host: localhost      ^|  Puerto: %DETECTED_PORT%
echo    Base de Datos: %DETECTED_DB%
echo    Usuario: root        ^|  Clave: root
echo    (Nota: Los datos estan a salvo en tu carpeta local)
echo ======================================================

:: Mantiene la ventana abierta para leer la confirmación
pause