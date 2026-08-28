# 🐳 crea-proyecto - Generador de Proyectos Docker

> Generador automatizado de proyectos Docker para **PHP**, **Node.js** y **.NET** con soporte para múltiples bases de datos y frameworks.

## 🖥️ Plataformas soportadas

- 🪟 **Windows** (PowerShell 5.0+ / WSL2)
- 🐧 **Linux** (Ubuntu, Debian, CentOS, Fedora, etc.)
- 🍎 **macOS** (11+)

---

## 📋 Tabla de Contenidos

- [🚀 Quick Start](#-quick-start)
- [📦 Características](#-características)
- [🛠️ Requisitos previos](#️-requisitos-previos)
- [🔧 Instalación](#-instalación)
- [💻 Uso](#-uso)
  - [Windows](#windows)
  - [Linux/macOS](#linuxmacos)
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
- [🔄 Diferencias entre plataformas](#-diferencias-entre-plataformas)
- [📖 Documentación adicional](#-documentación-adicional)
- [🎓 Próximos pasos](#-próximos-pasos)

---

## 🚀 Quick Start

### Windows (PowerShell)

```powershell
# 1. Clona el repositorio
git clone <repo-url> && cd crea-proyecto

# 2. Crea tu primer proyecto
.\crea-proyecto.ps1 -Nombre "mi-proyecto" -Tipo PHP -Framework Laravel -BD MariaDB

# 3. Entra al proyecto
cd proyectos-php\mi-proyecto

# 4. Inicia los servicios
.\start.ps1

# 5. Verifica
curl http://localhost:8080/health
```

### Linux/macOS (Bash)

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
- ✅ **Scripts utilitarios** incluidos (`start.sh`, `clean.sh`, `start.ps1`)
- ✅ **Multiplataforma:** Windows, Linux y macOS

---

## 🛠️ Requisitos previos

| Requisito | Windows | Linux/macOS | Notas |
|---|---|---|---|
| **PowerShell** | 5.0+ | - | Incluido en Windows 10/11 |
| **Bash** | - | 4.0+ | Incluido en Linux/macOS |
| **Docker Desktop** | 20.10+ | 20.10+ | Motor de contenedores |
| **Docker Compose** | 2.0+ | 2.0+ | Orquestación |
| **OpenSSL** | Opcional | Cualquier | Generación de claves |
| **Netcat** | Opcional | Cualquier | Verificación de puertos |

> **Nota:** En Windows, Docker Desktop incluye WSL2 backend. En Linux/macOS, instala Docker nativo.

---

## 🔧 Instalación

### Windows

```powershell
# 1. Instala Docker Desktop desde https://www.docker.com/products/docker-desktop/
# 2. Habilita WSL2 durante la instalación
# 3. Abre PowerShell como administrador
# 4. Verifica la instalación
docker --version
docker compose version
```

**Requisitos:**
- Windows 10/11 con WSL2 habilitado
- Docker Desktop instalado
- PowerShell 5.0+ (incluido por defecto)

### Linux/macOS

#### Opción A: Automática (recomendado)

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

#### Opción B: Manual

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

### Windows

```powershell
# Modo interactivo
.\crea-proyecto.ps1

# Modo automático
.\crea-proyecto.ps1 -Nombre "mi-proyecto" -Tipo PHP -Framework Laravel -BD MariaDB
```

### Linux/macOS

```bash
# Modo interactivo
./crea-proyecto.sh

# Modo automático
./crea-proyecto.sh -n "mi-proyecto" -t PHP -f Laravel -b MariaDB
```

### Modo interactivo

Ideal para principiantes. El script te guiará con preguntas paso a paso.

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
# Linux/macOS
./crea-proyecto.sh -n "mi-proyecto" -t PHP -f Laravel -b MariaDB

# Windows
.\crea-proyecto.ps1 -Nombre "mi-proyecto" -Tipo PHP -Framework Laravel -BD MariaDB
```

**Parámetros disponibles:**

| Parámetro | Windows | Linux/macOS | Descripción | Valores |
|---|---|---|---|---|
| Nombre | `-Nombre` | `-n` | Nombre del proyecto | Cualquier string sin caracteres especiales |
| Tipo | `-Tipo` | `-t` | Tipo de proyecto | `PHP`, `Node`, `DotNet` |
| Framework | `-Framework` | `-f` | Framework | Depende del tipo |
| Base de datos | `-BD` | `-b` | Base de datos | `MariaDB`, `SQLServer`, `PostgreSQL`, `MongoDB`, `Redis`, `Ambas` |
| Puerto app | `-PuertoApp` | `-p` | Puerto de la app | 1-65535 |
| Versión | `-VersionPHP/VersionNode/VersionDotNet` | `-v` | Versión runtime | PHP: 7.4-8.3, Node: 16-22, .NET: 6.0-9.0 |

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
    ├── start.sh / start.ps1     # Iniciar servicios (ejecutable)
    ├── clean.sh / clean.ps1     # Limpiar todo (ejecutable)
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

> **Nota:** En Windows, las rutas usan backslash `\`. En Linux/macOS, usan forward slash `/`.

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

#### Windows (PowerShell)

```powershell
# Iniciar servicios
.\start.ps1

# Ver estado
docker compose ps

# Ver logs
docker compose logs -f
docker compose logs -f app

# Detener servicios
docker compose down

# Limpiar todo (incluyendo volúmenes)
.\clean.ps1

# Acceder al contenedor
docker compose exec app powershell
```

#### Linux/macOS (Bash)

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
docker compose exec app bash
```

### Desarrollo

#### Windows

```powershell
# .NET
docker compose exec app dotnet restore
docker compose exec app dotnet watch run
```

#### Linux/macOS

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
# Health check (todas las plataformas)
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

### Windows (PowerShell)

```powershell
# PHP + Laravel + MariaDB
.\crea-proyecto.ps1 -Nombre "blog" -Tipo PHP -Framework Laravel -BD MariaDB
cd proyectos-php\blog
.\start.ps1

# Node.js + Express + PostgreSQL
.\crea-proyecto.ps1 -Nombre "api-rest" -Tipo Node -Framework Express -BD PostgreSQL
cd proyectos-node\api-rest
.\start.ps1

# .NET + Web API + SQLServer
.\crea-proyecto.ps1 -Nombre "microservicio" -Tipo DotNet -Framework "Web API" -BD SQLServer
cd proyectos-dotnet\microservicio
.\start.ps1
```

### Linux/macOS (Bash)

```bash
# Proyecto PHP + Laravel + MariaDB
./crea-proyecto.sh -n "blog" -t PHP -f Laravel -b MariaDB
cd proyectos-php/blog
./start.sh

# Proyecto Node.js + Express + PostgreSQL
./crea-proyecto.sh -n "api-rest" -t Node -f Express -b PostgreSQL
cd proyectos-node/api-rest
./start.sh
npm install

# Proyecto .NET + Web API + SQLServer
./crea-proyecto.sh -n "microservicio" -t DotNet -f "Web API" -b SQLServer
cd proyectos-dotnet/microservicio
./start.sh
dotnet restore
```

### Proyectos adicionales

```bash
# PHP + Symfony + PostgreSQL
./crea-proyecto.sh -n "app" -t PHP -f Symfony -b PostgreSQL

# Node.js + NestJS + MongoDB
./crea-proyecto.sh -n "backend" -t Node -f NestJS -b MongoDB

# .NET + Blazor + Redis (Cache)
./crea-proyecto.sh -n "dashboard" -t DotNet -f Blazor -b Redis
```

---

## 🐛 Troubleshooting

| Problema | Plataforma | Causa | Solución |
|---|---|---|---|
| `Permission denied` | Linux/macOS | Falta permiso de ejecución | `chmod +x crea-proyecto.sh` |
| `docker: command not found` | Todas | Docker no instalado | Instala Docker Desktop |
| `nc: command not found` | Linux/macOS | Netcat no instalado | `apt-get install netcat-openbsd` o `brew install netcat` |
| `openssl: command not found` | Linux/macOS | OpenSSL no instalado | `apt-get install openssl` o `brew install openssl` |
| Puerto ocupado | Todas | Puerto en uso | El script sugiere alternativas automáticamente |
| `Cannot connect to Docker daemon` | Todas | Docker no corriendo | Inicia Docker Desktop o `sudo systemctl start docker` |
| `clear: command not found` | Linux/macOS | Entorno sin terminal interactiva | El script lo maneja automáticamente |
| `execution of scripts is disabled` | Windows | Política de ejecución | `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| `WSL2 not installed` | Windows | WSL2 no disponible | Habilita WSL2 en "Características de Windows" |

### Verificar instalación

```bash
# Linux/macOS - Verificar bash
bash --version

# Todas las plataformas - Verificar Docker
docker --version
docker compose version

# Verificar Docker daemon
docker ps

# Linux - Verificar usuario en grupo docker
id -nG $USER | grep -qw "docker" && echo "OK" || echo "Agregar con: sudo usermod -aG docker $USER"

# Windows - Verificar PowerShell
powershell -Command "Get-Host | Select-Object Version"
```

---

## 🔄 Diferencias entre plataformas

### Windows vs Linux/macOS

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

### Diferencias de comportamiento

| Aspecto | PowerShell | Bash |
|---|---|---|
| **Manejo de errores** | Try/Catch | set -e / trap |
| **Variables globales** | $Script: scope | Variables de ambiente |
| **Piping** | Objects con propiedades | Text streams (strings) |
| **Tipo de datos** | Tipado (optional) | Strings por defecto |
| **Paths** | `\` backslash | `/` forward slash |
| **Búsqueda de comandos** | Get-Command | command -v |
| **Redirección de errores** | -ErrorAction | 2>&1, 2>/dev/null |
| **Condicionales** | -eq, -ne, -gt | =, !=, -gt |

---

## 📖 Documentación adicional

| Documento | Descripción |
|---|---|
| **INDEX.md** | Navegación central de toda la documentación |
| **QUICKSTART.md** | Guía de inicio rápido (5 minutos) |
| **README-Linux-Mac.md** | Guía completa de uso para Linux/macOS |
| **README.md** | Este documento - Documentación unificada |
| **CONVERSION-GUIDE.md** | Cambios técnicos PowerShell → Bash (15+ ejemplos) |
| **RESUMEN.md** | Resumen general del proyecto |
| **SETUP-COMPLETADO.md** | Verificación de instalación completada |
| **crea-proyecto.ps1** | ⭐ Script generador para Windows (PowerShell) |
| **crea-proyecto.sh** | ⭐ Script generador para Linux/macOS (Bash) |
| **setup.sh** | 🔧 Script de setup para Linux/macOS |

---

## 🎓 Próximos pasos

### Después de crear tu proyecto

1. **Explorar la estructura:**
   ```bash
   # Windows
   cd proyectos-php\mi-proyecto
   dir
   Get-Content README.md

   # Linux/macOS
   cd proyectos-php/mi-proyecto
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
   # Windows
   .\start.ps1
   docker compose ps

   # Linux/macOS
   ./start.sh
   docker compose ps
   ```

4. **Probar health check:**
   ```bash
   curl http://localhost:8080/health
   ```

5. **Desarrollar:**
   - Modifica archivos en `src/`, `public/`, `config/`
   - Usa `docker compose exec app powershell` (Windows) o `docker compose exec app bash` (Linux/macOS) para acceder al contenedor
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
- **PowerShell Docs:** https://docs.microsoft.com/en-us/powershell/

### Troubleshooting

1. Consulta la sección [Troubleshooting](#-troubleshooting) de este documento
2. En Linux/macOS, ejecuta `./setup.sh` para diagnosticar problemas
3. En Windows, ejecuta `.\crea-proyecto.ps1` para ver mensajes de error detallados
4. Revisa `CONVERSION-GUIDE.md` para errores de sintaxis
5. Verifica logs: `docker compose logs app`

---

## 📊 Resumen de archivos del proyecto

| Archivo | Plataforma | Propósito |
|---|---|---|
| `crea-proyecto.ps1` | 🪟 Windows | ⭐ Generador principal (PowerShell) |
| `crea-proyecto.sh` | 🐧🍎 Linux/macOS | ⭐ Generador principal (Bash) |
| `setup.sh` | 🐧🍎 Linux/macOS | 🔧 Verifica e instala requisitos |
| `INDEX.md` | Todas | 📍 Navegación central |
| `QUICKSTART.md` | Todas | 🚀 Inicio rápido (5 min) |
| `README-Linux-Mac.md` | 🐧🍎 Linux/macOS | 📖 Guía completa |
| **README.md** | **Todas** | **📖 Documentación unificada (este archivo)** |
| `CONVERSION-GUIDE.md` | Todas | 🔄 Cambios PowerShell → Bash |
| `RESUMEN.md` | Todas | 📋 Resumen general |
| `SETUP-COMPLETADO.md` | 🐧🍎 Linux/macOS | ✅ Verificación de setup |

---

## 🎯 Flujo de trabajo recomendado

### Windows (PowerShell)

```powershell
# 1. Lee QUICKSTART.md (5 min)
# 2. Instala Docker Desktop
# 3. Crea tu primer proyecto
.\crea-proyecto.ps1 -Nombre "mi-app" -Tipo PHP -Framework Laravel -BD MariaDB

# 4. Entra al proyecto
cd proyectos-php\mi-app

# 5. Inicia servicios
.\start.ps1

# 6. Verifica
curl http://localhost:8080/health
```

### Linux/macOS (Bash)

```bash
# 1. Lee QUICKSTART.md (5 min)
# 2. Ejecuta ./setup.sh (5 min)
# 3. Ejecuta ./crea-proyecto.sh (5 min)
# 4. Inicia con ./start.sh (1 min)
```

**Total:** 11 minutos

---

## 📝 Versión

**Versión actual:** 2.0.0

**Compatibilidad:**
- 🪟 Windows 10/11 con PowerShell 5.0+ y Docker Desktop
- 🐧 Linux (Ubuntu, Debian, CentOS, Fedora) con Bash 4.0+
- 🍎 macOS 11+ con Bash 4.0+
- 🐳 Docker 20.10+ y Docker Compose 2.0+

**Scripts disponibles:**
- `crea-proyecto.ps1` - Windows (PowerShell)
- `crea-proyecto.sh` - Linux/macOS (Bash)
- `setup.sh` - Linux/macOS (configuración automática)

**Origen:** Conversión de PowerShell a Bash para soporte multiplataforma

---

## 🤝 Contribuir

1. Modifica el script según tu plataforma (`crea-proyecto.ps1` para Windows, `crea-proyecto.sh` para Linux/macOS)
2. Consulta `CONVERSION-GUIDE.md` para entender las diferencias PowerShell/Bash
3. Prueba los cambios creando un proyecto de prueba
4. En Bash, usa ShellCheck para validar sintaxis: `shellcheck crea-proyecto.sh`
5. En PowerShell, usa `PSAnalyzer` o `PSScriptAnalyzer` para validar sintaxis

---

## 📄 Licencia

Open source - Libre uso y modificación.

---

**¿Listo?** → Ejecuta `./setup.sh` (Linux/macOS) o usa `.\crea-proyecto.ps1` (Windows)
