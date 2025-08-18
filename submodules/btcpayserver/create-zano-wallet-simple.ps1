# Simple Zano Wallet Directory Creator
# This script creates the wallet directory structure for Zano

param(
    [Parameter(Mandatory=$true)]
    [string]$WalletPassword
)

Write-Host "=== Zano Wallet Directory Creator ===" -ForegroundColor Green
Write-Host ""

# Check if wallet already exists
$WalletPath = "D:\Crypto\ZanoWallets\private\fresh-wallet"
if (Test-Path $WalletPath) {
    Write-Host "Wallet already exists at: $WalletPath" -ForegroundColor Yellow
    Write-Host "Skipping directory creation." -ForegroundColor Yellow
    exit 0
}

# Create wallet directory
$WalletDir = "D:\Crypto\ZanoWallets\private"
if (!(Test-Path $WalletDir)) {
    Write-Host "Creating wallet directory: $WalletDir" -ForegroundColor Blue
    New-Item -ItemType Directory -Path $WalletDir -Force | Out-Null
    Write-Host "Wallet directory created successfully!" -ForegroundColor Green
} else {
    Write-Host "Wallet directory already exists: $WalletDir" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Wallet Directory Ready! ===" -ForegroundColor Green
Write-Host "Wallet directory: $WalletDir" -ForegroundColor Cyan
Write-Host "Password: $WalletPassword" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: Save this password securely!" -ForegroundColor Red
Write-Host "You will need it to access your wallet." -ForegroundColor Red
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Blue
Write-Host "1. Download Zano wallet tools from: https://github.com/zano-project/zano/releases" -ForegroundColor White
Write-Host "2. Use the wallet tools to create your wallet file" -ForegroundColor White
Write-Host "3. Place the wallet file in: $WalletDir" -ForegroundColor White
Write-Host "4. BTCPayServer will automatically detect the wallet" -ForegroundColor White
Write-Host ""
Write-Host "The wallet directory is now ready for your wallet file!" -ForegroundColor Green
