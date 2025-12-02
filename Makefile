.PHONY: help dev build prod test clean migrate seed logs shell psql compose-check

# Detect which compose command to use
DOCKER_COMPOSE = $(shell which docker-compose 2>/dev/null || echo "docker compose")
ENV_FILE = .env
DOCKER_COMPOSE_FILES = -f docker-compose.yml

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

# Check for .env file
ifeq (,$(wildcard $(ENV_FILE)))
$(warning $(YELLOW)Warning: .env file not found. Using defaults.$(NC))
ENV_FILE = .env.example
endif

help: ## Show this help message
	@printf "$(BLUE)E-Commerce Project Management Commands$(NC)\n\n"
	@printf "Using: $(GREEN)$(DOCKER_COMPOSE)$(NC)\n"
	@printf "Environment: $(GREEN)$(ENV_FILE)$(NC)\n\n"
	@printf "Available commands:\n"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-25s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Development
dev: ## Start development environment with live reload
	@printf "$(BLUE)Starting development environment...$(NC)\n"
	$(DOCKER_COMPOSE) -f docker-compose.dev.yml up --build

dev-down: ## Stop development environment
	@printf "$(YELLOW)Stopping development environment...$(NC)\n"
	$(DOCKER_COMPOSE) -f docker-compose.dev.yml down

dev-logs: ## View development logs (follow)
	$(DOCKER_COMPOSE) -f docker-compose.dev.yml logs -f --tail=50

dev-restart: ## Restart development services
	@printf "$(YELLOW)Restarting development services...$(NC)\n"
	$(DOCKER_COMPOSE) -f docker-compose.dev.yml restart

# Production
build: ## Build production images
	@printf "$(BLUE)Building production images...$(NC)\n"
	$(DOCKER_COMPOSE) -f docker-compose.prod.yml build

prod: build ## Build and start production environment
	@printf "$(GREEN)Starting production environment...$(NC)\n"
	$(DOCKER_COMPOSE) -f docker-compose.prod.yml up -d

prod-down: ## Stop production environment
	@printf "$(YELLOW)Stopping production environment...$(NC)\n"
	$(DOCKER_COMPOSE) -f docker-compose.prod.yml down

prod-logs: ## View production logs
	$(DOCKER_COMPOSE) -f docker-compose.prod.yml logs -f --tail=100

prod-restart: ## Restart production services
	@printf "$(YELLOW)Restarting production services...$(NC)\n"
	$(DOCKER_COMPOSE) -f docker-compose.prod.yml restart

prod-update: ## Update production containers with latest images
	@printf "$(BLUE)Pulling latest images...$(NC)\n"
	$(DOCKER_COMPOSE) -f docker-compose.prod.yml pull
	@printf "$(GREEN)Recreating services...$(NC)\n"
	$(DOCKER_COMPOSE) -f docker-compose.prod.yml up -d

# Testing
test: ## Run all tests
	@printf "$(BLUE)Running tests...$(NC)\n"
	$(DOCKER_COMPOSE) -f docker-compose.test.yml run --rm web pytest -v

test-backend: ## Run backend tests only
	$(DOCKER_COMPOSE) -f docker-compose.test.yml run --rm web pytest apps/ -v

test-frontend: ## Run frontend tests (if configured)
	@printf "$(BLUE)Running frontend tests...$(NC)\n"
	cd frontend && npm test

test-coverage: ## Run tests with coverage report
	@printf "$(BLUE)Running tests with coverage...$(NC)\n"
	$(DOCKER_COMPOSE) -f docker-compose.test.yml run --rm web pytest --cov=apps --cov-report=html --cov-report=term

# Database
migrate: ## Run database migrations
	@printf "$(BLUE)Running migrations...$(NC)\n"
	$(DOCKER_COMPOSE) run --rm web python manage.py migrate

makemigrations: ## Create new migrations
	@printf "$(YELLOW)Creating migrations...$(NC)\n"
	$(DOCKER_COMPOSE) run --rm web python manage.py makemigrations

migrate-reset: ## Reset and reapply migrations (DANGER!)
	@printf "$(RED)⚠️  Resetting migrations...$(NC)\n"
	$(DOCKER_COMPOSE) run --rm web python manage.py migrate --fake $(APP) zero
	$(DOCKER_COMPOSE) run --rm web python manage.py migrate $(APP)

seed: ## Seed database with sample data
	@printf "$(GREEN)Seeding database...$(NC)\n"
	$(DOCKER_COMPOSE) run --rm web python manage.py seed_data

dumpdata: ## Dump database to fixture
	@printf "$(BLUE)Dumping database...$(NC)\n"
	$(DOCKER_COMPOSE) run --rm web python manage.py dumpdata --indent=2 > fixture.json

# Maintenance
logs: ## View all logs
	$(DOCKER_COMPOSE) logs -f

logs-web: ## View web service logs only
	$(DOCKER_COMPOSE) logs -f web

logs-db: ## View database logs only
	$(DOCKER_COMPOSE) logs -f db

shell: ## Open Django shell_plus
	$(DOCKER_COMPOSE) run --rm web python manage.py shell_plus

shell-db: ## Open PostgreSQL shell
	$(DOCKER_COMPOSE) exec db psql -U $(shell grep POSTGRES_USER $(ENV_FILE) | cut -d '=' -f2) $(shell grep POSTGRES_DB $(ENV_FILE) | cut -d '=' -f2)

clean: ## Clean up Docker resources (containers, volumes, networks)
	@printf "$(RED)Cleaning Docker resources...$(NC)\n"
	$(DOCKER_COMPOSE) -f docker-compose.dev.yml down -v
	$(DOCKER_COMPOSE) -f docker-compose.prod.yml down -v
	docker system prune -f --volumes

clean-images: ## Remove all Docker images
	@printf "$(RED)Removing all Docker images...$(NC)\n"
	docker rmi -f $$(docker images -q)

# Administration
create-superuser: ## Create Django superuser
	$(DOCKER_COMPOSE) run --rm web python manage.py createsuperuser

collectstatic: ## Collect static files
	$(DOCKER_COMPOSE) run --rm web python manage.py collectstatic --noinput

# Health
health: ## Check service health
	@printf "$(BLUE)Checking service health...$(NC)\n"
	@curl -f http://localhost:8000/api/health/ && printf "$(GREEN)✓ Backend is healthy$(NC)\n" || printf "$(RED)✗ Backend is unhealthy$(NC)\n"
	@curl -f http://localhost:3000/ && printf "$(GREEN)✓ Frontend is healthy$(NC)\n" || printf "$(RED)✗ Frontend is unhealthy$(NC)\n"

status: ## Show service status
	@printf "$(BLUE)Container Status:$(NC)\n"
	$(DOCKER_COMPOSE) ps

stats: ## Show container resource usage
	@printf "$(BLUE)Container Resource Usage:$(NC)\n"
	docker stats --no-stream

# Security
check-vuln: ## Check for security vulnerabilities
	@printf "$(YELLOW)Checking for security vulnerabilities...$(NC)\n"
	docker scan $$(docker images --format "{{.Repository}}:{{.Tag}}" | head -5)

# Development Setup
setup: ## Initial project setup
	@printf "$(BLUE)Setting up project...$(NC)\n"
	cp .env.example .env
	@printf "$(YELLOW)Please update .env file with your values$(NC)\n"
	$(DOCKER_COMPOSE) -f docker-compose.dev.yml build
	$(DOCKER_COMPOSE) -f docker-compose.dev.yml up -d
	@sleep 5
	@make migrate
	@make seed
	@printf "$(GREEN)✓ Setup complete!$(NC)\n"

# Debug
compose-check: ## Validate Docker Compose files
	@printf "$(BLUE)Validating Docker Compose files...$(NC)\n"
	$(DOCKER_COMPOSE) -f docker-compose.dev.yml config
	$(DOCKER_COMPOSE) -f docker-compose.prod.yml config
	$(DOCKER_COMPOSE) -f docker-compose.test.yml config

which-compose: ## Show which compose command is being used
	@printf "Using: $(GREEN)$(DOCKER_COMPOSE)$(NC)\n"
	@printf "Compose version: "
	@$(DOCKER_COMPOSE) --version

# Backup
backup: ## Create database backup
	@mkdir -p backups
	@printf "$(BLUE)Creating database backup...$(NC)\n"
	$(DOCKER_COMPOSE) exec -T db pg_dump -U $$(grep POSTGRES_USER $(ENV_FILE) | cut -d '=' -f2) $$(grep POSTGRES_DB $(ENV_FILE) | cut -d '=' -f2) > backups/backup_$$(date +%Y%m%d_%H%M%S).sql
	@printf "$(GREEN)✓ Backup created in backups/ directory$(NC)\n"