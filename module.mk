SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

# Features detection

## DotEnv feature enabled
DOTENV_ENABLED ?= true
ifneq ($(wildcard .tool-versions),)
## ASDF feature enabled
ASDF_ENABLED ?= true
endif
ifneq ($(wildcard Dockerfile),)
## Docker feature enabled
DOCKER_ENABLED ?= true
endif
ifneq ($(wildcard .devcontainer),)
## DevContainer feature enabled
DEVCONTAINER_ENABLED ?= true
endif
ifneq ($(wildcard package.json),)
## NodeJS feature enabled
NODEJS_ENABLED ?= true
endif
ifneq ($(wildcard Gemfile),)
## Ruby feature enabled
RUBY_ENABLED ?= true
endif

# Include variables
include $(SELF_DIR)src/functions.mk
include $(SELF_DIR)src/variables.mk
include $(SELF_DIR)src/log.mk
include $(SELF_DIR)src/dotenv.mk
include $(SELF_DIR)src/rescue.mk
include $(SELF_DIR)src/cache.mk

ifneq ($(ASDF_ENABLED),)
include $(SELF_DIR)src/asdf.mk
endif

ifneq ($(DOCKER_ENABLED),)
include $(SELF_DIR)src/docker.mk
include $(SELF_DIR)src/docker-compose.mk
endif

ifneq ($(DEVCONTAINER_ENABLED),)
include $(SELF_DIR)src/devcontainer.mk
endif

include $(SELF_DIR)src/githooks.mk

ifneq ($(NODEJS_ENABLED),)
include $(SELF_DIR)src/node.mk
endif

ifneq ($(RUBY_ENABLED),)
include $(SELF_DIR)src/ruby.mk
endif

include $(SELF_DIR)src/scalingo.mk

include $(SELF_DIR)src/workflow.mk

