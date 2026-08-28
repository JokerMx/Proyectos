# Conversión PowerShell → Bash: Cambios principales

## 📌 Resumen de cambios

Se ha convertido `crea-proyecto.ps1` a `crea-proyecto.sh` para compatibilidad con Linux y macOS. Este documento detalla los cambios específicos realizados.

---

## 🔄 Conversiones principales

### 1. **Shebang y configuración inicial**

**PowerShell:**
```powershell
# Sin shebang necesario
param(
    [Parameter(Mandatory = $false)]
    [string]$Nombre
)
```

**Bash:**
```bash
#!/usr/bin/env bash
set -euo pipefail

# Parsing manual de argumentos
while getopts "n:t:f:b:p:v:" opt; do
    case $opt in
        n) Nombre="$OPTARG" ;;
        t) Tipo="$OPTARG" ;;
    esac
done
```

---

### 2. **Funciones de salida**

**PowerShell:**
```powershell
function Write-Info([string]$Message) { 
    Write-Host $Message -ForegroundColor Cyan 
}
```

**Bash:**
```bash
CYAN='\033[0;36m'
NC='\033[0m'

write_info() { 
    echo -e "${CYAN}$1${NC}"
}
```

---

### 3. **Variables y expansión**

**PowerShell:**
```powershell
$RutaProyecto = Join-Path (Join-Path $PWD $CarpetaBase) $Nombre
$VersionPHP = "8.3"
```

**Bash:**
```bash
RutaProyecto="$PWD/$CarpetaBase/$Nombre"
VersionPHP="8.3"
```

---

### 4. **Tests de condición**

**PowerShell:**
```powershell
if (Test-Path -LiteralPath $GlobalConfigPath) {
    $GlobalConfig = Get-Content -LiteralPath $GlobalConfigPath -Raw | ConvertFrom-Json
}
```

**Bash:**
```bash
if [ -f "crea-proyecto.config.json" ]; then
    if command -v jq &> /dev/null; then
        GlobalConfig=$(cat crea-proyecto.config.json)
    fi
fi
```

---

### 5. **Tests de puertos**

**PowerShell:**
```powershell
function Test-PortAvailable([int]$Port) {
    try {
        return -not (Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction Stop)
    } catch {
        return $true
    }
}
```

**Bash:**
```bash
test_port_available() {
    local port=$1
    ! nc -z 127.0.0.1 "$port" 2>/dev/null
}
```

---

### 6. **Crear archivos con contenido**

**PowerShell:**
```powershell
function Write-GeneratedFile {
    param([string]$Path, [string[]]$Lines)
    $Lines | Set-Content -LiteralPath $Path -Encoding UTF8
}

Write-GeneratedFile "archivo.txt" @("linea1", "linea2")
```

**Bash:**
```bash
write_generated_file() {
    local path=$1
    shift
    
    mkdir -p "$(dirname "$path")"
    printf '%s\n' "$@" > "$path"
}

write_generated_file "archivo.txt" "linea1" "linea2"
```

---

### 7. **Lectura de entrada del usuario**

**PowerShell:**
```powershell
$Nombre = Read-Host 'Nombre del proyecto'
```

**Bash:**
```bash
read -p "Nombre del proyecto: " Nombre
```

---

### 8. **Menús interactivos**

**PowerShell:**
```powershell
function Read-MenuOption {
    param([hashtable]$Options)
    foreach ($Key in ($Options.Keys | Sort-Object)) {
        Write-Host "  $Key. $($Options[$Key])"
    }
}
```

**Bash:**
```bash
read_menu_option() {
    local title=$1
    declare -A options=()
    
    shift
    while [ $# -gt 1 ]; do
        options[$1]=$2
        shift 2
    done
    
    for key in $(echo "${!options[@]}" | tr ' ' '\n' | sort -n); do
        echo "  $key. ${options[$key]}"
    done
}
```

---

### 9. **Generación de claves aleatorias**

**PowerShell:**
```powershell
function New-RandomKey([int]$Length = 32) {
    $Bytes = New-Object byte[] $Length
    (New-Object System.Random).NextBytes($Bytes)
    return [Convert]::ToBase64String($Bytes)
}
```

**Bash:**
```bash
new_random_key() {
    local length=${1:-32}
    openssl rand -base64 "$length" 2>/dev/null || \
    head -c "$length" /dev/urandom | base64
}
```

---

### 10. **Operaciones con directorios**

**PowerShell:**
```powershell
New-Item -ItemType Directory -Path $Path -Force | Out-Null
Test-Path -LiteralPath $Path
Remove-Item -LiteralPath $Path -Recurse -Force
```

**Bash:**
```bash
mkdir -p "$Path"
[ -d "$Path" ]
rm -rf "$Path"
```

---

### 11. **Switch/Case**

**PowerShell:**
```powershell
$DatabaseServiceName = switch ($BD) {
    'SQLServer' { 'sqlserver' }
    'PostgreSQL' { 'postgres' }
    default { 'mariadb' }
}
```

**Bash:**
```bash
case $BD in
    SQLServer) DatabaseServiceName='sqlserver' ;;
    PostgreSQL) DatabaseServiceName='postgres' ;;
    *) DatabaseServiceName='mariadb' ;;
esac
```

---

### 12. **Barra de progreso**

**PowerShell:**
```powershell
Write-ProgressBar -Activity "Generando..." -Completed $Completed -Total $Total
```

**Bash:**
```bash
write_progress_bar() {
    local activity=$1
    local completed=$2
    local total=$3
    
    if [ "$total" -gt 0 ]; then
        local percent=$((completed * 100 / total))
        local bars=$((percent / 2))
        printf "\r${CYAN}[...]${NC} %d%% - %s (%d/%d)" "$percent" "$activity" "$completed" "$total"
    fi
}
```

---

### 13. **Validación de entrada**

**PowerShell:**
```powershell
if ($value -notmatch '[\\/:*?"<>|]') {
    return $value
}
```

**Bash:**
```bash
if ! [[ "$value" =~ [/:\\*\"?\'<>|] ]]; then
    echo "$value"
fi
```

---

### 14. **Escritura de múltiples líneas (aquí documents)**

**PowerShell:**
```powershell
@("linea1", "linea2", "linea3")
```

**Bash:**
```bash
write_generated_file "archivo.txt" \
    "linea1" \
    "linea2" \
    "linea3"

# O usando here-doc
cat << 'EOF'
linea1
linea2
linea3
EOF
```

---

### 15. **Salida de datos formateada**

**PowerShell:**
```powershell
Write-Host "Valor: $value" -ForegroundColor Green
```

**Bash:**
```bash
echo -e "${GREEN}Valor: $value${NC}"
```

---

## 🎯 Diferencias importantes en el comportamiento

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

## ✅ Verificación de compatibilidad

Para verificar que bash está instalado:

```bash
bash --version
```

Para ejecutar el script:

```bash
chmod +x crea-proyecto.sh
./crea-proyecto.sh
```

---

## 🔧 Troubleshooting

### Error: `command not found: docker`
- Docker no está instalado
- Solución: Instalar Docker (ver README-Linux-Mac.md)

### Error: `nc: command not found`
- Netcat no está instalado
- Solución: `apt-get install netcat-openbsd` o `brew install netcat`

### Error: `openssl: command not found`
- OpenSSL no está instalado
- Solución: `apt-get install openssl` o `brew install openssl`

### El script no se ejecuta
- Falta permiso de ejecución
- Solución: `chmod +x crea-proyecto.sh`

---

## 📚 Referencias

- **Bash Guide:** https://mywiki.wooledge.org/BashGuide
- **ShellCheck:** https://www.shellcheck.net (verificador de sintaxis bash)
- **POSIX Shell:** https://pubs.opengroup.org/onlinepubs/9699919799/
- **Docker Compose:** https://docs.docker.com/compose/

---

**Versión:** 2.0.0  
**Compatible con:** Linux (Ubuntu, Debian, CentOS, etc.) y macOS  
**Shell requerido:** Bash 4.0+
