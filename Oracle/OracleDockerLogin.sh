#!/bin/bash

# Este script es para iniciar sesión en el registro de contenedores de Oracle, lo que te permitirá descargar imágenes de Oracle desde su repositorio.

# Una vez que ejecutes este comando, se te pedirá que ingreses tus credenciales de Oracle (nombre de usuario y contraseña). Asegúrate de tener una cuenta de Oracle para poder iniciar sesión.
# - Si no tienes una cuenta, puedes crear una de forma gratuita en el sitio web de Oracle: https://www.oracle.com/account/
# - Si ya tienes una cuenta, simplemente ingresa tus credenciales cuando se te solicite.
# - Recuerda que la contraseña que debes usar es la llave sso, no la contraseña de tu cuenta de Oracle. La llave sso es una contraseña específica para acceder a los servicios de Oracle, 
#     y puedes encontrarla en tu cuenta de Oracle en la sección de seguridad.

# Una vez inciada la sesión se mantiene activa durante un tiempo en tu ordenador, por lo que no tendrás que iniciar sesión cada vez que quieras descargar una imagen de Oracle. 
# Sin embargo, si cierras la sesión o si pasa un tiempo prolongado sin actividad, es posible que tengas que iniciar sesión nuevamente.

# Después de iniciar sesión correctamente, podrás usar comandos de Docker para descargar imágenes de Oracle, como por ejemplo: docker pull container-registry.oracle.com/database/enterprise:latest
# Para ejecutar este script, simplemente abre una terminal, navega a la carpeta donde se encuentra este archivo OracleDockerLogin.sh y ejecuta el comando: bash OracleDockerLogin.sh
# Para cerrar sesión en el registro de Oracle, puedes usar el comando: docker logout container-registry.oracle.com

docker login container-registry.oracle.com
