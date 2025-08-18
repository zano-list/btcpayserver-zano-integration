# Zano Wallet Creation Script for BTCPayServer
# This script creates a new Zano wallet with user-provided password

param(
    [Parameter(Mandatory=$true)]
    [string]$WalletPassword,
    
    [string]$WalletPath = "D:\Crypto\ZanoWallets\private\fresh-wallet",
    [string]$DaemonAddress = "localhost:17787"
)

Write-Host "=== Zano Wallet Creator ===" -ForegroundColor Green
Write-Host ""

# Check if wallet already exists
if (Test-Path $WalletPath) {
    Write-Host "Wallet already exists at: $WalletPath" -ForegroundColor Yellow
    Write-Host "Skipping wallet creation." -ForegroundColor Yellow
    exit 0
}

# Create wallet directory
$WalletDir = Split-Path $WalletPath -Parent
if (!(Test-Path $WalletDir)) {
    Write-Host "Creating wallet directory: $WalletDir" -ForegroundColor Blue
    New-Item -ItemType Directory -Path $WalletDir -Force | Out-Null
}

Write-Host "Creating new Zano wallet..." -ForegroundColor Blue
Write-Host "Wallet path: $WalletPath" -ForegroundColor Cyan
Write-Host "Daemon address: $DaemonAddress" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
try {
    $null = docker ps
} catch {
    Write-Host "Error: Docker is not running or not accessible" -ForegroundColor Red
    exit 1
}

# Create wallet using Docker container
Write-Host "Creating wallet using Docker container..." -ForegroundColor Blue

$dockerCommand = "docker run --rm -v `"${WalletDir}:/home/ubuntu/.Zano/private`" -e WALLET_PASSWORD=`"$WalletPassword`" canardleteer/zano:master-zano-runner sh -c `"echo 'Creating Zano wallet...' && /usr/bin/simplewallet --generate-new-wallet=/home/ubuntu/.Zano/private/fresh-wallet --daemon-address=$DaemonAddress --password=`$WALLET_PASSWORD && echo 'Wallet created successfully!' && echo 'Wallet file: /home/ubuntu/.Zano/private/fresh-wallet' && echo 'Password: `$WALLET_PASSWORD`""

Write-Host "Executing Docker command..." -ForegroundColor Blue
Write-Host ""

try {
    Invoke-Expression $dockerCommand
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "=== Wallet Created Successfully! ===" -ForegroundColor Green
        Write-Host "Wallet location: $WalletPath" -ForegroundColor Cyan
        Write-Host "Password: $WalletPassword" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "IMPORTANT: Save this password securely!" -ForegroundColor Red
        Write-Host "You will need it to access your wallet." -ForegroundColor Red
    } else {
        Write-Host "Failed to create wallet. Exit code: $LASTEXITCODE" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error executing Docker command: $_" -ForegroundColor Red
    exit 1
}
