
# Docker Compose command
COMPOSE := docker compose
COMPOSE_FILE := compose-dev.yaml

PHONY += docker-compose-exec
docker-compose-exec: export DOCKER_BUILD_TARGET ?= $(CONTAINER_CI_TARGET)
docker-compose-exec: export APP_IMAGE = $(CONTAINER_CI_IMAGE):$(CONTAINER_CI_TAG)
docker-compose-exec: export COMPOSE_PROJECT_NAME ?= $(CI_PROJECT_NAME)-$(shell date '+%Y%m%d%H%M%S')
docker-compose-exec:
	@trap "echo '[Docker] Stopping...';$(COMPOSE) -f $(COMPOSE_FILE) down --volumes --remove-orphans &>/dev/null" EXIT ERR; \
	echo '[Docker] Starting...'; \
	$(COMPOSE) -f $(COMPOSE_FILE) up --detach; \
	echo '[Docker] Executing command...'; \
	sleep 10;$(COMPOSE) -f $(COMPOSE_FILE) exec web /bin/bash -c "echo 'ICI'"

PHONY += docker-compose-make-%
docker-compose-make-%:
	@$(MAKE) docker-compose-exec DOCKER_COMMAND="make $*"
