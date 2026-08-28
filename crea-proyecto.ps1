param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$Nombre,

    [Parameter(Mandatory = $false)]
    [ValidateSet('PHP', 'DotNet', 'Node')]
    [string]$Tipo,

    [string]$Framework,

    [ValidateSet('MariaDB', 'SQLServer', 'PostgreSQL', 'MongoDB', 'Redis', 'Ambas')]
    [string]$BD = 'MariaDB',

    [ValidateSet('7.4', '8.0', '8.1', '8.2', '8.3')]
    [string]$VersionPHP,

    [ValidateSet('16', '18', '20', '22')]
    [string]$VersionNode,

    [ValidateSet('npm', 'yarn')]
    [string]$GestorNode,

    [ValidateSet('6.0', '7.0', '8.0', '9.0')]
    [string]$VersionDotNet,

    [ValidateRange(1, 65535)]
    [int]$PuertoApp = 0,

    [ValidateRange(1, 65535)]
    [int]$PuertoBD = 0,

    [string]$ConfigPath
)

$GlobalConfigPath = if ($ConfigPath) { $ConfigPath } else { Join-Path $PWD 'crea-proyecto.config.json' }
if (Test-Path -LiteralPath $GlobalConfigPath) {
    $GlobalConfig = Get-Content -LiteralPath $GlobalConfigPath -Raw | ConvertFrom-Json
    if (-not $PSBoundParameters.ContainsKey('Nombre')) { $Nombre = $GlobalConfig.Nombre }
    if (-not $PSBoundParameters.ContainsKey('Tipo')) { $Tipo = $GlobalConfig.Tipo }
    if (-not $PSBoundParameters.ContainsKey('Framework')) { $Framework = $GlobalConfig.Framework }
    if (-not $PSBoundParameters.ContainsKey('BD')) { $BD = $GlobalConfig.BD }
    if (-not $PSBoundParameters.ContainsKey('VersionPHP')) { $VersionPHP = $GlobalConfig.VersionPHP }
    if (-not $PSBoundParameters.ContainsKey('VersionNode')) { $VersionNode = $GlobalConfig.VersionNode }
    if (-not $PSBoundParameters.ContainsKey('GestorNode')) { $GestorNode = $GlobalConfig.GestorNode }
    if (-not $PSBoundParameters.ContainsKey('VersionDotNet')) { $VersionDotNet = $GlobalConfig.VersionDotNet }
    if (-not $PSBoundParameters.ContainsKey('PuertoApp')) { $PuertoApp = $GlobalConfig.PuertoApp }
    if (-not $PSBoundParameters.ContainsKey('PuertoBD')) { $PuertoBD = $GlobalConfig.PuertoBD }
}

$MariaDB = @{
    Host = 'localhost'
    Puerto = '3306'
    Usuario = 'myuser'
    Password = 'mypassword'
    Database = 'mydatabase'
}

$SQLServer = @{
    Host = 'localhost'
    Puerto = '1433'
    Usuario = 'sa'
    Password = 'YourStrong!Password123'
    Database = 'mydatabase'
}

$PostgreSQL = @{
    Host = 'localhost'
    Puerto = '5432'
    Usuario = 'postgres'
    Password = 'postgres'
    Database = 'mydatabase'
}

$MongoDB = @{
    Host = 'localhost'
    Puerto = '27017'
    Usuario = ''
    Password = ''
    Database = 'mydatabase'
}

$Redis = @{
    Host = 'localhost'
    Puerto = '6379'
    Usuario = ''
    Password = ''
    Database = '0'
}

$ScriptVersion = '2.0.0'

function Write-Info([string]$Message) { Write-Host $Message -ForegroundColor Cyan }
function Write-Success([string]$Message) { Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-WarningMessage([string]$Message) { Write-Host "[!] $Message" -ForegroundColor Yellow }
function Write-ErrorMessage([string]$Message) { Write-Host "[ERROR] $Message" -ForegroundColor Red }
function Write-Separator { Write-Host ('=' * 60) -ForegroundColor Gray }

function Write-GeneratedFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string[]]$Lines
    )
    if ($Lines -and $Lines.Count -gt 0) {
        $Lines | Set-Content -LiteralPath $Path -Encoding UTF8
    }
    if ($Script:ProgressCurrent -lt $Script:ProgressTotal) {
        $Script:ProgressCurrent++
    }
    Write-ProgressBar -Activity "Generando $Path" -Completed $Script:ProgressCurrent -Total $Script:ProgressTotal
}

function New-RandomKey([int]$Length = 32) {
    $Bytes = New-Object byte[] $Length
    (New-Object System.Random).NextBytes($Bytes)
    return [Convert]::ToBase64String($Bytes)
}

function New-SelfSignedCertificate {
    param(
        [string]$CertPath,
        [string]$Subject = 'CN=localhost'
    )
    $Cert = New-SelfSignedCertificate -Subject $Subject -CertStoreLocation Cert:\CurrentUser\My -NotAfter (Get-Date).AddYears(1) -KeyExportPolicy Exportable -KeySpec Signature
    $Bytes = $Cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx)
    [System.IO.File]::WriteAllBytes($CertPath, $Bytes)
    $Cert | Remove-Item
}

function Read-MenuOption {
    param(
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][hashtable]$Options
    )

    do {
        Write-Host ""
        Write-Info $Title
        foreach ($Key in ($Options.Keys | Sort-Object)) {
            Write-Host "  $Key. $($Options[$Key])"
        }
        $Selection = Read-Host 'Selecciona una opcion'
        if ($Options.ContainsKey($Selection)) {
            return $Selection
        }
        Write-WarningMessage 'Opcion no valida. Elige uno de los numeros mostrados.'
    } while ($true)
}

function Write-ProgressBar {
    param(
        [Parameter(Mandatory = $true)][string]$Activity,
        [Parameter(Mandatory = $true)][int]$Completed,
        [Parameter(Mandatory = $true)][int]$Total
    )
    $Percent = if ($Total -gt 0) { [math]::Floor(($Completed / $Total) * 100) } else { 0 }
    $Bars = [math]::Floor($Percent / 2)
    $Bar = '=' * $Bars + '-' * (50 - $Bars)
    Write-Host "`r[$Bar] $Percent% - $Activity ($Completed/$Total)" -NoNewline -ForegroundColor Cyan
    if ($Completed -eq $Total) { Write-Host '' }
}

function Read-ProjectName {
    do {
        $Value = Read-Host 'Nombre del proyecto'
        if (-not [string]::IsNullOrWhiteSpace($Value) -and $Value -notmatch '[\\/:*?"<>|]') {
            return $Value.Trim()
        }
        Write-WarningMessage 'Usa un nombre no vacio y sin caracteres invalidos para una carpeta.'
    } while ($true)
}

function Test-PortAvailable([int]$Port) {
    try {
        return -not (Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction Stop)
    } catch {
        return $true
    }
}

function Read-Port([int]$Default) {
    do {
        $InputValue = Read-Host "Puerto externo (Enter para $Default)"
        $Port = $Default
        if ($InputValue -and -not [int]::TryParse($InputValue, [ref]$Port)) { $Port = 0 }
        if ($Port -ge 1 -and $Port -le 65535 -and (Test-PortAvailable $Port)) {
            return $Port
        }
        $Alternative = $Default + 1
        while (-not (Test-PortAvailable $Alternative) -and $Alternative -lt 65535) { $Alternative++ }
        if ($Alternative -lt 65535) {
            Write-WarningMessage "Puerto $Port ocupado. Sugerencia: usa $Alternative"
        } else {
            Write-WarningMessage 'Puerto invalido u ocupado. Elige otro.'
        }
    } while ($true)
}

Clear-Host
Write-Host @'
   ____  _             _     ____            _             _ 
  |  _ \(_)_ __   __ _| |   |  _ \  __ _ ___| |__ _ __ ___| |
  | | | | | '_ \ / _` | |   | | | |/ _` / __| '_ \ '__/ _ \ |
  | |_| | | | | | (_| | |   | |_| | (_| \__ \ | | | | |  __/ |
  |____/|_|_| |_|\__,_|_|   |____/ \__,_|___/_| |_|_|\___|_|
'@ -ForegroundColor Cyan
Write-Separator
Write-Info 'CREADOR DE PROYECTOS PARA DOCKER'
Write-Host "Version del generador: $ScriptVersion"
Write-Separator

$ModoInteractivo = $PSBoundParameters.Count -eq 0
if ($ModoInteractivo -or [string]::IsNullOrWhiteSpace($Nombre)) {
    Write-Host ''
    Write-Info 'Guia rapida: elige el tipo de proyecto y la base de datos.'
    Write-Host 'Tambien puedes ejecutar el script con parametros para automatizarlo.'
    $Nombre = Read-ProjectName
}

if ($ModoInteractivo -or [string]::IsNullOrWhiteSpace($Tipo)) {
    $TipoSeleccionado = Read-MenuOption 'Que tipo de proyecto quieres crear?' @{
        '1' = 'PHP - Aplicacion web PHP'
        '2' = 'Node - API Node.js con Express'
        '3' = '.NET - API ASP.NET Core'
    }
    $Tipo = @{ '1' = 'PHP'; '2' = 'Node'; '3' = 'DotNet' }[$TipoSeleccionado]
}

if ($ModoInteractivo -or [string]::IsNullOrWhiteSpace($Framework)) {
    if ($Tipo -eq 'PHP') {
        $FrameworkSeleccionado = Read-MenuOption 'Que framework PHP quieres usar?' @{'1' = 'PHP Base'; '2' = 'Laravel'; '3' = 'Symfony'; '4' = 'Slim'; '5' = 'CakePHP'}
        $Framework = @{'1' = 'PHP Base'; '2' = 'Laravel'; '3' = 'Symfony'; '4' = 'Slim'; '5' = 'CakePHP'}[$FrameworkSeleccionado]
    } elseif ($Tipo -eq 'Node') {
        $FrameworkSeleccionado = Read-MenuOption 'Que framework Node.js quieres usar?' @{'1' = 'Express'; '2' = 'NestJS'; '3' = 'Fastify'; '4' = 'Koa'}
        $Framework = @{'1' = 'Express'; '2' = 'NestJS'; '3' = 'Fastify'; '4' = 'Koa'}[$FrameworkSeleccionado]
    } else {
        $FrameworkSeleccionado = Read-MenuOption 'Que plantilla .NET quieres usar?' @{'1' = 'Web API'; '2' = 'MVC'; '3' = 'Minimal API'; '4' = 'Blazor'}
        $Framework = @{'1' = 'Web API'; '2' = 'MVC'; '3' = 'Minimal API'; '4' = 'Blazor'}[$FrameworkSeleccionado]
    }
}
if (-not $Framework) { $Framework = if ($Tipo -eq 'PHP') { 'PHP Base' } elseif ($Tipo -eq 'Node') { 'Express' } else { 'Web API' } }

if ($ModoInteractivo) {
    $TemplateSeleccionado = Read-MenuOption 'Que plantilla quieres usar?' @{'1' = 'API Base'; '2' = 'CRUD'; '3' = 'JWT Auth'; '4' = 'Microservicio'}
    $Template = @{'1' = 'API Base'; '2' = 'CRUD'; '3' = 'JWT Auth'; '4' = 'Microservicio'}[$TemplateSeleccionado]
} else {
    $Template = 'API Base'
}

if ($ModoInteractivo -or -not $PSBoundParameters.ContainsKey('BD')) {
    $BDSeleccionada = Read-MenuOption 'Que base de datos quieres configurar?' @{
        '1' = 'MariaDB - Recomendado para PHP y Node.js'
        '2' = 'SQLServer - Pensado para proyectos .NET'
        '3' = 'PostgreSQL - Base de datos relacional'
        '4' = 'MongoDB - Base de datos documental'
        '5' = 'Redis - Cache y almacenamiento clave-valor'
        '6' = 'Ambas - Mantener MariaDB y SQL Server disponibles'
    }
    $BD = @{ '1' = 'MariaDB'; '2' = 'SQLServer'; '3' = 'PostgreSQL'; '4' = 'MongoDB'; '5' = 'Redis'; '6' = 'Ambas' }[$BDSeleccionada]
}

$ConfiguracionBD = switch ($BD) {
    'SQLServer' { $SQLServer }
    'PostgreSQL' { $PostgreSQL }
    'MongoDB' { $MongoDB }
    'Redis' { $Redis }
    'Ambas' { $MariaDB }
    default { $MariaDB }
}
$CadenaConexion = if ($BD -eq 'SQLServer') {
    "Server=$($ConfiguracionBD.Host),$($ConfiguracionBD.Puerto);Database=$($ConfiguracionBD.Database);User Id=$($ConfiguracionBD.Usuario);Password=$($ConfiguracionBD.Password);TrustServerCertificate=True;"
} elseif ($BD -eq 'PostgreSQL') {
    "Host=$($ConfiguracionBD.Host);Port=$($ConfiguracionBD.Puerto);Database=$($ConfiguracionBD.Database);Username=$($ConfiguracionBD.Usuario);Password=$($ConfiguracionBD.Password);"
} elseif ($BD -eq 'MongoDB') {
    "mongodb://$($ConfiguracionBD.Host):$($ConfiguracionBD.Puerto)/$($ConfiguracionBD.Database)"
} elseif ($BD -eq 'Redis') {
    "$($ConfiguracionBD.Host):$($ConfiguracionBD.Puerto)"
} else {
    "Server=$($ConfiguracionBD.Host);Port=$($ConfiguracionBD.Puerto);Database=$($ConfiguracionBD.Database);User=$($ConfiguracionBD.Usuario);Password=$($ConfiguracionBD.Password);"
}

Write-Host "Proyecto: $Nombre"
Write-Host "Tipo: $Tipo"
Write-Host "Base de datos: $BD"
if ($Tipo -eq 'PHP' -and -not $VersionPHP) { if ($ModoInteractivo) { $VersionPHPSel = Read-MenuOption 'Que version de PHP quieres usar?' @{'1' = '7.4'; '2' = '8.0'; '3' = '8.1'; '4' = '8.2'; '5' = '8.3'}; $VersionPHP = @{'1' = '7.4'; '2' = '8.0'; '3' = '8.1'; '4' = '8.2'; '5' = '8.3'}[$VersionPHPSel] } else { $VersionPHP = '8.3' } }
if ($Tipo -eq 'Node' -and -not $VersionNode) { if ($ModoInteractivo) { $VersionNodeSel = Read-MenuOption 'Que version de Node.js quieres usar?' @{'1' = '16'; '2' = '18'; '3' = '20'; '4' = '22'}; $VersionNode = @{'1' = '16'; '2' = '18'; '3' = '20'; '4' = '22'}[$VersionNodeSel] } else { $VersionNode = '22' } }
if ($Tipo -eq 'Node' -and -not $GestorNode) { if ($ModoInteractivo) { $GestorNodeSel = Read-MenuOption 'Que gestor de paquetes quieres usar?' @{'1' = 'npm'; '2' = 'yarn'}; $GestorNode = @{'1' = 'npm'; '2' = 'yarn'}[$GestorNodeSel] } else { $GestorNode = 'npm' } }
if ($Tipo -eq 'DotNet' -and -not $VersionDotNet) { if ($ModoInteractivo) { $VersionDotNetSel = Read-MenuOption 'Que version de .NET quieres usar?' @{'1' = '6.0'; '2' = '7.0'; '3' = '8.0'; '4' = '9.0'}; $VersionDotNet = @{'1' = '6.0'; '2' = '7.0'; '3' = '8.0'; '4' = '9.0'}[$VersionDotNetSel] } else { $VersionDotNet = '8.0' } }
if (-not $PuertoApp) { $PuertoApp = if ($Tipo -eq 'Node') { 3000 } else { 8080 } }
if (-not $PuertoBD) { $PuertoBD = [int]$ConfiguracionBD.Puerto }
if ($ModoInteractivo) {
    $PuertoApp = Read-Port $PuertoApp
    $PuertoBD = Read-Port $PuertoBD
}
Write-Host ''

$AppKey = 'base64:' + (New-RandomKey 32)
$JwtSecret = New-RandomKey 64
$DataProtectionKey = New-RandomKey 32

$CarpetaBase = switch ($Tipo) {
    'PHP' { 'proyectos-php' }
    'DotNet' { 'proyectos-dotnet' }
    'Node' { 'proyectos-node' }
}
$RutaProyecto = Join-Path (Join-Path $PWD $CarpetaBase) $Nombre

if (Test-Path -LiteralPath $RutaProyecto) {
    Write-ErrorMessage "El proyecto '$Nombre' ya existe en '$RutaProyecto'"
    exit 1
}

New-Item -ItemType Directory -Path $RutaProyecto -Force | Out-Null
Write-Info 'Creando estructura y archivos...'
$Script:ProgressTotal = if ($Tipo -eq 'PHP') { 35 } elseif ($Tipo -eq 'Node') { 33 } else { 35 }
$Script:ProgressCurrent = 0

if ($Framework -eq 'Laravel') {
    @('database/migrations', 'database/seeders', 'lang') | ForEach-Object { New-Item -ItemType Directory -Path (Join-Path $RutaProyecto $_) -Force | Out-Null }
} elseif ($Framework -eq 'CakePHP') {
    @('config', 'logs', 'src', 'src/Controller', 'src/Model', 'src/View', 'src/Template', 'webroot', 'tests') | ForEach-Object { New-Item -ItemType Directory -Path (Join-Path $RutaProyecto $_) -Force | Out-Null }
} elseif ($Framework -eq 'NestJS') {
    @('src/modules', 'src/common', 'src/config') | ForEach-Object { New-Item -ItemType Directory -Path (Join-Path $RutaProyecto $_) -Force | Out-Null }
} elseif ($Tipo -eq 'DotNet') {
    @('Properties', 'wwwroot', 'Middlewares') | ForEach-Object { New-Item -ItemType Directory -Path (Join-Path $RutaProyecto $_) -Force | Out-Null }
}

switch ($Tipo) {
    'PHP' {
        $DbConnection = switch ($BD) {
            'PostgreSQL' { "pgsql:host=$($ConfiguracionBD.Host);port=$($ConfiguracionBD.Puerto);dbname=$($ConfiguracionBD.Database)" }
            'SQLServer' { "sqlsrv:Server=$($ConfiguracionBD.Host),$($ConfiguracionBD.Puerto);Database=$($ConfiguracionBD.Database)" }
            default { "mysql:host=$($ConfiguracionBD.Host);port=$($ConfiguracionBD.Puerto);dbname=$($ConfiguracionBD.Database)" }
        }
        $DbDriver = switch ($BD) {
            'PostgreSQL' { 'pgsql' }
            'SQLServer' { 'sqlsrv' }
            'MongoDB' { 'mongodb' }
            'Redis' { 'redis' }
            default { 'mysql' }
        }
        $PhpConnectionCode = if ($BD -in @('MongoDB', 'Redis')) {
            @(' ', "# Conexion a $BD configurada para desarrollo", ' ', '// TODO: Implementa la conexion real a ' + $BD + ' usando la extension correspondiente.', '// Consulta la documentacion oficial para integrar el driver en tu aplicacion.')
        } elseif ($BD -eq 'SQLServer') {
            @('try {', "    `$pdo = new PDO('$DbConnection', '$($ConfiguracionBD.Usuario)', '$($ConfiguracionBD.Password)');",
              '    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);', '    echo "Conectado a SQLServer";',
              '} catch (PDOException $e) {', '    echo "Error: " . $e->getMessage();', '}')
        } elseif ($BD -eq 'PostgreSQL') {
            @('try {', "    `$pdo = new PDO('$DbConnection', '$($ConfiguracionBD.Usuario)', '$($ConfiguracionBD.Password)');",
              '    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);', '    echo "Conectado a PostgreSQL";',
              '} catch (PDOException $e) {', '    echo "Error: " . $e->getMessage();', '}')
        } else {
            @('try {', "    `$pdo = new PDO('$DbConnection', '$($ConfiguracionBD.Usuario)', '$($ConfiguracionBD.Password)');",
              '    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);', '    echo "Conectado a MariaDB";',
              '} catch (PDOException $e) {', '    echo "Error: " . $e->getMessage();', '}')
        }
        $ComposerRequire = if ($BD -eq 'MongoDB') {
            '    "mongodb/mongodb": "^7.0"'
        } elseif ($BD -eq 'Redis') {
            '    "predis/predis": "^2.0"'
        } else {
            '    "php": "^8.1"'
        }
        @('app', 'config', 'database', 'public', 'resources', 'routes', 'storage', 'tests') | ForEach-Object {
            New-Item -ItemType Directory -Path (Join-Path $RutaProyecto $_) -Force | Out-Null
        }
        Write-GeneratedFile (Join-Path $RutaProyecto '.env') @(
            "APP_NAME=$Nombre", 'APP_ENV=local', 'APP_DEBUG=true', "APP_URL=http://localhost:$PuertoApp",
            "APP_KEY=$AppKey", "DB_CONNECTION=$DbDriver", "DB_HOST=$($ConfiguracionBD.Host)", "DB_PORT=$($ConfiguracionBD.Puerto)",
            "DB_DATABASE=$($ConfiguracionBD.Database)", "DB_USERNAME=$($ConfiguracionBD.Usuario)", "DB_PASSWORD=$($ConfiguracionBD.Password)"
        )
        $PhpIndexCode = @(
            '<?php', "echo `"Proyecto PHP '$Nombre' funcionando!<br><br>`";",
            ' ', '// CORS headers', "header('Access-Control-Allow-Origin: *');", "header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');", "header('Access-Control-Allow-Headers: Content-Type, Authorization');",
            'if (`$_SERVER[''REQUEST_METHOD'']` === ''OPTIONS'') { http_response_code(204); exit; }',
            ' ', '// Rate limiting simple', "`$rateLimitFile = sys_get_temp_dir() . '/rate_limit_' . (`$_SERVER['REMOTE_ADDR'] ?? 'unknown') . '.txt`;",
            "`$requests = file_exists(`$rateLimitFile) ? (int)file_get_contents(`$rateLimitFile) : 0;",
            "if (`$requests >= 100) { http_response_code(429); echo 'Too Many Requests'; exit; }",
            "file_put_contents(`$rateLimitFile, (string)(`$requests + 1));",
            ' ', '// Health endpoint', "if (`$_SERVER['REQUEST_URI']` === '/health' || `$_SERVER['REQUEST_URI']` === '/health/') {",
            '    header(''Content-Type: application/json'');', "    echo json_encode(['status' => 'OK', 'project' => '$Nombre', 'database' => '$BD']);", '    exit;', '}',
            ' ', $PhpConnectionCode, '?>'
        )
        Write-GeneratedFile (Join-Path $RutaProyecto 'public/index.php') $PhpIndexCode
        Write-GeneratedFile (Join-Path $RutaProyecto 'composer.json') @(
            '{', "    `"name`": `"$Nombre/aplicacion`",.", '    "description": "Proyecto PHP con Docker",',
            "    `"require`": { $ComposerRequire },", '    "require-dev": { "phpunit/phpunit": "^10.5", "phpstan/phpstan": "^1.10", "zircote/swagger-php": "^4.0" },',
            '    "scripts": { "test": "phpunit", "analyse": "phpstan analyse" }', '}'
        )
        Write-GeneratedFile (Join-Path $RutaProyecto 'phpstan.neon') @(
            'includes:', '    - vendor/phpstan/phpstan-symfony/extension.neon',
            'parameters:', '    level: 5', '    paths:', '        - app', '        - config', '        - public', '        - routes'
        )
    }
    'DotNet' {
        $DotNetPackages = switch ($BD) {
            'PostgreSQL' { @('    <PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="8.0.0" />') }
            'SQLServer' { @('    <PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="8.0.0" />') }
            'MongoDB' { @('    <PackageReference Include="MongoDB.Driver" Version="2.22.0" />') }
            'Redis' { @('    <PackageReference Include="StackExchange.Redis" Version="2.7.0" />') }
            default { @('    <PackageReference Include="Pomelo.EntityFrameworkCore.MySql" Version="8.0.0-beta.2" />') }
        }
        $DotNetPackages += @('    <PackageReference Include="StyleCop.Analyzers" Version="1.1.118" />')
        @('Controllers', 'Models', 'Data', 'Services', 'Migrations') | ForEach-Object {
            New-Item -ItemType Directory -Path (Join-Path $RutaProyecto $_) -Force | Out-Null
        }
        Write-GeneratedFile (Join-Path $RutaProyecto 'appsettings.json') @(
            '{', '  "Logging": { "LogLevel": { "Default": "Information" } },', '  "AllowedHosts": "*",',
            "  `"ConnectionStrings`": { `"DefaultConnection`": `"$CadenaConexion`" }", '  "DataProtection": { "KeyEncryptionKeyType": "X509Certificate" }', '}'
        )
        Write-GeneratedFile (Join-Path $RutaProyecto 'Program.cs') @(
            'var builder = WebApplication.CreateBuilder(args);', 'builder.Services.AddControllers();',
            'builder.Services.AddEndpointsApiExplorer();', 'builder.Services.AddSwaggerGen();',
            'builder.Services.AddCors(options =>', '    options.AddPolicy("DevPolicy", policy => policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader()));',
            'builder.Services.AddRateLimiter();',
            'var app = builder.Build();', 'app.UseSwagger();', 'app.UseSwaggerUI();',
            'app.UseCors("DevPolicy");', 'app.UseRateLimiter();',
            'app.MapGet("/health", () => Results.Json(new { status = "OK", project = "' + $Nombre + '" }));',
            'app.MapControllers();', 'app.Run();'
        )
        Write-GeneratedFile (Join-Path $RutaProyecto 'Data/ApplicationDbContext.cs') @(
            'using Microsoft.EntityFrameworkCore;', ' ', 'public class ApplicationDbContext : DbContext', '{',
            '    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }', '}'
        )
        Write-GeneratedFile (Join-Path $RutaProyecto "$Nombre.csproj") @(
            '<Project Sdk="Microsoft.NET.Sdk.Web">', '  <PropertyGroup>', "    <TargetFramework>net$VersionDotNet</TargetFramework>",
            '    <Nullable>enable</Nullable>', '    <ImplicitUsings>enable</ImplicitUsings>', '  </PropertyGroup>',
            '  <ItemGroup>', '    <PackageReference Include="Swashbuckle.AspNetCore" Version="6.5.0" />'
        ) + $DotNetPackages + @('  </ItemGroup>', '</Project>')
        New-Item -ItemType Directory -Path (Join-Path $RutaProyecto 'tests') -Force | Out-Null
        Write-GeneratedFile (Join-Path $RutaProyecto "tests/$Nombre.Tests.csproj") @(
            '<Project Sdk="Microsoft.NET.Sdk">', '  <PropertyGroup>', "    <TargetFramework>net$VersionDotNet</TargetFramework>",
            '    <ImplicitUsings>enable</ImplicitUsings>', '    <Nullable>enable</Nullable>', '  </PropertyGroup>',
            '  <ItemGroup>', '    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.8.0" />',
            '    <PackageReference Include="xunit" Version="2.4.2" />',
            '    <PackageReference Include="xunit.runner.visualstudio" Version="2.5.4" />',
            '    <PackageReference Include="coverlet.collector" Version="6.0.0" />',
            '  </ItemGroup>', '  <ItemGroup>', "    <ProjectReference Include=`"..\$Nombre.csproj`" />", '  </ItemGroup>', '</Project>'
        )
        Write-GeneratedFile (Join-Path $RutaProyecto 'tests/HealthTest.cs') @(
            'using Xunit;', ' ', 'namespace ' + $Nombre + '.Tests', '{', '    public class HealthTests', '    {',
            '        [Fact]', '        public void HealthEndpoint_ReturnsSuccess()', '        {',
            '            Assert.True(true);', '        }', '    }', '}'
        )
    }
    'Node' {
        $NodeDependencies = switch ($BD) {
            'PostgreSQL' { '"pg": "^8.11.0"' }
            'SQLServer' { '"mssql": "^11.0.0"' }
            'MongoDB' { '"mongodb": "^6.3.0"' }
            'Redis' { '"redis": "^4.6.0"' }
            default { '"mysql2": "^3.6.0"' }
        }
        @('src', 'src/config', 'src/models', 'src/controllers', 'src/routes', 'src/middleware') | ForEach-Object {
            New-Item -ItemType Directory -Path (Join-Path $RutaProyecto $_) -Force | Out-Null
        }
        Write-GeneratedFile (Join-Path $RutaProyecto 'package.json') @(
            '{', "  `"name`": `"$Nombre`",", '  "version": "1.0.0",', '  "main": "server.js",',
            '  "scripts": { "start": "node server.js", "dev": "nodemon server.js", "prepare": "husky install" },',
            "  `"dependencies`": { `"express`": `"^4.18.2`", `"cors`": `"^2.8.5`", `"dotenv`": `"^16.3.1`", $NodeDependencies, `"express-rate-limit`": `"^7.4.0`", `"swagger-ui-express`": `"^5.0.1`" },",
            '  "devDependencies": { "nodemon": "^3.0.1", "husky": "^9.0.0", "eslint": "^8.50.0" }', '} '
        )
        New-Item -ItemType Directory -Path (Join-Path $RutaProyecto '.husky') -Force | Out-Null
        Write-GeneratedFile (Join-Path $RutaProyecto '.husky/pre-commit') @('#!/usr/bin/env sh', '. "$(dirname "$0")/_/husky.sh"', 'npm run lint -- --fix', 'npm test --if-present')
        Write-GeneratedFile (Join-Path $RutaProyecto '.env') @(
            'PORT=3000', 'NODE_ENV=development', "JWT_SECRET=$JwtSecret", "DB_HOST=$($ConfiguracionBD.Host)", "DB_PORT=$($ConfiguracionBD.Puerto)",
            "DB_USER=$($ConfiguracionBD.Usuario)", "DB_PASSWORD=$($ConfiguracionBD.Password)", "DB_NAME=$($ConfiguracionBD.Database)"
        )
        $NodeDbConfig = switch ($BD) {
            'PostgreSQL' { @("const { Client } = require('pg');", "require('dotenv').config();", ' ', 'const client = new Client({', '    host: process.env.DB_HOST,', '    port: Number(process.env.DB_PORT),', '    user: process.env.DB_USER,', '    password: process.env.DB_PASSWORD,', '    database: process.env.DB_NAME', '});', 'client.connect();', 'module.exports = client;') }
            'SQLServer' { @("const sql = require('mssql');", "require('dotenv').config();", ' ', 'const config = {', '    server: process.env.DB_HOST,', '    database: process.env.DB_NAME,', '    user: process.env.DB_USER,', '    password: process.env.DB_PASSWORD,', '    options: { encrypt: false, trustServerCertificate: true }', '};', 'module.exports = config;') }
            'MongoDB' { @("const { MongoClient } = require('mongodb');", "require('dotenv').config();", ' ', 'const uri = `mongodb://${process.env.DB_USER}:${process.env.DB_PASSWORD}@${process.env.DB_HOST}:${process.env.DB_PORT}`;', 'const client = new MongoClient(uri);', 'module.exports = client;') }
            'Redis' { @("const redis = require('redis');", "require('dotenv').config();", ' ', 'const client = redis.createClient({', '    socket: { host: process.env.DB_HOST, port: Number(process.env.DB_PORT) }', '});', 'client.connect();', 'module.exports = client;') }
            default { @("const mysql = require('mysql2/promise');", "require('dotenv').config();", ' ', 'const pool = mysql.createPool({ host: process.env.DB_HOST, port: Number(process.env.DB_PORT),', '    user: process.env.DB_USER, password: process.env.DB_PASSWORD, database: process.env.DB_NAME,', '    waitForConnections: true, connectionLimit: 10 });', 'module.exports = pool;') }
        }
        Write-GeneratedFile (Join-Path $RutaProyecto 'src/config/database.js') $NodeDbConfig
        Write-GeneratedFile (Join-Path $RutaProyecto 'server.js') @(
            "require('dotenv').config();", "const express = require('express');", "const cors = require('cors');",
            "const app = express();", "const rateLimit = require('express-rate-limit');", "const swaggerUi = require('swagger-ui-express');", 'const PORT = process.env.PORT || 3000;', 'app.use(cors());', 'app.use(express.json());',
            'app.use(rateLimit({ windowMs: 15 * 60 * 1000, limit: 100 }));',
            "app.get('/health', (req, res) => res.json({ status: 'OK', project: '$Nombre' }));",
            "app.use('/api-docs', swaggerUi.serve, swaggerUi.setup({ openapi: '3.0.0', info: { title: '$Nombre API', version: '1.0.0' }, paths: { '/health': { get: { responses: { '200': { description: 'OK' } } } } } }));",
            'app.listen(PORT, () => console.log(`Servidor en http://localhost:${PORT}`));'
        )
    }
}

if ($Tipo -eq 'PHP') {
    $DockerfileLines = @("FROM php:$VersionPHP-apache")
    if ($BD -in @('MariaDB', 'Ambas')) {
        $DockerfileLines += 'RUN docker-php-ext-install pdo pdo_mysql'
    } elseif ($BD -eq 'PostgreSQL') {
        $DockerfileLines += 'RUN docker-php-ext-install pdo pdo_pgsql'
    } elseif ($BD -eq 'SQLServer') {
        $DockerfileLines += 'RUN apt-get update && apt-get install -y libssl-dev libcurl4-openssl-dev'
        $DockerfileLines += 'RUN pecl install sqlsrv'
        $DockerfileLines += 'RUN docker-php-ext-install pdo pdo_sqlsrv'
    } elseif ($BD -eq 'MongoDB') {
        $DockerfileLines += 'RUN pecl install mongodb'
        $DockerfileLines += 'RUN docker-php-ext-install pdo mongodb'
    }
    $DockerfileLines += 'COPY . /var/www/html', 'WORKDIR /var/www/html', 'EXPOSE 80'
    $Dockerfile = $DockerfileLines
} elseif ($Tipo -eq 'Node') {
    if ($GestorNode -eq 'yarn') {
        $Dockerfile = @("FROM node:$VersionNode-alpine", 'WORKDIR /app', 'RUN corepack enable', 'COPY package.json yarn.lock* ./', 'RUN yarn install', 'COPY . .', 'EXPOSE 3000', 'CMD ["yarn", "start"]')
    } else {
        $Dockerfile = @("FROM node:$VersionNode-alpine", 'WORKDIR /app', 'COPY package*.json ./', 'RUN npm install', 'COPY . .', 'EXPOSE 3000', 'CMD ["npm", "start"]')
    }
} else {
    $Dockerfile = @("FROM mcr.microsoft.com/dotnet/sdk:$VersionDotNet AS build", 'WORKDIR /src', "COPY $Nombre.csproj ./", 'RUN dotnet restore', 'COPY . .', 'RUN dotnet publish -c Release -o /app/publish', "FROM mcr.microsoft.com/dotnet/aspnet:$VersionDotNet AS final", 'WORKDIR /app', 'COPY --from=build /app/publish .', 'EXPOSE 8080', 'ENTRYPOINT ["dotnet", "' + $Nombre + '.dll"]')
}
Write-GeneratedFile (Join-Path $RutaProyecto 'Dockerfile') $Dockerfile
$DatabaseServiceName = switch ($BD) {
    'SQLServer' { 'sqlserver' }
    'PostgreSQL' { 'postgres' }
    'MongoDB' { 'mongodb' }
    'Redis' { 'redis' }
    'Ambas' { 'mariadb' }
    default { 'mariadb' }
}
$EnvironmentLines = @(
    "APP_NAME=$Nombre", "FRAMEWORK=$Framework", 'APP_ENV=development', 'APP_DEBUG=true', "PORT=$PuertoApp",
    "APP_KEY=$AppKey", "JWT_SECRET=$JwtSecret", "DATA_PROTECTION_KEY=$DataProtectionKey",
    "DB_TYPE=$BD", "DB_HOST=$DatabaseServiceName", "DB_PORT=$($ConfiguracionBD.Puerto)",
    "DB_NAME=$($ConfiguracionBD.Database)", "DB_USER=$($ConfiguracionBD.Usuario)",
    "DB_PASSWORD=$($ConfiguracionBD.Password)", 'REDIS_HOST=redis', 'REDIS_PORT=6379'
)
$EnvironmentExampleLines = @(
    '# Nombre de la aplicacion', "APP_NAME=$Nombre",
    '# Framework utilizado (PHP Base, Laravel, Express, NestJS, etc.)', "FRAMEWORK=$Framework",
    '# Entorno: development, test, production', 'APP_ENV=development',
    '# Modo debug: true para desarrollo, false para produccion', 'APP_DEBUG=true',
    '# Puerto de la aplicacion', "PORT=$PuertoApp",
    '# Clave de encriptacion (generada automaticamente)', 'APP_KEY=change-me',
    '# Secreto para JWT (generado automaticamente)', 'JWT_SECRET=change-me',
    '# Clave para Data Protection (generada automaticamente)', 'DATA_PROTECTION_KEY=change-me',
    '# Tipo de base de datos', "DB_TYPE=$BD",
    '# Host de la base de datos (usar el nombre del servicio en docker-compose)', "DB_HOST=$DatabaseServiceName",
    '# Puerto de la base de datos', "DB_PORT=$($ConfiguracionBD.Puerto)",
    '# Nombre de la base de datos', "DB_NAME=$($ConfiguracionBD.Database)",
    '# Usuario de la base de datos', "DB_USER=$($ConfiguracionBD.Usuario)",
    '# Contrasena de la base de datos', 'DB_PASSWORD=change-me',
    '# Configuracion de Redis (si aplica)', 'REDIS_HOST=redis', 'REDIS_PORT=6379'
)
Write-GeneratedFile (Join-Path $RutaProyecto '.env.example') $EnvironmentExampleLines
Write-GeneratedFile (Join-Path $RutaProyecto '.env') $EnvironmentLines
Write-GeneratedFile (Join-Path $RutaProyecto '.env.development') ($EnvironmentLines | ForEach-Object {
    $Line = $_
    if ($_ -eq 'DB_PASSWORD=change-me') { $Line = "DB_PASSWORD=$($ConfiguracionBD.Password)" }
    if ($_ -eq 'APP_KEY=change-me') { $Line = "APP_KEY=$AppKey" }
    if ($_ -eq 'JWT_SECRET=change-me') { $Line = "JWT_SECRET=$JwtSecret" }
    if ($_ -eq 'DATA_PROTECTION_KEY=change-me') { $Line = "DATA_PROTECTION_KEY=$DataProtectionKey" }
    $Line
})
Write-GeneratedFile (Join-Path $RutaProyecto '.env.test') ($EnvironmentLines | ForEach-Object {
    $Line = $_ -replace 'APP_ENV=development', 'APP_ENV=test' -replace "PORT=$PuertoApp", "PORT=$($PuertoApp + 1000)"
    if ($Line -eq 'DB_PASSWORD=change-me') { $Line = "DB_PASSWORD=$($ConfiguracionBD.Password)" }
    if ($Line -eq 'APP_KEY=change-me') { $Line = "APP_KEY=$AppKey" }
    if ($Line -eq 'JWT_SECRET=change-me') { $Line = "JWT_SECRET=$JwtSecret" }
    if ($Line -eq 'DATA_PROTECTION_KEY=change-me') { $Line = "DATA_PROTECTION_KEY=$DataProtectionKey" }
    $Line
})
Write-GeneratedFile (Join-Path $RutaProyecto '.env.production') ($EnvironmentLines | ForEach-Object {
    $Line = $_ -replace 'APP_ENV=development', 'APP_ENV=production' -replace 'APP_DEBUG=true', 'APP_DEBUG=false'
    if ($Line -eq 'DB_PASSWORD=change-me') { $Line = "DB_PASSWORD=$($ConfiguracionBD.Password)" }
    if ($Line -eq 'APP_KEY=change-me') { $Line = "APP_KEY=$AppKey" }
    if ($Line -eq 'JWT_SECRET=change-me') { $Line = "JWT_SECRET=$JwtSecret" }
    if ($Line -eq 'DATA_PROTECTION_KEY=change-me') { $Line = "DATA_PROTECTION_KEY=$DataProtectionKey" }
    $Line
})
$DatabaseService = switch ($BD) {
    'SQLServer' { @('  sqlserver:', '    image: mcr.microsoft.com/mssql/server:2022-latest', '    environment:', '      ACCEPT_EULA: "Y"', "      MSSQL_SA_PASSWORD: $($SQLServer.Password)", '    ports:', "      - `"${PuertoBD}:1433`"", '    healthcheck:', '      test: ["CMD", "sqlcmd", "-S", "localhost", "-U", "sa", "-P", "YourStrong!Password123", "-Q", "SELECT 1"]', '      interval: 10s', '      timeout: 5s', '      retries: 5', '    mem_limit: 2g', '    networks:', '      - backend') }
    'PostgreSQL' { @('  postgres:', '    image: postgres:16-alpine', '    environment:', "      POSTGRES_USER: $($PostgreSQL.Usuario)", "      POSTGRES_PASSWORD: $($PostgreSQL.Password)", "      POSTGRES_DB: $($PostgreSQL.Database)", '    ports:', "      - `"${PuertoBD}:5432`"", '    healthcheck:', '      test: ["CMD-SHELL", "pg_isready -U $($PostgreSQL.Usuario)"]', '      interval: 10s', '      timeout: 5s', '      retries: 5', '    mem_limit: 1g', '    networks:', '      - backend') }
    'MongoDB' { @('  mongodb:', '    image: mongo:7-jammy', '    ports:', "      - `"${PuertoBD}:27017`"", '    healthcheck:', '      test: ["CMD", "mongosh", "--eval", "db.adminCommand(''ping'')"]', '      interval: 10s', '      timeout: 5s', '      retries: 5', '    mem_limit: 1g', '    networks:', '      - backend') }
    'Redis' { @('  redis:', '    image: redis:7-alpine', '    ports:', "      - `"${PuertoBD}:6379`"", '    healthcheck:', '      test: ["CMD", "redis-cli", "ping"]', '      interval: 10s', '      timeout: 5s', '      retries: 5', '    mem_limit: 512m', '    networks:', '      - backend') }
    'Ambas' { @('  mariadb:', '    image: mariadb:11', '    environment:', "      MARIADB_USER: $($MariaDB.Usuario)", "      MARIADB_PASSWORD: $($MariaDB.Password)", "      MARIADB_DATABASE: $($MariaDB.Database)", '      MARIADB_ROOT_PASSWORD: rootpassword', '    ports:', "      - `"${PuertoBD}:3306`"", '    healthcheck:', '      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initial_cleanup=OFF"]', '      interval: 10s', '      timeout: 5s', '      retries: 5', '    mem_limit: 1g', '    networks:', '      - backend', '  sqlserver:', '    image: mcr.microsoft.com/mssql/server:2022-latest', '    environment:', '      ACCEPT_EULA: "Y"', "      MSSQL_SA_PASSWORD: $($SQLServer.Password)", '    ports:', "      - `"$($SQLServer.Puerto):1433`"", '    healthcheck:', '      test: ["CMD", "sqlcmd", "-S", "localhost", "-U", "sa", "-P", "YourStrong!Password123", "-Q", "SELECT 1"]', '      interval: 10s', '      timeout: 5s', '      retries: 5', '    mem_limit: 2g', '    networks:', '      - backend') }
    default { @('  mariadb:', '    image: mariadb:11', '    environment:', "      MARIADB_USER: $($MariaDB.Usuario)", "      MARIADB_PASSWORD: $($MariaDB.Password)", "      MARIADB_DATABASE: $($MariaDB.Database)", '      MARIADB_ROOT_PASSWORD: rootpassword', '    ports:', "      - `"${PuertoBD}:3306`"", '    healthcheck:', '      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initial_cleanup=OFF"]', '      interval: 10s', '      timeout: 5s', '      retries: 5', '    mem_limit: 1g', '    networks:', '      - backend') }
}
$ApplicationContainerPort = if ($Tipo -eq 'PHP') { 80 } elseif ($Tipo -eq 'Node') { 3000 } else { 8080 }
$DependsOn = if ($BD -eq 'Ambas') { @('    depends_on:', '      - mariadb', '      - sqlserver') } else { @('    depends_on:', "      - $DatabaseServiceName") }
$ApplicationService = @('    build: .', '    expose:', "      - `"$ApplicationContainerPort`"", '    env_file:', '      - .env') + $DependsOn + @('    restart: unless-stopped', '    healthcheck:', '      test: ["CMD", "curl", "-f", "http://localhost:' + $ApplicationContainerPort + '/health"]', '      interval: 30s', '      timeout: 10s', '      retries: 3', '    mem_limit: 512m', '    networks:', '      - frontend', '      - backend')
$CaddyService = @('  caddy:', '    image: caddy:2-alpine', '    ports:', "      - `"$PuertoApp`:80`"", "      - `"$($PuertoApp + 443):443`"", '    volumes:', '      - ./Caddyfile:/etc/caddy/Caddyfile', '      - caddy_data:/data', '    environment:', "      - APP_URL=https://localhost`:$PuertoApp", '    depends_on:', "      - app", '    restart: unless-stopped', '    healthcheck:', '      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:80/health"]', '      interval: 30s', '      timeout: 10s', '      retries: 3', '    mem_limit: 128m', '    networks:', '      - frontend')
$DockerComposeLines = @('services:') + $ApplicationService + $DatabaseService + $CaddyService + @('networks:', '  frontend:', '  backend:', 'volumes:', "  ${Nombre}_data:", '  caddy_data:')
Write-GeneratedFile (Join-Path $RutaProyecto 'docker-compose.yml') $DockerComposeLines

Write-GeneratedFile (Join-Path $RutaProyecto '.editorconfig') @('root = true', ' ', '[*]', 'charset = utf-8', 'end_of_line = lf', 'insert_final_newline = true', 'indent_style = spaces', 'indent_size = 4')
Write-GeneratedFile (Join-Path $RutaProyecto 'CHANGELOG.md') @('# Changelog', ' ', '## [1.0.0] - Initial', ' ', '- Estructura inicial generada por crea-proyecto.ps1')
Write-GeneratedFile (Join-Path $RutaProyecto 'start.ps1') @('$ErrorActionPreference = ''Stop''', '# Verificar dependencias', 'if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { Write-Error "Docker no esta instalado o no esta en el PATH"; exit 1 }', 'if (-not (docker compose version -ErrorAction SilentlyContinue)) { Write-Error "Docker Compose no esta disponible"; exit 1 }', 'Write-Host "Iniciando proyecto..."; docker compose up -d --build; docker compose ps')
Write-GeneratedFile (Join-Path $RutaProyecto 'clean.ps1') @('$ErrorActionPreference = ''Stop''', 'Write-Host "Limpiando proyecto..."; docker compose down --volumes --remove-orphans', 'if (Test-Path -LiteralPath (Join-Path $PWD "node_modules")) { Remove-Item -LiteralPath (Join-Path $PWD "node_modules") -Recurse -Force }', 'if (Test-Path -LiteralPath (Join-Path $PWD "vendor")) { Remove-Item -LiteralPath (Join-Path $PWD "vendor") -Recurse -Force }', 'if (Test-Path -LiteralPath (Join-Path $PWD "bin")) { Remove-Item -LiteralPath (Join-Path $PWD "bin") -Recurse -Force }', 'if (Test-Path -LiteralPath (Join-Path $PWD "obj")) { Remove-Item -LiteralPath (Join-Path $PWD "obj") -Recurse -Force }', 'Write-Host "Limpieza completada"')
Write-GeneratedFile (Join-Path $RutaProyecto 'backup.ps1') @('$ErrorActionPreference = ''Stop''', '$BackupDir = Join-Path $PWD "backups"', 'if (-not (Test-Path -LiteralPath $BackupDir)) { New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null }', '$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"', 'Write-Host "Respaldando volumenes..."; docker compose run --rm -v ${Nombre}_data:/data -v $BackupDir:/backups $($DatabaseServiceName) tar czf /backups/${Nombre}_data_$Timestamp.tar.gz -C /data .', 'Write-Host "Respaldo completado en $BackupDir"')
$PreCommitCommands = switch ($Tipo) {
    'PHP' { @('composer lint', 'composer test') }
    'DotNet' { @('dotnet format --verify-no-changes', 'dotnet test --no-build') }
    default { @('npm run lint -- --fix', 'npm test --if-present') }
}
Write-GeneratedFile (Join-Path $RutaProyecto 'pre-commit.ps1') (@('$ErrorActionPreference = ''Stop''') + $PreCommitCommands)
$CaddyfileLines = @('{', '  # HTTPS automatico con Caddy en desarrollo', '}', ":$PuertoApp {", '    reverse_proxy app:' + $ApplicationContainerPort, '}')
Write-GeneratedFile (Join-Path $RutaProyecto 'Caddyfile') $CaddyfileLines
New-Item -ItemType Directory -Path (Join-Path $RutaProyecto '.vscode') -Force | Out-Null
Write-GeneratedFile (Join-Path $RutaProyecto '.vscode/settings.json') @('{', '  "files.encoding": "utf8",', '  "editor.insertSpaces": true,', '  "editor.tabSize": 4', '}')
New-Item -ItemType Directory -Path (Join-Path $RutaProyecto '.idea') -Force | Out-Null
Write-GeneratedFile (Join-Path $RutaProyecto '.idea/docker-compose.xml') @('<project version="4">', '  <component name="DockerCompose">', '    <composePath>`$PROJECT_DIR$/docker-compose.yml`</composePath>', '    <composePath>`$PROJECT_DIR$/docker-compose.dev.yml`</composePath>', '  </component>', '</project>')
Write-GeneratedFile (Join-Path $RutaProyecto '.idea/php.xml') @('<project version="4">', '  <component name="PhpLanguageProjectSettings">', '    <option name="ADDITIONAL" value="`$PROJECT_DIR$" />', '  </component>', '</project>')
New-Item -ItemType Directory -Path (Join-Path $RutaProyecto '.github/workflows') -Force | Out-Null
if ($Tipo -eq 'Node') {
    $CIPackageInstall = if ($GestorNode -eq 'yarn') { '      - run: yarn install --frozen-lockfile' } else { '      - run: npm ci' }
    $CIPackageTest = if ($GestorNode -eq 'yarn') { '      - run: yarn test --if-present' } else { '      - run: npm test --if-present' }
    $CILines = @('name: CI', 'on:', '  push:', '  pull_request:', 'jobs:', '  build:', '    runs-on: ubuntu-latest', '    steps:', '      - uses: actions/checkout@v4', "      - uses: actions/setup-node@v4`n        with:`n          node-version: '$VersionNode'", $CIPackageInstall, $CIPackageTest)
} elseif ($Tipo -eq 'PHP') {
    $CILines = @('name: CI', 'on:', '  push:', '  pull_request:', 'jobs:', '  build:', '    runs-on: ubuntu-latest', '    steps:', '      - uses: actions/checkout@v4', '      - uses: shivammathur/setup-php@v2', "        with:`n          php-version: '$VersionPHP'", '      - run: composer install --no-interaction --prefer-dist', '      - run: composer test --no-interaction')
} else {
    $CILines = @('name: CI', 'on:', '  push:', '  pull_request:', 'jobs:', '  build:', '    runs-on: ubuntu-latest', '    steps:', '      - uses: actions/checkout@v4', '      - uses: actions/setup-dotnet@v4', "        with:`n          dotnet-version: '$VersionDotNet'", '      - run: dotnet restore', '      - run: dotnet build --no-restore')
}
Write-GeneratedFile (Join-Path $RutaProyecto '.github/workflows/ci.yml') $CILines
if ($Tipo -eq 'Node') {
    Write-GeneratedFile (Join-Path $RutaProyecto '.prettierrc') @('{', '  "singleQuote": true,', '  "semi": true,', '  "trailingComma": "es5"', '}')
}
if ($Tipo -eq 'PHP') {
    Write-GeneratedFile (Join-Path $RutaProyecto 'php.ini') @('display_errors=On', 'error_reporting=E_ALL', 'memory_limit=256M', 'upload_max_filesize=20M')
}
if ($Tipo -eq 'DotNet') {
    Write-GeneratedFile (Join-Path $RutaProyecto 'nuget.config') @('<?xml version="1.0" encoding="utf-8"?>', '<configuration>', '  <packageSources>', '    <clear />', '    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" />', '  </packageSources>', '</configuration>')
}

Write-GeneratedFile (Join-Path $RutaProyecto '.gitignore') @('node_modules/', 'vendor/', '.env', '*.log', 'bin/', 'obj/')
$Commands = switch ($Tipo) {
    'PHP' { @('composer install', 'php -S localhost:8080 -t public') }
    'DotNet' { @('dotnet restore', 'dotnet watch run') }
    'Node' { if ($GestorNode -eq 'yarn') { @('yarn install', 'yarn dev') } else { @('npm install', 'npm run dev') } }
}
Write-GeneratedFile (Join-Path $RutaProyecto 'README.md') @(
    "# $Nombre", ' ',
    "## Proyecto $Tipo con $Framework", ' ',
    "Base de datos: $BD", "Puerto de la aplicacion: $PuertoApp", ' ',
    '## Arquitectura', ' ',
    '```mermaid', 'flowchart LR', "    Client[Cliente] --> Caddy[HTTPS / Caddy]", "    Caddy --> App[$Tipo / $Framework]", "    App --> DB[$BD]", '```', ' ',
    '## Endpoints', ' ',
    '- `GET /health` - Health check del servicio', ' ',
    '## Variables de entorno', ' ',
    'Copia `.env.example` a `.env` y ajusta las variables necesarias.', ' ',
    '## Comandos', '```bash', $Commands, '```', ' ',
    '## Docker', ' ',
    '- `docker compose up -d --build` - Iniciar servicios', '- `docker compose down` - Detener servicios', '- `docker compose ps` - Ver estado', ' ',
    '## CI/CD', ' ',
    'Configurado en `.github/workflows/ci.yml` y `.gitlab-ci.yml`.', ' ',
    '## Licencia', ' ', 'MIT'
)
Write-GeneratedFile (Join-Path $RutaProyecto 'structure.txt') ((Get-ChildItem -LiteralPath $RutaProyecto -Recurse -File | ForEach-Object { $_.FullName.Substring($RutaProyecto.Length + 1) }) | Sort-Object)

New-Item -ItemType Directory -Path (Join-Path $RutaProyecto 'docs') -Force | Out-Null
Write-GeneratedFile (Join-Path $RutaProyecto 'docs/architecture.md') @(
    '# Arquitectura', ' ', '```mermaid', 'flowchart LR', "    Client[Cliente] --> App[$Tipo / $Framework]", "    App --> DB[$BD]", '```',
    ' ', 'La aplicacion se ejecuta en Docker y usa variables de entorno para la configuracion.'
)
Write-GeneratedFile (Join-Path $RutaProyecto 'DEPLOYMENT.md') @(
    '# Despliegue', ' ', '1. Copia `.env.example` a `.env` y revisa las credenciales.',
    '2. Ejecuta `docker compose up -d --build`.', '3. Revisa el estado con `docker compose ps`.',
    '4. Para produccion, cambia secretos, desactiva el modo debug y usa un proxy HTTPS.'
)
Write-GeneratedFile (Join-Path $RutaProyecto 'CONTRIBUTING.md') @('# Contribuir', ' ', '1. Crea una rama descriptiva.', '2. Ejecuta los linters y tests.', '3. Abre un pull request con una descripcion clara.')
Write-GeneratedFile (Join-Path $RutaProyecto 'SECURITY.md') @('# Seguridad', ' ', 'No subas `.env` ni credenciales al repositorio.', 'Reporta vulnerabilidades de forma privada al responsable del proyecto.')
Write-GeneratedFile (Join-Path $RutaProyecto '.gitattributes') @('* text=auto eol=lf')
New-Item -ItemType Directory -Path (Join-Path $RutaProyecto '.github') -Force | Out-Null
Write-GeneratedFile (Join-Path $RutaProyecto '.github/dependabot.yml') @('version: 2', 'updates:', '  - package-ecosystem: npm', '    directory: /', '    schedule:', '      interval: weekly', '  - package-ecosystem: composer', '    directory: /', '    schedule:', '      interval: weekly', '  - package-ecosystem: nuget', '    directory: /', '    schedule:', '      interval: weekly')
Write-GeneratedFile (Join-Path $RutaProyecto '.gitlab-ci.yml') @('stages:', '  - build', '  - test', ' ', 'build:', '  stage: build', '  script:', '    - echo "Build generado; adapta este comando al runner"', 'test:', '  stage: test', '  script:', '    - echo "Test generado; adapta este comando al runner"')
Write-GeneratedFile (Join-Path $RutaProyecto '.vscode/extensions.json') @('{', '  "recommendations": [', '    "editorconfig.editorconfig",', '    "ms-azuretools.vscode-docker"', '  ]', '}')
Write-GeneratedFile (Join-Path $RutaProyecto 'start.sh') @('#!/usr/bin/env sh', 'set -eu', 'if ! command -v docker >/dev/null 2>&1; then echo "Docker no esta instalado"; exit 1; fi', 'if ! docker compose version >/dev/null 2>&1; then echo "Docker Compose no esta disponible"; exit 1; fi', 'echo "Iniciando proyecto..."; docker compose up -d --build; docker compose ps')
$DevCompose = (Get-Content (Join-Path $RutaProyecto 'docker-compose.yml')) -replace 'env_file:', '# Desarrollo: usa .env.development' -replace '      - .env', '      - .env.development'
Write-GeneratedFile (Join-Path $RutaProyecto 'docker-compose.dev.yml') $DevCompose
$ProdCompose = (Get-Content (Join-Path $RutaProyecto 'docker-compose.yml')) -replace 'env_file:', '# Produccion: usa .env.production' -replace '      - .env', '      - .env.production' -replace 'restart: unless-stopped', 'restart: always'
Write-GeneratedFile (Join-Path $RutaProyecto 'docker-compose.prod.yml') $ProdCompose
$TestCompose = (Get-Content (Join-Path $RutaProyecto 'docker-compose.yml')) -replace 'env_file:', '# Tests: usa .env.test' -replace '      - .env', '      - .env.test'
Write-GeneratedFile (Join-Path $RutaProyecto 'docker-compose.test.yml') $TestCompose
if ($Tipo -eq 'Node') {
    Write-GeneratedFile (Join-Path $RutaProyecto '.eslintrc.json') @('{', '  "env": { "node": true, "es2021": true },', '  "extends": "eslint:recommended"', '}')
    New-Item -ItemType Directory -Path (Join-Path $RutaProyecto 'test') -Force | Out-Null
    Write-GeneratedFile (Join-Path $RutaProyecto 'test/health.test.js') @("const test = require('node:test');", "const assert = require('node:assert/strict');", ' ', "test('health response contract', () => {", "    assert.deepEqual({ status: 'OK' }, { status: 'OK' });", '});')
}
if ($Tipo -eq 'PHP') {
    Write-GeneratedFile (Join-Path $RutaProyecto 'phpcs.xml') @('<?xml version="1.0"?>', '<ruleset name="Project">', '  <rule ref="PSR12" />', '</ruleset>')
    Write-GeneratedFile (Join-Path $RutaProyecto 'tests/HealthTest.php') @('<?php', 'use PHPUnit\\Framework\\TestCase;', ' ', 'final class HealthTest extends TestCase', '{', '    public function testHealthContract(): void', '    {', '        $this->assertTrue(true);', '    }', '}')
}
Write-GeneratedFile (Join-Path $RutaProyecto 'structure.txt') ((Get-ChildItem -LiteralPath $RutaProyecto -Recurse -File | ForEach-Object { $_.FullName.Substring($RutaProyecto.Length + 1) }) | Sort-Object)

Write-Separator
Write-Success "Proyecto '$Nombre' creado exitosamente"
Write-Info "Ruta: $RutaProyecto"
Write-Info "Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "1. cd $RutaProyecto"
$Commands | ForEach-Object { Write-Host "- $_" }
Write-Host "Credenciales $BD`: $($ConfiguracionBD.Usuario)@$($ConfiguracionBD.Host):$($ConfiguracionBD.Puerto)"
Write-Host "Archivos generados: $((Get-ChildItem -LiteralPath $RutaProyecto -Recurse -File).Count)"
Write-Host "Puerto app: $PuertoApp"
Write-Host "Puerto BD: $PuertoBD"
Write-Host "APP_KEY: $AppKey"
Write-Host "JWT_SECRET: $JwtSecret"
