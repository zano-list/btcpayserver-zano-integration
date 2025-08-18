# BTCPayServer Docker Setup

This directory contains Docker Compose files to run BTCPayServer with all required services.

## Prerequisites

- Docker and Docker Compose installed
- Ports 14142, 32838, 39372, 43782, 39388, 28332, 28333 available

## Quick Start

### Option 1: HTTPS (Recommended)
```bash
docker-compose -f docker-compose.btcpayserver.yml up -d
```

### Option 2: HTTP (Development)
```bash
docker-compose -f docker-compose.btcpayserver.http.yml up -d
```

## What Gets Started

1. **PostgreSQL** (Port 39372) - Database for BTCPayServer and NBXplorer
2. **Bitcoin Core** (Ports 43782, 39388, 28332, 28333) - Bitcoin node in regtest mode
3. **NBXplorer** (Port 32838) - Bitcoin blockchain indexer
4. **BTCPayServer** (Port 14142) - Main application

## Access

- **BTCPayServer**: https://localhost:14142 (HTTPS) or http://localhost:14142 (HTTP)
- **NBXplorer**: http://localhost:32838
- **PostgreSQL**: localhost:39372

## Environment Variables

Key configuration:
- `BTCPAY_NETWORK=regtest` - Uses Bitcoin regtest network
- `BTCPAY_CHAINS=btc` - Supports Bitcoin
- `BTCPAY_ALLOW-ADMIN-REGISTRATION=true` - Allows admin registration
- `BTCPAY_DISABLE-REGISTRATION=false` - Registration enabled

## First Run

1. Wait for all services to start (check with `docker-compose ps`)
2. Open BTCPayServer in your browser
3. Create your first admin account
4. Configure your store

## Troubleshooting

### Check Service Status
```bash
docker-compose -f docker-compose.btcpayserver.yml ps
```

### View Logs
```bash
docker-compose -f docker-compose.btcpayserver.yml logs btcpayserver
```

### Stop Services
```bash
docker-compose -f docker-compose.btcpayserver.yml down
```

### Clean Start (Remove Volumes)
```bash
docker-compose -f docker-compose.btcpayserver.yml down -v
```

## Development Notes

- Uses Bitcoin regtest network for testing
- All data is persisted in Docker volumes
- Services automatically restart unless stopped manually
- Network isolation between services
