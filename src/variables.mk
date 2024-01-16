# Project paths

## Project root path
PROJECT_PATH ?= $(CURDIR)
## Project cache path
PROJECT_CACHE_PATH ?= .cache
## Project documentation path
PROJECT_DOCS_PATH ?= docs
## Project script path
PROJECT_SCRIPT_PATH ?= scripts
## External library path
PROJECT_VENDOR_PATH ?= vendor
## Git hooks directory (pre-commit, pre-push, etc)
PROJECT_GITHOOKS_PATH ?= .githooks


# Continuous Integration

# Register CI variables (for docker env export for example)
CI_VARIABLES :=

## Available for all jobs executed in CI/CD. true when available.
CI ?=
export CI
CI_VARIABLES += CI

## The name of the project’s default branch.
CI_DEFAULT_BRANCH ?= $(notdir $(shell ${GIT} rev-parse --abbrev-ref origin/HEAD))
export CI_DEFAULT_BRANCH
CI_VARIABLES += CI_DEFAULT_BRANCH

## The commit branch name
CI_COMMIT_BRANCH ?= $(shell ${GIT} rev-parse --abbrev-ref HEAD)
export CI_COMMIT_BRANCH
CI_VARIABLES += CI_COMMIT_BRANCH

## The author of the commit in Name <email> format
CI_COMMIT_AUTHOR ?= $(shell ${GIT} log -1 --format='%an <%ae>')
export CI_COMMIT_AUTHOR
CI_VARIABLES += CI_COMMIT_AUTHOR

## The branch or tag name for which project is built
CI_COMMIT_REF_NAME ?= ${CI_COMMIT_BRANCH}
export CI_COMMIT_REF_NAME
CI_VARIABLES += CI_COMMIT_REF_NAME

## CI_COMMIT_REF_NAME in lowercase, shortened to 63 bytes
CI_COMMIT_REF_SLUG ?= $(shell echo ${CI_COMMIT_REF_NAME} | tr '[:upper:]' '[:lower:]' | tr '[:punct:]' '-' )
export CI_COMMIT_REF_SLUG
CI_VARIABLES += CI_COMMIT_REF_SLUG

## The commit revision the project is built for
CI_COMMIT_SHA ?= $(shell ${GIT} rev-parse HEAD)
export CI_COMMIT_SHA
CI_VARIABLES += CI_COMMIT_SHA

## The first eight characters of CI_COMMIT_SHA
CI_COMMIT_SHORT_SHA ?= $(shell ${GIT} rev-parse --short HEAD)
export CI_COMMIT_SHORT_SHA
CI_VARIABLES += CI_COMMIT_SHORT_SHA

## The timestamp of the commit in the ISO 8601 format.
CI_COMMIT_TIMESTAMP ?= $(shell git log -1 --format=%ct)
export CI_COMMIT_TIMESTAMP
CI_VARIABLES += CI_COMMIT_TIMESTAMP

## The full path the repository is cloned to
CI_PROJECT_DIR ?= $(PROJECT_PATH)
export CI_PROJECT_DIR
CI_VARIABLES += CI_PROJECT_DIR

## The commit tag name. Can be empty if no tag corresponds to commit
CI_COMMIT_TAG ?= $(shell ${GIT} describe --tags --exact-match 2>/dev/null)
export CI_COMMIT_TAG
CI_VARIABLES += CI_COMMIT_TAG

## The internal ID of the job,
CI_JOB_ID ?= 0
export CI_JOB_ID
CI_VARIABLES += CI_JOB_ID

## The UTC datetime when the pipeline was created
CI_PIPELINE_CREATED_AT ?= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
export CI_PIPELINE_CREATED_AT
CI_VARIABLES += CI_PIPELINE_CREATED_AT

## The UTC datetime when a job started
CI_JOB_STARTED_AT ?= $(CI_PIPELINE_CREATED_AT)
export CI_JOB_STARTED_AT
CI_VARIABLES += CI_JOB_STARTED_AT

## The name of the environment for this job
CI_ENVIRONMENT_NAME ?= local
export CI_ENVIRONMENT_NAME
CI_VARIABLES += CI_ENVIRONMENT_NAME

## The simplified version of CI_ENVIRONMENT_NAME
CI_ENVIRONMENT_SLUG ?= $(CI_ENVIRONMENT_NAME)
export CI_ENVIRONMENT_SLUG
CI_VARIABLES += CI_ENVIRONMENT_SLUG

## The HTTP(S) address of the project.
CI_PROJECT_URL ?= $(basename $(shell echo "$(shell ${GIT} remote get-url origin)" | sed -r 's:git@([^/]+)\:(.*):https\://\1/\2:g' ))
export CI_PROJECT_URL
CI_VARIABLES += CI_PROJECT_URL

## The HTTP(S) address of the project.
CI_PROJECT_NAME ?= $(basename $(notdir $(shell ${GIT} remote get-url origin)))
export CI_PROJECT_NAME
CI_VARIABLES += CI_PROJECT_NAME

## The project namespace (username or group name) of the job.
CI_PROJECT_NAMESPACE ?= $(shell echo $(CI_PROJECT_URL) | sed -r 's|^https?://||' | cut -d '/' -f2- | xargs dirname)
export CI_PROJECT_NAMESPACE
CI_VARIABLES += CI_PROJECT_NAMESPACE

## The root project namespace (username or group name).
CI_PROJECT_ROOT_NAMESPACE ?= $(shell echo $(CI_PROJECT_NAMESPACE) | cut -d '/' -f1)
export CI_PROJECT_ROOT_NAMESPACE
CI_VARIABLES += CI_PROJECT_ROOT_NAMESPACE

## The project namespace with the project name included.
CI_PROJECT_PATH ?= $(CI_PROJECT_NAMESPACE)/$(CI_PROJECT_NAME)
export CI_PROJECT_PATH
CI_VARIABLES += CI_PROJECT_PATH

## The description of the runner.
CI_RUNNER_DESCRIPTION ?= $(shell hostname)
export CI_RUNNER_DESCRIPTION
CI_VARIABLES += CI_RUNNER_DESCRIPTION

## The unique ID of the runner being used
CI_RUNNER_ID ?= $(shell hostname)
export CI_RUNNER_ID
CI_VARIABLES += CI_RUNNER_ID

## The address of the GitLab Container Registry
CI_REGISTRY ?=
export CI_REGISTRY
CI_VARIABLES += CI_REGISTRY

ifneq ($(CI_REGISTRY),)
CI_REGISTRY_IMAGE_DEFAULT := $(CI_REGISTRY)/$(CI_PROJECT_PATH)
else
CI_REGISTRY_IMAGE_DEFAULT := $(CI_PROJECT_PATH)
endif
## The address of the project’s Container Registry
CI_REGISTRY_IMAGE ?= $(CI_REGISTRY_IMAGE_DEFAULT)
export CI_REGISTRY_IMAGE
CI_VARIABLES += CI_REGISTRY_IMAGE

## The username to push containers to the project’s Container Registry.
CI_REGISTRY_USER ?=
export CI_REGISTRY_USER
CI_VARIABLES += CI_REGISTRY_USER

## The password to push containers to the project’s Container Registry.
CI_REGISTRY_PASSWORD ?=
export CI_REGISTRY_PASSWORD
# To avoid unwanted forward to a container : this must be set explicitely if needed
# CI_VARIABLES += CI_REGISTRY_PASSWORD

## The docker image repository with the $CI_COMMIT_REF_SLUG suffix if not a release
CI_APPLICATION_REPOSITORY ?= $(if $(CI_COMMIT_TAG),$(CI_REGISTRY_IMAGE),$(CI_REGISTRY_IMAGE)/$(CI_COMMIT_REF_SLUG))
export CI_APPLICATION_REPOSITORY
CI_VARIABLES += CI_APPLICATION_REPOSITORY

## The docker image tag
CI_APPLICATION_TAG ?= $(or $(CI_COMMIT_TAG), $(CI_COMMIT_SHA))
export CI_APPLICATION_TAG
CI_VARIABLES += CI_APPLICATION_TAG

# Git variables

## Current git branch
GIT_BRANCH ?= $(CI_COMMIT_BRANCH)
## Current git commit
GIT_COMMIT ?= $(CI_COMMIT_SHA)
# Possible default git branches
# GIT_DEFAULT_BRANCH_LIST := main master next dev develop $(shell ${GIT} config --get 'init.defaultBranch')
## Default git branch (default: main)
GIT_DEFAULT_BRANCH ?= $(CI_DEFAULT_BRANCH)
## List of git remotes
# GIT_REMOTES ?= $(shell git remote -v | awk '{ print $$1; }' | sort | uniq)

# https://github.com/semantic-release/git#environment-variables

## The author name associated with commit
GIT_AUTHOR_NAME ?=
export GIT_AUTHOR_NAME

## The author email associated with commit
GIT_AUTHOR_EMAIL ?=
export GIT_AUTHOR_EMAIL

## The committer name associated with commit
GIT_COMMITTER_NAME ?=
export GIT_COMMITTER_NAME

## The committer email associated with commit
GIT_COMMITTER_EMAIL ?=
export GIT_COMMITTER_EMAIL

# Debug
##
# DEBUG_BIND ?= 127.0.0.1
##
# DEBUG_PORT ?= 9229

# print-%  : ; @echo "$*" = "$($*)"
