# BTCPayServer with Zano Plugin - Docker Setup Validation (PowerShell)
# Fast validation script that checks file existence and basic setup

Write-Host "Validating Docker setup..." -ForegroundColor Cyan

# Initialize error counter
$errors = 0

Write-Host ""
Write-Host "Checking required commands..." -ForegroundColor Yellow

# Quick Docker check
try {
    $dockerVersion = docker --version 2>$null
    if ($dockerVersion) {
        Write-Host "OK - Docker is available" -ForegroundColor Green
    } else {
        Write-Host "ERROR - Docker is not available" -ForegroundColor Red
        $errors++
    }
} catch {
    Write-Host "ERROR - Docker is not available" -ForegroundColor Red
    $errors++
}

# Quick Docker Compose check
try {
    $composeVersion = docker-compose --version 2>$null
    if ($composeVersion) {
        Write-Host "OK - Docker Compose is available" -ForegroundColor Green
    } else {
        Write-Host "ERROR - Docker Compose is not available" -ForegroundColor Red
        $errors++
    }
} catch {
    Write-Host "ERROR - Docker Compose is not available" -ForegroundColor Red
    $errors++
}

Write-Host ""
Write-Host "Checking required files..." -ForegroundColor Yellow

# Check required files
$requiredFiles = @(
    "docker-compose.yml",
    "Dockerfile", 
    "nginx.conf",
    ".dockerignore",
    ".env.example",
    "Makefile",
    "deploy.sh",
    "deploy.ps1"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "OK - $file" -ForegroundColor Green
    } else {
        Write-Host "ERROR - $file (missing)" -ForegroundColor Red
        $errors++
    }
}

Write-Host ""
Write-Host "Checking required directories..." -ForegroundColor Yellow

# Check required directories
$requiredDirs = @(
    "Plugins",
    "Plugins/Zano", 
    "submodules",
    "submodules/btcpayserver"
)

foreach ($dir in $requiredDirs) {
    if (Test-Path $dir -PathType Container) {
        Write-Host "OK - $dir" -ForegroundColor Green
    } else {
        Write-Host "ERROR - $dir (missing)" -ForegroundColor Red
        $errors++
    }
}

Write-Host ""
Write-Host "Checking SSL configuration..." -ForegroundColor Yellow

# Check SSL certificates
if ((Test-Path "ssl") -and (Test-Path "ssl/cert.pem") -and (Test-Path "ssl/key.pem")) {
    Write-Host "OK - SSL certificates found" -ForegroundColor Green
} else {
    Write-Host "WARNING - SSL certificates not found (will be generated on first run)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Validation Summary:" -ForegroundColor Cyan

if ($errors -eq 0) {
    Write-Host "SUCCESS - All checks passed! Your Docker setup is ready." -ForegroundColor Green
    Write-Host ""
    Write-Host "To start your BTCPayServer stack:" -ForegroundColor Cyan
    Write-Host "   .\deploy.ps1              # Windows deployment" -ForegroundColor White
    Write-Host "   docker-compose up -d      # Start services" -ForegroundColor White
    Write-Host "   docker-compose logs -f    # View logs" -ForegroundColor White
    Write-Host ""
    Write-Host "For more commands:" -ForegroundColor Cyan
    Write-Host "   docker-compose ps         # Check status" -ForegroundColor White
    Write-Host "   docker-compose down       # Stop services" -ForegroundColor White
    Write-Host "   docker-compose restart    # Restart services" -ForegroundColor White
} else {
    Write-Host "ERROR - Found $errors error(s). Please fix them before proceeding." -ForegroundColor Red
}

Write-Host ""
Write-Host "Ready to deploy!" -ForegroundColor Green
