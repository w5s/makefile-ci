
# Docker Compose command
COMPOSE := docker compose
COMPOSE_FILE := compose-dev.yaml

COMPOSE_MAIN_SERVICE ?= web

.PHONY: docker-compose-run
docker-compose-run: export DOCKER_BUILD_TARGET ?= $(CONTAINER_CI_TARGET)
docker-compose-run: export APP_IMAGE = $(CONTAINER_CI_IMAGE):$(CONTAINER_CI_TAG)
docker-compose-run: export COMPOSE_PROJECT_NAME ?= $(CI_PROJECT_NAME)-$(shell date '+%Y%m%d%H%M%S')
docker-compose-run:
	@trap "echo '[Docker Compose] Stopping...';$(COMPOSE) -f $(COMPOSE_FILE) down --volumes --remove-orphans &>/dev/null" EXIT INT QUIT TERM; \
	echo '[Docker Compose] Starting...'; \
	$(COMPOSE) -f $(COMPOSE_FILE) up --detach --remove-orphans --quiet-pull; \
	echo '[Docker Compose] Executing command...'; \
	$(COMPOSE) -f $(COMPOSE_FILE) run --use-aliases --rm $(COMPOSE_MAIN_SERVICE) $(DOCKER_COMMAND)


.PHONY: docker-compose-make-%
docker-compose-make-%:
	@$(MAKE) docker-compose-run DOCKER_COMMAND="make $*"
