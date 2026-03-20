-- 1. Abrir la PDB (imprescindible en 21c)
ALTER PLUGGABLE DATABASE XEPDB1 OPEN READ WRITE;

-- 2. Configurar usuario system
ALTER USER system IDENTIFIED BY Oracle123 ACCOUNT UNLOCK;

-- 3. Crear tu usuario de trabajo (opcional pero recomendado)
ALTER SESSION SET "_ORACLE_SCRIPT"=true;
CREATE USER ALONSO_DEV IDENTIFIED BY Oracle123;
GRANT CONNECT, RESOURCE, DBA TO ALONSO_DEV;