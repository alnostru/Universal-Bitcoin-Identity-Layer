.PHONY: help install install-dev test test-unit test-integration test-coverage lint format security clean docker-build docker-up docker-down

# Default target
.DEFAULT_GOAL := help

# Variables
PYTHON := python3
PIP := $(PYTHON) -m pip
PYTEST := pytest
BLACK := black
ISORT := isort
FLAKE8 := flake8
PYLINT := pylint
MYPY := mypy
BANDIT := bandit
DOCKER_COMPOSE := docker-compose

help: ## Show this help message
	@echo "HODLXXI - Universal Bitcoin Identity Layer"
	@echo ""
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Install production dependencies
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt

install-dev: ## Install development dependencies
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt
	$(PIP) install -r requirements-dev.txt
	pre-commit install

test: ## Run all tests
	$(PYTEST) tests/ -v

test-unit: ## Run unit tests only
	$(PYTEST) tests/unit -v

test-integration: ## Run integration tests only
	$(PYTEST) tests/integration -v

test-coverage: ## Run tests with coverage report
	$(PYTEST) tests/ -v --cov=app --cov-report=html --cov-report=term-missing
	@echo "Coverage report generated in htmlcov/index.html"

test-fast: ## Run tests in parallel (fast)
	$(PYTEST) tests/ -v -n auto

test-watch: ## Run tests in watch mode
	$(PYTEST) tests/ -v -f

lint: ## Run all linters
	$(FLAKE8) app/ tests/
	$(PYLINT) app/ tests/ --exit-zero
	$(MYPY) app/ --ignore-missing-imports

lint-flake8: ## Run flake8 linter
	$(FLAKE8) app/ tests/ --count --show-source --statistics

lint-pylint: ## Run pylint linter
	$(PYLINT) app/ tests/

lint-mypy: ## Run mypy type checker
	$(MYPY) app/

format: ## Format code with black and isort
	$(BLACK) app/ tests/
	$(ISORT) app/ tests/

format-check: ## Check code formatting without making changes
	$(BLACK) --check app/ tests/
	$(ISORT) --check-only app/ tests/

security: ## Run security scans
	$(BANDIT) -r app/ -f screen
	safety check --json || true
	safety check

security-bandit: ## Run Bandit security scan
	$(BANDIT) -r app/ -ll -f json -o bandit-report.json
	$(BANDIT) -r app/ -ll -f screen

security-safety: ## Check dependencies for vulnerabilities
	safety check

pre-commit: ## Run pre-commit hooks on all files
	pre-commit run --all-files

pre-commit-update: ## Update pre-commit hooks
	pre-commit autoupdate

clean: ## Clean up generated files
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name ".coverage" -delete
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "htmlcov" -exec rm -rf {} + 2>/dev/null || true
	rm -f bandit-report.json
	rm -f coverage.xml

docker-build: ## Build Docker image
	docker build -t hodlxxi:latest .

docker-up: ## Start Docker Compose services
	$(DOCKER_COMPOSE) up -d

docker-down: ## Stop Docker Compose services
	$(DOCKER_COMPOSE) down

docker-logs: ## View Docker Compose logs
	$(DOCKER_COMPOSE) logs -f

docker-restart: ## Restart Docker Compose services
	$(DOCKER_COMPOSE) restart

docker-clean: ## Clean Docker containers and volumes
	$(DOCKER_COMPOSE) down -v
	docker system prune -f

run: ## Run the application locally
	$(PYTHON) app/app.py

run-prod: ## Run the application with Gunicorn
	gunicorn --worker-class gevent --workers 4 --bind 0.0.0.0:5000 app.app:app

run-dev: ## Run the application in development mode
	FLASK_ENV=development FLASK_DEBUG=1 $(PYTHON) app/app.py

shell: ## Open Python shell with app context
	$(PYTHON) -i -c "from app.app import app; app.app_context().push()"

requirements: ## Update requirements files
	$(PIP) freeze > requirements.txt.new
	@echo "Review requirements.txt.new and update requirements.txt manually"

check: format-check lint test ## Run all checks (format, lint, test)

ci: clean install-dev format-check lint security test-coverage ## Run full CI pipeline locally

setup-dev: install-dev ## Setup development environment
	@echo "Development environment setup complete!"
	@echo "Run 'make test' to verify installation"

verify: ## Verify installation and configuration
	$(PYTHON) --version
	$(PIP) --version
	$(PYTEST) --version
	$(BLACK) --version
	$(FLAKE8) --version
	@echo "Environment verification complete!"

.PHONY: all
all: clean install-dev format lint test ## Run complete build pipeline
