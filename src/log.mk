
# Externally define log levels
export LOG_DEBUG := 0
export LOG_INFO := 1
export LOG_WARN := 2
export LOG_ERROR := 3
export LOG_FATAL := 4

## Set the log level
MAKE_LOG_LEVEL ?= $(LOG_INFO)
export MAKE_LOG_LEVEL

# Define some commonly used values in log strings
log_header_debug := -d-
log_header_info := =i=
log_header_warn := =!=
log_header_error := =!=
log_header_fatal := !!!

# Defined in makefile-core
log_sgr0 := $(RESET)
log_color_debug := $(PURPLE)
log_color_info := $(BLUE)
log_color_warn := $(YELLOW)
log_color_error := $(RED)
log_color_fatal := $(RED)

#define some useful macros
log_to_upper = $(shell echo $(1) | tr '[:lower:]' '[:upper:]')
log_to_lower = $(shell echo $(1) | tr '[:upper:]' '[:lower:]')

# Define the logging macros

define __log_generic
([ $$MAKE_LOG_LEVEL -gt $(2) ] || echo "$(log_bold)$(3)$(4) $(5)$(1)$(log_sgr0)")
endef

define log
$(call __log_generic,$(2),$(LOG_$(call log_to_upper,$(1))),$(log_color_$(call log_to_lower,$(1))),$(log_header_$(call log_to_lower,$(1))),$(shell [ "$(or $(3),0)" = 0 ] || for i in $(shell seq 1 $(or $(3),0)); do echo -n '--'; done))
endef

# A function that will display a password with **** + last 4 characters
define mask-password
$(shell [ -z "$(1)" ] && (echo '') || (echo "****$(shell printf "$(1)" | tail -c 4)"))
endef
