# 📦 Generador de Proyectos Docker - Versión Linux/macOS

## 📋 Archivos creados

Se han generado los siguientes archivos para hacer que el script de generación de proyectos Docker sea compatible con **Linux y macOS**:

### 1. **crea-proyecto.sh** ⭐
Script principal en Bash/Shell que crea proyectos Docker para:
- **PHP** (Laravel, Symfony, Slim, CakePHP, PHP Base)
- **Node.js** (Express, NestJS, Fastify, Koa)
- **.NET** (Web API, MVC, Minimal API, Blazor)

Con soporte para bases de datos:
- MariaDB, PostgreSQL, SQLServer, MongoDB, Redis

**Uso:**
```bash
chmod +x crea-proyecto.sh
./crea-proyecto.sh
```

---

### 2. **setup.sh** 🔧
Script de configuración que:
- ✓ Detecta el sistema operativo (Linux/macOS)
- ✓ Verifica requisitos (Docker, Docker Compose, Bash, etc.)
- ✓ Instala dependencias faltantes
- ✓ Configura permisos
- ✓ Valida el daemon de Docker

**Uso:**
```bash
chmod +x setup.sh
./setup.sh
```

---

### 3. **README-Linux-Mac.md** 📖
Guía completa de uso que incluye:
- Requisitos previos por sistema operativo
- Instrucciones de instalación
- Ejemplos de uso por tipo de proyecto
- Estructura de directorios generada
- Casos de uso comunes
- Solución de problemas
- Verificación de funcionamiento

---

### 4. **CONVERSION-GUIDE.md** 🔄
Documento técnico con las diferencias entre PowerShell y Bash:
- Conversión de cmdlets de PowerShell a comandos Unix
- Comparativas lado a lado (15+ ejemplos)
- Tabla de diferencias de comportamiento
- Referencias y troubleshooting técnico
- Compatibilidad verificada

---

## 🚀 Comparación: PowerShell vs Bash

| Aspecto | Windows PowerShell | Linux/macOS Bash |
|---|---|---|
| **Archivo** | `crea-proyecto.ps1` | `crea-proyecto.sh` |
| **Lenguaje** | PowerShell scripting | Bash/POSIX shell |
| **Funcionalidad** | Idéntica ✓ | Idéntica ✓ |
| **Requisitos** | PowerShell 5.0+ | Bash 4.0+ |
| **Docker** | Windows + WSL2 | Linux nativo / macOS |
| **Gestión puertos** | Get-NetTCPConnection | netcat (nc) |
| **Ruta archivos** | Backslash `\` | Forward slash `/` |

---

## 📊 Estructura de archivos generados

Después de ejecutar `./crea-proyecto.sh`, obtendrás:

```
proyectos-{tipo}/
└── tu-proyecto/
    ├── .env                          # Variables de entorno
    ├── .env.example                  # Plantilla
    ├── .env.development
    ├── .env.production
    ├── .env.test
    ├── .gitignore
    ├── Dockerfile                    # Imagen Docker
    ├── docker-compose.yml            # Orquestación
    ├── docker-compose.dev.yml
    ├── docker-compose.prod.yml
    ├── docker-compose.test.yml
    ├── README.md
    ├── DEPLOYMENT.md
    ├── start.sh                      # Script para iniciar (ejecutable)
    ├── clean.sh                      # Limpiar todo
    ├── .github/workflows/ci.yml      # CI/CD
    │
    ├── src/                          # Código fuente
    ├── public/                       # Archivos públicos (PHP/Node)
    ├── config/                       # Configuración
    ├── tests/                        # Tests
    └── docs/                         # Documentación
```

---

## 🎯 Ejemplos de uso rápido

### Crear proyecto PHP con Laravel:
```bash
./crea-proyecto.sh -n "blog" -t PHP -f Laravel -b MariaDB
cd proyectos-php/blog
./start.sh
curl http://localhost:8080/health
```

### Crear proyecto Node.js con Express:
```bash
./crea-proyecto.sh -n "api" -t Node -f Express -b PostgreSQL
cd proyectos-node/api
./start.sh
curl http://localhost:3000/health
```

### Crear proyecto .NET:
```bash
./crea-proyecto.sh -n "microservice" -t DotNet -f "Web API" -b SQLServer
cd proyectos-dotnet/microservice
./start.sh
curl http://localhost:8080/health
```

---

## ✅ Checklist de instalación

- [ ] Descargar/clonar los scripts
- [ ] `chmod +x setup.sh crea-proyecto.sh`
- [ ] Ejecutar `./setup.sh` para verificar requisitos
- [ ] Instalar Docker si es necesario
- [ ] Ejecutar `./crea-proyecto.sh` en modo interactivo
- [ ] Navegar a `proyectos-{tipo}/{nombre}`
- [ ] Ejecutar `./start.sh` para iniciar servicios
- [ ] Verificar con `docker compose ps`

---

## 🔐 Características de seguridad

✓ Variables de entorno separadas por ambiente (dev, prod, test)  
✓ `.gitignore` incluye `.env` automáticamente  
✓ Claves generadas aleatoriamente (APP_KEY, JWT_SECRET)  
✓ Contraseñas de BD en `.env.example` marcadas como "change-me"  
✓ Documentación de seguridad incluida (SECURITY.md)  

---

## 🛠️ Requisitos previos

### Linux (Ubuntu/Debian):
```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose curl git netcat-openbsd openssl
```

### macOS:
```bash
brew install docker docker-compose curl git netcat openssl
```

O ejecuta `./setup.sh` que hace esto automáticamente.

---

## 📚 Documentación disponible

1. **README-Linux-Mac.md**
   - Guía de inicio rápido
   - Casos de uso
   - Troubleshooting común

2. **CONVERSION-GUIDE.md**
   - Cambios técnicos de PowerShell a Bash
   - Ejemplos de conversión
   - Referencias técnicas

3. **Dentro de cada proyecto generado:**
   - README.md - Documentación del proyecto
   - DEPLOYMENT.md - Guía de despliegue
   - CONTRIBUTING.md - Guía de contribución
   - SECURITY.md - Políticas de seguridad

---

## 🐛 Troubleshooting rápido

| Problema | Solución |
|---|---|
| `Permission denied` | `chmod +x crea-proyecto.sh` |
| `docker: command not found` | Ejecutar `./setup.sh` e instalar Docker |
| `nc: command not found` | `apt-get install netcat-openbsd` o `brew install netcat` |
| Puerto ocupado | El script sugiere alternativas automáticamente |
| `Cannot connect to Docker daemon` | `sudo systemctl start docker` o iniciar Docker Desktop |

---

## 🔄 Diferencias clave Windows ↔ Linux/macOS

| Windows (PS1) | Linux/macOS (SH) |
|---|---|
| `$variable = valor` | `variable="valor"` |
| `Join-Path $a $b` | `"$a/$b"` |
| `Test-Path -Path $p` | `[ -f "$p" ]` o `[ -d "$p" ]` |
| `Get-Content` | `cat` |
| `New-Item -Path` | `mkdir -p` |
| `Get-NetTCPConnection` | `nc -z host port` |
| `Write-Host "texto"` | `echo -e "texto"` |
| `[Convert]::ToBase64String` | `openssl rand -base64` |

---

## 📝 Notas importantes

1. **Compatibilidad:** Bash 4.0+ es requerido (macOS puede necesitar actualización)
2. **Docker Compose:** El script usa `docker compose` (versión 2.0+), no `docker-compose`
3. **Permisos:** En Linux, el usuario necesita estar en el grupo `docker`
4. **Puertos:** El script verifica disponibilidad automáticamente
5. **Configuración:** Los archivos `.env` están en `.gitignore` por seguridad

---

## 🎓 Siguiente paso

Ejecuta el script setup para verificar que todo esté listo:

```bash
chmod +x setup.sh
./setup.sh
```

Luego crea tu primer proyecto:

```bash
./crea-proyecto.sh
```

---

**Versión:** 2.0.0  
**Última actualización:** 2024  
**Plataformas soportadas:** Linux (Ubuntu, Debian, CentOS, etc.) y macOS  
**Requisito mínimo:** Bash 4.0+, Docker 20.10+, Docker Compose 2.0+
