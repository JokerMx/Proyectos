#!/usr/bin/env bash
set -euo pipefail

# Script generador de proyectos Docker para PHP, Node.js y .NET
# Uso: ./crea-proyecto.sh [opciones]

# Colores
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Configuración de bases de datos
MariaDB_Host='localhost'
MariaDB_Puerto='3306'
MariaDB_Usuario='myuser'
MariaDB_Password='mypassword'
MariaDB_Database='mydatabase'

SQLServer_Host='localhost'
SQLServer_Puerto='1433'
SQLServer_Usuario='sa'
SQLServer_Password='YourStrong!Password123'
SQLServer_Database='mydatabase'

PostgreSQL_Host='localhost'
PostgreSQL_Puerto='5432'
PostgreSQL_Usuario='postgres'
PostgreSQL_Password='postgres'
PostgreSQL_Database='mydatabase'

MongoDB_Host='localhost'
MongoDB_Puerto='27017'
MongoDB_Usuario=''
MongoDB_Password=''
MongoDB_Database='mydatabase'

Redis_Host='localhost'
Redis_Puerto='6379'
Redis_Usuario=''
Redis_Password=''
Redis_Database='0'

ScriptVersion='2.0.0'
ProgressCurrent=0
ProgressTotal=0
InvalidNameChars='[\\/:\*"?<>|'\'']'

# Funciones de utilidad
write_info() { echo -e "${CYAN}$1${NC}"; }
write_success() { echo -e "${GREEN}[OK] $1${NC}"; }
write_warning() { echo -e "${YELLOW}[!] $1${NC}"; }
write_error() { echo -e "${RED}[ERROR] $1${NC}"; }
write_separator() { echo -e "${GRAY}$(printf '%.0s=' {1..60})${NC}"; }

write_progress_bar() {
    local activity=$1
    local completed=$2
    local total=$3
    
    if [ "$total" -gt 0 ]; then
        local percent=$((completed * 100 / total))
        local bars=$((percent / 2))
        local spaces=$((50 - bars))
        printf "\r${CYAN}[$(printf '%.0s=' $(seq 1 "$bars"))$(printf '%.0s-' $(seq 1 "$spaces"))] %d%% - %s (%d/%d)${NC}" "$percent" "$activity" "$completed" "$total"
    fi
    
    if [ "$completed" -eq "$total" ]; then
        echo ""
    fi
}

write_generated_file() {
    local path=$1
    shift
    
    mkdir -p "$(dirname "$path")"
    printf '%s\n' "$@" > "$path"
    
    if [ $ProgressCurrent -lt $ProgressTotal ]; then
        ((ProgressCurrent++))
    fi
    
    write_progress_bar "Generando $path" $ProgressCurrent $ProgressTotal
}

new_random_key() {
    local length=${1:-32}
    openssl rand -base64 "$length" 2>/dev/null || head -c "$length" /dev/urandom | base64
}

read_menu_option() {
    local title=$1
    declare -A options=()
    
    shift
    while [ $# -gt 1 ]; do
        options[$1]=$2
        shift 2
    done
    
    while true; do
        echo "" >&2
        write_info "$title" >&2
        for key in $(echo "${!options[@]}" | tr ' ' '\n' | sort -n); do
            echo "  $key. ${options[$key]}" >&2
        done
        
        read -p "Selecciona una opcion: " selection
        
        if [ -n "${options[$selection]:-}" ]; then
            echo "$selection"
            return 0
        fi
        
        write_warning "Opcion no valida. Elige uno de los numeros mostrados." >&2
    done
}

read_project_name() {
    while true; do
        read -p "Nombre del proyecto: " value
        
        if [ -n "$value" ] && ! [[ "$value" =~ $InvalidNameChars ]]; then
            echo "${value:0:${#value}}"
            return 0
        fi
        
        write_warning "Usa un nombre no vacio y sin caracteres invalidos para una carpeta."
    done
}

test_port_available() {
    local port=$1
    ! nc -z 127.0.0.1 "$port" 2>/dev/null
}

read_port() {
    local default=$1
    
    while true; do
        read -p "Puerto externo (Enter para $default): " input_value
        
        local port=$default
        if [ -n "$input_value" ]; then
            if ! [[ "$input_value" =~ ^[0-9]+$ ]]; then
                port=0
            else
                port=$input_value
            fi
        fi
        
        if [ "$port" -ge 1 ] && [ "$port" -le 65535 ] && test_port_available "$port"; then
            echo "$port"
            return 0
        fi
        
        local alternative=$((default + 1))
        while [ $alternative -lt 65535 ] && ! test_port_available "$alternative"; do
            ((alternative++))
        done
        
        if [ $alternative -lt 65535 ]; then
            write_warning "Puerto $port ocupado. Sugerencia: usa $alternative"
        else
            write_warning "Puerto invalido u ocupado. Elige otro."
        fi
    done
}

# Banner
clear || true
cat << 'EOF'
   ____  _             _     ____            _             _ 
  |  _ \(_)_ __   __ _| |   |  _ \  __ _ ___| |__ _ __ ___| |
  | | | | | '_ \ / _` | |   | | | |/ _` / __| '_ \ '__/ _ \ |
  | |_| | | | | | (_| | |   | |_| | (_| \__ \ | | | | |  __/ |
  |____/|_|_| |_|\__,_|_|   |____/ \__,_|___/_| |_|_|\___|_|
EOF
write_separator
write_info "CREADOR DE PROYECTOS PARA DOCKER"
echo "Version del generador: $ScriptVersion"
write_separator

# Modo interactivo
Nombre=""
Tipo=""
Framework=""
BD="MariaDB"
VersionPHP=""
VersionNode=""
GestorNode="npm"
VersionDotNet=""
PuertoApp=0
PuertoBD=0

# Parsear argumentos (opcional)
while getopts "n:t:f:b:p:v:" opt; do
    case $opt in
        n) Nombre="$OPTARG" ;;
        t) Tipo="$OPTARG" ;;
        f) Framework="$OPTARG" ;;
        b) BD="$OPTARG" ;;
        p) PuertoApp="$OPTARG" ;;
        v) VersionPHP="$OPTARG" ;;
        *) ;;
    esac
done

ModoInteractivo=$([[ -z "$Nombre" && -z "$Tipo" ]] && echo "true" || echo "false")

# Leer archivo de configuración si existe
if [ -f "crea-proyecto.config.json" ]; then
    if command -v jq &> /dev/null; then
        GlobalConfig=$(cat crea-proyecto.config.json)
        [ -z "$Nombre" ] && Nombre=$(echo "$GlobalConfig" | jq -r '.Nombre // empty')
        [ -z "$Tipo" ] && Tipo=$(echo "$GlobalConfig" | jq -r '.Tipo // empty')
        [ -z "$Framework" ] && Framework=$(echo "$GlobalConfig" | jq -r '.Framework // empty')
        [ -z "$BD" ] && BD=$(echo "$GlobalConfig" | jq -r '.BD // empty')
    fi
fi

# Preguntas interactivas
if [ "$ModoInteractivo" = "true" ] || [ -z "$Nombre" ]; then
    echo ""
    write_info "Guia rapida: elige el tipo de proyecto y la base de datos."
    echo "Tambien puedes ejecutar el script con parametros para automatizarlo."
    Nombre=$(read_project_name)
fi

if [ "$ModoInteractivo" = "true" ] || [ -z "$Tipo" ]; then
    TipoSeleccionado=$(read_menu_option "Que tipo de proyecto quieres crear?" \
        "1" "PHP - Aplicacion web PHP" \
        "2" "Node - API Node.js con Express" \
        "3" "DotNet - API ASP.NET Core")
    case $TipoSeleccionado in
        1) Tipo="PHP" ;;
        2) Tipo="Node" ;;
        3) Tipo="DotNet" ;;
    esac
fi

if [ "$ModoInteractivo" = "true" ] || [ -z "$Framework" ]; then
    if [ "$Tipo" = "PHP" ]; then
        FrameworkSeleccionado=$(read_menu_option "Que framework PHP quieres usar?" \
            "1" "PHP Base" "2" "Laravel" "3" "Symfony" "4" "Slim" "5" "CakePHP")
        case $FrameworkSeleccionado in
            1) Framework="PHP Base" ;;
            2) Framework="Laravel" ;;
            3) Framework="Symfony" ;;
            4) Framework="Slim" ;;
            5) Framework="CakePHP" ;;
        esac
    elif [ "$Tipo" = "Node" ]; then
        FrameworkSeleccionado=$(read_menu_option "Que framework Node.js quieres usar?" \
            "1" "Express" "2" "NestJS" "3" "Fastify" "4" "Koa")
        case $FrameworkSeleccionado in
            1) Framework="Express" ;;
            2) Framework="NestJS" ;;
            3) Framework="Fastify" ;;
            4) Framework="Koa" ;;
        esac
    else
        FrameworkSeleccionado=$(read_menu_option "Que plantilla .NET quieres usar?" \
            "1" "Web API" "2" "MVC" "3" "Minimal API" "4" "Blazor")
        case $FrameworkSeleccionado in
            1) Framework="Web API" ;;
            2) Framework="MVC" ;;
            3) Framework="Minimal API" ;;
            4) Framework="Blazor" ;;
        esac
    fi
fi

if [ -z "$Framework" ]; then
    case $Tipo in
        PHP) Framework="PHP Base" ;;
        Node) Framework="Express" ;;
        DotNet) Framework="Web API" ;;
    esac
fi

if [ "$ModoInteractivo" = "true" ]; then
    TemplateSeleccionado=$(read_menu_option "Que plantilla quieres usar?" \
        "1" "API Base" "2" "CRUD" "3" "JWT Auth" "4" "Microservicio")
    case $TemplateSeleccionado in
        1) Template="API Base" ;;
        2) Template="CRUD" ;;
        3) Template="JWT Auth" ;;
        4) Template="Microservicio" ;;
    esac
else
    Template="API Base"
fi

if [ "$ModoInteractivo" = "true" ] || [ -z "$BD" ]; then
    BDSeleccionada=$(read_menu_option "Que base de datos quieres configurar?" \
        "1" "MariaDB - Recomendado para PHP y Node.js" \
        "2" "SQLServer - Pensado para proyectos .NET" \
        "3" "PostgreSQL - Base de datos relacional" \
        "4" "MongoDB - Base de datos documental" \
        "5" "Redis - Cache y almacenamiento clave-valor" \
        "6" "Ambas - Mantener MariaDB y SQL Server disponibles")
    case $BDSeleccionada in
        1) BD="MariaDB" ;;
        2) BD="SQLServer" ;;
        3) BD="PostgreSQL" ;;
        4) BD="MongoDB" ;;
        5) BD="Redis" ;;
        6) BD="Ambas" ;;
    esac
fi

# Configuración de base de datos
case $BD in
    SQLServer)
        ConfiguracionBD_Host=$SQLServer_Host
        ConfiguracionBD_Puerto=$SQLServer_Puerto
        ConfiguracionBD_Usuario=$SQLServer_Usuario
        ConfiguracionBD_Password=$SQLServer_Password
        ConfiguracionBD_Database=$SQLServer_Database
        ;;
    PostgreSQL)
        ConfiguracionBD_Host=$PostgreSQL_Host
        ConfiguracionBD_Puerto=$PostgreSQL_Puerto
        ConfiguracionBD_Usuario=$PostgreSQL_Usuario
        ConfiguracionBD_Password=$PostgreSQL_Password
        ConfiguracionBD_Database=$PostgreSQL_Database
        ;;
    MongoDB)
        ConfiguracionBD_Host=$MongoDB_Host
        ConfiguracionBD_Puerto=$MongoDB_Puerto
        ConfiguracionBD_Usuario=$MongoDB_Usuario
        ConfiguracionBD_Password=$MongoDB_Password
        ConfiguracionBD_Database=$MongoDB_Database
        ;;
    Redis)
        ConfiguracionBD_Host=$Redis_Host
        ConfiguracionBD_Puerto=$Redis_Puerto
        ConfiguracionBD_Usuario=$Redis_Usuario
        ConfiguracionBD_Password=$Redis_Password
        ConfiguracionBD_Database=$Redis_Database
        ;;
    Ambas)
        ConfiguracionBD_Host=$MariaDB_Host
        ConfiguracionBD_Puerto=$MariaDB_Puerto
        ConfiguracionBD_Usuario=$MariaDB_Usuario
        ConfiguracionBD_Password=$MariaDB_Password
        ConfiguracionBD_Database=$MariaDB_Database
        ;;
    *)
        ConfiguracionBD_Host=$MariaDB_Host
        ConfiguracionBD_Puerto=$MariaDB_Puerto
        ConfiguracionBD_Usuario=$MariaDB_Usuario
        ConfiguracionBD_Password=$MariaDB_Password
        ConfiguracionBD_Database=$MariaDB_Database
        ;;
esac

# Cadena de conexión
case $BD in
    SQLServer)
        CadenaConexion="Server=$ConfiguracionBD_Host,$ConfiguracionBD_Puerto;Database=$ConfiguracionBD_Database;User Id=$ConfiguracionBD_Usuario;Password=$ConfiguracionBD_Password;TrustServerCertificate=True;"
        ;;
    PostgreSQL)
        CadenaConexion="Host=$ConfiguracionBD_Host;Port=$ConfiguracionBD_Puerto;Database=$ConfiguracionBD_Database;Username=$ConfiguracionBD_Usuario;Password=$ConfiguracionBD_Password;"
        ;;
    MongoDB)
        CadenaConexion="mongodb://$ConfiguracionBD_Host:$ConfiguracionBD_Puerto/$ConfiguracionBD_Database"
        ;;
    Redis)
        CadenaConexion="$ConfiguracionBD_Host:$ConfiguracionBD_Puerto"
        ;;
    *)
        CadenaConexion="Server=$ConfiguracionBD_Host;Port=$ConfiguracionBD_Puerto;Database=$ConfiguracionBD_Database;User=$ConfiguracionBD_Usuario;Password=$ConfiguracionBD_Password;"
        ;;
esac

echo "Proyecto: $Nombre"
echo "Tipo: $Tipo"
echo "Base de datos: $BD"

# Versiones específicas
if [ "$Tipo" = "PHP" ] && [ -z "$VersionPHP" ]; then
    if [ "$ModoInteractivo" = "true" ]; then
        VersionPHPSel=$(read_menu_option "Que version de PHP quieres usar?" \
            "1" "7.4" "2" "8.0" "3" "8.1" "4" "8.2" "5" "8.3")
        case $VersionPHPSel in
            1) VersionPHP="7.4" ;;
            2) VersionPHP="8.0" ;;
            3) VersionPHP="8.1" ;;
            4) VersionPHP="8.2" ;;
            5) VersionPHP="8.3" ;;
        esac
    else
        VersionPHP="8.3"
    fi
fi

if [ "$Tipo" = "Node" ] && [ -z "$VersionNode" ]; then
    if [ "$ModoInteractivo" = "true" ]; then
        VersionNodeSel=$(read_menu_option "Que version de Node.js quieres usar?" \
            "1" "16" "2" "18" "3" "20" "4" "22")
        case $VersionNodeSel in
            1) VersionNode="16" ;;
            2) VersionNode="18" ;;
            3) VersionNode="20" ;;
            4) VersionNode="22" ;;
        esac
    else
        VersionNode="22"
    fi
fi

if [ "$Tipo" = "Node" ] && [ -z "$GestorNode" ]; then
    if [ "$ModoInteractivo" = "true" ]; then
        GestorNodeSel=$(read_menu_option "Que gestor de paquetes quieres usar?" \
            "1" "npm" "2" "yarn")
        case $GestorNodeSel in
            1) GestorNode="npm" ;;
            2) GestorNode="yarn" ;;
        esac
    else
        GestorNode="npm"
    fi
fi

if [ "$Tipo" = "DotNet" ] && [ -z "$VersionDotNet" ]; then
    if [ "$ModoInteractivo" = "true" ]; then
        VersionDotNetSel=$(read_menu_option "Que version de .NET quieres usar?" \
            "1" "6.0" "2" "7.0" "3" "8.0" "4" "9.0")
        case $VersionDotNetSel in
            1) VersionDotNet="6.0" ;;
            2) VersionDotNet="7.0" ;;
            3) VersionDotNet="8.0" ;;
            4) VersionDotNet="9.0" ;;
        esac
    else
        VersionDotNet="8.0"
    fi
fi

if [ $PuertoApp -eq 0 ]; then
    case $Tipo in
        Node) PuertoApp=3000 ;;
        *) PuertoApp=8080 ;;
    esac
fi

if [ $PuertoBD -eq 0 ]; then
    PuertoBD=$ConfiguracionBD_Puerto
fi

if [ "$ModoInteractivo" = "true" ]; then
    PuertoApp=$(read_port $PuertoApp)
    PuertoBD=$(read_port $PuertoBD)
fi

echo ""

# Generar claves
AppKey="base64:$(new_random_key 32)"
JwtSecret=$(new_random_key 64)
DataProtectionKey=$(new_random_key 32)

# Crear estructura de carpetas
case $Tipo in
    PHP) CarpetaBase='proyectos-php' ;;
    DotNet) CarpetaBase='proyectos-dotnet' ;;
    Node) CarpetaBase='proyectos-node' ;;
esac

RutaProyecto="$PWD/$CarpetaBase/$Nombre"

if [ -d "$RutaProyecto" ]; then
    write_error "El proyecto '$Nombre' ya existe en '$RutaProyecto'"
    exit 1
fi

mkdir -p "$RutaProyecto"
write_info "Creando estructura y archivos..."

case $Tipo in
    PHP) ProgressTotal=35 ;;
    Node) ProgressTotal=33 ;;
    DotNet) ProgressTotal=35 ;;
esac

ProgressCurrent=0

# Crear directorios específicos
case $Framework in
    Laravel)
        mkdir -p "$RutaProyecto"/{database/migrations,database/seeders,lang}
        ;;
    CakePHP)
        mkdir -p "$RutaProyecto"/{config,logs,src/Controller,src/Model,src/View,src/Template,webroot,tests}
        ;;
    NestJS)
        mkdir -p "$RutaProyecto"/{src/modules,src/common,src/config}
        ;;
esac

if [ "$Tipo" = "DotNet" ]; then
    mkdir -p "$RutaProyecto"/{Properties,wwwroot,Middlewares}
fi

# Generar archivos según tipo de proyecto
case $Tipo in
    PHP)
        mkdir -p "$RutaProyecto"/{app,config,database,public,resources,routes,storage,tests}
        
        # .env
        write_generated_file "$RutaProyecto/.env" \
            "APP_NAME=$Nombre" \
            'APP_ENV=local' \
            'APP_DEBUG=true' \
            "APP_URL=http://localhost:$PuertoApp" \
            "APP_KEY=$AppKey" \
            "DB_HOST=$ConfiguracionBD_Host" \
            "DB_PORT=$ConfiguracionBD_Puerto" \
            "DB_DATABASE=$ConfiguracionBD_Database" \
            "DB_USERNAME=$ConfiguracionBD_Usuario" \
            "DB_PASSWORD=$ConfiguracionBD_Password"
        
        # public/index.php
        write_generated_file "$RutaProyecto/public/index.php" \
            '<?php' \
            "echo \"Proyecto PHP '"'"'$Nombre'"'"' funcionando!<br><br>\";" \
            ' ' \
            "// CORS headers" \
            "header('Access-Control-Allow-Origin: *');" \
            "header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');" \
            "header('Access-Control-Allow-Headers: Content-Type, Authorization');" \
            'if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(204); exit; }' \
            ' ' \
            '// Health endpoint' \
            "if (\$_SERVER['REQUEST_URI'] === '/health' || \$_SERVER['REQUEST_URI'] === '/health/') {" \
            "    header('Content-Type: application/json');" \
            "    echo json_encode(['status' => 'OK', 'project' => '$Nombre', 'database' => '$BD']);" \
            '    exit;' \
            '}' \
            '?>'
        
        # composer.json
        write_generated_file "$RutaProyecto/composer.json" \
            '{' \
            "    \"name\": \"$Nombre/aplicacion\"," \
            '    "description": "Proyecto PHP con Docker",' \
            '    "require": { "php": "^8.1" },' \
            '    "require-dev": { "phpunit/phpunit": "^10.5", "phpstan/phpstan": "^1.10" },' \
            '    "scripts": { "test": "phpunit", "analyse": "phpstan analyse" }' \
            '}'
        ;;
        
    Node)
        mkdir -p "$RutaProyecto"/{src/config,src/models,src/controllers,src/routes,src/middleware,test}
        
        # package.json
        write_generated_file "$RutaProyecto/package.json" \
            '{' \
            "  \"name\": \"$Nombre\"," \
            '  "version": "1.0.0",' \
            '  "main": "server.js",' \
            '  "scripts": { "start": "node server.js", "dev": "nodemon server.js" },' \
            '  "dependencies": { "express": "^4.18.2", "cors": "^2.8.5", "dotenv": "^16.3.1" },' \
            '  "devDependencies": { "nodemon": "^3.0.1", "eslint": "^8.50.0" }' \
            '}'
        
        # .env
        write_generated_file "$RutaProyecto/.env" \
            'PORT=3000' \
            'NODE_ENV=development' \
            "JWT_SECRET=$JwtSecret" \
            "DB_HOST=$ConfiguracionBD_Host" \
            "DB_PORT=$ConfiguracionBD_Puerto" \
            "DB_USER=$ConfiguracionBD_Usuario" \
            "DB_PASSWORD=$ConfiguracionBD_Password" \
            "DB_NAME=$ConfiguracionBD_Database"
        
        # server.js
        write_generated_file "$RutaProyecto/server.js" \
            "require('dotenv').config();" \
            "const express = require('express');" \
            "const cors = require('cors');" \
            "const app = express();" \
            "const PORT = process.env.PORT || 3000;" \
            'app.use(cors());' \
            'app.use(express.json());' \
            "app.get('/health', (req, res) => res.json({ status: 'OK', project: '$Nombre' }));" \
            "app.listen(PORT, () => console.log(\`Servidor en http://localhost:\${PORT}\`));"
        ;;
        
    DotNet)
        mkdir -p "$RutaProyecto"/{Controllers,Models,Data,Services,Migrations,tests}
        
        # appsettings.json
        write_generated_file "$RutaProyecto/appsettings.json" \
            '{' \
            '  "Logging": { "LogLevel": { "Default": "Information" } },' \
            '  "AllowedHosts": "*",' \
            "  \"ConnectionStrings\": { \"DefaultConnection\": \"$CadenaConexion\" }" \
            '}'
        
        # Program.cs
        write_generated_file "$RutaProyecto/Program.cs" \
            'var builder = WebApplication.CreateBuilder(args);' \
            'builder.Services.AddControllers();' \
            'var app = builder.Build();' \
            'app.MapGet("/health", () => Results.Json(new { status = "OK", project = "' "$Nombre" '" }));' \
            'app.MapControllers();' \
            'app.Run();'
        ;;
esac

# Dockerfile
case $Tipo in
    PHP)
        write_generated_file "$RutaProyecto/Dockerfile" \
            "FROM php:$VersionPHP-apache" \
            'RUN docker-php-ext-install pdo pdo_mysql' \
            'COPY . /var/www/html' \
            'WORKDIR /var/www/html' \
            'EXPOSE 80'
        ;;
    Node)
        if [ "$GestorNode" = "yarn" ]; then
            write_generated_file "$RutaProyecto/Dockerfile" \
                "FROM node:$VersionNode-alpine" \
                'WORKDIR /app' \
                'RUN corepack enable' \
                'COPY package.json yarn.lock* ./' \
                'RUN yarn install' \
                'COPY . .' \
                'EXPOSE 3000' \
                'CMD ["yarn", "start"]'
        else
            write_generated_file "$RutaProyecto/Dockerfile" \
                "FROM node:$VersionNode-alpine" \
                'WORKDIR /app' \
                'COPY package*.json ./' \
                'RUN npm install' \
                'COPY . .' \
                'EXPOSE 3000' \
                'CMD ["npm", "start"]'
        fi
        ;;
    DotNet)
        write_generated_file "$RutaProyecto/Dockerfile" \
            "FROM mcr.microsoft.com/dotnet/sdk:$VersionDotNet AS build" \
            'WORKDIR /src' \
            "COPY $Nombre.csproj ./" \
            'RUN dotnet restore' \
            'COPY . .' \
            'RUN dotnet publish -c Release -o /app/publish' \
            "FROM mcr.microsoft.com/dotnet/aspnet:$VersionDotNet AS final" \
            'WORKDIR /app' \
            'COPY --from=build /app/publish .' \
            'EXPOSE 8080' \
            "ENTRYPOINT [\"dotnet\", \"$Nombre.dll\"]"
        ;;
esac

# docker-compose.yml
case $BD in
    SQLServer) DatabaseServiceName='sqlserver' ;;
    PostgreSQL) DatabaseServiceName='postgres' ;;
    MongoDB) DatabaseServiceName='mongodb' ;;
    Redis) DatabaseServiceName='redis' ;;
    Ambas) DatabaseServiceName='mariadb' ;;
    *) DatabaseServiceName='mariadb' ;;
esac

# Variables de entorno
write_generated_file "$RutaProyecto/.env.example" \
    '# Nombre de la aplicacion' \
    "APP_NAME=$Nombre" \
    '# Framework utilizado' \
    "FRAMEWORK=$Framework" \
    '# Entorno' \
    'APP_ENV=development' \
    'APP_DEBUG=true' \
    "PORT=$PuertoApp" \
    'APP_KEY=change-me' \
    'JWT_SECRET=change-me' \
    "DB_TYPE=$BD" \
    "DB_HOST=$DatabaseServiceName" \
    "DB_PORT=$ConfiguracionBD_Puerto" \
    "DB_NAME=$ConfiguracionBD_Database" \
    "DB_USER=$ConfiguracionBD_Usuario" \
    'DB_PASSWORD=change-me'

# .gitignore
write_generated_file "$RutaProyecto/.gitignore" \
    'node_modules/' \
    'vendor/' \
    '.env' \
    '*.log' \
    'bin/' \
    'obj/' \
    '.DS_Store'

# start.sh
write_generated_file "$RutaProyecto/start.sh" \
    '#!/usr/bin/env sh' \
    'set -eu' \
    'if ! command -v docker >/dev/null 2>&1; then' \
    '  echo "Docker no esta instalado"' \
    '  exit 1' \
    'fi' \
    'if ! docker compose version >/dev/null 2>&1; then' \
    '  echo "Docker Compose no esta disponible"' \
    '  exit 1' \
    'fi' \
    'echo "Iniciando proyecto..."' \
    'docker compose up -d --build' \
    'docker compose ps'

chmod +x "$RutaProyecto/start.sh"

# clean.sh
write_generated_file "$RutaProyecto/clean.sh" \
    '#!/usr/bin/env sh' \
    'set -eu' \
    'echo "Limpiando proyecto..."' \
    'docker compose down --volumes --remove-orphans' \
    'rm -rf node_modules vendor bin obj .DS_Store' \
    'echo "Limpieza completada"'

chmod +x "$RutaProyecto/clean.sh"

# README.md
write_generated_file "$RutaProyecto/README.md" \
    "# $Nombre" \
    ' ' \
    "## Proyecto $Tipo con $Framework" \
    ' ' \
    "Base de datos: $BD" \
    "Puerto de la aplicacion: $PuertoApp" \
    ' ' \
    '## Inicio rapido' \
    '```bash' \
    './start.sh' \
    '```' \
    ' ' \
    '## Detener' \
    '```bash' \
    'docker compose down' \
    '```' \
    ' ' \
    '## Endpoints' \
    ' ' \
    '- `GET /health` - Health check del servicio' \
    ' ' \
    '## Documentacion' \
    ' ' \
    'Consulta los archivos en la carpeta `docs/`'

# DEPLOYMENT.md
write_generated_file "$RutaProyecto/DEPLOYMENT.md" \
    '# Despliegue' \
    ' ' \
    '1. Copia `.env.example` a `.env` y revisa las credenciales.' \
    '2. Ejecuta `docker compose up -d --build`.' \
    '3. Revisa el estado con `docker compose ps`.' \
    '4. Para produccion, cambia secretos, desactiva el modo debug y usa un proxy HTTPS.'

write_separator
write_success "Proyecto '"'"'$Nombre'"'"' creado exitosamente"
write_info "Ruta: $RutaProyecto"
write_info "Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "Proximos pasos:"
echo "1. cd $RutaProyecto"
echo "2. ./start.sh"
echo ""
echo "Credenciales $BD: $ConfiguracionBD_Usuario@$ConfiguracionBD_Host:$ConfiguracionBD_Puerto"
echo "Puerto app: $PuertoApp"
echo "Puerto BD: $PuertoBD"
echo ""
echo "Claves generadas (guardadas en .env):"
echo "- APP_KEY: $AppKey"
echo "- JWT_SECRET: $JwtSecret"
