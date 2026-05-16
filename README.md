🚀 Auto-Despliegue de Laboratorios CTF con Docker (WSL2/Linux) V5 Raw
Script en Bash diseñado para automatizar el despliegue de máquinas vulnerables en formato .tar usando Docker. Esta versión "Raw" está optimizada para la resolución directa de dependencias y despliegues rápidos en WSL2, Kali Linux, Debian, Ubuntu y Fedora.

📌 Características Principales
🔄 Carga Directa: Importación eficiente de imágenes Docker desde archivos comprimidos .tar.

🛠️ Instalador Inteligente: Detección y configuración automática de Docker para sistemas basados en Debian (Apt) y Fedora (Dnf).

⚙️ Compatibilidad Universal de Servicios: Gestor híbrido que soporta systemd y init.d (ideal para WSL2).

🛡️ Auto-Reparación de Permisos: Configura automáticamente el socket de Docker y grupos de usuario para evitar errores de "Permission Denied".

🛑 Ciclo de Vida Automatizado: Al pulsar CTRL + C, el script garantiza la detención y eliminación total del contenedor.

🧰 Requisitos
Sistema Linux / WSL2 (Ubuntu, Debian, Kali, Fedora, etc.).

Privilegios de sudo.

Archivo .tar del laboratorio (compatible con DockerLabs).

📦 Uso
Sigue estos pasos para desplegar tu laboratorio:

Bash
# 1. Asignar permisos de ejecución
chmod +x deploy4me.sh

# 2. Ejecutar el despliegue indicando el archivo .tar
./deploy4me.sh <nombre_del_laboratorio.tar>

# Ejemplo:
./deploy4me.sh machine_name.tar
⚙️ Flujo de Trabajo del Script
Validación de Entorno: Comprueba la existencia del archivo y dependencias de Docker.

Aprovisionamiento: Si Docker no existe, el script lo instala, habilita el servicio y gestiona los permisos del socket /var/run/docker.sock.

Despliegue Dinámico:

Genera un ID Único basado en la marca de tiempo para el contenedor.

Mapea automáticamente el puerto 80 del contenedor.

Activación de Servicios Internos: Inicia automáticamente en la máquina vulnerable:

Apache2 / Nginx

MariaDB / MySQL

Reporte: Entrega la IP interna del contenedor y el nombre asignado para comenzar la auditoría.

🛑 Finalización y Limpieza
Para cerrar el laboratorio de forma limpia, presiona CTRL + C.

El script ejecutará la función detener_y_eliminar_contenedor, la cual:

Detiene el proceso del contenedor inmediatamente.

Elimina el contenedor para mantener tu sistema libre de residuos.

Restaura la configuración del terminal (stty).

📄 Licencia y Propósito
Este script es de uso libre para la comunidad de ciberseguridad. Diseñado para facilitar el entrenamiento en DockerLabs y entornos de práctica controlados.

[!TIP]
Nota para WSL2: Si no puedes acceder a la IP del contenedor directamente desde Windows, recuerda que puedes abrir un navegador web o usar curl directamente desde tu terminal de Linux/WSL.