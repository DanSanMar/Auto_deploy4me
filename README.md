# 🚀 Auto-Despliegue de Laboratorios CTF con Docker (WSL2/Linux) V3 MULTILAB

Script en Bash diseñado para automatizar el despliegue de máquinas vulnerables en formato `.tar` usando Docker. Ideal para entornos de práctica CTF en Kali Linux, WSL2 o cualquier sistema basado en Linux.

---

## 📌 Características

- 🔄 Carga automática de imágenes Docker desde `.tar`
- 🧹 Limpieza previa de contenedores e imágenes
- ⚙️ Instalación automática de Docker (si no está presente)
- 🌐 Exposición del servicio en el puerto `8080`
- 🛑 Eliminación completa del entorno con `CTRL + C`
- 📡 Muestra IP interna y acceso desde host

---

## 🧰 Requisitos

- Sistema Linux / WSL2
- Permisos de `sudo`
- Archivo `.tar` de la máquina vulnerable

---

## 📦 Uso

```bash
chmod +x deploy4me.sh
./deploy4me.sh <archivo.tar>
Ejemplo:
./deploy4me.sh maquina_ctf.tar
⚙️ ¿Qué hace el script?
✅ Verifica que se haya proporcionado un archivo .tar
🔍 Comprueba si Docker está instalado
Si no lo está, lo instala automáticamente
🧹 Elimina contenedores/imágenes previas con el mismo nombre
📥 Carga la imagen Docker desde el .tar
🚀 Lanza el contenedor:
Intenta iniciar servicios comunes (apache2, nginx, mariadb)


🌍 Expone el servicio en:

http://localhost:8080
📡 Muestra:
IP interna del contenedor
IP accesible desde la máquina host
🌐 Acceso al laboratorio

Una vez desplegado:

Desde la misma máquina:

http://localhost:8080

Desde otra máquina en la red:

http://<IP_HOST>:8080
🛑 Detener el laboratorio

Simplemente presiona:

CTRL + C

El script automáticamente:

🛑 Detiene el contenedor
🗑️ Elimina el contenedor
❌ Elimina la imagen Docker
🧠 Notas técnicas
El nombre del contenedor se genera automáticamente a partir del nombre de la imagen
Se reemplazan : por _ para evitar errores
Se usan múltiples estrategias de arranque:
/bin/bash
sh
/bin/sh
tail -f /dev/null
⚠️ Posibles problemas
Docker no se instala correctamente

Ejecuta manualmente:

sudo apt update
sudo apt install docker.io -y
sudo systemctl enable --now docker
El contenedor no responde en el puerto 8080
Verifica que el servicio web esté activo dentro del contenedor

Comprueba puertos ocupados:

sudo lsof -i :8080
🧪 Uso recomendado
Laboratorios CTF
Pentesting práctico
Entornos de formación en ciberseguridad
Máquinas dokerlabs / Hack The Box / VulnHub exportadas a .tar

VERSIÓN 2.2

✔ Eliminado el fallback innecesario → script más claro
✔ $? bien usado → control de errores correcto
✔ IMAGE_NAME bien definido → sin variables vacías
✔ Validación de imagen con --format → más precisa
✔ Flujo simple y determinista → ideal para CTF


📄 Licencia
Uso libre para fines educativos y de investigación.
