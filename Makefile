
# ==============================================================================
# VARIABLES

# -- Docker
# Get the current user ID to use for docker run and docker exec commands

DOCKER_UID           = $(shell id -u)
DOCKER_GID           = $(shell id -g)
DOCKER_USER          = $(DOCKER_UID):$(DOCKER_GID)

DOCKER_IMAGE         = fundocker/bbb-stress-test
DOCKER_RUN           = docker run -ti --rm -u "$(DOCKER_USER)"
DOCKER_RUN_DEV       = $(DOCKER_RUN) --env-file=.env -v "$(PWD):/app" $(DOCKER_IMAGE):development

# ==============================================================================
# RULES

default: help

# -- Test suite

list-meetings: ## List meetings running on the BBB server
	@$(DOCKER_RUN) -ti --rm --env-file=.env $(DOCKER_IMAGE) bbb-list-meetings

stress: ## start the stress test
	@./stress-test.sh
.PHONY: stress


# -- Project bootstrap
bootstrap: ## Prepare Docker images for the project
bootstrap: \
	build \
	.env
.PHONY: bootstrap

# -- Docker
build: ## build the app container
	docker build --target development -t "$(DOCKER_IMAGE):development" .
.PHONY: build

run: ## start the test client
	@$(DOCKER_RUN) --env-file=.env $(DOCKER_IMAGE):latest
.PHONY: run

run-dev: ## start the test client in development mode
	@$(DOCKER_RUN_DEV)
.PHONY: run-dev

.env:
	@cp .env.default .env
	@echo ".env file generated successfully. Please edit it to set BBB_URL, BBB_SECRET and BBB_MEETING_ID"
.PHONY: .env

# -- Python sources

# Nota bene: Black should come after isort just in case they don't agree...
lint: ## lint python sources
lint: \
  lint-isort \
  lint-black \
  lint-flake8 \
  lint-mypy \
  lint-pylint \
  lint-bandit
.PHONY: lint

lint-bandit: ## lint back-end python sources with bandit
	@echo 'lint:bandit started…'
	@$(DOCKER_RUN_DEV) bandit -qr src
.PHONY: lint-bandit

lint-black: ## lint python sources with black
	@echo 'lint:black started…'
	@$(DOCKER_RUN_DEV) black src
.PHONY: lint-black

lint-flake8: ## lint back-end python sources with flake8
	@echo 'lint:flake8 started…'
	@$(DOCKER_RUN_DEV) flake8
.PHONY: lint-flake8

lint-isort: ## automatically re-arrange python imports in back-end code base
	@echo 'lint:isort started…'
	@$(DOCKER_RUN_DEV) isort --recursive --atomic .
.PHONY: lint-isort

lint-mypy: ## type check back-end python sources with mypy
	@echo 'lint:mypy started…'
	@$(DOCKER_RUN_DEV) mypy src
.PHONY: lint-mypy

lint-pylint: ## lint back-end python sources with pylint
	@echo 'lint:pylint started…'
	@$(DOCKER_RUN_DEV) pylint src
.PHONY: lint-pylint


# -- Misc
help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help
