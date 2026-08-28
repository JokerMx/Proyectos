#!/usr/bin/env bash
set -euo pipefail

# Script de setup para Linux/macOS
# Verifica e instala requisitos para ejecutar crea-proyecto.sh

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}"
cat << 'EOF'
╔════════════════════════════════════════════════════════════╗
║      Setup de crea-proyecto para Linux/macOS               ║
║                                                            ║
║  Este script verifica e instala los requisitos necesarios  ║
╚════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Detectar SO
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    DISTRO=$(lsb_release -si 2>/dev/null || echo "Unknown")
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    echo -e "${RED}SO no soportado: $OSTYPE${NC}"
    exit 1
fi

echo -e "${YELLOW}Sistema detectado: $OS ($OSTYPE)${NC}\n"

# Funciones
check_command() {
    if command -v "$1" &> /dev/null; then
        local version=$("$1" --version 2>&1 | head -n1)
        echo -e "${GREEN}✓${NC} $1 instalado: $version"
        return 0
    else
        echo -e "${RED}✗${NC} $1 no instalado"
        return 1
    fi
}

install_docker_linux() {
    echo -e "\n${YELLOW}Instalando Docker en Linux...${NC}"
    
    if [[ "$DISTRO" == "Ubuntu" ]] || [[ "$DISTRO" == "Debian" ]]; then
        sudo apt-get update
        sudo apt-get install -y curl gnupg lsb-release
        
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        
        sudo usermod -aG docker $USER
        
        echo -e "${GREEN}✓ Docker instalado correctamente${NC}"
        echo -e "${YELLOW}Nota: Ejecuta 'newgrp docker' para aplicar los permisos sin reiniciar${NC}"
        
    elif [[ "$DISTRO" == "CentOS" ]] || [[ "$DISTRO" == "Fedora" ]]; then
        sudo dnf install -y dnf-plugins-core
        echo '[docker-ce-stable]
name=Docker CE Stable
baseurl=https://download.docker.com/linux/fedora/$releasever/$basearch
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/fedora/gpg' | sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null
        sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -aG docker $USER
        
        echo -e "${GREEN}✓ Docker instalado correctamente${NC}"
    else
        echo -e "${RED}Distro no automáticamente soportada: $DISTRO${NC}"
        echo "Instala Docker manualmente desde: https://docs.docker.com/engine/install/"
        return 1
    fi
}

install_docker_macos() {
    echo -e "\n${YELLOW}Instalando Docker en macOS...${NC}"
    
    if command -v brew &> /dev/null; then
        brew install docker docker-compose
        echo -e "${GREEN}✓ Docker instalado con Homebrew${NC}"
        echo -e "${YELLOW}Inicia Docker Desktop manualmente o usa 'colima start'${NC}"
    else
        echo -e "${RED}Homebrew no está instalado${NC}"
        echo "Instala Homebrew primero: https://brew.sh"
        return 1
    fi
}

install_dependencies() {
    echo -e "\n${YELLOW}Instalando dependencias...${NC}"
    
    if [[ "$OS" == "linux" ]]; then
        if [[ "$DISTRO" == "Ubuntu" ]] || [[ "$DISTRO" == "Debian" ]]; then
            sudo apt-get install -y \
                curl \
                git \
                netcat-openbsd \
                openssl \
                jq
        elif [[ "$DISTRO" == "CentOS" ]] || [[ "$DISTRO" == "Fedora" ]]; then
            sudo dnf install -y \
                curl \
                git \
                nmap-ncat \
                openssl \
                jq
        fi
    elif [[ "$OS" == "macos" ]]; then
        if ! command -v brew &> /dev/null; then
            echo -e "${RED}Homebrew no instalado${NC}"
            return 1
        fi
        brew install curl git netcat openssl jq
    fi
    
    echo -e "${GREEN}✓ Dependencias instaladas${NC}"
}

# Verificaciones
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}1. Verificando requisitos...${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}\n"

DOCKER_OK=false
DOCKER_COMPOSE_OK=false
BASH_OK=false
NETCAT_OK=false
OPENSSL_OK=false

check_command "bash" && BASH_OK=true
check_command "docker" && DOCKER_OK=true
check_command "docker-compose" && DOCKER_COMPOSE_OK=true
check_command "nc" || check_command "ncat" && NETCAT_OK=true
check_command "openssl" && OPENSSL_OK=true

# Resumen
echo -e "\n${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}2. Resumen de verificación${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}\n"

if $BASH_OK; then
    echo -e "${GREEN}✓${NC} Bash está instalado"
else
    echo -e "${RED}✗${NC} Bash no está disponible (requerido)"
    exit 1
fi

if $DOCKER_OK && $DOCKER_COMPOSE_OK; then
    echo -e "${GREEN}✓${NC} Docker y Docker Compose están listos"
else
    echo -e "${RED}✗${NC} Docker no está instalado o no está accesible"
    
    read -p "¿Deseas instalar Docker ahora? (s/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        if [[ "$OS" == "linux" ]]; then
            install_docker_linux
        else
            install_docker_macos
        fi
    else
        echo -e "${YELLOW}Por favor instala Docker manualmente${NC}"
        exit 1
    fi
fi

if ! $NETCAT_OK; then
    echo -e "${YELLOW}⚠${NC} Netcat no instalado (necesario para verificar puertos)"
    read -p "¿Instalar ahora? (s/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        install_dependencies
    fi
else
    echo -e "${GREEN}✓${NC} Netcat está disponible"
fi

if ! $OPENSSL_OK; then
    echo -e "${YELLOW}⚠${NC} OpenSSL no instalado (necesario para generar claves)"
    read -p "¿Instalar ahora? (s/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        install_dependencies
    fi
else
    echo -e "${GREEN}✓${NC} OpenSSL está disponible"
fi

# Permisos
echo -e "\n${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}3. Configurando permisos${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}\n"

if [ -f "crea-proyecto.sh" ]; then
    chmod +x crea-proyecto.sh
    echo -e "${GREEN}✓${NC} Permisos configurados para crea-proyecto.sh"
else
    echo -e "${YELLOW}⚠${NC} crea-proyecto.sh no encontrado en el directorio actual"
fi

# Usuario en grupo docker
if [[ "$OS" == "linux" ]]; then
    if id -nG "$USER" | grep -qw "docker"; then
        echo -e "${GREEN}✓${NC} Usuario en grupo docker"
    else
        echo -e "${YELLOW}⚠${NC} Usuario no está en el grupo docker"
        echo -e "Ejecuta: ${CYAN}newgrp docker${NC}"
    fi
fi

# Verificar Docker daemon
echo -e "\n${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}4. Verificando Docker daemon${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}\n"

if docker ps &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker daemon está corriendo"
    DOCKER_VERSION=$(docker --version)
    echo "  $DOCKER_VERSION"
else
    echo -e "${YELLOW}⚠${NC} Docker daemon no está corriendo"
    if [[ "$OS" == "macos" ]]; then
        echo -e "  Inicia Docker Desktop o ejecuta: ${CYAN}colima start${NC}"
    else
        echo -e "  Inicia el daemon: ${CYAN}sudo systemctl start docker${NC}"
    fi
fi

# Finalización
echo -e "\n${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}5. Setup completado${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}\n"

echo -e "${GREEN}✓ ¡Todo listo!${NC}\n"

echo "Próximos pasos:"
echo "1. Ejecuta el generador:"
echo -e "   ${CYAN}./crea-proyecto.sh${NC}"
echo ""
echo "2. O con parámetros:"
echo -e "   ${CYAN}./crea-proyecto.sh -n tu-proyecto -t PHP -b MariaDB${NC}"
echo ""
echo "3. Documentación disponible en:"
echo -e "   - ${CYAN}README-Linux-Mac.md${NC} (Guía de uso)"
echo -e "   - ${CYAN}CONVERSION-GUIDE.md${NC} (Cambios técnicos)"
echo ""

# Link de documentación
if command -v xdg-open &> /dev/null; then
    read -p "¿Abrir documentación en el navegador? (s/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        xdg-open "README-Linux-Mac.md" 2>/dev/null || echo "Abre README-Linux-Mac.md manualmente"
    fi
fi
