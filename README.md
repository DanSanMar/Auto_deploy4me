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
# Dar permisos de ejecución
chmod +x deploy4me.sh

# Ejecutar el despliegue
sudo ./deploy4me.sh <archivo.tar>

# Ejemplo práctico:
sudo ./deploy4me.sh candy.tar
