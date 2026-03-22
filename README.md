<div align="center">
  <h1>🌐 Multi-Stack Docker Ecosystem</h1>
  <p><strong>Automated infrastructure for rapid and consistent development environments</strong></p>
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT">
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20Docker-blue?logo=docker" alt="Platform">
  <img src="https://img.shields.io/github/actions/workflow/status/AlusoReza/Dockers-Image-Creator/main.yml?branch=main&label=CI/CD&logo=github-actions&logoColor=white" alt="Build Status">
</div>

---
# Dockers-Image-Creator 🐳

[![Live Demo](https://img.shields.io/badge/Check-The_Landing_Page-0db7ed?style=for-the-badge&logo=docker&logoColor=white)](https://alusoreza.github.io/Dockers-Image-Creator/)

This repository constitutes the foundation of a **scalable ecosystem** designed for the rapid, automated, and consistent deployment of **comprehensive development environments** using Docker. The architecture has been designed to evolve modularly, enabling the future integration of various **technology stacks, microservices, and network infrastructure**, providing a portable, persistent, and license-unrestricted working environment.

### 🚀 Quick Start
Choose the method that best fits your workflow to get your environment up and running in less than a minute:

#### 1️⃣ The Easy Way (Interactive Menu)
The fastest and most user-friendly way to deploy. Just run the main script in the root folder:
* **Windows:** Double-click `dockers_image_creator.bat` or run it from your terminal:
    ```powershell
    .\dockers_image_creator.bat
    ```

#### 2️⃣ The Manual Way (Direct Instance)
If you want to go directly to a specific service or you are on a non-Windows system:
1. Navigate to the desired folder (e.g., `Instances/Instance MySQL 8.4`).
2. Run the local deployment:
    * **Windows:** Double-click `Launch_MySQL.bat`.
    * **Linux/macOS:** Run `docker-compose up -d`.

#### 3️⃣ Scaling: Add More Instances 🛠️
This project is designed to be **modular and scalable**. If you need a new database or service:
1. **Duplicate** any existing folder inside the `Instances/` directory.
2. **Rename** the new folder and its internal `.bat` file (e.g., `Instance PostgreSQL`).
3. **Modify** the `docker-compose.yml` inside the new folder (ensure you change ports and container names to avoid conflicts).
4. **Update the Menu:** Add the new option to the main `dockers_image_creator.bat` file to keep it integrated.

### 🧪 Verify Connection
Once the container is running, use the credentials and ports provided in the [Access Table](#-access-credentials-and-ports) to connect via your favorite DB client (DBeaver, MySQL Workbench, etc.).

---

## 🛡️ Security Notice
> [!IMPORTANT]
> * **Default Credentials:** This ecosystem uses default passwords (e.g., `Oracle123`, `root`). Always modify the `.env` files before deploying in shared or non-private networks.
> * **Port Mapping:** Services are mapped to `0.0.0.0` by default. For enhanced security, restrict access to `127.0.0.1` in the `docker-compose.yml` files.
> * **Data Persistence:** Databases store information in local folders (`mysql_data`, `oracle_data`). Do not delete these folders unless you want to perform a complete data wipe.

---

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

## ⚙️ GitHub Actions (CI/CD)
The repository includes an automated workflow (`.github/workflows/main.yml`) that performs:
* **YAML Validation:** Checks the syntax of all `docker-compose.yml` files.
* **Consistency Check:** Ensures that environment variables and volume paths are correctly configured.
* **Stability Testing:** Prevents broken configurations from being merged into the main branch.

---

## 🚀 Operation Guide

### 1. Environment Preparation
* **Automated Docker Check:** The main script now automatically detects if **Docker Desktop** is running. If it's closed, it will launch the engine and wait for it to be in a **"Ready"** state before continuing.
* **Customization (.env):** Before launching, you can centralize configuration by editing the `.env` file inside each instance folder:
    * `PUERTO_HOST`: Defines the port to use on your machine (e.g., `3308`, `1522`).
    * `NOMBRE_DB` / `ORACLE_PASS`: Configure your schema name or master password.

### 2. Smart Deployment (Interactive & Manual)
* **Interactive Menu (Recommended):** Run `dockers_image_creator.bat` from the root. It handles the engine check and lets you choose your database with a single keystroke.
* **Direct Launch:** You can still navigate to `Instances/` and run any `.bat` file directly (e.g., `Launch_MySQL.bat`).
* **Conflict Management:** Scripts automatically detect if a container with the same name or port already exists; they will stop and recreate it to ensure a **clean installation** every time.

### 3. Automatic Configuration (Zero-Touch)
* **Auto-Wait Sync:** Includes a synchronized wait routine (up to 60s) to ensure the database engine is fully initialized before accepting connections.
* **Post-Installation Scripts:** Internal routines automatically configure network privileges, legacy authentication (MySQL), or PDB opening (Oracle) without manual intervention.
* **Data Persistence:** All information is stored in local volumes (`mysql_data` / `oracle_data`). Your data persists even if the containers are removed or the machine restarts.

---

### 📂 Recommended File Structure
To maintain automation, each instance folder should contain:
* `docker-compose.yml` -> Orchestration template.
* `.env` -> Variable control center.
* `Launch_*.bat` -> Smart deployment script.
* `init-db/` -> (Optional) SQL scripts for initial setup.

---

## ⚠️ Technical Considerations
* **Compatibility:** In visual management tools (such as MySQL Workbench), version warnings may appear. It is recommended to ignore them and proceed ("Continue Anyway").
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
