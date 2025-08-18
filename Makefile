# BTCPayServer with Zano Plugin - Makefile
# Common Docker operations for managing the stack

.PHONY: help build up down restart logs status clean ssl deploy dev

# Default target
help:
	@echo "BTCPayServer with Zano Plugin - Available commands:"
	@echo ""
	@echo "  build    - Build all Docker images"
	@echo "  up       - Start all services"
	@echo "  down     - Stop all services"
	@echo "  restart  - Restart all services"
	@echo "  logs     - Show logs for all services"
	@echo "  status   - Show status of all services"
	@echo "  clean    - Remove all containers, volumes, and images"
	@echo "  ssl      - Generate self-signed SSL certificates"
	@echo "  deploy   - Full deployment (build + up)"
	@echo "  dev      - Development mode (up with overrides)"
	@echo ""

# Build all images
build:
	@echo "🔨 Building Docker images..."
	docker-compose build --no-cache

# Start all services
up:
	@echo "🚀 Starting services..."
	docker-compose up -d

# Stop all services
down:
	@echo "🛑 Stopping services..."
	docker-compose down

# Restart all services
restart:
	@echo "🔄 Restarting services..."
	docker-compose restart

# Show logs
logs:
	@echo "📋 Showing logs..."
	docker-compose logs -f

# Show status
status:
	@echo "📊 Service status:"
	docker-compose ps

# Clean everything
clean:
	@echo "🧹 Cleaning up..."
	docker-compose down -v --rmi all
	docker system prune -a --volumes -f

# Generate SSL certificates
ssl:
	@echo "🔐 Generating SSL certificates..."
	@mkdir -p ssl
	@if [ ! -f ssl/cert.pem ] || [ ! -f ssl/key.pem ]; then \
		openssl req -x509 -newkey rsa:4096 -keyout ssl/key.pem -out ssl/cert.pem -days 365 -nodes -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"; \
		echo "✅ SSL certificates generated"; \
	else \
		echo "ℹ️  SSL certificates already exist"; \
	fi

# Full deployment
deploy: ssl build up
	@echo "🎉 Deployment completed!"
	@echo "📱 Access your BTCPayServer at:"
	@echo "   HTTP:  http://localhost"
	@echo "   HTTPS: https://localhost"

# Development mode
dev: ssl up
	@echo "🔧 Development mode started!"
	@echo "📱 Access your BTCPayServer at:"
	@echo "   HTTP:  http://localhost"
	@echo "   HTTPS: https://localhost"

# Quick commands
logs-btc:
	docker-compose logs -f btcpayserver

logs-zano:
	docker-compose logs -f zano-daemon

logs-wallet:
	docker-compose logs -f zano-wallet-rpc

logs-bitcoin:
	docker-compose logs -f bitcoin

logs-nginx:
	docker-compose logs -f nginx

# Shell access
shell-btc:
	docker-compose exec btcpayserver bash

shell-zano:
	docker-compose exec zano-daemon sh

shell-bitcoin:
	docker-compose exec bitcoin bash

# Health checks
health:
	@echo "🏥 Checking service health..."
	@docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# Backup
backup:
	@echo "💾 Creating backup..."
	@mkdir -p backups
	@docker run --rm -v btcpayserver_data:/data -v $(PWD)/backups:/backup alpine tar czf /backup/btcpayserver_$(shell date +%Y%m%d_%H%M%S).tar.gz -C /data .
	@echo "✅ Backup created in backups/ directory"

# Update
update:
	@echo "🔄 Updating services..."
	docker-compose pull
	docker-compose up -d --build
