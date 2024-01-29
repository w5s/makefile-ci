
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

## Enable Docker push when building
DOCKER_BUILD_PUSH ?=
export DOCKER_BUILD_PUSH

ifneq ($(CI_REGISTRY_IMAGE),)
## Docker registry to pull/push images
DOCKER_REGISTRY ?= $(CI_REGISTRY_IMAGE)/
endif
export DOCKER_REGISTRY


## Container builder image repository (for CI)
CONTAINER_BUILDER_IMAGE ?= $(DOCKER_REGISTRY)dev
## Container builder image target (for CI)
CONTAINER_BUILDER_TARGET ?= builder
## Container builder image tag  (for CI)
CONTAINER_BUILDER_TAG ?=
ifeq ($(CONTAINER_BUILDER_TAG),)
	ifneq ($(CI),)
		CONTAINER_BUILDER_TAG = $(CI_COMMIT_REF_SLUG)-$(CI_COMMIT_SHORT_SHA)--$(CONTAINER_BUILDER_TARGET)
	else
		CONTAINER_BUILDER_TAG = $(CI_COMMIT_REF_SLUG)-head--$(CONTAINER_BUILDER_TARGET)
	endif
endif

## Container runner image repository (for server)
CONTAINER_RUNNER_IMAGE ?= $(CONTAINER_BUILDER_IMAGE)
## Container runner image target (for server)
CONTAINER_RUNNER_TARGET ?= runner
## Container runner image tag (for server)
CONTAINER_RUNNER_TAG ?=
ifeq ($(CONTAINER_RUNNER_TAG),)
	ifneq ($(CI),)
		CONTAINER_RUNNER_TAG = $(CI_COMMIT_REF_SLUG)-$(CI_COMMIT_SHORT_SHA)--$(CONTAINER_RUNNER_TARGET)
	else
		CONTAINER_RUNNER_TAG = $(CI_COMMIT_REF_SLUG)-head--$(CONTAINER_RUNNER_TARGET)
	endif
endif

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
docker-build: docker-image-builder docker-image-runner

docker-image-builder:
	@${MAKE} .docker-pull-cache .docker-build \
		DOCKER_BUILD_CACHE_FROM="\
			$(CONTAINER_BUILDER_IMAGE):$(CI_COMMIT_REF_SLUG)-cache--$(CONTAINER_BUILDER_TARGET) \
			$(CONTAINER_BUILDER_IMAGE):$(CI_DEFAULT_BRANCH)-cache--$(CONTAINER_BUILDER_TARGET)" \
		DOCKER_BUILD_TAG="$(CONTAINER_BUILDER_IMAGE):$(CONTAINER_BUILDER_TAG)" \
		DOCKER_BUILD_TAGS="$(CONTAINER_BUILDER_IMAGE):$(CI_COMMIT_REF_SLUG)-cache--$(CONTAINER_BUILDER_TARGET)" \
		DOCKER_BUILD_TARGET="$(CONTAINER_BUILDER_TARGET)"

docker-image-runner: docker-image-builder
	@${MAKE} .docker-build \
		DOCKER_BUILD_CACHE_FROM="$(CONTAINER_BUILDER_IMAGE):$(CONTAINER_BUILDER_TAG)" \
		DOCKER_BUILD_TAG="$(CONTAINER_RUNNER_IMAGE):$(CONTAINER_RUNNER_TAG)" \
		DOCKER_BUILD_TARGET="$(CONTAINER_RUNNER_TARGET)"

.PHONY: docker-make-%
docker-make-%:
	@$(MAKE) .docker-run \
		DOCKER_IMAGE="$(CONTAINER_BUILDER_IMAGE)" \
		DOCKER_TAG="$(CONTAINER_BUILDER_TAG)" \
		DOCKER_COMMAND="make $*"

.PHONY: docker-release
docker-release:
  docker pull "$(CONTAINER_RUNNER_IMAGE):$(CONTAINER_RUNNER_TAG)"
	docker tag "$(CONTAINER_RUNNER_IMAGE):$(CONTAINER_RUNNER_TAG)" "$(CONTAINER_RELEASE_IMAGE):$(CONTAINER_RELEASE_TAG)"
  docker push "$(CONTAINER_RELEASE_IMAGE):$(CONTAINER_RELEASE_TAG)"

# Generic target for building an image
.PHONY: .docker-build
.docker-build:
	@$(call log,info,"[Docker] Building Image tag=$(DOCKER_BUILD_TAG) target=$(DOCKER_BUILD_TARGET)",1)
	@docker buildx build\
		$(DOCKER_BUILD_ARGS)\
		--target "$(DOCKER_BUILD_TARGET)" \
		$(foreach cache, $(DOCKER_BUILD_CACHE_FROM), --cache-from $(cache)) \
		$(foreach tag, $(DOCKER_BUILD_TAG) $(DOCKER_BUILD_TAGS), --tag $(tag)) \
		.
	@if [[ ! -z "$(DOCKER_BUILD_PUSH)" ]];then \
		docker push --quiet "$(DOCKER_BUILD_TAG)"; \
	fi

# Generic target for pulling images
.PHONY: .docker-pull-cache
.docker-pull-cache:
	@$(call log,info,"[Docker] Pulling cache...",1)
	@for image in $(DOCKER_BUILD_CACHE_FROM); do \
		docker pull $$image &>/dev/null && { echo "[Docker] $$image found"; break; } || echo "[Docker] $$image not found, skipping."; \
	done

# Generic Docker run
.PHONY: .docker-run
.docker-run:
	@$(call log,info,"[Docker] Open container...",1)
	@docker run\
		$(DOCKER_RUN_ARGS) \
		--rm \
		--pull missing \
		--quiet \
		--volume "$(PROJECT_PATH)":/app \
		--volume "$(DOCKER_SOCKET_PATH)":/var/run/docker.sock \
		"$(DOCKER_IMAGE):$(DOCKER_TAG)" /bin/bash -c "set -euo pipefail; $(DOCKER_COMMAND)"
