#!/bin/bash

# ==============================================================================
# SCRIPT DE AUTO-DESPLIEGUE PARA LABORATORIOS CTF - (DOCKER + WSL2) - VERSIÓN 6
# ==============================================================================
stty -echoctl

# --- DEFINICIÓN DE COLORES ---
CRE='\033[31m'; CYE='\033[33m'; CGR='\033[32m'; CBL='\033[34m'
CBLE='\033[36m'; CBK='\033[37m'; CGY='\033[90m'; BLD='\033[1m'; CNC='\033[0m'

detener_y_eliminar_contenedor() {
    if [ -n "$CONTAINER_NAME" ]; then
        echo -e "\n\e[1;34m[*] Limpiando entorno del contenedor: $CONTAINER_NAME...\e[0m"
        sudo docker rm -f "$CONTAINER_NAME" > /dev/null 2>&1 || true
        echo -e "\n\e[1;32m[+] Contenedor $CONTAINER_NAME eliminado con éxito.\e[0m"
        echo -e "\n\e[1;34m[!] Gracias por usar DOCKERLABS con deploy4me, bye bye!\e[0m"
    fi
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

check_docker_installed() {
    command -v docker &> /dev/null
}

start_docker_service() {
    if [ -d /run/systemd/system ]; then
        sudo systemctl enable docker 2>/dev/null || true
        sudo systemctl start docker 2>/dev/null || true
    else
        sudo service docker start 2>/dev/null || true
    fi
}

is_docker_running() {
    if [ -d /run/systemd/system ]; then
        systemctl is-active --quiet docker 2>/dev/null
    else
        sudo service docker status 2>/dev/null | grep -qE "is running|start/running"
    fi
}

install_docker_debian_based() {
    echo -e "\n${CGR}[INSTALACIÓN]${CNC} Detectado: Sistema basado en Debian/Ubuntu/Kali"
    echo -e "${CBL}[PASO 1/4]${CNC} Actualizando repositorios..."
    sudo apt update -y 2>&1 | tee /tmp/apt_update.log
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        echo -e "${CRE}[ERROR]${CNC} Fallo al actualizar repositorios. Revisa tu conexión."
        return 1
    fi
    
    echo -e "${CBL}[PASO 2/4]${CNC} Instalando Docker.io..."
    echo -e "${CGY}(Esto puede tardar unos minutos...)${CNC}\n"
    
    sudo apt install docker.io -y 2>&1 | while read line; do
        echo -e -n "${CBLE}.${CNC}"
    done
    echo ""
    
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        echo -e "${CRE}[ERROR]${CNC} Fallo al instalar Docker.io."
        return 1
    fi
    
    echo -e "\n${CBL}[PASO 3/4]${CNC} Habilitando servicio Docker..."
    start_docker_service
    echo -e "${CBL}[PASO 4/4]${CNC} Verificando instalación..."
    sleep 2
}

install_docker_fedora_based() {
    echo -e "\n${CGR}[INSTALACIÓN]${CNC} Detectado: Sistema basado en Fedora/RHEL/CentOS"
    echo -e "${CBL}[PASO 1/4]${CNC} Actualizando repositorios..."
    sudo dnf makecache 2>&1 | tee /tmp/dnf_update.log
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        echo -e "${CRE}[ERROR]${CNC} Fallo al actualizar repositorios."
        return 1
    fi
    
    echo -e "${CBL}[PASO 2/4]${CNC} Instalando Docker..."
    echo -e "${CGY}(Esto puede tardar unos minutos...)${CNC}\n"
    
    sudo dnf install docker -y 2>&1 | while read line; do
        echo -e -n "${CBLE}.${CNC}"
    done
    echo ""
    
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        echo -e "${CRE}[ERROR]${CNC} Fallo al instalar Docker."
        return 1
    fi
    
    echo -e "\n${CBL}[PASO 3/4]${CNC} Habilitando servicio Docker..."
    start_docker_service
    echo -e "${CBL}[PASO 4/4]${CNC} Verificando instalación..."
    sleep 2
}

detect_distribution() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            debian|ubuntu|kali|linuxmint|pop) echo "debian" ;;
            fedora|rhel|centos|rocky|almalinux) echo "fedora" ;;
            *) echo "unknown" ;;
        esac
    else
        echo "unknown"
    fi
}

# --- EJECUCIÓN PRINCIPAL DE INSTALACIÓN ---
if ! check_docker_installed; then
    echo -e "\n${CRE}[⚠]${CNC} Docker no está instalado en tu sistema."
    echo -e "${CYE}[?]${CNC} ¿Deseas instalarlo ahora? (s/n)"
    read -r INSTALL_CONFIRM
    
    if [[ "$INSTALL_CONFIRM" =~ ^[SsYy]$ ]]; then
        DISTRO_TYPE=$(detect_distribution)
        echo -e "\n${CGR}[✓]${CNC} Iniciando instalación de Docker..."
        echo -e "${CBLE}----------------------------------------${CNC}\n"
        
        case "$DISTRO_TYPE" in
            debian) install_docker_debian_based || exit 1 ;;
            fedora) install_docker_fedora_based || exit 1 ;;
            *)
                echo -e "${CRE}[ERROR]${CNC} Distribución no soportada automáticamente."
                exit 1
                ;;
        esac
        
        if check_docker_installed; then
            echo -e "\n${CGR}[✓]${CNC} Docker instalado correctamente."
            sudo chmod 666 /var/run/docker.sock 2>/dev/null || true
            if ! id -nG "$USER" | grep -qw "docker"; then
                sudo groupadd docker 2>/dev/null || true
                sudo usermod -aG docker "$USER"
            fi
            echo -e "${CBLE}----------------------------------------${CNC}\n"
            sleep 2
        else
            echo -e "\n${CRE}[✗]${CNC} Error: Docker no se pudo instalar."
            exit 1
        fi
    else
        exit 1
    fi
else
    echo -e "\n${CGR}[✓]${CNC} Docker ya está instalado (${CBL}$(docker --version | cut -d' ' -f3)${CNC})"
fi

if ! is_docker_running; then
    start_docker_service
    sleep 3
    if ! is_docker_running; then
        echo -e "${CRE}[✗]${CNC} Error: No se pudo iniciar el servicio Docker."
        exit 1
    fi
fi

echo -e "${CGR}[✓]${CNC} Servicio Docker activado y en ejecución."

TAR_FILE="$1"
if [ ! -f "$TAR_FILE" ]; then
    echo -e "\e[1;31m[!] Error: El archivo '$TAR_FILE' no existe.\e[0m"
    exit 1
fi

SCRIPT_NAME=$(basename "$TAR_FILE" .tar)
VERSION="con deploy4me v6.0 Robust"

print_logo() {
    printf "\n"
    printf "\t                       ${CRE} ##       ${CBK} .         \n"
    printf "\t                 ${CRE} ## ## ##      ${CBK} ==         \n"
    printf "\t               ${CRE}## ## ## ##      ${CBK}===         \n"
    printf "\t       ${CBLE}/\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\\\___/ ${CBL}===       \n"
    printf "\t  ${CBL}~~~ ${CBK}{${CBL}~~ ~~~~ ~~~ ~~~~ ~~ ~ ${CBK}/  ${CYE}- ${CBL}===- ${CBL}~~~${CBK}\n"
    printf "\t       \\______${CBK} o ${CBK}         __/           \n"
    printf "\t         \\    \\        __/            \n"
    printf "\t          \\____\\______/               \n"
    printf "\n"
    printf "${BLD}${CBLE}                                          \n"
    printf "  ___  ____ ____ _  _ ____ ____ _    ____ ___  ____ \n"
    printf "  |  \\ |  | |    |_/  |___ |__/ |    |__| |__] [__  \n"
    printf "  |__/ |__| |___ | \\_ |___ |  \\ |___ |  | |__] ___] \n"
    printf "${CNC}                                          \n"
    printf "\n"
    printf "${CGR}[✔]${CNC} Lanzando [${BLD}${CBLE}${SCRIPT_NAME}${CNC}${BLD}]${CNC} ${VERSION}${CNC}...\n"
}

print_logo

echo -e "\e[1;93m\n[*] Cargando imagen desde: $TAR_FILE\n\e[0m"

# 1. Cargar imagen
if ! sudo docker load -i "$TAR_FILE"; then
    echo -e "\n\e[91m\n[X] Error fatal al cargar el .tar. Revisa el archivo.\e[0m"
    exit 1
fi

IMAGE_REPO=$(basename "$TAR_FILE" .tar)
IMAGE_NAME="${IMAGE_REPO}:latest"

if ! sudo docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
    echo -e "\e[91m[X] La imagen $IMAGE_NAME no se encontró tras cargar.\e[0m"
    exit 1
fi

ID_UNICO=$(date +%s)
CONTAINER_NAME_BASE=$(echo "$IMAGE_REPO" | sed 's/[^a-zA-Z0-9]//g')
CONTAINER_NAME="${CONTAINER_NAME_BASE}_${ID_UNICO}" 

echo -e "\e[1;34m[*] Analizando y ejecutando Entrypoint original...\e[0m"

# ==============================================================================
# CAMBIO CLAVE: Ejecutamos el contenedor respetando su configuración nativa.
# Mapeamos puertos comunes y dejamos que Docker ejecute el CMD/ENTRYPOINT original.
# ==============================================================================
sudo docker run -d \
    -p 80:80 \
    -p 443:443 \
    -p 21:21 \
    -p 22:22 \
    -p 3306:3306 \
    -p 8080:8080 \
    --name "$CONTAINER_NAME" "$IMAGE_NAME"

if [ $? -ne 0 ]; then
    echo -e "\e[91m\n[X] Error al iniciar el contenedor. Revisa los logs de Docker o conflictos de puertos.\e[0m"
    detener_y_eliminar_contenedor
    exit 1
fi

# 4. Obtener IP
IP_DOCKER=$(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME" 2>/dev/null)

echo -e "\n\e[1;92m[✔] ¡Máquina vulnerable lista!\n\e[0m"
echo -e "\e[1;97m--------------------------------------------------------------------------------\e[0m"
echo -e "\e[1;97m  Contenedor cargado: ------------------------------>\e[1;92m $CONTAINER_NAME\e[0m"
echo -e "\e[1;97m  IP del laboratorio (Local Docker): --------------->\e[1;96m $IP_DOCKER\e[0m"
echo -e "\e[1;97m  Puertos expuestos en localhost: ------------------>\e[1;33m 21, 22, 80, 443, 3306, 8080\e[0m"
echo -e "\e[1;97m--------------------------------------------------------------------------------\e[0m"
echo -e "\n\e[1;5m[Exit] Pulsa Control C para detener el contenedor de ${SCRIPT_NAME} y salir del programa.\n\e[0m"

while true; do sleep 1; done
