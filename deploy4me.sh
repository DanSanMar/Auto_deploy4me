#!/bin/bash
#Script pasado por dos2unix por error en despligues distintos
# ==============================================================================
# SCRIPT DE AUTO-DESPLIEGUE PARA LABORATORIOS CTF (DOCKER + WSL2) - VERSIÓN 2.2
# ==============================================================================

# --- FUNCIONES DE CONTROL ---

detener_y_eliminar_contenedor() {
    IMAGE_NAME=${IMAGE_NAME:-$(basename "$TAR_FILE" .tar)}
    CONTAINER_NAME="${IMAGE_NAME}_container"

    echo -e "\n\e[1;34m[*] Limpiando entorno...\e[0m"

    docker rm -f "$CONTAINER_NAME" > /dev/null 2>&1 || true

    if [ "$(docker images -q "$IMAGE_NAME")" ]; then
        docker rmi -f "$IMAGE_NAME" > /dev/null 2>&1 || true
    fi
}

# Manejo de salida (CTRL+C)
trap ctrl_c INT

function ctrl_c() {
    echo -e "\e[1;33m\n[!] Eliminando el laboratorio, espere un momento...\e[0m"
    detener_y_eliminar_contenedor
    echo -e 
    echo -e "\e[1;32m[+] El laboratorio ha sido eliminado por completo.\e[0m"
    echo -e 
    # Color con parpadeo que he descubierto...
    echo -e "\e[1;5m[✔] Nos vemos vemos en la próxima!!.\e[0m"
    exit 0
}

# --- VALIDACIONES INICIALES ---

if [ $# -ne 1 ]; then
    echo -e "\e[1;31m[!] Error: Debes proporcionar el archivo .tar\e[0m"
    echo "Uso: $0 <archivo_tar>"
    exit 1
fi

TAR_FILE="$1"

# Verificar si el archivo existe antes de continuar
if [ ! -f "$TAR_FILE" ]; then
    echo -e "\e[1;31m[!] Error: El archivo '$TAR_FILE' no existe.\e[0m"
    exit 1
fi

# --- VERIFICACIÓN DE DEPENDENCIAS ---

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    echo -e "\033[1;36m\n[!] Docker no instalado. Intentando instalar...\033[0m"
    sudo apt update && sudo apt install docker.io -y
    sudo systemctl enable --now docker
    
    # Verificar si la instalación fue exitosa
    if ! command -v docker &> /dev/null; then
        echo -e "\e[1;31m[X] Error crítico: No se pudo instalar Docker automáticamente.\e[0m"
        exit 1
    fi
fi

# --- DESPLIEGUE ---

echo -e "\e[1;93m\n[*] Desplegando máquina vulnerable: $TAR_FILE\e[0m"

# Limpieza inicial profunda para evitar conflictos de nombres
detener_y_eliminar_contenedor



# 1. Cargar imagen
docker load -i "$TAR_FILE"

if [ $? -eq 0 ]; then
   IMAGE_NAME=$(basename "$TAR_FILE" .tar) # Obtiene el nombre del archivo sin la extensión .tar
   CONTAINER_NAME="${IMAGE_NAME}_container"
   
    echo -e "\e[1;34m[*] Lanzando contenedor...\e[0m"
	echo
	echo "IMAGE_NAME=$IMAGE_NAME"
	echo "CONTAINER_NAME=$CONTAINER_NAME"
	echo
    # Intento normal
  docker run -d -p 8080:80 --name "$CONTAINER_NAME" "$IMAGE_NAME" \
  /bin/bash -c "
  service apache2 start 2>/dev/null;
  service nginx start 2>/dev/null;
  service mariadb start 2>/dev/null;
  while true; do sleep 60; done
  "
    
    sleep 2

    if ! docker images --format "{{.Repository}}" | grep -wq "$IMAGE_NAME"; then
        echo "[!] Advertencia: la imagen cargada no coincide con el nombre esperado"
    fi

    # IPs
    IP_DOCKER=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME")
    IP_KALI=$(hostname -I | awk '{print $1}')

    echo -e "\n\e[1;92m[✔] ¡Máquina vulnerable lista!\e[0m"
    echo -e "\e[1;97m----------------------------------------------------------------------\e[0m"
    echo -e "\e[1;97m    IP interna de Docker (Kali/WSL2 u otro Linux): -------------------->\e[1;96m $IP_DOCKER\e[0m"
    echo -e "\e[1;97m    Acceso fuera de WSL2 (Local/Windows,localhost:8080): -------------->\e[1;92m http://$IP_KALI:8080\e[0m"
    echo -e "\e[1;97m----------------------------------------------------------------------\e[0m"
	echo
	# Color con parpadeo que he descubierto para llamar la atención
 	echo -e "\e[1;5m[Exit] Pulsa Control C para detener y eliminar el despliegue completo\e[0m"
else
    echo -e "\e[91m\n[X] Error al cargar el .tar\e[0m"
    detener_y_eliminar_contenedor
    exit 1
fi
while true; do sleep 1; done
