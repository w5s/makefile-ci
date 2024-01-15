
## Enable Docker buildx feature
DOCKER_BUILDKIT ?= 1

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
	CI_RUNNER_TAGS \
	GITLAB_USER_EMAIL \
	GITLAB_USER_ID \
  GITLAB_USER_LOGIN \
	GITLAB_USER_NAME

# Construct --label flags

# DOCKER_BUILD_ARGS
DOCKER_BUILD_ARGS_VARIABLES := \
	BUNDLER_VERSION \
	NODEJS_VERSION \
	RUBY_VERSION

DOCKER_BUILD_ARGS := $(foreach var,$(DOCKER_BUILD_ARGS_VARIABLES),$(if $($(var)), --build-arg $(var)="$($(var))"))
# Append inline cache
DOCKER_BUILD_ARGS += --build-arg BUILDKIT_INLINE_CACHE=${BUILDKIT_INLINE_CACHE:-1}
# Append labels
DOCKER_BUILD_ARGS += $(foreach var,$(DOCKER_LABEL_VARIABLES),$(if $($(var)), --label $(var)="$($(var))"))

PHONY += docker-image-dev
docker-build: docker-image-dev docker-image-rc

PHONY += docker-image-dev
docker-image-dev:
	$(info Building CI Image)
	@docker build\
		$(DOCKER_BUILD_ARGS)\
		--target "$(CONTAINER_CI_TARGET)" \
		--cache-from "$(CONTAINER_CI_IMAGE):$(CI_COMMIT_REF_SLUG)-cache--$(CONTAINER_CI_TARGET)" \
		--cache-from "$(CONTAINER_CI_IMAGE):$(CI_DEFAULT_BRANCH)-cache--$(CONTAINER_CI_TARGET)" \
		--tag "$(CONTAINER_CI_IMAGE):$(CI_COMMIT_REF_SLUG)-cache--$(CONTAINER_CI_TARGET)" \
		--tag "$(CONTAINER_CI_IMAGE):$(CONTAINER_CI_TAG)" \
		.

PHONY += docker-image-dev
docker-image-rc: docker-image-dev
	$(info Building RC Image)
	@docker build\
		$(DOCKER_BUILD_ARGS)\
		--target "$(CONTAINER_RC_TARGET)" \
		--cache-from "$(CONTAINER_CI_IMAGE):$(CONTAINER_CI_TAG)" \
		--tag "$(CONTAINER_RC_IMAGE):$(CONTAINER_RC_TAG)" \
		.

PHONY += docker-release
docker-release:
  docker pull "$(CONTAINER_RC_IMAGE):$(CONTAINER_RC_TAG)"
	docker tag "$(CONTAINER_RC_IMAGE):$(CONTAINER_RC_TAG)" "$(CONTAINER_RELEASE_IMAGE):$(CONTAINER_RELEASE_TAG)"
  docker push "$(CONTAINER_RELEASE_IMAGE):$(CONTAINER_RELEASE_TAG)"
