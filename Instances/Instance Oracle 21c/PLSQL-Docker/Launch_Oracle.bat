@echo off
:: Asegura que el script se ejecute en la carpeta donde está guardado
cd /d "%~dp0"

:: =======================================================================================
:: LANZADOR Y CONFIGURADOR AUTOMÁTICO DE ORACLE XE
:: Propósito: Levantar Docker y configurar privilegios/contraseñas de la base de datos.
:: =======================================================================================

title Lanzador de Oracle Docker

echo [1/3] Verificando login...
:: Autenticación necesaria para bajar la imagen oficial de Oracle
docker login container-registry.oracle.com

echo.
echo [2/3] Levantando contenedor...
:: Al estar el .bat y el .yml en la misma carpeta, usamos el comando estándar
docker-compose up -d

echo.
echo [3/3] Configurando base de datos...
echo Esperando 60 segundos a que el motor despierte...
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
  echo ALTER USER system IDENTIFIED BY Oracle123;
  
  :: Cambia el contexto a la base de datos XEPDB1 (donde solemos trabajar)
  echo ALTER SESSION SET CONTAINER = XEPDB1;
  
  :: Cambia/Asegura la contraseña del usuario SYSTEM dentro de la PDB
  echo ALTER USER system IDENTIFIED BY Oracle123;
  
  :: Sale de SQL*Plus para finalizar el proceso
  echo EXIT;
) | docker exec -i oracle-xe sqlplus / as sysdba
:: IMPORTANTE: "oracle-xe" debe coincidir con el 'container_name' definido en tu .yml

echo.
echo ==============================================
echo    SISTEMA LISTO! Datos de conexion:
echo ==============================================
echo    Host: localhost  ^| Puerto: 1521
echo    Service Name: XEPDB1
echo    Usuario: system  ^| Clave: Oracle123
echo ==============================================

:: Pausa final para que el usuario pueda leer los datos antes de cerrar la ventana
pause