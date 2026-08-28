# 🐳 crea-proyecto - Generador de Proyectos Docker

> Generador automatizado de proyectos Docker para **PHP**, **Node.js** y **.NET** con soporte para múltiples bases de datos y frameworks.

---

## 📋 Tabla de Contenidos

- [🚀 Quick Start](#-quick-start)
- [📦 Características](#-características)
- [🛠️ Requisitos previos](#️-requisitos-previos)
- [🔧 Instalación](#-instalación)
- [💻 Uso](#-uso)
  - [Modo interactivo](#modo-interactivo)
  - [Modo automático](#modo-automático)
- [🗂️ Tipos de proyecto](#️-tipos-de-proyecto)
- [🗄️ Bases de datos soportadas](#️-bases-de-datos-soportadas)
- [📁 Estructura generada](#-estructura-generada)
- [⚙️ Configuración](#️-configuración)
- [🔐 Seguridad](#-seguridad)
- [🧪 Comandos útiles](#-comandos-útiles)
- [📚 Ejemplos](#-ejemplos)
- [🐛 Troubleshooting](#-troubleshooting)
- [🔄 Diferencias Windows vs Linux/macOS](#-diferencias-windows-vs-linuxmacos)
- [📖 Documentación adicional](#-documentación-adicional)
- [🎓 Próximos pasos](#-próximos-pasos)

---

## 🚀 Quick Start

```bash
# 1. Clona el repositorio
git clone <repo-url> && cd crea-proyecto

# 2. Ejecuta el setup (verifica/instala requisitos)
chmod +x setup.sh
./setup.sh

# 3. Crea tu primer proyecto
chmod +x crea-proyecto.sh
./crea-proyecto.sh

# 4. Inicia los servicios
cd proyectos-{tipo}/{nombre}
./start.sh

# 5. Verifica
curl http://localhost:8080/health
```

**Tiempo total:** ~5 minutos

---

## 📦 Características

- ✅ **Modo interactivo** con menús guiados
- ✅ **Modo automático** con parámetros CLI
- ✅ **3 tipos de proyecto:** PHP, Node.js, .NET
- ✅ **11 frameworks soportados:** Laravel, Symfony, Slim, CakePHP, Express, NestJS, Fastify, Koa, Web API, MVC, Minimal API, Blazor
- ✅ **6 bases de datos:** MariaDB, PostgreSQL, SQLServer, MongoDB, Redis, Ambas
- ✅ **Detección de puertos** ocupados con sugerencias automáticas
- ✅ **Claves generadas** automáticamente (APP_KEY, JWT_SECRET)
- ✅ **Estructura completa** con Dockerfile, docker-compose, tests, CI/CD
- ✅ **Scripts utilitarios** incluidos (`start.sh`, `clean.sh`)
- ✅ **Multiplataforma:** Linux y macOS

---

## 🛠️ Requisitos previos

| Requisito | Versión mínima | Notas |
|---|---|---|
| **Bash** | 4.0+ | Incluido en Linux/macOS |
| **Docker** | 20.10+ | Motor de contenedores |
| **Docker Compose** | 2.0+ | Orquestación |
| **OpenSSL** | Cualquier | Generación de claves |
| **Netcat** | Cualquier | Verificación de puertos |

> **macOS:** Puede requerir actualizar Bash con Homebrew: `brew install bash`

---

## 🔧 Instalación

### Opción A: Automática (recomendado)

```bash
chmod +x setup.sh
./setup.sh
```

Este script:
- Detecta tu sistema operativo
- Verifica Docker, Bash, Netcat, OpenSSL
- Instala dependencias faltantes
- Configura permisos de ejecución
- Valida el daemon de Docker

### Opción B: Manual

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose curl git netcat-openbsd openssl jq
sudo usermod -aG docker $USER
newgrp docker
```

**Fedora/CentOS:**
```bash
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin curl git nmap-ncat openssl jq
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker
```

**macOS:**
```bash
brew install docker docker-compose curl git netcat openssl jq
# Inicia Docker Desktop o ejecuta: colima start
```

---

## 💻 Uso

### Modo interactivo

Ideal para principiantes. El script te guiará con preguntas paso a paso.

```bash
./crea-proyecto.sh
```

**Preguntas del menú:**
1. Nombre del proyecto
2. Tipo de proyecto (PHP, Node, .NET)
3. Framework específico
4. Plantilla (API Base, CRUD, JWT Auth, Microservicio)
5. Base de datos
6. Versión del runtime
7. Puerto de la aplicación
8. Puerto de la base de datos

### Modo automático

Ideal para automatización y CI/CD.

```bash
./crea-proyecto.sh -n "mi-proyecto" -t PHP -f Laravel -b MariaDB
./crea-proyecto.sh -n "api-rest" -t Node -f Express -b PostgreSQL
./crea-proyecto.sh -n "servicio" -t DotNet -f "Web API" -b SQLServer
```

**Parámetros disponibles:**

| Parámetro | Descripción | Valores |
|---|---|---|
| `-n` | Nombre del proyecto | Cualquier string sin caracteres especiales |
| `-t` | Tipo de proyecto | `PHP`, `Node`, `DotNet` |
| `-f` | Framework | Depende del tipo |
| `-b` | Base de datos | `MariaDB`, `SQLServer`, `PostgreSQL`, `MongoDB`, `Redis`, `Ambas` |
| `-p` | Puerto de la app | 1-65535 |
| `-v` | Versión runtime | PHP: 7.4-8.3, Node: 16-22, .NET: 6.0-9.0 |

---

## 🗂️ Tipos de proyecto

### PHP

| Framework | Descripción | Puerto default |
|---|---|---|
| **PHP Base** | Mínimo, sin framework | 8080 |
| **Laravel** | MVC moderno, ecosistema rico | 8080 |
| **Symfony** | Enterprise, componentes modulares | 8080 |
| **Slim** | Microframework ligero | 8080 |
| **CakePHP** | Full-stack, convención sobre configuración | 8080 |

### Node.js

| Framework | Descripción | Puerto default |
|---|---|---|
| **Express** | Minimalista, ampliamente usado | 3000 |
| **NestJS** | Enterprise TypeScript | 3000 |
| **Fastify** | Alto rendimiento | 3000 |
| **Koa** | Minimalista, async/await | 3000 |

### .NET

| Framework | Descripción | Puerto default |
|---|---|---|
| **Web API** | REST APIs tradicional | 8080 |
| **MVC** | Web tradicional con vistas | 8080 |
| **Minimal API** | Lightweight, minimalista | 8080 |
| **Blazor** | Full-stack con C# | 8080 |

---

## 🗄️ Bases de datos soportadas

| Base de datos | Puerto | Usuario default | Password default | Mejor para |
|---|---|---|---|---|
| **MariaDB** | 3306 | `myuser` | `mypassword` | PHP, Node |
| **SQLServer** | 1433 | `sa` | `YourStrong!Password123` | .NET |
| **PostgreSQL** | 5432 | `postgres` | `postgres` | Todos |
| **MongoDB** | 27017 | - | - | Node, Documentos |
| **Redis** | 6379 | - | - | Cache, Sesiones |
| **Ambas** | 3306/1433 | `myuser`/`sa` | `mypassword`/`YourStrong!Password123` | Multi-BD |

---

## 📁 Estructura generada

```
proyectos-{tipo}/
└── tu-proyecto/
    ├── .env                      # Variables de entorno (NO en git)
    ├── .env.example              # Plantilla de variables
    ├── .gitignore               # Archivos ignorados
    ├── Dockerfile               # Imagen Docker
    ├── docker-compose.yml       # Orquestación de servicios
    ├── README.md                # Documentación del proyecto
    ├── DEPLOYMENT.md            # Guía de despliegue
    ├── CONTRIBUTING.md          # Guía de contribución
    ├── SECURITY.md              # Políticas de seguridad
    ├── start.sh                 # Iniciar servicios (ejecutable)
    ├── clean.sh                 # Limpiar todo (ejecutable)
    ├── .editorconfig            # Configuración de editor
    │
    ├── src/                     # Código fuente
    ├── public/                  # Archivos públicos (PHP/Node)
    ├── config/                  # Configuración
    ├── database/                # Migraciones y seeders (PHP)
    ├── tests/                   # Tests unitarios
    ├── docs/                    # Documentación técnica
    │
    ├── .github/workflows/       # CI/CD GitHub
    └── .gitlab-ci.yml           # CI/CD GitLab
```

---

## ⚙️ Configuración

### Variables de entorno

El archivo `.env` contiene toda la configuración del proyecto:

```env
# Aplicación
APP_NAME=mi-proyecto
APP_ENV=development
APP_DEBUG=true
APP_URL=http://localhost:8080
APP_KEY=base64:...
JWT_SECRET=...

# Base de datos
DB_TYPE=MariaDB
DB_HOST=mariadb
DB_PORT=3306
DB_NAME=mydatabase
DB_USER=myuser
DB_PASSWORD=mypassword

# Puerto
PORT=8080
```

### Puertos

| Proyecto | Puerto default | Variable |
|---|---|---|
| PHP | 8080 | `PuertoApp` |
| Node.js | 3000 | `PuertoApp` |
| .NET | 8080 | `PuertoApp` |
| MariaDB | 3306 | `PuertoBD` |
| PostgreSQL | 5432 | `PuertoBD` |
| SQLServer | 1433 | `PuertoBD` |
| MongoDB | 27017 | `PuertoBD` |
| Redis | 6379 | `PuertoBD` |

### Archivo de configuración global

Puedes crear `crea-proyecto.config.json` para valores por defecto:

```json
{
  "Nombre": "mi-proyecto",
  "Tipo": "PHP",
  "Framework": "Laravel",
  "BD": "MariaDB"
}
```

---

## 🔐 Seguridad

- ✅ **`.env` excluido de git** automáticamente
- ✅ **Claves generadas** aleatoriamente en cada proyecto
- ✅ **Variables separadas** por ambiente (`.env.development`, `.env.production`, `.env.test`)
- ✅ **Secretos en `.env.example`** marcados como `change-me`
- ✅ **Documentación `SECURITY.md`** incluida en cada proyecto
- ✅ **CORS configurado** en el código generado
- ✅ **Health check** endpoint incluido (`/health`)

### Claves generadas automáticamente

| Clave | Uso | Longitud |
|---|---|---|
| `APP_KEY` | Encriptación de aplicación | 32 bytes (base64) |
| `JWT_SECRET` | Autenticación JWT | 64 bytes (base64) |
| `DATA_PROTECTION_KEY` | Protección de datos | 32 bytes (base64) |

---

## 🧪 Comandos útiles

### Gestión del proyecto

```bash
# Iniciar servicios
./start.sh

# Ver estado
docker compose ps

# Ver logs
docker compose logs -f
docker compose logs -f app

# Detener servicios
docker compose down

# Limpiar todo (incluyendo volúmenes)
./clean.sh

# Acceder al contenedor
docker compose exec app bash       # PHP/Node
docker compose exec app powershell # .NET
```

### Desarrollo

```bash
# PHP
docker compose exec app composer install
docker compose exec app php artisan migrate

# Node.js
docker compose exec app npm install
docker compose exec app npm run dev

# .NET
docker compose exec app dotnet restore
docker compose exec app dotnet watch run
```

### Verificación

```bash
# Health check
curl http://localhost:8080/health
curl http://localhost:3000/health

# Acceder a BD desde host
mysql -h localhost -P 3306 -u myuser -p           # MariaDB
psql -h localhost -p 5432 -U postgres             # PostgreSQL
mongosh mongodb://localhost:27017                  # MongoDB
redis-cli -h localhost -p 6379                     # Redis
```

---

## 📚 Ejemplos

### Proyecto PHP + Laravel + MariaDB

```bash
./crea-proyecto.sh -n "blog" -t PHP -f Laravel -b MariaDB
cd proyectos-php/blog
./start.sh
```

### Proyecto Node.js + Express + PostgreSQL

```bash
./crea-proyecto.sh -n "api-rest" -t Node -f Express -b PostgreSQL
cd proyectos-node/api-rest
./start.sh
npm install
```

### Proyecto .NET + Web API + SQLServer

```bash
./crea-proyecto.sh -n "microservicio" -t DotNet -f "Web API" -b SQLServer
cd proyectos-dotnet/microservicio
./start.sh
dotnet restore
```

### Proyecto PHP + Symfony + PostgreSQL

```bash
./crea-proyecto.sh -n "app" -t PHP -f Symfony -b PostgreSQL
cd proyectos-php/app
./start.sh
```

### Proyecto Node.js + NestJS + MongoDB

```bash
./crea-proyecto.sh -n "backend" -t Node -f NestJS -b MongoDB
cd proyectos-node/backend
./start.sh
```

### Proyecto .NET + Blazor + Redis (Cache)

```bash
./crea-proyecto.sh -n "dashboard" -t DotNet -f Blazor -b Redis
cd proyectos-dotnet/dashboard
./start.sh
```

---

## 🐛 Troubleshooting

| Problema | Causa | Solución |
|---|---|---|
| `Permission denied` | Falta permiso de ejecución | `chmod +x crea-proyecto.sh` |
| `docker: command not found` | Docker no instalado | Ejecuta `./setup.sh` |
| `nc: command not found` | Netcat no instalado | `apt-get install netcat-openbsd` o `brew install netcat` |
| `openssl: command not found` | OpenSSL no instalado | `apt-get install openssl` o `brew install openssl` |
| Puerto ocupado | Puerto en uso | El script sugiere alternativas automáticamente |
| `Cannot connect to Docker daemon` | Docker no corriendo | `sudo systemctl start docker` o inicia Docker Desktop |
| `clear: command not found` | Entorno sin terminal interactiva | El script lo maneja automáticamente |

### Verificar instalación

```bash
# Verificar bash
bash --version

# Verificar Docker
docker --version
docker compose version

# Verificar Docker daemon
docker ps

# Verificar usuario en grupo docker (Linux)
id -nG $USER | grep -qw "docker" && echo "OK" || echo "Agregar con: sudo usermod -aG docker $USER"
```

---

## 🔄 Diferencias Windows vs Linux/macOS

| Aspecto | Windows PowerShell | Linux/macOS Bash |
|---|---|---|
| **Archivo** | `crea-proyecto.ps1` | `crea-proyecto.sh` |
| **Sintaxis variables** | `$variable = valor` | `variable="valor"` |
| **Paths** | `C:\ruta\archivo` | `/ruta/archivo` |
| **Unir paths** | `Join-Path $a $b` | `"$a/$b"` |
| **Test archivo existe** | `Test-Path $path` | `[ -f "$path" ]` |
| **Leer archivo** | `Get-Content` | `cat` |
| **Crear directorio** | `New-Item` | `mkdir -p` |
| **Test puerto** | `Get-NetTCPConnection` | `nc -z host port` |
| **Output con color** | `Write-Host` | `echo -e "${COLOR}texto${NC}"` |
| **Generar clave** | `[Convert]::ToBase64String` | `openssl rand -base64` |
| **Parsing argumentos** | `param()` | `getopts` |
| **Funciones** | `function Nombre { }` | `nombre() { }` |
| **Switch** | `switch ($x) { ... }` | `case $x in ... esac` |
| **Set ejecutable** | Automático | `chmod +x archivo` |

---

## 📖 Documentación adicional

| Documento | Descripción |
|---|---|
| **INDEX.md** | Navegación central de toda la documentación |
| **QUICKSTART.md** | Guía de inicio rápido (5 minutos) |
| **README-Linux-Mac.md** | Guía completa de uso |
| **CONVERSION-GUIDE.md** | Cambios técnicos PowerShell → Bash (15+ ejemplos) |
| **RESUMEN.md** | Resumen general del proyecto |
| **SETUP-COMPLETADO.md** | Verificación de instalación completada |

---

## 🎓 Próximos pasos

### Después de crear tu proyecto

1. **Explorar la estructura:**
   ```bash
   cd proyectos-{tipo}/{nombre}
   ls -la
   cat README.md
   ```

2. **Revisar configuración:**
   ```bash
   cat .env
   cat docker-compose.yml
   ```

3. **Iniciar servicios:**
   ```bash
   ./start.sh
   docker compose ps
   ```

4. **Probar health check:**
   ```bash
   curl http://localhost:8080/health
   ```

5. **Desarrollar:**
   - Modifica archivos en `src/`, `public/`, `config/`
   - Usa `docker compose exec app bash` para acceder al contenedor
   - Consulta logs con `docker compose logs -f`

### Despliegue a producción

1. Lee `DEPLOYMENT.md` en tu proyecto
2. Cambia variables de entorno para producción
3. Desactiva `APP_DEBUG`
4. Configura HTTPS/proxy inverso
5. Usa secrets management para credenciales

### CI/CD

Cada proyecto incluye:
- `.github/workflows/ci.yml` - GitHub Actions
- `.gitlab-ci.yml` - GitLab CI

Personaliza según tu pipeline.

---

## 📞 Soporte

### Recursos

- **ShellCheck:** https://www.shellcheck.net - Verificador de sintaxis Bash
- **Bash Guide:** https://mywiki.wooledge.org/BashGuide
- **POSIX Shell:** https://pubs.opengroup.org/onlinepubs/9699919799/
- **Docker Compose:** https://docs.docker.com/compose/

### Troubleshooting

1. Consulta la sección [Troubleshooting](#-troubleshooting) de este documento
2. Ejecuta `./setup.sh` para diagnosticar problemas
3. Revisa `CONVERSION-GUIDE.md` para errores de sintaxis
4. Verifica logs: `docker compose logs app`

---

## 📊 Resumen de archivos del proyecto

| Archivo | Propósito |
|---|---|
| `crea-proyecto.sh` | ⭐ Generador principal de proyectos |
| `setup.sh` | 🔧 Verifica e instala requisitos |
| `INDEX.md` | 📍 Navegación central |
| `QUICKSTART.md` | 🚀 Inicio rápido (5 min) |
| `README-Linux-Mac.md` | 📖 Guía completa |
| `CONVERSION-GUIDE.md` | 🔄 Cambios PowerShell → Bash |
| `RESUMEN.md` | 📋 Resumen general |
| `SETUP-COMPLETADO.md` | ✅ Verificación de setup |

---

## 🎯 Flujo de trabajo recomendado

### Primera vez (15 minutos)

1. Lee `QUICKSTART.md` (5 min)
2. Ejecuta `./setup.sh` (5 min)
3. Ejecuta `./crea-proyecto.sh` (5 min)

### Uso diario

```bash
./crea-proyecto.sh                    # Modo interactivo
./crea-proyecto.sh -n "app" -t PHP    # Modo rápido
cd proyectos-php/app
./start.sh
```

### Desarrollo avanzado

- Consulta `README-Linux-Mac.md` para características avanzadas
- Estudia `CONVERSION-GUIDE.md` para modificar el script
- Personaliza templates y frameworks según tus necesidades

---

## 📝 Versión

**Versión actual:** 2.0.0

**Compatibilidad:**
- Bash 4.0+
- Docker 20.10+
- Docker Compose 2.0+
- Linux (Ubuntu, Debian, CentOS, Fedora)
- macOS 11+
- WSL2

**Origen:** Conversión de `crea-proyecto.ps1` (PowerShell)

---

## 🤝 Contribuir

1. Modifica `crea-proyecto.sh` según tus necesidades
2. Consulta `CONVERSION-GUIDE.md` para entender las diferencias Bash/PowerShell
3. Prueba los cambios con `./setup.sh` y creando un proyecto de prueba
4. Usa ShellCheck para validar sintaxis: `shellcheck crea-proyecto.sh`

---

## 📄 Licencia

Open source - Libre uso y modificación.

---

**¿Listo?** → Ejecuta `./setup.sh` y luego `./crea-proyecto.sh`
