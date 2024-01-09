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
include $(SELF_DIR)variables.mk
include $(SELF_DIR)dotenv.mk
include $(SELF_DIR)rescue.mk
include $(SELF_DIR)cache.mk

ifneq ($(ASDF_ENABLED),)
include $(SELF_DIR)asdf.mk
endif

ifneq ($(DOCKER_ENABLED),)
include $(SELF_DIR)docker.mk
endif

ifneq ($(DEVCONTAINER_ENABLED),)
include $(SELF_DIR)devcontainer.mk
endif

include $(SELF_DIR)githooks.mk

ifneq ($(NODEJS_ENABLED),)
include $(SELF_DIR)node.mk
endif

ifneq ($(RUBY_ENABLED),)
include $(SELF_DIR)ruby.mk
endif

include $(SELF_DIR)workflow.mk

