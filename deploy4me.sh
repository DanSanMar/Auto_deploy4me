#!/bin/bash

# ==============================================================================
# SCRIPT DE AUTO-DESPLIEGUE PARA LABORATORIOS CTF - (DOCKER + WSL2) - VERSIÓN 3 MULTI-CONTENEDOR
# ==============================================================================

# --- FUNCIONES DE CONTROL ---

detener_y_eliminar_contenedor() {
    # Usamos las variables locales para este contenedor específico
    echo -e "\n\e[1;34m[*] Limpiando entorno del contenedor: $CONTAINER_NAME...\e[0m"

    docker rm -f "$CONTAINER_NAME" > /dev/null 2>&1 || true
    # No borramos la imagen por defecto para no romper otros contenedores que la usen
    
    echo -e "\e[1;32m[+] Contenedor $CONTAINER_NAME eliminado con éxito.\e[0m"
}

trap ctrl_c INT

function ctrl_c() {
    echo -e "\n\e[1;33m[!] Señal de interrupción detectada. Eliminando este laboratorio...\e[0m"
    detener_y_eliminar_contenedor
    exit 0
}

# --- VALIDACIONES INICIALES ---

if [ $# -ne 1 ]; then
    echo -e "\e[1;31m[!] Error: Debes proporcionar el archivo .tar\e[0m"
    echo "Uso: $0 <archivo_tar>"
    exit 1
fi

TAR_FILE="$1"

if [ ! -f "$TAR_FILE" ]; then
    echo -e "\e[1;31m[!] Error: El archivo '$TAR_FILE' no existe.\e[0m"
    exit 1
fi

# --- DESPLIEGUE ---

echo -e "\e[1;93m\n[*] Cargando imagen desde: $TAR_FILE\e[0m"

# 1. Cargar imagen y obtener su nombre real
docker load -i "$TAR_FILE"

if [ $? -eq 0 ]; then
    # CAMBIO 1: Nombre único usando el timestamp para que no choque con otros
    IMAGE_NAME=$(basename "$TAR_FILE" .tar)
    ID_UNICO=$(date +%s)
    CONTAINER_NAME="${IMAGE_NAME}_${ID_UNICO}"

    # CAMBIO 2: Buscar un puerto libre automáticamente entre 8080 y 8100
    for port in $(seq 8080 8100); do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
            PUERTO_LIBRE=$port
            break
        fi
    done

    echo -e "\e[1;34m[*] Lanzando contenedor '$CONTAINER_NAME' en puerto $PUERTO_LIBRE...\e[0m"
    
    docker run -d -p $PUERTO_LIBRE:80 --name "$CONTAINER_NAME" "$IMAGE_NAME" \
        /bin/bash -c "
        service apache2 start 2>/dev/null;
        service nginx start 2>/dev/null;
        service mariadb start 2>/dev/null;
        while true; do sleep 60; done
        "

    # Obtener IP interna para el mensaje
    IP_DOCKER=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME")

    echo -e "\n\e[1;92m[✔] ¡Máquina vulnerable lista!\e[0m"
    echo -e "\e[1;97m----------------------------------------------------------------------\e[0m"
    echo -e "\e[1;97m    IP interna de Docker: ---------------------------->\e[1;96m $IP_DOCKER\e[0m"
    echo -e "\e[1;97m    Acceso (Localhost/Windows): ---------------------->\e[1;92m http://localhost:$PUERTO_LIBRE\e[0m"
    echo -e "\e[1;97m----------------------------------------------------------------------\e[0m"

    echo -e "\e[1;5m[Exit] Pulsa Control C para detener ESTE contenedor\e[0m"
else
    echo -e "\e[91m\n[X] Error al cargar el .tar\e[0m"
    exit 1
fi

while true; do sleep 1; done
