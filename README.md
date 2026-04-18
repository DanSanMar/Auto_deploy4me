🚀 Auto-Despliegue de Laboratorios CTF con Docker (WSL2/Linux) V4 
Script en Bash diseñado para automatizar el despliegue de máquinas vulnerables en formato .tar usando Docker. Optimizado específicamente para resolver errores comunes en WSL2, Kali Linux, Debian, Ubuntu y Fedora.

📌 Características
🔄 Carga inteligente: Parche automático para el error stat /var/lib/docker/tmp.

🔍 Buscador de puertos: Localiza automáticamente un puerto libre entre el 8080 y el 8100.

🛠️ Multi-Distro: Soporte de instalación automática para sistemas basados en Debian (Apt) y Fedora (Dnf).

⚙️ Auto-Gestión de Servicios: Inicia el demonio de Docker automáticamente en entornos sin Systemd (como WSL2).

🛑 Limpieza Total: Al pulsar CTRL + C, el contenedor se detiene y elimina automáticamente.

📡 Muestra IP interna y redirección lista para Windows/Host principal.

🧰 Requisitos
Sistema Linux / WSL2 (Ubuntu, Debian, Kali, Fedora, etc.)

Permisos de sudo

Archivo .tar de la máquina vulnerable

📦 Uso
Bash
chmod +x deploy4me.sh
sudo ./deploy4me.sh <archivo.tar>

# Ejemplo:
sudo ./deploy4me.sh candy.tar
⚙️ ¿Qué hace el script?
Validación: Verifica el archivo .tar y los privilegios de usuario.

Entorno Docker:

Si no existe Docker, lo instala y configura el grupo de usuario.

Repara permisos del socket (docker.sock) y crea directorios temporales necesarios.

Despliegue:

Carga la imagen desde el .tar.

Busca el primer puerto disponible en el rango 8080-8100.

Lanza el contenedor iniciando servicios críticos (apache2, nginx, mysql, etc.).

Acceso: Proporciona la IP interna y la URL de acceso local.

🌐 Acceso al laboratorio
Una vez desplegado, el script te indicará el puerto seleccionado:

Desde la misma máquina o Windows (WSL2): http://localhost:<PUERTO_ASIGNADO>

Desde otra máquina en la red: http://<IP_HOST>:<PUERTO_ASIGNADO>

🛑 Detener el laboratorio
Simplemente presiona: CTRL + C

El script automáticamente realizará la limpieza:

🛑 Detiene el contenedor.

🗑️ Elimina el contenedor del sistema para ahorrar recursos.

🧠 Notas técnicas (Versión 4.0)
Compatibilidad WSL2: Usa un fallback de service docker start si detecta que no hay systemctl.

Gestión de Puertos: Utiliza ss o netstat para verificar disponibilidad de puertos en tiempo real.

Robustez: Se han añadido permisos 1777 al directorio temporal de Docker para evitar fallos de carga en instalaciones nuevas.

📄 Licencia
Uso libre para fines educativos, de investigación y para la comunidad de DockerLabs.

¿Qué ha cambiado en esta versión?
V4.0: Añadido soporte para Fedora.

V4.0: Corregido error de carga stat /var/lib/docker/tmp.

V4.0: Implementado rango de puertos dinámico (8080-8100).

V4.0: Corregidos permisos de socket en caliente.
