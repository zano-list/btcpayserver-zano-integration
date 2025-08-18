# Zano Wallet Creation for BTCPayServer

This directory contains scripts to create Zano wallets for use with BTCPayServer.

## Prerequisites

1. **Docker must be running** - The scripts use Docker containers to create wallets
2. **BTCPayServer services must be running** - Zano daemon should be accessible
3. **Directory structure** - `D:\Crypto\ZanoWallets` will be created automatically

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
2. **Directory Creation**: Creates `D:\Crypto\ZanoWallets\private\` if it doesn't exist
3. **Directory Structure**: Prepares the folder structure for wallet files
4. **Instructions**: Provides clear next steps for wallet creation
5. **Integration**: BTCPayServer will detect the wallet directory automatically

**Note**: The current scripts create the directory structure only. You'll need to:
- Download Zano wallet tools from the official releases
- Create the wallet file manually using those tools
- Place the wallet file in the created directory

## Wallet File Details

- **Location**: `D:\Crypto\ZanoWallets\private\fresh-wallet`
- **Format**: Zano wallet file (encrypted with your password)
- **Access**: Requires the password you set during creation
- **Backup**: Copy this file to a secure location

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
