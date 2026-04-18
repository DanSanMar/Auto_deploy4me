#!/bin/bash

# ==============================================================================
# SCRIPT DE AUTO-DESPLIEGUE PARA LABORATORIOS CTF - (DOCKER + WSL2) - VERSIÓN 4 ROBUSTA
# ==============================================================================
# para limpiar la salida:
stty -echoctl
# --- FUNCIONES DE CONTROL ---
# --- DEFINICIÓN DE COLORES ---
CRE='\033[31m'; CYE='\033[33m'; CGR='\033[32m'; CBL='\033[34m'
CBLE='\033[36m'; CBK='\033[37m'; CGY='\033[90m'; BLD='\033[1m'; CNC='\033[0m'

detener_y_eliminar_contenedor() {
    if [ -n "$CONTAINER_NAME" ]; then
        echo -e "\n\e[1;34m[*] Limpiando entorno del contenedor: $CONTAINER_NAME...\e[0m"
        docker rm -f "$CONTAINER_NAME" > /dev/null 2>&1 || true
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

# --- COMPROBACIÓN E INSTALACIÓN DE DOCKER ---

check_docker_installed() {
    command -v docker &> /dev/null
}

# --- GESTOR DE SERVICIOS (COMPATIBILIDAD VMS y WSL2) ---

start_docker_service() {
    # Comprueba si systemd está en uso
    if [ -d /run/systemd/system ]; then
        sudo systemctl enable docker 2>/dev/null || true
        sudo systemctl start docker 2>/dev/null || true
    else
        # Fallback para WSL2 u otros sistemas usando init.d
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

# --------------------------------------------------------

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
    
    # Instalación con retroalimentación visible
    sudo apt install docker.io -y 2>&1 | while read line; do
        echo -e -n "${CBLE}.${CNC}"
    done
    echo "" # Salto de línea limpio
    
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
    
    # SOLUCIÓN: Usar makecache en lugar de check-update
    sudo dnf makecache 2>&1 | tee /tmp/dnf_update.log
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        echo -e "${CRE}[ERROR]${CNC} Fallo al actualizar repositorios."
        return 1
    fi
    
    echo -e "${CBL}[PASO 2/4]${CNC} Instalando Docker..."
    echo -e "${CGY}(Esto puede tardar unos minutos...)${CNC}\n"
    
    # Se usa -n para imprimir los puntos en la misma línea
    sudo dnf install docker -y 2>&1 | while read line; do
        echo -e -n "${CBLE}.${CNC}"
    done
    echo "" # Salto de línea para limpiar la terminal
    
    # Comprobación de la instalación
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        echo -e "${CRE}[ERROR]${CNC} Fallo al instalar Docker."
        return 1
    fi
    
    echo -e "\n${CBL}[PASO 3/4]${CNC} Habilitando servicio Docker..."
    start_docker_service
    
    echo -e "${CBL}[PASO 4/4]${CNC} Verificando instalación..."
    sleep 2
}

# --- DETECCIÓN DE DISTRIBUCIÓN ---

detect_distribution() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            debian|ubuntu|kali|linuxmint|pop)
                echo "debian"
                ;;
            fedora|rhel|centos|rocky|almalinux)
                echo "fedora"
                ;;
            *)
                echo "unknown"
                ;;
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
            debian)
                install_docker_debian_based || exit 1
                ;;
            fedora)
                install_docker_fedora_based || exit 1
                ;;
            *)
                echo -e "${CRE}[ERROR]${CNC} Distribución no soportada automáticamente."
                echo -e "${CYE}[INFO]${CNC} Por favor, instala Docker manualmente siguiendo:"
                echo -e "${CBLE}https://docs.docker.com/engine/install/${CNC}\n"
                exit 1
                ;;
        esac
        
        # Verificación final
        if check_docker_installed; then
            echo -e "\n${CGR}[✓]${CNC} Docker instalado correctamente."
            # Dar permisos al socket para evitar errores de "permission denied" sin cerrar sesión
            sudo chmod 666 /var/run/docker.sock 2>/dev/null || true
            # Añadir usuario al grupo docker si es necesario
            if id -nG "$USER" | grep -qw "docker"; then
                echo -e "${CGR}[✓]${CNC} Usuario ya pertenece al grupo docker."
            else
                echo -e "${CYE}[!]${CNC} Agregando usuario '$USER' al grupo docker..."
                # Creamos el grupo por si acaso (muy común en WSL)
                sudo groupadd docker 2>/dev/null || true
                sudo usermod -aG docker "$USER"
                echo -e "${CYE}[INFO]${CNC} Debes reiniciar tu sesión/terminal para aplicar los cambios de grupo."
            fi
            
            echo -e "${CBLE}----------------------------------------${CNC}\n"
            sleep 2
        else
            echo -e "\n${CRE}[✗]${CNC} Error: Docker no se pudo instalar correctamente."
            echo -e "${CYE}[INFO]${CNC} Revisa los logs anteriores para diagnosticar el problema."
            exit 1
        fi
    else
        echo -e "\n${CRE}[✗]${CNC} Docker es requerido para continuar."
        echo -e "${CYE}[INFO]${CNC} Instala Docker manualmente y vuelve a ejecutar el script."
        exit 1
    fi
else
    echo -e "\n${CGR}[✓]${CNC} Docker ya está instalado (${CBL}$(docker --version | cut -d' ' -f3)${CNC})"
fi

# Verificar que el servicio esté corriendo independientemente del entorno
if ! is_docker_running; then
    echo -e "${CYE}[!]${CNC} Servicio Docker no está activo. Intentando iniciarlo..."
    start_docker_service
    sleep 3
    
    if ! is_docker_running; then
        echo -e "${CRE}[✗]${CNC} Error: No se pudo iniciar el servicio Docker."
        echo -e "${CYE}[INFO]${CNC} Si estás en WSL2, asegúrate de haber ejecutado el script o iniciado Docker de forma compatible."
        exit 1
    fi
fi

echo -e "${CGR}[✓]${CNC} Servicio Docker activado y en ejecución."


TAR_FILE="$1"

if [ ! -f "$TAR_FILE" ]; then
    echo -e "\e[1;31m[!] Error: El archivo '$TAR_FILE' no existe.\e[0m"
    exit 1
fi


# --- VARIABLES DINÁMICAS ---
# Si no se pasa nombre, usa el nombre del archivo sin extensión
SCRIPT_NAME=$(basename "$TAR_FILE" .tar)
VERSION="con deploy4me v4.0"

# --- FUNCIÓN DE IMPRESIÓN DEL LOGO ---
print_logo() {
    printf "\n"
    printf "\t                   ${CRE} ##       ${CBK} .         \n"
    printf "\t             ${CRE} ## ## ##      ${CBK} ==         \n"
    printf "\t           ${CRE}## ## ## ##      ${CBK}===         \n"
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
    # Línea de estado y nombre del script
    printf "${CGR}[✔]${CNC} Lanzando [${BLD}${CBLE}${SCRIPT_NAME}${CNC}${BLD}]${CNC} ${VERSION}${CNC} - Solo será un momento...\n"
    
    # Línea de información y ayuda
    printf "${CYE}[I]${BLD} Programa desarrollado para desplegar en WSL2 y Kali Linux\n"
    printf "${CBK}[!] Puedes abrir el navegador desde la terminal o usar la redirección automática del puerto 80 desde tu equipo principal${CNC}\n"
    
}

# Ejecutar logo
print_logo

# --- DESPLIEGUE ---

echo -e "\e[1;93m\n[*] Cargando imagen desde: $TAR_FILE\n\e[0m"

# --- Antes del docker load ---
echo -e "\n${CBL}[*]${CNC} Preparando entorno de carga..."
sudo mkdir -p /var/lib/docker/tmp
sudo chmod 1777 /var/lib/docker/tmp
# 1. Cargar imagen
if ! sudo docker load -i "$TAR_FILE"; then
    echo -e "\n\e[91m\n[X] Error fatal al cargar el .tar. Revisa el archivo.\e[0m"
    exit 1
fi

IMAGE_REPO=$(basename "$TAR_FILE" .tar)
IMAGE_NAME="${IMAGE_REPO}:latest"

if ! docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
    echo -e "\e[91m[X] La imagen $IMAGE_NAME no se encontró tras cargar.\e[0m"
    exit 1
fi

ID_UNICO=$(date +%s)
CONTAINER_NAME="${IMAGE_NAME//:/_}_${ID_UNICO}" # Reemplaza dos puntos por guiones bajos para el nombre

echo -e "\n\e[1;34m[*] Buscando puerto libre entre 8080 y 8100...\e[0m"

# 2. Búsqueda de puerto libre  usando ss o netstat
PUERTO_LIBRE=""
for port in $(seq 8080 8100); do
    # Intentamos usar 'ss' (común en systemd) o 'netstat' como fallback
    if command -v ss &> /dev/null; then
        if ! ss -tuln | grep -q ":$port "; then
            PUERTO_LIBRE=$port
            break
        fi
    elif command -v netstat &> /dev/null; then
        if ! netstat -tuln | grep -q ":$port "; then
            PUERTO_LIBRE=$port
            break
        fi
    else
        PUERTO_LIBRE=$port
        break
    fi
done

if [ -z "$PUERTO_LIBRE" ]; then
    echo -e "\n\e[91m[X] No se encontró ningún puerto libre en el rango 8080-8100.\e[0m"
    exit 1
fi

echo -e "\n\e[1;34m[*] Puerto libre encontrado: $PUERTO_LIBRE. Lanzando contenedor con el ID: \n\e[0m"

# 3. Ejecutar contenedor
sudo docker run -d -p $PUERTO_LIBRE:80 --name "$CONTAINER_NAME" "$IMAGE_NAME" \
    /bin/bash -c "
    service apache2 start 2>/dev/null || true;
    service nginx start 2>/dev/null || true;
    service mariadb start 2>/dev/null || true;
    service mysql start 2>/dev/null || true;
    while true; do sleep 60; done
    "

if [ $? -ne 0 ]; then
    echo -e "\e[91m\n[X] Error al iniciar el contenedor. Revisa los logs de Docker.\e[0m"
    detener_y_eliminar_contenedor
    exit 1
fi

# 4. Obtener IP
IP_DOCKER=$(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME" 2>/dev/null)

echo -e "\n\e[1;92m[✔] ¡Máquina vulnerable lista!\n\e[0m"
echo -e "\e[1;97m------------------------------------------------------------------------------------\e[0m"
echo -e "\e[1;97m  Contenedor cargado: ----------------------------------->\e[1;92m $CONTAINER_NAME\e[0m"
echo -e "\e[1;97m  IP del laboratorio (para WSL2 o otra VM): ------------->\e[1;96m $IP_DOCKER\e[0m"
echo -e "\e[1;97m  Redirección automática (para Localhost/Windows): ------>\e[1;92m http://localhost:$PUERTO_LIBRE\e[0m"
echo -e "\e[1;97m-------------------------------------------------------------------------------------\e[0m"
echo -e "\n\e[1;5m[Exit] Pulsa Control C para detener el contenedor de ${SCRIPT_NAME} y salir del programa.\n\e[0m"

# Mantener el script vivo
while true; do sleep 1; done