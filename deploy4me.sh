#!/bin/bash

# ==============================================================================
# SCRIPT DE AUTO-DESPLIEGUE PARA LABORATORIOS CTF (DOCKER + WSL2) - VERSIÓN 2.1
# ==============================================================================

# --- FUNCIONES DE CONTROL ---

detener_y_eliminar_contenedor() {
    # Extraer nombre base de forma segura para las variables globales
    IMAGE_NAME=${IMAGE_NAME:-$(basename "$TAR_FILE" .tar)}
    SAFE_NAME=$(echo "$IMAGE_NAME" | tr ':' '_' )
    CONTAINER_NAME="${SAFE_NAME}_container"

    echo -e "\n\e[1;34m[*] Limpiando entorno...\e[0m"

    # 1. Intentar detener y eliminar el contenedor POR NOMBRE (fuerza bruta)
    # Usamos || true para que el script no se detenga si el contenedor no existe
    docker rm -f "$CONTAINER_NAME" > /dev/null 2>&1 || true

    # 2. Eliminar la imagen (fuerza bruta para evitar errores de referencia)
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
LOAD_OUTPUT=$(docker load -i "$TAR_FILE")

if [ $? -eq 0 ]; then
    # Extraer nombre real
    IMAGE_NAME=$(echo "$LOAD_OUTPUT" | grep -oP '(?<=Loaded image: ).*')

    # Fallback
    if [ -z "$IMAGE_NAME" ]; then
        IMAGE_NAME=$(basename "$TAR_FILE" .tar)
    fi

   SAFE_NAME=$(echo "$IMAGE_NAME" | tr ':' '_' )
   CONTAINER_NAME="${SAFE_NAME}_container"

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
    
    if ! docker ps | grep -q "$CONTAINER_NAME"; then
        echo -e "\e[1;33m[!] Contenedor muerto, aplicando fallback...\e[0m"
        
        docker rm -f "$CONTAINER_NAME" > /dev/null 2>&1
    
        docker run -dit -p 8080:80 --name "$CONTAINER_NAME" "$IMAGE_NAME" sh > /dev/null 2>&1 \
        || docker run -dit -p 8080:80 --name "$CONTAINER_NAME" "$IMAGE_NAME" /bin/sh > /dev/null 2>&1 \
        || docker run -dit -p 8080:80 --name "$CONTAINER_NAME" "$IMAGE_NAME" tail -f /dev/null > /dev/null
    fi

    # IPs
    IP_DOCKER=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME")
    IP_KALI=$(hostname -I | awk '{print $1}')

    echo -e "\n\e[1;92m[✔] ¡Máquina vulnerable lista!\e[0m"
    echo -e "\e[1;97m----------------------------------------------------------------------\e[0m"
    echo -e "\e[1;97m    IP orignen del despliegue de Docker (Kali/WSL2 u otra máquina virutal): ------------------->\e[1;96m $IP_DOCKER\e[0m"
    echo -e "\e[1;97m    Acceso fuera del host de origen (Linux/Windows: también por: localhost:8080): ------------->\e[1;92m http://$IP_KALI:8080\e[0m"
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
