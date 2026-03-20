@echo off
:: =======================================================================================
:: LANZADOR Y CONFIGURADOR DE MYSQL
:: Archivo Compose: MySQL_ImageCreator.yml
:: =======================================================================================

title Lanzador de MySQL Docker

echo [1/2] Levantando contenedor MySQL...
:: Levanta los servicios definidos en el YAML en modo "detached" (segundo plano)
docker-compose up -d

echo.
echo [2/2] Configurando base de datos...
echo Esperando 15 segundos a que el servicio MySQL inicie correctamente...
:: IMPORTANTE: Se usa PING porque 'timeout' suele fallar en la terminal de VS Code.
:: MySQL necesita este tiempo para inicializar los archivos en el volumen 'mysql_data'.
ping -n 60 127.0.0.1 > nul

echo Verificando base de datos y privilegios...
:: El bloque entre paréntesis envía una ráfaga de comandos SQL al cliente interno de MySQL.
(
  :: Crea la base de datos definida en el YAML si por alguna razón no se creó automáticamente
  echo CREATE DATABASE IF NOT EXISTS Nombre_Base_de_Datos;
  
  :: Asegura que el usuario root pueda conectarse desde fuera del contenedor (host '%%')
  :: Se usa doble '%%' porque en archivos .bat un solo '%%' se confunde con una variable.
  echo ALTER USER 'root'@'%%' IDENTIFIED WITH mysql_native_password BY 'root';
  
  :: Refresca la tabla de permisos para aplicar los cambios de inmediato
  echo FLUSH PRIVILEGES;
  
  :: Muestra las bases de datos actuales para confirmar que todo está en orden
  echo SHOW DATABASES;
) | docker exec -i mysql-workbench-server mysql -u root -proot
:: NOTA: "mysql-workbench-server" es el 'container_name' de tu archivo .yml

echo.
echo ======================================================
echo    SISTEMA LISTO! Datos de conexion MySQL:
echo ======================================================
echo    Host: localhost      ^|  Puerto: 3308
echo    Base de Datos: Nombre_Base_de_Datos
echo    Usuario: root        ^|  Clave: root
echo ======================================================

:: Mantiene la ventana abierta para leer la confirmación
pause