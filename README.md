<div align="center">
  <h1>🌐 Multi-Stack Docker Ecosystem</h1>
  <img src="https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg" alt="License: CC BY-NC 4.0">
</div>

---

This repository constitutes the foundation of a **scalable ecosystem** designed for the rapid, automated, and consistent deployment of **comprehensive development environments** using Docker. The architecture has been designed to evolve modularly, enabling the future integration of various **technology stacks, microservices, and network infrastructure**, providing a portable, persistent, and license-unrestricted working environment.

## 📌 Project Status
> **Development Note:** This project is currently in its initial expansion phase. Although the current services are fully functional, the ecosystem is designed to grow. It is a living environment that may require compatibility adjustments depending on the versions of the official images used.

## 🛠️ Technologies and Requirements
* **Orchestration:** Docker Desktop (Must be running before starting the services).
* **Automation:** Control scripts optimized for **Windows environments (.bat)**.
* **Persistence:** Local volume management to ensure data integrity across sessions.

## 📂 Available Services Catalog

Currently, the ecosystem includes the following infrastructure modules:

### 🗄️ Data Layer (Databases)
* **Oracle Database XE 21c**: Automated instance with Pluggable Database (XEPDB1) initialization and system credential management via script injection.
* **MySQL Server**: High-availability deployment with remote root access configuration and predefined schemas.

> *Coming soon: Web servers (Nginx/Apache), Backend stacks (Node.js/Python), and monitoring tools.*

## 🔌 Access Credentials and Ports

| Service | Host Port | User | Password | Identifier (DB/SID) |
| :--- | :--- | :--- | :--- | :--- |
| **Oracle XE** | `1521` | `system` | `Oracle123` | `XEPDB1` |
| **MySQL** | `3308` | `root` | `root` | `Mi_Base_De_Datos` |

---

Here is the complete and properly formatted Markdown block, ready to be copied and pasted directly into your GitHub README.md file. Icons and code blocks have been included for a professional look.

## 🚀 Operation Guide

Follow these steps to deploy your database instances automatically and without configuration errors.

### 1. Environment Preparation
* **Docker Engine:** Ensure Docker Desktop is running and in **"Running"** state.
* **Customization (.env):** Before launching, you can centralize configuration by editing the `.env` file inside the instance folder:
    * `PUERTO_HOST`: Defines the port to use on your machine (e.g., `3308`, `1522`).
    * `NOMBRE_DB` / `ORACLE_PASS`: Configure your schema name or master password.

### 2. One-Click Deployment
* Navigate to the instance folder under `Instances/`.
* Run the corresponding **`.bat`** file (e.g., `Launch_MySQL.bat` or `Launch_Oracle.bat`).
* **Conflict Management:** The script will automatically detect if a container with the same name or port already exists, stop it, and recreate it to ensure a clean installation.

### 3. Automatic Configuration (Zero-Touch)
* **Auto-Wait:** Scripts include a synchronized wait routine (60s) to ensure the database engine is ready before receiving commands.
* **Post-Installation:** Internal scripts are automatically executed to:
    * Create the database defined in the variables.
    * Configure network privileges and password compatibility (Legacy Auth in MySQL / PDB Open in Oracle).
* **Persistence:** All data is stored in local folders (`mysql_data` / `oracle_data`), so information is not lost when containers are removed.

---

### 📂 Recommended File Structure
To maintain automation, each instance folder should contain:
* `docker-compose.yml` -> Orchestration template.
* `.env` -> Variable control center.
* `Launch_*.bat` -> Smart deployment script.
* `init-db/` -> (Optional) SQL scripts for initial setup.

---

## ⚠️ Technical Considerations
* **Compatibility:** In visual management tools (such as MySQL Workbench), version warnings may appear. It is recommended to ignore them and proceed ("Continue Anyway") to operate normally.
* **Privileges:** Some configuration scripts require administrator privileges to properly manage volumes on Windows.
* **Optimization:** It is recommended to stop unused services to free system resources (RAM/CPU).

---

## ⚖️ License and Intellectual Property

**Copyright (c) 2026 - Alonso José Suárez Reza**

This project is licensed under the **MIT License**, a permissive open-source license that allows reuse, modification, and distribution with minimal restrictions.

### ✅ Permissions:
- Commercial use
- Modification
- Distribution
- Private use

### 📌 Conditions:
- Attribution: You must include the original copyright notice and license in any copy or substantial portion of the software.

### ⚠️ Disclaimer:
This software is provided "as is", without warranty of any kind, express or implied. The author shall not be held liable for any damages arising from the use of this software.

> [Read the full MIT License](https://opensource.org/licenses/MIT)

---

## 🛠️ Contributions
This project is **open and continuously improvable**. If you would like to propose a new integration, fix a bug, or enhance the automation, Pull Requests are welcome.
