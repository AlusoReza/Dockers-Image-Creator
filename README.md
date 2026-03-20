# 🌐 Multi-Stack Docker Ecosystem

Este repositorio constituye la base de un **ecosistema escalable** diseñado para el despliegue rápido, automatizado y consistente de **entornos de desarrollo integrales** mediante Docker. La arquitectura ha sido proyectada para evolucionar modularmente, permitiendo la incorporación futura de diversos **stacks tecnológicos, servicios de microservicios e infraestructura de red**, proporcionando un entorno de trabajo portable, persistente y sin restricciones de licenciamiento temporal.

## 📌 Estado del Proyecto
> **Nota de Desarrollo:** Este proyecto se encuentra en su fase inicial de expansión. Aunque los servicios actuales son plenamente funcionales, el ecosistema está diseñado para crecer. Es un entorno vivo que puede presentar ajustes de compatibilidad según las versiones de las imágenes oficiales utilizadas.

## 🛠️ Tecnologías y Requisitos
* **Orquestación:** Docker Desktop (Debe estar iniciado antes de ejecutar los servicios).
* **Automatización:** Scripts de control optimizados para entornos **Windows (.bat)**.
* **Persistencia:** Gestión de volúmenes locales para garantizar la integridad de los datos entre sesiones.

## 📂 Catálogo de Servicios Disponibles

Actualmente, el ecosistema cuenta con los siguientes módulos de infraestructura:

### 🗄️ Área de Datos (Databases)
* **Oracle Database XE 21c**: Instancia automatizada con apertura de Pluggable Database (XEPDB1) y gestión de credenciales de sistema mediante inyección de scripts.
* **MySQL Server**: Despliegue de alta disponibilidad con configuración de acceso root remoto y esquemas predefinidos.

> *Próximamente: Servidores Web (Nginx/Apache), Stacks de Backend (Node.js/Python), y herramientas de monitorización.*

## 🔌 Credenciales y Puertos de Acceso

| Servicio | Puerto Host | Usuario | Contraseña | Identificador (DB/SID) |
| :--- | :--- | :--- | :--- | :--- |
| **Oracle XE** | `1521` | `system` | `Oracle123` | `XEPDB1` |
| **MySQL** | `3308` | `root` | `root` | `UNIR_1ero` |

---

## 🚀 Guía de Operación
1.  **Detección:** Asegúrate de que el motor de Docker esté en estado "Running".
2.  **Despliegue:** Ejecuta el archivo `.bat` correspondiente al servicio que desees iniciar.
3.  **Configuración Automática:** Los scripts incluyen rutinas de espera y comandos de post-instalación para que el servicio esté listo sin intervención manual.

---

## ⚠️ Consideraciones Técnicas
* **Compatibilidad:** En herramientas de gestión visual (como MySQL Workbench), es posible recibir avisos de versión. Se recomienda omitir y continuar ("Continue Anyway") para operar con normalidad.
* **Privilegios:** Algunos scripts de configuración requieren la ejecución con permisos de administrador para gestionar correctamente los volúmenes en Windows.
* **Optimización:** Se recomienda detener los servicios que no estén en uso para liberar recursos del sistema (RAM/CPU).

---

## ⚖️ Licencia y Propiedad Intelectual

**Copyright (c) 2024 - [Tu Nombre o Usuario de GitHub]**

Este ecosistema se distribuye bajo las siguientes condiciones:

1.  **Redistribución No Comercial:** Se permite el uso, copia y modificación del código siempre que no exista un fin lucrativo tras la actividad.
2.  **Atribución Obligatoria:** Cualquier derivación o redistribución de estos scripts debe incluir el reconocimiento explícito al autor original.
3.  **Garantía Limitada:** El software se entrega "tal cual". El autor no se responsabiliza de pérdidas de información o desajustes técnicos derivados del uso del entorno.

---

## 🛠️ Contribuciones
Este proyecto es **abierto y mejorable**. Si deseas proponer una nueva integración, corregir un bug o mejorar la automatización, las Pull Requests son bienvenidas.
