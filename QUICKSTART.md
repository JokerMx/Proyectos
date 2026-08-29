# 🚀 Quick Start - crea-proyecto para Linux/macOS

Bienvenido! Este es tu guía de **5 minutos** para empezar.

---

## 📋 Paso 1: Preparar el entorno (2 min)

### Opción A: Instalación automática (recomendado)
```bash
chmod +x setup.sh
./setup.sh
```

Este script:
- ✓ Detecta tu SO
- ✓ Verifica Docker e instalaciones necesarias
- ✓ Ofrece instalar Docker, Docker Compose y dependencias faltantes
- ✓ Configura permisos

### Opción B: Instalación manual

**En Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose curl git
sudo usermod -aG docker $USER
newgrp docker
```

**En macOS:**
```bash
brew install docker docker-compose curl git
# Inicia Docker Desktop o colima
```

---

## 🎯 Paso 2: Crear un proyecto (2 min)

### Modo interactivo (más fácil):
```bash
chmod +x crea-proyecto.sh
./crea-proyecto.sh
```

Te hará preguntas sobre:
- Nombre del proyecto
- Tipo (PHP, Node.js, .NET)
- Framework específico
- Base de datos (MariaDB, PostgreSQL, etc.)
- Puerto (sugiere uno si está ocupado)

### Modo comando (más rápido):
```bash
./crea-proyecto.sh -n "mi-app" -t PHP -f Laravel -b MariaDB
./crea-proyecto.sh -n "api" -t Node -f Express -b PostgreSQL
./crea-proyecto.sh -n "servicio" -t DotNet -f "Web API" -b SQLServer
```

---

## ✅ Paso 3: Completar e iniciar servicios

```bash
# Entra a tu proyecto
cd proyectos-{tipo}/tu-proyecto

# El generador Bash actual no crea docker-compose.yml.
# Añade o copia un archivo Compose antes de iniciar.
./start.sh

# Verifica que todo funciona
docker compose ps
```

---

## 🧪 Paso 4: Prueba (opcional)

```bash
# Desde otra terminal en el mismo directorio
curl http://localhost:8080/health    # PHP/DotNet
curl http://localhost:3000/health    # Node.js
```

Deberías ver:
```json
{"status":"OK","project":"tu-proyecto"}
```

---

## 📁 ¿Dónde está mi proyecto?

Después de ejecutar `crea-proyecto.sh`, encontrarás una estructura base:

```
tu-directorio-actual/
└── proyectos-{tipo}/
    └── tu-proyecto/          ← Aquí está tu proyecto
        ├── Dockerfile
        ├── start.sh
        ├── .env
        └── ... código fuente ...
```

---

## 🛑 Detener proyecto

```bash
docker compose down
```

---

## 🧹 Limpiar todo

```bash
./clean.sh
```

---

## 📚 Más información

| Documento | Propósito |
|---|---|
| **README-Linux-Mac.md** | Guía completa de características y uso |
| **CONVERSION-GUIDE.md** | Explicación técnica de cambios de PowerShell a Bash |
| **RESUMEN.md** | Resumen general de archivos y características |

---

## 🆘 Problemas comunes

### ❌ "Permission denied: crea-proyecto.sh"
```bash
chmod +x crea-proyecto.sh
```

### ❌ "docker: command not found"
```bash
./setup.sh
# O instala manualmente según tu SO
```

### ❌ "Puerto 8080 ya está en uso"
El script sugiere un puerto alternativo automáticamente. Escribe el nuevo número cuando te lo pida.

### ❌ "Docker daemon not running"
```bash
# Linux
sudo systemctl start docker

# macOS
# Abre Docker Desktop o ejecuta: colima start
```

---

## 💡 Tips útiles

### Ver logs de la aplicación:
```bash
docker compose logs app -f
```

### Acceder a la base de datos desde tu máquina host:
```bash
# MariaDB
mysql -h localhost -P 3306 -u myuser -p

# PostgreSQL
psql -h localhost -p 5432 -U postgres

# MongoDB
mongosh mongodb://localhost:27017
```

### Ejecutar comandos en el contenedor:
Después de crear `docker-compose.yml`:
```bash
docker compose exec app bash          # PHP/Node
docker compose exec app powershell    # .NET
```

### Regenerar bases de datos:
```bash
docker compose down -v
docker compose up -d --build
```

---

## 🎓 Ejemplos rápidos

### Proyecto PHP Laravel + MariaDB:
```bash
./crea-proyecto.sh -n "blog" -t PHP -f Laravel -b MariaDB
cd proyectos-php/blog
# Añade docker-compose.yml y después ejecuta: ./start.sh
```

### Proyecto Node.js Express + PostgreSQL:
```bash
./crea-proyecto.sh -n "api" -t Node -f Express -b PostgreSQL  
cd proyectos-node/api
# Añade docker-compose.yml y después ejecuta: ./start.sh
```

### Proyecto .NET Web API + SQLServer:
```bash
./crea-proyecto.sh -n "microservice" -t DotNet -f "Web API" -b SQLServer
cd proyectos-dotnet/microservice
# Añade docker-compose.yml y después ejecuta: ./start.sh
```

---

## 🔑 Claves generadas automáticamente

Los proyectos PHP incluyen `APP_KEY` y los proyectos Node.js incluyen `JWT_SECRET` en `.env`. El script Bash no guarda `DATA_PROTECTION_KEY` en los archivos generados.

---

## 📈 Próximos pasos

1. **Desarrollo local:**
   - Modifica el código en tu editor favorito
   - Los cambios se verán en el contenedor (si está configurado)
   - Recarga el navegador o re-ejecuta comandos

2. **Despliegue a producción:**
   - Lee `DEPLOYMENT.md` en tu proyecto
   - Cambia variables de entorno
   - Desactiva DEBUG
   - Sube a un servidor o plataforma cloud

3. **Configurar CI/CD:**
   - `.github/workflows/ci.yml` está pre-configurado
   - `.gitlab-ci.yml` está pre-configurado
   - Personaliza según tus necesidades

---

## 🎉 ¡Listo!

Ya tienes todo lo que necesitas para:
✓ Crear proyectos Docker rápidamente  
✓ Trabajar con PHP, Node.js o .NET  
✓ Usar diferentes bases de datos  
✓ Mantener código limpio y seguro  

**¿Alguna duda?** Consulta los archivos de documentación incluidos.

---

**Versión:** 2.0.0  
**Script:** crea-proyecto.sh  
**Plataformas:** Linux, macOS  
**Requisito:** Bash 4.0+, Docker 20.10+
