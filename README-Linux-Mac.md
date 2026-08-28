# Guía: crea-proyecto.sh para Linux/macOS

## 📋 Descripción

`crea-proyecto.sh` es la versión bash/shell del generador de proyectos Docker para Linux y macOS. Realiza la misma función que `crea-proyecto.ps1` pero con sintaxis compatible con Unix.

## 🚀 Requisitos previos

### En Linux:
```bash
sudo apt-get update
sudo apt-get install -y curl docker.io netcat-openbsd
sudo usermod -aG docker $USER
```

### En macOS:
```bash
# Instalar Homebrew si no lo tienes
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instalar Docker
brew install docker docker-compose
```

## 📝 Uso básico

### Modo interactivo (recomendado):
```bash
chmod +x crea-proyecto.sh
./crea-proyecto.sh
```

Esto te guiará a través de preguntas sobre:
- Nombre del proyecto
- Tipo de proyecto (PHP, Node, .NET)
- Framework específico
- Base de datos (MariaDB, PostgreSQL, SQLServer, MongoDB, Redis)
- Versiones de runtime
- Puertos

### Modo automático (con parámetros):
```bash
./crea-proyecto.sh -n "mi-proyecto" -t PHP -f Laravel -b MariaDB
```

**Parámetros disponibles:**
- `-n` = Nombre del proyecto
- `-t` = Tipo (PHP, Node, DotNet)
- `-f` = Framework
- `-b` = Base de datos (MariaDB, PostgreSQL, SQLServer, MongoDB, Redis, Ambas)
- `-p` = Puerto de la aplicación
- `-v` = Versión (PHP/Node/DotNet)

## 📂 Estructura generada

El script crea:

```
proyectos-{tipo}/
└── tu-proyecto/
    ├── .env                      # Variables de entorno
    ├── .env.example              # Plantilla de variables
    ├── .gitignore               # Archivos a ignorar en git
    ├── Dockerfile               # Imagen Docker
    ├── docker-compose.yml       # Orquestación de servicios
    ├── README.md                # Documentación
    ├── DEPLOYMENT.md            # Guía de despliegue
    ├── start.sh                 # Script para iniciar (chmod +x)
    ├── clean.sh                 # Script para limpiar
    │
    ├── public/                  # Archivos públicos (PHP/Node)
    ├── src/                     # Código fuente
    ├── config/                  # Configuración
    ├── tests/                   # Tests
    └── ...                      # Más según el framework
```

## 🔧 Diferencias con la versión PowerShell

| Característica | PowerShell | Bash |
|---|---|---|
| **Sintaxis** | Cmdlets de PowerShell | Comandos Unix estándar |
| **Paths** | Backslash (\\) | Forward slash (/) |
| **Tests de puertos** | Get-NetTCPConnection | netcat (nc) |
| **Directorios** | New-Item | mkdir |
| **Lectura archivos** | Get-Content | cat |
| **Permisos ejecutables** | Automático | chmod +x manual |
| **Generador aleatorio** | [Convert]::ToBase64String | openssl rand |

## 💻 Casos de uso

### PHP con Laravel y MariaDB:
```bash
./crea-proyecto.sh -n "blog-app" -t PHP -f Laravel -b MariaDB
cd proyectos-php/blog-app
./start.sh
```

### Node.js con Express y PostgreSQL:
```bash
./crea-proyecto.sh -n "api-rest" -t Node -f Express -b PostgreSQL
cd proyectos-node/api-rest
./start.sh
```

### .NET con Web API y SQLServer:
```bash
./crea-proyecto.sh -n "microservicio" -t DotNet -f "Web API" -b SQLServer
cd proyectos-dotnet/microservicio
./start.sh
```

## 🎯 Después de crear el proyecto

1. **Entra al directorio:**
   ```bash
   cd proyectos-{tipo}/{nombre}
   ```

2. **Inicia los servicios:**
   ```bash
   ./start.sh
   ```

3. **Verifica el estado:**
   ```bash
   docker compose ps
   ```

4. **Ver logs:**
   ```bash
   docker compose logs -f app
   ```

5. **Detener:**
   ```bash
   docker compose down
   ```

6. **Limpiar todo:**
   ```bash
   ./clean.sh
   ```

## 🔐 Seguridad

- **.env nunca en git:** El `.gitignore` incluye `.env`
- **Claves generadas automáticamente:** APP_KEY y JWT_SECRET se crean al generar el proyecto
- **Variables de ejemplo:** Usa `.env.example` como referencia, no como secretos

## 🐛 Solución de problemas

### El script no es ejecutable:
```bash
chmod +x crea-proyecto.sh
```

### Docker no instalado:
El script verifica automáticamente. Instálalo con:
- Linux: `sudo apt-get install docker.io docker-compose`
- macOS: `brew install docker docker-compose` o usa Docker Desktop

### Puerto ya en uso:
El script detecta puertos ocupados y sugiere alternativas.

### Problemas con netcat:
En macOS, instálalo con: `brew install netcat`

## 📚 Archivos generados por tipo

### PHP
- `composer.json` - Dependencias PHP
- `public/index.php` - Punto de entrada
- `phpstan.neon` - Análisis estático

### Node.js
- `package.json` - Dependencias npm/yarn
- `server.js` - Servidor Express
- `.eslintrc.json` - Linting

### .NET
- `{Nombre}.csproj` - Proyecto
- `Program.cs` - Configuración y startup
- `appsettings.json` - Configuración

## ✅ Verifica el funcionamiento

Después de iniciar con `./start.sh`:

```bash
# Health check
curl http://localhost:8080/health

# Ver logs de la app
docker compose logs app

# Ejecutar comandos en el contenedor
docker compose exec app ls -la
```

## 📖 Configuración de puertos

- **PHP/DotNet:** Puerto 8080 por defecto
- **Node.js:** Puerto 3000 por defecto
- **Bases de datos:**
  - MariaDB: 3306
  - PostgreSQL: 5432
  - SQLServer: 1433
  - MongoDB: 27017
  - Redis: 6379

El script te permite cambiar los puertos durante la creación del proyecto.

---

**Versión:** 2.0.0  
**Última actualización:** 2024
