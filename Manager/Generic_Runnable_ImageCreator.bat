@echo off
:: =======================================================================================
:: LANZADOR GENÉRICO DE DOCKER COMPOSE
:: Propósito: Automatizar el despliegue y monitoreo de cualquier entorno Docker.
:: Instrucciones: Modifica las variables de la sección "CONFIGURACIÓN" para tu proyecto.
:: =======================================================================================

:: ---------------------------------------------------------------------------------------
:: CONFIGURACIÓN (Variables)
:: ---------------------------------------------------------------------------------------
:: Nombre que aparecerá en la ventana de la terminal
set "TITULO_VENTANA=Lanzador de Mi Proyecto Docker"

:: Nombre de tu archivo de configuración YAML
set "ARCHIVO_COMPOSE=docker-compose.yml"

:: Nombre del contenedor del que quieres ver los logs para saber si arrancó bien
set "NOMBRE_CONTENEDOR=mi_app_principal"

:: URL del registro (Opcional, útil para imágenes privadas de AWS, Oracle, etc.)
:: set "REGISTRO_DOCKER=container-registry.oracle.com"


:: ---------------------------------------------------------------------------------------
:: EJECUCIÓN DEL SCRIPT
:: ---------------------------------------------------------------------------------------
title %TITULO_VENTANA%

:: PASO 1 (Opcional): Login en el registro de Docker
:: Descomenta las siguientes dos líneas (quitando los ::) si necesitas autenticación
:: echo [1/3] Verificando login en %REGISTRO_DOCKER%...
:: docker login %REGISTRO_DOCKER%
:: echo.

echo [1/2] Levantando servicios desde el archivo: %ARCHIVO_COMPOSE%...
:: 'up -d' levanta los contenedores en segundo plano (modo detached)
docker-compose -f %ARCHIVO_COMPOSE% up -d

echo.
echo [2/2] Conectando a los logs de: %NOMBRE_CONTENEDOR%...
echo (Nota: Presiona Ctrl+C en cualquier momento para dejar de ver los logs sin apagar el contenedor)
echo ---------------------------------------------------------------------------------------

:: '-f' sigue la salida en tiempo real. Se quedará aquí hasta que presiones Ctrl+C
docker logs -f %NOMBRE_CONTENEDOR%

echo.
echo ---------------------------------------------------------------------------------------
echo Fin de visualización de logs. El contenedor sigue ejecutándose en segundo plano.

:: Crea una pausa de 60 segundos antes de cerrar la ventana de la consola para poder leer el final.
:: (Es una versión más limpia y moderna que usar 'ping 127.0.0.1', aunque ambos funcionan)
:: Si timeout no funciona, descomenta la siguiente línea y comenta la línea de timeout:
:: ping -n 15 127.0.0.1 > nul
timeout /t 60 >nul