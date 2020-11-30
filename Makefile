# /!\ /!\ /!\ /!\ /!\ /!\ /!\ DISCLAIMER /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\
#
# This Makefile is only meant to be used for DEVELOPMENT purpose as we are
# changing the user id that will run in the container.
#
# PLEASE DO NOT USE IT FOR YOUR CI/PRODUCTION/WHATEVER...
#
# /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\
#
# Note to developpers:
#
# While editing this file, please respect the following statements:
#
# 1. Every variable should be defined in the ad hoc VARIABLES section with a
#    relevant subsection
# 2. Every new rule should be defined in the ad hoc RULES section with a
#    relevant subsection depending on the targeted service
# 3. Rules should be sorted alphabetically within their section
# 4. When a rule has multiple dependencies, you should:
#    - duplicate the rule name to add the help string (if required)
#    - write one dependency per line to increase readability and diffs
# 5. .PHONY rule statement should be written after the corresponding rule
# ==============================================================================
# VARIABLES

# -- Docker
# Get the current user ID to use for docker run and docker exec commands
DOCKER_UID           = $(shell id -u)
DOCKER_GID           = $(shell id -g)
DOCKER_USER          = $(DOCKER_UID):$(DOCKER_GID)

COMPOSE              = DOCKER_USER=$(DOCKER_USER) docker-compose
COMPOSE_RUN          = $(COMPOSE) run --rm
COMPOSE_RUN_APP      = $(COMPOSE_RUN) app
COMPOSE_RUN_NODE     = $(COMPOSE_RUN) -e HOME="/tmp" app

YARN                 = $(COMPOSE_RUN_NODE) yarn

# ==============================================================================
# RULES

default: help

# -- Test suite

stress: ## Run stress test
	@$(COMPOSE_RUN_APP) ./cli.js stress -v
.PHONY: stress

list-meetings: ## List meetings running on the BBB server
	@$(COMPOSE_RUN_APP) ./cli.js list-meetings
.PHONY: list-meetings


# -- Project bootstrap

.env:
	cp .env.default .env
	@echo ".env file generated successfully. Please edit it to set BBB_URL, BBB_SECRET and BBB_MEETING_ID"


bootstrap: ## Prepare Docker images for the project
bootstrap: \
	.env \
	build
.PHONY: bootstrap

# -- Build tools

build: ## Build front-end application
build: \
	build-image \
	install
.PHONY: build

build-image: ## Build the docker image
	docker-compose build app
.PHONY: build-image

install: ## Install dependencies
	@$(YARN) install
.PHONY: install

# -- Node

lint: ## Run linters
lint: \
  lint-prettier
.PHONY: lint

lint-prettier: ## Run prettier over js/jsx/json/ts/tsx files -- beware! overwrites files
	@$(YARN) prettier-write
.PHONY: lint-prettier

node-console: # Run a terminal inside the node docker image
	$(COMPOSE_RUN_NODE) bash
.PHONY: node-console


# -- Misc
help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help
