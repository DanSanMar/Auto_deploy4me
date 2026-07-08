# 🚀 Auto-Despliegue de Laboratorios CTF con Docker (WSL2/Linux) V6.0 Robust

Script en Bash diseñado para automatizar el despliegue de máquinas vulnerables en formato `.tar` usando Docker de la forma más fiel posible. Esta versión **"Robust"** está optimizada para mantener la integridad del laboratorio original, garantizando la compatibilidad absoluta con cualquier CTF (como los de DockerLabs) ejecutado en WSL2, Kali Linux, Debian, Ubuntu y Fedora.

## 📌 Características Principales
* **🔄 Carga Directa:** Importación eficiente de imágenes Docker desde archivos comprimidos `.tar`.
* **🔥 Compatibilidad Absoluta (Engine Nativo):** A diferencia de otras versiones, la V6 **no sobrescribe el CMD/Entrypoint original** de la máquina. Esto asegura que *todos* los servicios, scripts internos y configuraciones diseñadas por el creador del CTF se inicien correctamente de forma automática.
* **🌐 Mapeo Multi-puerto Inteligente:** Exposición automática hacia tu `localhost` de los puertos más explotados en CTF (`21` FTP, `22` SSH, `80`/`443` Web, `3306` MySQL/MariaDB, `8080` HTTP-Alt).
* **🛠️ Instalador Inteligente:** Detección y configuración automática de Docker para sistemas basados en Debian (`apt`) y Fedora (`dnf`).
* **⚙️ Compatibilidad de Servicios en WSL2:** Gestor híbrido que soporta `systemd` e `init.d`, ideal para subsistemas de Windows.
* **🛡️ Auto-Reparación de Permisos:** Configura automáticamente el socket de Docker y grupos de usuario para evitar los molestos errores de *"Permission Denied"*.
* **🛑 Ciclo de Vida Automatizado:** Al pulsar `CTRL + C`, el script garantiza la detención y eliminación total del contenedor, dejando tu sistema limpio de residuos.

---

## 🧰 Requisitos
* Sistema Linux / WSL2 (Kali Linux, Ubuntu, Debian, Fedora, etc.).
* Privilegios de `sudo`.
* Archivo `.tar` del laboratorio (compatible con DockerLabs).

---

## 📦 Uso
Sigue estos pasos para desplegar tu laboratorio:

```bash
# 1. Asignar permisos de ejecución al script
chmod +x deploy4me.sh

# 2. Ejecutar el despliegue indicando el archivo .tar
sudo ./deploy4me.sh <nombre_del_laboratorio.tar>

# Ejemplo:
sudo ./deploy4me.sh machine_name.tar 
o así:
sudo bash deploy4me.sh machine_name.tar
```

## ⚙️ Flujo de Trabajo del Script

1. **Validación de Entorno:** Comprueba la existencia del archivo `.tar` y verifica el estado de las dependencias de Docker.
    
2. **Aprovisionamiento:** Si Docker no existe, el script lo instala de forma transparente, habilita el servicio y gestiona los permisos del socket `/var/run/docker.sock`.
    
3. **Despliegue Dinámico Nivel Robust:**
    
    - Genera un ID Único basado en la marca de tiempo para evitar colisiones de contenedores.
        
    - Carga la imagen e inicia el contenedor respetando su configuración nativa interna.
        
    - Mapea un abanico de puertos estándar hacia el host para garantizar la accesibilidad total.
        
4. **Reporte Completo:** Entrega la IP interna del contenedor, el nombre asignado y la lista de puertos expuestos listos para la fase de escaneo (Nmap) y auditoría.
    

## 🛑 Finalización y Limpieza

Para cerrar el laboratorio de forma limpia, presiona **`CTRL + C`**.

El script interceptará la señal y ejecutará la función `detener_y_eliminar_contenedor`, la cual:

- Detiene el proceso del contenedor inmediatamente mediante Docker.
    
- Elimina el contenedor del entorno para mantener tu sistema libre de espacio ocupado innecesariamente.
    
- Restaura la configuración visual del terminal (`stty`).
    

## 📄 Licencia y Propósito

Este script es de uso libre para la comunidad de ciberseguridad. Diseñado para facilitar y agilizar el entrenamiento en DockerLabs, laboratorios locales y entornos de práctica controlados.

> [!TIP] **Nota para WSL2:** Al mapear de forma nativa los puertos a `localhost`, puedes atacar la máquina en entornos WSL2 apuntando directamente a su IP interna o bien accediendo desde tu navegador en Windows a `http://localhost:<puerto>` (ej. `http://localhost:80` o `http://localhost:8080`).


