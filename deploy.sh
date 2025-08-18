#!/bin/bash

# BTCPayServer with Zano Plugin Deployment Script
# This script deploys the complete BTCPayServer stack with Zano cryptocurrency support

set -e

echo "🚀 Starting BTCPayServer with Zano Plugin deployment..."

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create SSL directory if it doesn't exist
if [ ! -d "ssl" ]; then
    echo "📁 Creating SSL directory..."
    mkdir -p ssl
fi

# Generate self-signed SSL certificate if it doesn't exist
if [ ! -f "ssl/cert.pem" ] || [ ! -f "ssl/key.pem" ]; then
    echo "🔐 Generating self-signed SSL certificate..."
    openssl req -x509 -newkey rsa:4096 -keyout ssl/key.pem -out ssl/cert.pem -days 365 -nodes -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
    echo "✅ SSL certificate generated successfully"
fi

# Set proper permissions for SSL files
chmod 600 ssl/key.pem
chmod 644 ssl/cert.pem

# Create environment file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "📝 Creating environment file..."
    cat > .env << EOF
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
EOF
    echo "✅ Environment file created. Please edit .env with your actual values."
fi

# Build and start the services
echo "🔨 Building Docker images..."
docker-compose build --no-cache

echo "🚀 Starting services..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Check service status
echo "📊 Checking service status..."
docker-compose ps

# Show logs
echo "📋 Recent logs:"
docker-compose logs --tail=20

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📱 Access your BTCPayServer at:"
echo "   HTTP:  http://localhost"
echo "   HTTPS: https://localhost"
echo ""
echo "🔧 Useful commands:"
echo "   View logs: docker-compose logs -f"
echo "   Stop services: docker-compose down"
echo "   Restart services: docker-compose restart"
echo "   Update services: docker-compose pull && docker-compose up -d"
echo ""
echo "⚠️  IMPORTANT:"
echo "   1. Edit .env file with your actual passwords and usernames"
echo "   2. Replace SSL certificates with real ones for production"
echo "   3. Configure your firewall to allow ports 80, 443, and 23000"
echo "   4. The Zano plugin will be automatically loaded"
echo ""
echo "🔍 To check if the Zano plugin is loaded:"
echo "   docker-compose exec btcpayserver ls -la /app/plugins/"
echo ""
echo "📚 For more information, visit: https://docs.btcpayserver.org/"
