# -------------------------------------------------------------------------------------------
# VARIABLES: Variable declarations to be used within make to generate commands.
# -------------------------------------------------------------------------------------------
PROJECT_NAME := go-kea
COMPOSE      := docker-compose --project-name $(PROJECT_NAME) --project-directory "develop" -f "develop/docker-compose.yml"

default: help

# -------------------------------------------------------------------------------------------
# CODE-QUALITY/TESTS: Linting and testing directives.
# -------------------------------------------------------------------------------------------
lint: .env ## Run golangci-lint on all sub-packages within docker
	@echo "🐳 Launching golangci-lint in docker..."
	@$(COMPOSE) run --rm develop make _lint
.PHONY: lint

_lint: ## Run golangci-lint on all sub-packages
	@echo "🧪 Running golangci-lint..."
	@golangci-lint run --tests=false --exclude-use-default=false
	@echo "Completed golangci-lint."
.PHONY: _lint

# -------------------------------------------------------------------------------------------
# DEVELOPMENT: Development tools for use when contributing to this project.
# -------------------------------------------------------------------------------------------
build: .env ## Build the development docker image and push to registry
	@echo "🐳 Building development docker image and pushing to registry..."
	@$(COMPOSE) build --no-cache
	@docker push jsilvas/${PROJECT_NAME}-develop:latest
.PHONY: build

cli: .env ## Launch a bash shell inside the running container.
	@echo "🐳 Launching a bash shell 💻 inside the running container..."
	@$(COMPOSE) run --rm develop bash
.PHONY: cli

destroy: .env ## Destroy the docker-compose environment and volumes
	@$(COMPOSE) down --volumes
.PHONY: destroy

# -------------------------------------------------------------------------------------------
# HELPERS: Internal Make Commands
# -------------------------------------------------------------------------------------------
tidy: ## Run go mod tidy and go mod vendor
	@go mod tidy && go mod vendor
.PHONY: tidy

.env:
	@if [ ! -f "develop/.env" ]; then \
	   echo "Creating environment file...\nPLEASE OVERRIDE VARIABLES IN develop/.env WITH YOUR OWN VALUES!"; \
	   cp develop/example.env develop/.env; \
	fi
.PHONY: .env

help: ## Display this help screen
	@echo "\033[1m\033[01;32m\
	$(shell echo $(PROJECT_NAME) | tr  '[:lower:]' '[:upper:]') \
	\033[00m\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' \
	$(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; \
	{printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help