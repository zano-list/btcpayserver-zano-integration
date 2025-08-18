# BTCPayServer with Zano Plugin - Docker Deployment

This repository contains a complete Docker setup for deploying BTCPayServer with Zano cryptocurrency support. The setup includes all necessary services for a production-ready BTCPayServer instance.

## 🚀 Features

- **BTCPayServer** with integrated Zano plugin
- **Zano Daemon** for blockchain synchronization
- **Zano Wallet RPC** for transaction management
- **Bitcoin Core** node for Bitcoin support
- **NBXplorer** for blockchain indexing
- **PostgreSQL** database
- **Nginx** reverse proxy with HTTPS support
- **Automatic SSL certificate generation**
- **Health monitoring and logging**

## 📋 Prerequisites

- Docker Desktop (Windows/Mac) or Docker Engine (Linux)
- Docker Compose
- At least 4GB RAM available for Docker
- At least 50GB free disk space
- OpenSSL (for SSL certificate generation)

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nginx (80/443)│───▶│  BTCPayServer   │───▶│   PostgreSQL    │
│   (HTTPS)       │    │   (Port 23000)  │    │   Database      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   Zano Daemon   │
                       │   (Port 11211)  │
                       └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │  Zano Wallet    │
                       │   (Port 11233)  │
                       └─────────────────┘
```

## 🚀 Quick Start

### Option 1: Automated Deployment (Recommended)

#### Linux/macOS:
```bash
chmod +x deploy.sh
./deploy.sh
```

#### Windows PowerShell:
```powershell
.\deploy.ps1
```

### Option 2: Manual Deployment

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd ZanoGitHub
   ```

2. **Create SSL certificates:**
   ```bash
   mkdir ssl
   openssl req -x509 -newkey rsa:4096 -keyout ssl/key.pem -out ssl/cert.pem -days 365 -nodes -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
   ```

3. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your actual values
   ```

4. **Build and start services:**
   ```bash
   docker-compose up -d --build
   ```

## ⚙️ Configuration

### Environment Variables

Edit the `.env` file or set these environment variables:

```bash
# BTCPayServer Configuration
BTCPAY_NETWORK=regtest          # mainnet, testnet, or regtest
BTCPAY_CHAINS=btc,zano         # Supported cryptocurrencies
BTCPAY_HTTPSREDIRECT=false     # Force HTTPS (false for development)

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
```

### Port Configuration

- **80**: HTTP (redirects to HTTPS)
- **443**: HTTPS (main application)
- **23000**: BTCPayServer SSH service
- **11211**: Zano daemon RPC
- **11233**: Zano wallet RPC
- **43782**: Bitcoin Core RPC
- **39373**: PostgreSQL
- **32838**: NBXplorer

## 🔧 Management Commands

### View Service Status
```bash
docker-compose ps
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f btcpayserver
docker-compose logs -f zano-daemon
docker-compose logs -f zano-wallet-rpc
```

### Stop Services
```bash
docker-compose down
```

### Restart Services
```bash
docker-compose restart
```

### Update Services
```bash
docker-compose pull
docker-compose up -d
```

### Access BTCPayServer Container
```bash
docker-compose exec btcpayserver bash
```

### Check Zano Plugin
```bash
docker-compose exec btcpayserver ls -la /app/plugins/
```

## 🔐 SSL Certificates

### Self-Signed (Development)
The deployment script automatically generates self-signed certificates for development.

### Production SSL
For production, replace the SSL certificates:

1. **Obtain certificates** from Let's Encrypt or your CA
2. **Place certificates** in the `ssl/` directory:
   - `ssl/cert.pem` - Certificate file
   - `ssl/key.pem` - Private key file
3. **Restart services**:
   ```bash
   docker-compose restart nginx
   ```

## 🗄️ Data Persistence

All data is stored in Docker volumes:

- `btcpayserver_data`: BTCPayServer data and configuration
- `postgres_data`: Database files
- `bitcoin_data`: Bitcoin blockchain data
- `zano_daemon_data`: Zano blockchain data
- `zano_wallet_data`: Zano wallet files

### Backup
```bash
# Backup all data
docker run --rm -v btcpayserver_data:/data -v $(pwd):/backup alpine tar czf /backup/btcpayserver_backup.tar.gz -C /data .

# Restore data
docker run --rm -v btcpayserver_data:/data -v $(pwd):/backup alpine tar xzf /backup/btcpayserver_backup.tar.gz -C /data
```

## 🔍 Troubleshooting

### Common Issues

1. **Port conflicts**: Ensure ports 80, 443, 23000, 11211, 11233 are not in use
2. **Insufficient memory**: Increase Docker memory limit to at least 4GB
3. **SSL errors**: Check certificate files and permissions
4. **Plugin not loading**: Verify plugin files are in `/app/plugins/`
5. **Zano daemon not starting**: Check if the zanode/zano image is available

### Debug Mode
```bash
# Start with debug logging
docker-compose up -d
docker-compose logs -f btcpayserver

# Check plugin loading
docker-compose exec btcpayserver dotnet BTCPayServer.dll --help

# Check Zano daemon status
docker-compose exec zano-daemon zanod --help
```

### Reset Everything
```bash
# Stop and remove all containers, volumes, and images
docker-compose down -v --rmi all
docker system prune -a --volumes
```

## 📚 Additional Resources

- [BTCPayServer Documentation](https://docs.btcpayserver.org/)
- [Zano Documentation](https://docs.zano.org/)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

This setup is for educational and development purposes. For production use, ensure proper security measures, use real SSL certificates, and follow security best practices.

## 🆘 Support

If you encounter issues:

1. Check the logs: `docker-compose logs -f`
2. Verify configuration in `.env` file
3. Check Docker resource allocation
4. Open an issue with detailed error information

---

**Happy deploying! 🎉**
