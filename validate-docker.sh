#!/bin/bash

# BTCPayServer with Zano Plugin - Docker Setup Validation
# This script validates that all required files and configurations are present

set -e

echo "🔍 Validating Docker setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "✅ $1"
        return 0
    else
        echo -e "${RED}❌ $1 (missing)${NC}"
        return 1
    fi
}

# Function to check if directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo -e "✅ $1"
        return 0
    else
        echo -e "${RED}❌ $1 (missing)${NC}"
        return 1
    fi
}

# Function to check if command exists
check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "✅ $1"
        return 0
    else
        echo -e "${RED}❌ $1 (not installed)${NC}"
        return 1
    fi
}

# Initialize error counter
errors=0

echo ""
echo "📋 Checking required commands..."
check_command docker || ((errors++))
check_command docker-compose || ((errors++))

echo ""
echo "📁 Checking required files..."
check_file docker-compose.yml || ((errors++))
check_file Dockerfile || ((errors++))
check_file nginx.conf || ((errors++))
check_file .dockerignore || ((errors++))
check_file .env.example || ((errors++))
check_file Makefile || ((errors++))
check_file deploy.sh || ((errors++))
check_file deploy.ps1 || ((errors++))

echo ""
echo "📁 Checking required directories..."
check_dir Plugins || ((errors++))
check_dir Plugins/Zano || ((errors++))
check_dir submodules || ((errors++))
check_dir submodules/btcpayserver || ((errors++))

echo ""
echo "🔧 Checking Docker Compose configuration..."

# Check if docker-compose.yml is valid
if docker-compose config > /dev/null 2>&1; then
    echo -e "✅ docker-compose.yml is valid"
else
    echo -e "${RED}❌ docker-compose.yml has syntax errors${NC}"
    ((errors++))
fi

# Check if required services are defined
required_services=("btcpay-postgres" "bitcoin" "zano-daemon" "zano-wallet-rpc" "nbxplorer" "btcpayserver" "nginx")
for service in "${required_services[@]}"; do
    if docker-compose config | grep -q "service.*$service"; then
        echo -e "✅ Service: $service"
    else
        echo -e "${RED}❌ Service: $service (missing)${NC}"
        ((errors++))
    fi
done

echo ""
echo "🔐 Checking SSL configuration..."
if [ -d "ssl" ] && [ -f "ssl/cert.pem" ] && [ -f "ssl/key.pem" ]; then
    echo -e "✅ SSL certificates found"
else
    echo -e "${YELLOW}⚠️  SSL certificates not found (will be generated on first run)${NC}"
fi

echo ""
echo "📊 Validation Summary:"
if [ $errors -eq 0 ]; then
    echo -e "${GREEN}🎉 All checks passed! Your Docker setup is ready.${NC}"
    echo ""
    echo "🚀 To start your BTCPayServer stack:"
    echo "   make deploy    # Full deployment"
    echo "   make dev       # Development mode"
    echo "   ./deploy.sh    # Linux/macOS deployment"
    echo "   .\\deploy.ps1   # Windows deployment"
    echo ""
    echo "📚 For more commands: make help"
else
    echo -e "${RED}❌ Found $errors error(s). Please fix them before proceeding.${NC}"
    exit 1
fi
