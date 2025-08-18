# BTCPayServer with Zano Plugin Deployment Script for Windows
# This script deploys the complete BTCPayServer stack with Zano cryptocurrency support

param(
    [switch]$SkipBuild,
    [switch]$SkipSSL
)

Write-Host "🚀 Starting BTCPayServer with Zano Plugin deployment..." -ForegroundColor Green

# Check if Docker Desktop is running
try {
    docker version | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Check if Docker Compose is available
try {
    docker-compose --version | Out-Null
    Write-Host "✅ Docker Compose is available" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose is not available. Please install Docker Compose first." -ForegroundColor Red
    exit 1
}

# Create SSL directory if it doesn't exist
if (!(Test-Path "ssl")) {
    Write-Host "📁 Creating SSL directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "ssl" -Force | Out-Null
}

# Generate self-signed SSL certificate if it doesn't exist and SSL generation is not skipped
if ((!(Test-Path "ssl\cert.pem") -or !(Test-Path "ssl\key.pem")) -and !$SkipSSL) {
    Write-Host "🔐 Generating self-signed SSL certificate..." -ForegroundColor Yellow
    
    # Check if OpenSSL is available
    try {
        openssl version | Out-Null
        openssl req -x509 -newkey rsa:4096 -keyout "ssl\key.pem" -out "ssl\cert.pem" -days 365 -nodes -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
        Write-Host "✅ SSL certificate generated successfully" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  OpenSSL not found. Please install OpenSSL or manually create SSL certificates." -ForegroundColor Yellow
        Write-Host "   You can download OpenSSL from: https://slproweb.com/products/Win32OpenSSL.html" -ForegroundColor Cyan
        Write-Host "   Or skip SSL generation with: .\deploy.ps1 -SkipSSL" -ForegroundColor Cyan
    }
}

# Create environment file if it doesn't exist
if (!(Test-Path ".env")) {
    Write-Host "📝 Creating environment file..." -ForegroundColor Yellow
    @"
# BTCPayServer Configuration
BTCPAY_NETWORK=regtest
BTCPAY_CHAINS=btc,zano
BTCPAY_HTTPSREDIRECT=false
BTCPAY_HOST=localhost

# SSH Configuration
BTCPAY_SSHSERVICEPASSWORD=your_secure_password_here
BTCPAY_SSHSERVICEUSER=btcpay

# Zano Configuration
BTCPAY_ZANO_DAEMON_URI=http://zano-daemon:11211
BTCPAY_ZANO_WALLET_DAEMON_URI=http://zano-wallet-rpc:11233
BTCPAY_ZANO_DAEMON_USERNAME=your_username
BTCPAY_ZANO_DAEMON_PASSWORD=your_password

# Database Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=btcpayserver
NBXPLORER_PASSWORD=nbxplorer

# Bitcoin Configuration
BITCOIN_RPC_USER=rpcuser
BITCOIN_RPC_PASSWORD=rpcpass
"@ | Out-File -FilePath ".env" -Encoding UTF8
    
    Write-Host "Environment file created. Please edit .env with your actual values." -ForegroundColor Green
}

# Build and start the services
if (!$SkipBuild) {
    Write-Host "🔨 Building Docker images..." -ForegroundColor Yellow
    docker-compose build --no-cache
} else {
    Write-Host "⏭️  Skipping build step..." -ForegroundColor Yellow
}

Write-Host "🚀 Starting services..." -ForegroundColor Yellow
docker-compose up -d

# Wait for services to be ready
Write-Host "⏳ Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Check service status
Write-Host "📊 Checking service status..." -ForegroundColor Yellow
docker-compose ps

# Show logs
Write-Host "📋 Recent logs:" -ForegroundColor Yellow
docker-compose logs --tail=20

Write-Host ""
Write-Host "🎉 Deployment completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📱 Access your BTCPayServer at:" -ForegroundColor Cyan
Write-Host "   HTTP:  http://localhost" -ForegroundColor White
Write-Host "   HTTPS: https://localhost" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Useful commands:" -ForegroundColor Cyan
Write-Host "   View logs: docker-compose logs -f" -ForegroundColor White
Write-Host "   Stop services: docker-compose down" -ForegroundColor White
Write-Host "   Restart services: docker-compose restart" -ForegroundColor White
Write-Host "   Update services: docker-compose pull && docker-compose up -d" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  IMPORTANT:" -ForegroundColor Yellow
Write-Host "   1. Edit .env file with your actual passwords and usernames" -ForegroundColor White
Write-Host "   2. Replace SSL certificates with real ones for production" -ForegroundColor White
Write-Host "   3. Configure your firewall to allow ports 80, 443, and 23000" -ForegroundColor White
Write-Host "   4. The Zano plugin will be automatically loaded" -ForegroundColor White
Write-Host ""
Write-Host "🔍 To check if the Zano plugin is loaded:" -ForegroundColor Cyan
Write-Host "   docker-compose exec btcpayserver ls -la /app/plugins/" -ForegroundColor White
Write-Host ""
Write-Host "📚 For more information, visit: https://docs.btcpayserver.org/" -ForegroundColor Cyan
