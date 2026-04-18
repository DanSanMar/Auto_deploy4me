# 🚀 Auto-Despliegue de Laboratorios CTF con Docker (WSL2/Linux) V4 ROBUSTA

Script en Bash diseñado para automatizar el despliegue de máquinas vulnerables en formato `.tar` usando Docker. Optimizado específicamente para resolver errores comunes en **WSL2, Kali Linux, Debian, Ubuntu y Fedora**.

---

## 📌 Características

* 🔄 **Carga inteligente:** Parche automático para el error `stat /var/lib/docker/tmp`.
* 🔍 **Buscador de puertos:** Localiza automáticamente un puerto libre entre el **8080 y el 8100**.
* 🛠️ **Multi-Distro:** Soporte de instalación automática para sistemas basados en **Debian (Apt)** y **Fedora (Dnf)**.
* ⚙️ **Auto-Gestión de Servicios:** Inicia el demonio de Docker automáticamente en entornos sin Systemd (como WSL2 estándar).
* 🛑 **Limpieza Total:** Al pulsar `CTRL + C`, el contenedor se detiene y se elimina automáticamente.
* 📡 **Información de Red:** Muestra la IP interna y genera la URL de redirección lista para el Host principal (Windows/Mac).

---

## 🧰 Requisitos

* Sistema Linux / WSL2 (Ubuntu, Debian, Kali, Fedora, etc.).
* Permisos de **sudo**.
* Archivo `.tar` de la máquina vulnerable (DockerLabs o similar).

---

## 📦 Uso

Para ejecutar el script, utiliza los siguientes comandos en tu terminal:

```bash
# 1. Dar permisos de ejecución
chmod +x deploy4me.sh

# 2. Ejecutar el despliegue con privilegios de sudo
sudo ./deploy4me.sh <archivo.tar>

# Ejemplo práctico:
sudo ./deploy4me.sh candy.tar

## ⚙️ ¿Qué hace el script?

* **Validación:** Verifica que se haya proporcionado un archivo `.tar` válido y que el usuario tenga privilegios de administrador.
* **Entorno Docker:** * Si no detecta Docker, lo instala automáticamente según la distribución.
    * Configura el grupo de usuario y repara permisos del socket (`docker.sock`).
    * Crea y otorga permisos al directorio `/var/lib/docker/tmp` para evitar fallos de carga.
* **Despliegue:**
    * Carga la imagen Docker directamente desde el archivo `.tar`.
    * Escanea el sistema para encontrar un puerto libre en el rango **8080-8100**.
    * Lanza el contenedor e inicia servicios críticos como **Apache2, Nginx, MariaDB o MySQL**.
* **Acceso:** Genera un reporte detallado con la IP interna del laboratorio y la URL de acceso local.

---

## 🌐 Acceso al laboratorio

Una vez desplegado, el script te indicará el puerto seleccionado por consola. Puedes acceder mediante:

* **Desde la misma máquina o Windows (WSL2):** `http://localhost:<PUERTO_ASIGNADO>`
* **Desde otra máquina en la misma red:** `http://<IP_HOST>:<PUERTO_ASIGNADO>`

---

## 🛑 Detener el laboratorio

Para finalizar la sesión de práctica, simplemente presiona: **`CTRL + C`**

El script activará automáticamente una función de limpieza que:
1.  🛑 **Detiene** el contenedor en ejecución de forma segura.
2.  🗑️ **Elimina** el contenedor para liberar recursos del sistema y evitar conflictos futuros.

---

## 🧠 Notas técnicas (Versión 4.0)

* **Compatibilidad WSL2:** Implementa un sistema *fallback* que utiliza `service docker start` si detecta la ausencia de `systemctl`.
* **Gestión Inteligente de Puertos:** Utiliza herramientas de red (`ss` o `netstat`) para garantizar que el puerto asignado no esté ocupado.
* **Robustez de Carga:** La aplicación de permisos `1777` al directorio de Docker previene el error crítico de carga en instalaciones frescas.

---

## 📋 ¿Qué ha cambiado en esta versión?

* **V4.0:** Soporte oficial para distribuciones basadas en **Fedora/RHEL**.
* **V4.0:** Solución definitiva al error `stat /var/lib/docker/tmp`.
* **V4.0:** Sistema de asignación de puertos dinámico (**8080-8100**).
* **V4.0:** Reparación automática de permisos de socket durante la ejecución.

---

## 📄 Licencia

Uso libre para fines educativos, entrenamiento en ciberseguridad y para toda la comunidad de **DockerLabs**.
