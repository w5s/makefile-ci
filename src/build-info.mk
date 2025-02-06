# File containing the current build number
#
# In local mode, the build number is generated when make command is executed
# In CI mode, the build number is generated at the start of pipeline
CI_BUILD_NUMBER_FILE := $(MAKE_CACHE_PATH)/build-number

## Type of build (release/debug)
CI_BUILD_TYPE ?=
ifeq ($(CI_BUILD_TYPE),)
	ifneq ($(call filter-false,$(CI)),)
		CI_BUILD_TYPE = release
	else
		CI_BUILD_TYPE = debug
	endif
endif
export CI_BUILD_TYPE
CI_VARIABLES += CI_BUILD_TYPE

# Target generating the build number from current timestamp
$(CI_BUILD_NUMBER_FILE): $(MAKE_PIDFILE)
	$(Q)$(MKDIRP) $(dir $@)
	$(Q)echo "$$($(DATE) +%s)" > $@;
	@$(call log,debug,[Make] CI_BUILD_NUMBER=$(CI_BUILD_NUMBER) saved to "$@",0)

# Create or update make build-number file before each job.
# This will ensure that the file always exists
before_each:: $(CI_BUILD_NUMBER_FILE)
	@:

## A unique identifier for this build, it can be used in ios, android version number
CI_BUILD_NUMBER ?= $(shell cat $(CI_BUILD_NUMBER_FILE))
export CI_BUILD_NUMBER
CI_VARIABLES += CI_BUILD_NUMBER

# Target that will create the current build number
# WARNING: this implementation will recreate a new build number for every new make command
# TODO: we should implement a special case for CI, that will use a previously generated file
.PHONY: build-number
build-number: $(CI_BUILD_NUMBER_FILE) ## Generate a new build number and display it in console
	@echo $(CI_BUILD_NUMBER)
