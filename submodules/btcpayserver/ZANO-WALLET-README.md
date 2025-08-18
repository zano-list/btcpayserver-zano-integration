# Zano Wallet Creation for BTCPayServer

This directory contains scripts to create Zano wallets for use with BTCPayServer.

## Prerequisites

1. **Docker must be running** - The Zano services run in Docker containers
2. **BTCPayServer services must be running** - Zano daemon and wallet RPC should be accessible
3. **Docker volumes** - `zano_data` and `zano_wallet_data` volumes are managed automatically

## Available Scripts

### 1. PowerShell Script (Recommended)
**File**: `create-zano-wallet-simple.ps1`

**Usage**:
```powershell
# Run with password parameter
.\create-zano-wallet-simple.ps1 -WalletPassword "YourSecurePassword123!"
```

**Features**:
- Creates wallet directory structure
- Parameter validation
- Clear next steps instructions
- No Docker dependencies

### 2. Advanced PowerShell Script
**File**: `create-zano-wallet-download.ps1`

**Usage**:
```powershell
# Run with password parameter
.\create-zano-wallet-download.ps1 -WalletPassword "YourSecurePassword123!"
```

**Features**:
- Attempts to download Zano wallet tools
- Creates wallet directory structure
- More complex but may have compatibility issues

### 3. Batch File
**File**: `create-zano-wallet.bat`

**Usage**:
```cmd
# Double-click the file or run from command prompt
create-zano-wallet.bat
```

**Features**:
- Interactive password input
- Simple error handling
- Windows batch compatibility

## How It Works

1. **Script Execution**: The script prompts for a wallet password
2. **Container Setup**: Zano services run in Docker containers with managed volumes
3. **Data Storage**: Blockchain and wallet data stored in Docker volumes
4. **Automatic Integration**: BTCPayServer automatically detects Zano services
5. **No Host Dependencies**: All data stays within the Docker environment

**Note**: The current setup uses Docker containers and volumes:
- Zano daemon data stored in `zano_data` volume
- Wallet data stored in `zano_wallet_data` volume
- No local host directory dependencies

## Wallet File Details

- **Location**: Stored in Docker volume `zano_wallet_data`
- **Format**: Zano wallet file (encrypted with your password)
- **Access**: Requires the password you set during creation
- **Backup**: Docker volumes can be backed up using Docker commands

## Security Notes

⚠️ **IMPORTANT**: 
- Save your wallet password securely
- The password cannot be recovered if lost
- Backup your wallet file
- Never share your wallet password

## Troubleshooting

### Common Issues

1. **Docker not running**
   - Start Docker Desktop
   - Ensure Docker is accessible from command line

2. **Permission denied**
   - Run as Administrator
   - Check folder permissions on `D:\Crypto\ZanoWallets`

3. **Wallet creation fails**
   - Ensure Zano daemon is running
   - Check Docker container logs
   - Verify network connectivity

### Verification

After wallet creation, verify:
1. File exists: `D:\Crypto\ZanoWallets\private\fresh-wallet`
2. File size > 0 bytes
3. Can access wallet with password

## Integration with BTCPayServer

Once the wallet is created:
1. BTCPayServer will automatically detect the wallet
2. Wallet RPC service will use the wallet file
3. You can manage Zano payments through BTCPayServer interface

## Support

If you encounter issues:
1. Check Docker container logs
2. Verify all services are running
3. Ensure proper directory permissions
4. Check network connectivity between containers
