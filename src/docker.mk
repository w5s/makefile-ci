
## Enable Docker buildx feature
DOCKER_BUILDKIT ?= 1
export DOCKER_BUILDKIT
## Docker Daemon socket path
DOCKER_SOCKET_PATH ?= /var/run/docker.sock
export DOCKER_SOCKET_PATH
## Enable CLI hints (docker scout)
DOCKER_CLI_HINTS ?= false
export DOCKER_CLI_HINTS
## Docker build progress display
DOCKER_BUILDKIT_PROGRESS ?= auto
export DOCKER_BUILDKIT_PROGRESS
## Docker build platform (ex: linux/arm64)
DOCKER_BUILD_PLATFORMS ?=
export DOCKER_BUILD_PLATFORMS

ifneq ($(CI_REGISTRY_IMAGE),)
## Docker registry to pull/push images
DOCKER_REGISTRY ?= $(CI_REGISTRY_IMAGE)/
endif
export DOCKER_REGISTRY

## CI Docker image repository
CONTAINER_CI_IMAGE ?= $(DOCKER_REGISTRY)dev
## CI Docker target image
CONTAINER_CI_TARGET ?= builder
## CI Docker image tag
CONTAINER_CI_TAG ?= $(CI_COMMIT_REF_SLUG)-$(CI_COMMIT_SHORT_SHA)--$(CONTAINER_CI_TARGET)

## Release Candidate Docker image repository
CONTAINER_RC_IMAGE ?= $(CONTAINER_CI_IMAGE)
## Release Candidate Docker target image
CONTAINER_RC_TARGET ?= runner
## Release Candidate Docker image tag
CONTAINER_RC_TAG ?= $(CI_COMMIT_REF_SLUG)-$(CI_COMMIT_SHORT_SHA)--$(CONTAINER_RC_TARGET)

## Release Docker image repository
CONTAINER_RELEASE_IMAGE ?= $(CI_REGISTRY_IMAGE)
## Release Docker image tag
CONTAINER_RELEASE_TAG ?= 1.$(shell echo "$(CI_PIPELINE_CREATED_AT)" | cut -c 1-19 | sed 's/[:-]//g;s/T/./g')-sha.$(CI_COMMIT_SHORT_SHA)

DOCKER_LABEL_VARIABLES := \
	CI_COMMIT_AUTHOR \
	CI_COMMIT_REF_NAME \
	CI_COMMIT_REF_SLUG \
	CI_COMMIT_SHA \
  CI_COMMIT_SHORT_SHA \
	CI_COMMIT_TIMESTAMP \
	CI_JOB_ID \
	CI_JOB_URL \
	CI_PIPELINE_ID \
	CI_PIPELINE_IID \
	CI_PIPELINE_URL \
	CI_PROJECT_ID \
	CI_PROJECT_PATH_SLUG \
	CI_PROJECT_URL \
	CI_REPOSITORY_URL \
	CI_RUNNER_ID \
	CI_RUNNER_REVISION \
	CI_RUNNER_TAGS

DOCKER_ENV_VARIABLES := $(CI_VARIABLES) \
	TIMEOUT_SECONDS \
	DOCKER_SOCKET_PATH

# Construct --label flags

# DOCKER_BUILD_ARGS
DOCKER_BUILD_ARGS_VARIABLES := \
	$(ASDF_VARIABLES)

DOCKER_BUILD_ARGS := $(foreach var,$(DOCKER_BUILD_ARGS_VARIABLES),$(if $($(var)), --build-arg $(var)="$($(var))"))
# Append inline cache
DOCKER_BUILD_ARGS += --build-arg BUILDKIT_INLINE_CACHE=${BUILDKIT_INLINE_CACHE:-1}
# Append labels
DOCKER_BUILD_ARGS += $(foreach var,$(DOCKER_LABEL_VARIABLES),$(if $($(var)), --label $(var)="$($(var))"))
# Append progress arguments
DOCKER_BUILD_ARGS += --progress=$(DOCKER_BUILDKIT_PROGRESS)
# Append build platform
ifneq ("$(DOCKER_BUILD_PLATFORMS)","")
DOCKER_BUILD_ARGS += --platform="$(DOCKER_BUILD_PLATFORMS)"
endif

DOCKER_RUN_ARGS :=
# Append env
DOCKER_RUN_ARGS += $(foreach var,$(DOCKER_ENV_VARIABLES),$(if $($(var)), --env $(var)))

.PHONY: docker-build
docker-build: docker-image-dev docker-image-rc

.PHONY: docker-image-dev
docker-image-dev: \
	export DOCKER_BUILD_CACHE_FROM = \
		$(CONTAINER_CI_IMAGE):$(CI_COMMIT_REF_SLUG)-cache--$(CONTAINER_CI_TARGET) \
		$(CONTAINER_CI_IMAGE):$(CI_DEFAULT_BRANCH)-cache--$(CONTAINER_CI_TARGET)
  export DOCKER_BUILD_TAGS = \
		$(CONTAINER_CI_IMAGE):$(CI_COMMIT_REF_SLUG)-cache--$(CONTAINER_CI_TARGET) \
		$(CONTAINER_CI_IMAGE):$(CONTAINER_CI_TAG)
  export DOCKER_BUILD_TARGET = $(CONTAINER_CI_TARGET)
docker-image-dev: .docker-pull-cache .docker-build

.PHONY: docker-image-rc
docker-image-rc: docker-image-dev
docker-image-rc: \
	export DOCKER_BUILD_CACHE_FROM = \
		$(CONTAINER_CI_IMAGE):$(CONTAINER_CI_TAG)
	export DOCKER_BUILD_TAGS = \
		$(CONTAINER_RC_IMAGE):$(CONTAINER_RC_TAG)
	export DOCKER_BUILD_TARGET = $(CONTAINER_RC_TARGET)
docker-image-rc: .docker-build

.PHONY: docker-make-%
docker-make-%:
	@$(MAKE) .docker-run \
		DOCKER_IMAGE="$(CONTAINER_CI_IMAGE)" \
		DOCKER_TAG="$(CONTAINER_CI_TAG)" \
		DOCKER_COMMAND="make $*"

.PHONY: docker-release
docker-release:
  docker pull "$(CONTAINER_RC_IMAGE):$(CONTAINER_RC_TAG)"
	docker tag "$(CONTAINER_RC_IMAGE):$(CONTAINER_RC_TAG)" "$(CONTAINER_RELEASE_IMAGE):$(CONTAINER_RELEASE_TAG)"
  docker push "$(CONTAINER_RELEASE_IMAGE):$(CONTAINER_RELEASE_TAG)"

# Generic target for building an image
.PHONY: .docker-build
.docker-build:
	$(info [Docker] Building Image)
	@docker buildx build\
		$(DOCKER_BUILD_ARGS)\
		--target "$(DOCKER_BUILD_TARGET)" \
		$(foreach cache, $(DOCKER_BUILD_CACHE_FROM), --cache-from $(cache)) \
		$(foreach tag, $(DOCKER_BUILD_TAGS), --tag $(tag)) \
		.

# Generic target for pulling images
.PHONY: .docker-pull-cache
.docker-pull-cache:
	$(info [Docker] Pulling cache)
	@for image in $(DOCKER_BUILD_CACHE_FROM); do \
		docker pull $$image &>/dev/null && { echo "[Docker] $$image found"; break; } || echo "[Docker] $$image not found, skipping."; \
	done

# Generic Docker run
.PHONY: .docker-run
.docker-run:
	$(info [Docker] Open container...)
	@docker run\
		$(DOCKER_RUN_ARGS) \
		--rm \
		--pull missing \
		--volume "$(PROJECT_PATH)":/app \
		--volume "$(DOCKER_SOCKET_PATH)":/var/run/docker.sock \
		"$(DOCKER_IMAGE):$(DOCKER_TAG)" /bin/bash -c "set -euo pipefail; $(DOCKER_COMMAND)"
