
# Docker Compose command
COMPOSE := docker compose
COMPOSE_FILE := compose-dev.yaml

COMPOSE_MAIN_SERVICE ?= web

.PHONY: docker-compose-run
docker-compose-run: export DOCKER_BUILD_TARGET ?= $(CONTAINER_BUILDER_TARGET)
docker-compose-run: export APP_IMAGE = $(CONTAINER_BUILDER_IMAGE):$(CONTAINER_BUILDER_TAG)
docker-compose-run: export COMPOSE_PROJECT_NAME ?= $(CI_PROJECT_NAME)-$(shell date '+%Y%m%d%H%M%S')
docker-compose-run:
	@ cleanup() { $(call log,info,[Docker Compose] Stopping...,1);$(COMPOSE) -f $(COMPOSE_FILE) down --volumes --remove-orphans &>/dev/null; } \
	&& trap cleanup EXIT INT QUIT TERM \
	&& $(call log,info,[Docker Compose] Starting...,1) \
	&& $(COMPOSE) -f $(COMPOSE_FILE) up --detach --remove-orphans --quiet-pull \
  && $(call log,info,[Docker Compose] Executing command...,1) \
	&& $(COMPOSE) -f $(COMPOSE_FILE) run --use-aliases --rm $(COMPOSE_MAIN_SERVICE) $(DOCKER_COMMAND);


.PHONY: docker-compose-make-%
docker-compose-make-%:
	@$(MAKE) docker-compose-run DOCKER_COMMAND="make $*"
