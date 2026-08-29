# 📚 Índice Master - crea-proyecto Linux/macOS

> Este archivo sirve como **navegación central** para todos los recursos disponibles.

---

## 🗂️ Archivos principales

### 1️⃣ **QUICKSTART.md** ⭐ ← EMPIEZA AQUÍ
**Nivel:** Principiante  
**Tiempo:** 5 minutos  
**Contenido:**
- Instalación rápida en 4 pasos
- Ejemplos de comandos básicos
- Troubleshooting común
- Tips útiles

👉 **Ideal si:** Es tu primera vez y quieres empezar ya mismo

---

### 2️⃣ **crea-proyecto.sh** 
**Tipo:** Script ejecutable  
**Requisito:** Bash 4.0+, Docker 20.10+  
**Función:** Generador principal de proyectos  

**Características:**
- Modo interactivo con menús
- Modo automático con parámetros
- Soporta PHP, Node.js, .NET
- 6 opciones de base de datos
- Genera una estructura base con Dockerfile y configuración

**Cómo usar:**
```bash
chmod +x crea-proyecto.sh
./crea-proyecto.sh              # Modo interactivo
./crea-proyecto.sh -n "app" -t PHP -b MariaDB  # Automático
```

---

### 3️⃣ **setup.sh** 🔧
**Tipo:** Script de configuración  
**Función:** Verificar e instalar requisitos  

**Características:**
- Detecta automáticamente tu SO (Linux/macOS)
- Verifica Docker, Bash, Netcat, OpenSSL
- Instala dependencias faltantes
- Configura permisos de archivo
- Valida docker daemon

**Cómo usar:**
```bash
chmod +x setup.sh
./setup.sh
```

**Resuelve:**
- ✓ Verificar si está todo instalado
- ✓ Instalar Docker/Docker Compose automáticamente
- ✓ Configurar permisos de usuario
- ✓ Diagnosticar problemas de Docker

---

## 📖 Documentación

### 📕 **README-Linux-Mac.md**
**Nivel:** Intermedio  
**Extensión:** Completa  
**Temas:**

1. **Requisitos previos**
   - Instrucciones por SO (Linux/macOS)
   - Comandos de instalación
   
2. **Uso del script**
   - Modo interactivo
   - Modo automático con parámetros
   
3. **Estructura generada**
   - Directorios creados
   - Archivos por tipo de proyecto
   
4. **Casos de uso**
   - PHP + Laravel + MariaDB
   - Node.js + Express + PostgreSQL
   - .NET + Web API + SQLServer
   
5. **Después de crear el proyecto**
   - Iniciar servicios
   - Ver logs
   - Detener/limpiar
   
6. **Seguridad**
   - Variables de entorno
   - Manejo de secretos
   
7. **Troubleshooting**
   - Problemas comunes y soluciones
   - Verificación de funcionamiento

👉 **Ideal si:** Quieres dominar todas las características

---

### 📗 **CONVERSION-GUIDE.md**
**Nivel:** Avanzado  
**Audiencia:** Desarrolladores, DevOps  
**Temas:**

1. **Cambios de PowerShell a Bash** (15+ ejemplos)
   - Funciones
   - Variables
   - Condicionales
   - Bucles
   - I/O de usuario
   - Manejo de archivos

2. **Tabla comparativa**
   - Lado a lado: PS1 ↔ SH
   - Sintaxis equivalente

3. **Diferencias de comportamiento**
   - Manejo de errores
   - Tipado de datos
   - Piping
   - Redirección

4. **Referencias técnicas**
   - Enlaces a documentación
   - Verificador de sintaxis (ShellCheck)
   - Estándares POSIX

5. **Troubleshooting técnico**
   - Errores comunes
   - Cómo debuggear

👉 **Ideal si:** Quieres entender los cambios técnicos o adaptar el código

---

### 📘 **RESUMEN.md**
**Nivel:** Introductorio  
**Extensión:** Media  
**Contenido:**

- Descripción general de los 5 archivos creados
- Comparación Windows ↔ Linux/macOS
- Estructura de proyectos generados
- Ejemplos de uso rápido
- Checklist de instalación
- Características de seguridad
- Requisitos previos

👉 **Ideal si:** Quieres una visión general de todo

---

## 🎯 Matriz de decisión

¿Qué documento debo leer?

```
┌─ ¿Quiero empezar YA?
│  └─ SÍ → QUICKSTART.md (5 min)
│
└─ ¿Necesito ayuda con instalación?
   ├─ SÍ → Ejecuta setup.sh
   └─ NO → Continúa
   
   ├─ ¿Quiero más control/automatización?
   │  ├─ SÍ → README-Linux-Mac.md (Parámetros del script)
   │  └─ NO → Modo interactivo
   │
   ├─ ¿Soy técnico/DevOps?
   │  ├─ SÍ → CONVERSION-GUIDE.md (Arquitectura)
   │  └─ NO → QUICKSTART.md (Uso básico)
   │
   └─ ¿Quiero resumen rápido?
      └─ SÍ → RESUMEN.md
```

---

## 🚀 Flujo de trabajo recomendado

### Día 1 - Instalación

1. Lee **QUICKSTART.md** (5 min)
2. Ejecuta `./setup.sh` (2 min)
3. Ejecuta `./crea-proyecto.sh` (3 min)
4. Añade `docker-compose.yml` y ejecuta `./start.sh`

**Total:** 11 minutos

### Día 2+ - Uso avanzado

- Consulta **README-Linux-Mac.md** para características específicas
- Usa parámetros automáticos en `crea-proyecto.sh`
- Personaliza el código generado

### Cuando sea técnico/Adaptación

- Estudia **CONVERSION-GUIDE.md**
- Modifica `crea-proyecto.sh` según tus necesidades
- Contribuye mejoras

---

## 📋 Checklist de inicio

### Antes de ejecutar:
- [ ] Sistema operativo soportado (Linux o macOS)
- [ ] Acceso a terminal/bash
- [ ] Conexión a internet (para descargar Docker)
- [ ] ~5 minutos de tiempo

### Instalación:
- [ ] `chmod +x setup.sh crea-proyecto.sh`
- [ ] `./setup.sh` (verifica/instala requisitos)
- [ ] Docker daemon corriendo
- [ ] Usuario en grupo docker (Linux)

### Crear primer proyecto:
- [ ] `./crea-proyecto.sh` (modo interactivo)
- [ ] Responde preguntas
- [ ] Navega a proyecto: `cd proyectos-{tipo}/{nombre}`
- [ ] `./start.sh` (inicia servicios)
- [ ] `curl http://localhost:PORT/health` (verifica)

---

## 🔑 Información clave por tipo de proyecto

### PHP (Laravel, Symfony, etc.)
- Puerto default: **8080**
- Base de datos recomendada: **MariaDB**
- Requisito: PHP 7.4+
- Archivo de entrada: `public/index.php`

### Node.js (Express, NestJS, etc.)
- Puerto default: **3000**
- Base de datos recomendada: **PostgreSQL**
- Requisito: Node.js 16+
- Archivo de entrada: `server.js`

### .NET (Web API, MVC, etc.)
- Puerto default: **8080**
- Base de datos recomendada: **SQLServer**
- Requisito: .NET 6.0+
- Archivo de entrada: `Program.cs`

---

## 🛠️ Máquinas virtuales / WSL

Si estás en **Windows usando WSL2** o **máquina virtual Linux**:

1. Instala Docker en Linux (NO Docker Desktop)
   ```bash
   ./setup.sh  # Hará la instalación automáticamente
   ```

2. Asegúrate de estar en usuario con permisos docker
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

3. Procedimiento normal
   ```bash
   ./crea-proyecto.sh
   ```

---

## 🌐 Plataformas soportadas

| SO | Versión | Estado | Notas |
|---|---|---|---|
| **Ubuntu** | 20.04+ | ✅ Soportado | Recomendado |
| **Debian** | 11+ | ✅ Soportado | Funciona bien |
| **CentOS** | 8+ | ✅ Soportado | RHEL compatible |
| **Fedora** | 35+ | ✅ Soportado | Moderno |
| **macOS** | 11+ | ✅ Soportado | Requiere Homebrew |
| **WSL2** | Ubuntu 20.04+ | ✅ Soportado | En Windows |

---

## 📞 Soporte

### Troubleshooting
1. Consulta la sección de Troubleshooting en **README-Linux-Mac.md**
2. Revisa errores específicos en **CONVERSION-GUIDE.md**
3. Ejecuta `./setup.sh` para diagnosticar problemas

### Documentación en proyectos generados
La salida actual de `crea-proyecto.sh` incluye:
- `README.md` - Documentación del proyecto
- `DEPLOYMENT.md` - Guía de despliegue

La salida ampliada de `crea-proyecto.ps1` también incluye `SECURITY.md` y `CONTRIBUTING.md`.

---

## 📊 Archivos generados por cada ejecutable

### crea-proyecto.sh genera:
```
Dockerfile
.env (con claves generadas)
.env.example
.gitignore
README.md
DEPLOYMENT.md
start.sh (ejecutable)
clean.sh (ejecutable)
[Código fuente según framework]
```

No genera `docker-compose.yml`; proporciona o crea ese archivo antes de ejecutar `start.sh`.

### setup.sh hace:
```
✓ Detectar SO
✓ Verificar requisitos
✓ Ofrecer instalar Docker y Docker Compose (si faltan)
✓ Ofrecer instalar dependencias
✓ Configurar permisos
✓ Validar docker daemon
```

---

## ⚡ Comandos más usados

```bash
# Crear proyecto (interactivo)
./crea-proyecto.sh

# Crear proyecto (automático)
./crea-proyecto.sh -n "app" -t PHP -f Laravel -b MariaDB

# Verificar instalación
./setup.sh

# Iniciar proyecto
cd proyectos-{tipo}/{nombre}
./start.sh

# Ver servicios corriendo
docker compose ps

# Ver logs
docker compose logs -f app

# Acceder a terminal del contenedor
docker compose exec app bash

# Detener servicios
docker compose down

# Limpiar todo
./clean.sh

# Verificar salud
curl http://localhost:8080/health
```

---

## 🎓 Próximos pasos después de crear un proyecto

1. **Explorar la estructura:**
   ```bash
   cd proyectos-{tipo}/{nombre}
   ls -la
   cat README.md
   ```

2. **Entender el docker-compose:**
   ```bash
   cat docker-compose.yml
   ```

3. **Ver las variables de entorno:**
   ```bash
   cat .env
   cat .env.example
   ```

4. **Modificar código:**
   - Edita los archivos en tu editor favorito
   - Los cambios se reflejan en el contenedor

5. **Ejecutar comandos:**
   ```bash
   docker compose exec app npm install
   docker compose exec app composer install
   docker compose exec app dotnet restore
   ```

---

## 📝 Versión y créditos

- **Versión:** 2.0.0
- **Lenguaje:** Bash/POSIX Shell
- **Compatibilidad:** Linux, macOS
- **Requisitos:** Bash 4.0+, Docker 20.10+
- **Conversión de:** PowerShell 5.0+ (crea-proyecto.ps1)

---

## 🗺️ Navegación rápida

| Necesitas | Archivo |
|---|---|
| Empezar en 5 min | **QUICKSTART.md** |
| Guía completa | **README-Linux-Mac.md** |
| Entender cambios técnicos | **CONVERSION-GUIDE.md** |
| Resumen general | **RESUMEN.md** |
| Usar el generador | **crea-proyecto.sh** |
| Instalar/verificar | **setup.sh** |
| Este índice | **INDEX.md** (este archivo) |

---

**¿Listo? → [QUICKSTART.md](QUICKSTART.md)**

---

Última actualización: 2024
