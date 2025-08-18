# Zano Wallet Creator with Download
# This script downloads Zano wallet tools and creates a new wallet

param(
    [Parameter(Mandatory=$true)]
    [string]$WalletPassword
)

Write-Host "=== Zano Wallet Creator ===" -ForegroundColor Green
Write-Host ""

# Check if wallet already exists
$WalletPath = "D:\Crypto\ZanoWallets\private\fresh-wallet"
if (Test-Path $WalletPath) {
    Write-Host "Wallet already exists at: $WalletPath" -ForegroundColor Yellow
    Write-Host "Skipping wallet creation." -ForegroundColor Yellow
    exit 0
}

# Create wallet directory
$WalletDir = "D:\Crypto\ZanoWallets\private"
if (!(Test-Path $WalletDir)) {
    Write-Host "Creating wallet directory: $WalletDir" -ForegroundColor Blue
    New-Item -ItemType Directory -Path $WalletDir -Force | Out-Null
}

Write-Host "Creating new Zano wallet..." -ForegroundColor Blue
Write-Host "Wallet path: $WalletPath" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
try {
    $null = docker ps
} catch {
    Write-Host "Error: Docker is not running or not accessible" -ForegroundColor Red
    exit 1
}

# Create wallet using Docker container with Alpine and download Zano tools
Write-Host "Creating wallet using Docker container..." -ForegroundColor Blue

$dockerCommand = @"
docker run --rm -v "${WalletDir}:/wallet" alpine:latest sh -c "
    echo 'Installing required packages...'
    apk add --no-cache wget unzip
    
    echo 'Downloading Zano wallet tools...'
    cd /tmp
    
    # Download Zano wallet tools (you may need to adjust the URL)
    wget -O zano-tools.zip https://github.com/zano-project/zano/releases/latest/download/zano-tools-linux-x64.zip || echo 'Failed to download from GitHub, trying alternative...'
    
    if [ ! -f zano-tools.zip ]; then
        echo 'Creating a basic wallet structure manually...'
        mkdir -p /wallet
        echo 'Wallet directory created at /wallet'
        echo 'Note: You will need to manually create the wallet using Zano wallet tools'
        echo 'The wallet directory is ready at: $WalletDir'
        exit 0
    fi
    
    echo 'Extracting wallet tools...'
    unzip -o zano-tools.zip
    
    echo 'Creating wallet...'
    # Try to use the extracted tools to create wallet
    if [ -f './simplewallet' ]; then
        ./simplewallet --generate-new-wallet=/wallet/fresh-wallet --daemon-address=localhost:17787 --password='$WalletPassword'
        if [ \$? -eq 0 ]; then
            echo 'Wallet created successfully!'
            echo 'Wallet file: /wallet/fresh-wallet'
        else
            echo 'Failed to create wallet with tools'
            exit 1
        fi
    else
        echo 'Wallet tools not found, creating directory structure only'
        echo 'You will need to manually create the wallet'
    fi
"
"@

Write-Host "Executing Docker command..." -ForegroundColor Blue
Write-Host ""

try {
    Invoke-Expression $dockerCommand
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "=== Wallet Directory Created! ===" -ForegroundColor Green
        Write-Host "Wallet directory: $WalletDir" -ForegroundColor Cyan
        Write-Host "Password: $WalletPassword" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Note: The wallet directory has been created." -ForegroundColor Yellow
        Write-Host "You may need to manually create the wallet file using Zano wallet tools." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "IMPORTANT: Save this password securely!" -ForegroundColor Red
        Write-Host "You will need it to access your wallet." -ForegroundColor Red
    } else {
        Write-Host "Failed to create wallet directory. Exit code: $LASTEXITCODE" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error executing Docker command: $_" -ForegroundColor Red
    exit 1
}
