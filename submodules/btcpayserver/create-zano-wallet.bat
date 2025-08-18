@echo off
setlocal enabledelayedexpansion

echo ========================================
echo        Zano Wallet Creator
echo ========================================
echo.

REM Check if wallet already exists
if exist "D:\Crypto\ZanoWallets\private\fresh-wallet" (
    echo Wallet already exists!
    echo Location: D:\Crypto\ZanoWallets\private\fresh-wallet
    echo Skipping wallet creation.
    pause
    exit /b 0
)

REM Create wallet directory
if not exist "D:\Crypto\ZanoWallets\private" (
    echo Creating wallet directory...
    mkdir "D:\Crypto\ZanoWallets\private"
)

REM Get password from user
set /p "WALLET_PASSWORD=Enter wallet password: "
if "!WALLET_PASSWORD!"=="" (
    echo Error: Password cannot be empty
    pause
    exit /b 1
)

echo.
echo Creating new Zano wallet...
echo Wallet path: D:\Crypto\ZanoWallets\private\fresh-wallet
echo Daemon address: localhost:17787
echo.

REM Check if Docker is running
docker ps >nul 2>&1
if errorlevel 1 (
    echo Error: Docker is not running or not accessible
    pause
    exit /b 1
)

REM Create wallet using Docker
echo Creating wallet using Docker container...
docker run --rm ^
  -v "D:\Crypto\ZanoWallets\private:/home/ubuntu/.Zano/private" ^
  -e WALLET_PASSWORD="!WALLET_PASSWORD!" ^
  canardleteer/zano:master-zano-runner ^
  sh -c "echo 'Creating Zano wallet...' && /usr/bin/simplewallet --generate-new-wallet=/home/ubuntu/.Zano/private/fresh-wallet --daemon-address=localhost:17787 --password=!WALLET_PASSWORD! && echo 'Wallet created successfully!' && echo 'Wallet file: /home/ubuntu/.Zano/private/fresh-wallet' && echo 'Password: !WALLET_PASSWORD!'"

if errorlevel 1 (
    echo.
    echo Failed to create wallet!
    pause
    exit /b 1
)

echo.
echo ========================================
echo      Wallet Created Successfully!
echo ========================================
echo Wallet location: D:\Crypto\ZanoWallets\private\fresh-wallet
echo Password: !WALLET_PASSWORD!
echo.
echo IMPORTANT: Save this password securely!
echo You will need it to access your wallet.
echo.
pause
