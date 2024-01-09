
## Enable Docker buildx feature
DOCKER_BUILDKIT ?= 1

ifneq ($(CI_REGISTRY_IMAGE),)
## Docker registry to pull/push images
DOCKER_REGISTRY ?= $(CI_REGISTRY_IMAGE)/
endif
export DOCKER_REGISTRY

## CI Docker image repository
CONTAINER_CI_IMAGE ?= $(DOCKER_REGISTRY)dev
## CI Docker image tag
CONTAINER_CI_TAG ?= ci-$(CI_COMMIT_REF_SLUG)-$(CI_COMMIT_SHORT_SHA)
## CI Docker sub image
CONTAINER_CI_TARGET ?= builder

## Release Candidate Docker image repository
CONTAINER_RC_IMAGE ?= $(CONTAINER_CI_IMAGE)
## Release Candidate Docker image tag
CONTAINER_RC_TAG ?= rc-$(CI_COMMIT_REF_SLUG)-$(CI_COMMIT_SHORT_SHA)
## Release Candidate Docker sub image
CONTAINER_RC_TARGET ?= runner


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
	CI_RUNNER_TAGS \
	GITLAB_USER_EMAIL \
	GITLAB_USER_ID \
  GITLAB_USER_LOGIN \
	GITLAB_USER_NAME

# Construct --label flags
DOCKER_LABEL_ARGS := $(foreach var,$(DOCKER_LABEL_VARIABLES),$(if $($(var)), --label $(var)="$($(var))"))

DOCKER_BUILD_ARGS_VARIABLES := \
	NODEJS_VERSION \
	RUBY_VERSION

DOCKER_BUILD_ARGS := $(foreach var,$(DOCKER_BUILD_ARGS_VARIABLES),$(if $($(var)), --build-arg $(var)="$($(var))"))

DOCKER_BUILD_CACHE_ARGS := --build-arg BUILDKIT_INLINE_CACHE=${BUILDKIT_INLINE_CACHE:-1}

DOCKER_BUILD := docker build

PHONY += docker-image-dev
docker-build: docker-image-dev docker-image-rc

PHONY += docker-image-dev
docker-image-dev:
	$(info Building CI Image)
	@$(DOCKER_BUILD)\
		$(DOCKER_LABEL_ARGS)\
		$(DOCKER_BUILD_ARGS)\
		$(DOCKER_BUILD_CACHE_ARGS) \
		--target "$(CONTAINER_CI_TARGET)" \
		--tag "$(CONTAINER_CI_IMAGE):$(CONTAINER_CI_TAG)" \
		.

PHONY += docker-image-dev
docker-image-rc:
	$(info Building RC Image)
	@$(DOCKER_BUILD)\
		$(DOCKER_LABEL_ARGS)\
		$(DOCKER_BUILD_ARGS)\
		$(DOCKER_BUILD_CACHE_ARGS) \
		--target "$(CONTAINER_RC_TARGET)" \
		--tag "$(CONTAINER_RC_IMAGE):$(CONTAINER_RC_TAG)" \
		.
