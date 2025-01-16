# Return a newline character
#
# @example
#   $(newline)
define newline


endef

# Display a password with **** + last 4 characters
#
# @example
#  echo $(call mask-password,$(PASSWORD))
#
define mask-password
$(shell [ -z '$(1)' ] && (echo '') || (echo "****$(shell echo $(1) | tail -c 4)"))
endef

# Escape a shell string passed as a single quoted string
#
# @example
#  embeddable-text = $(call escape-shell,$(SOME_TEXT))
#
escape-shell = $(subst $(newline),\$(newline),$(subst ','\'',$(1)))

# Fallback if log is not defined
#
# @example
# $(call log,info,Message,0)
#
ifeq ($(log),)
define log
echo [$(1)] $(2)
endef
endif

# Returns the first command found
#
# @example
# NODE_VERSION_MANAGER := $(call resolve-command,asdf nodenv nvm)
#
define resolve-command
$(firstword $(foreach cmd,$(1),$(shell which $(cmd) &>/dev/null && echo $(cmd))))
endef

# Log a message and exit program
#
# @example
# $(call panic,Something wrong happened !)
#
define panic
	$(call log,fatal,$(1))
	exit 1
endef

# Slugify a string value.
#
# @param $(1) - The string to slugify
#
# @example
# 	$(call slugify,HeLlO wOrLd) # "hello-world"
slugify = $(shell echo $(call escape-shell,$(1)) | tr '[:upper:]' '[:lower:]' | tr '[:punct:]' '-' | tr ' ' '-' )

# Lower-case a string value.
#
# @param $(1) - The string to lower-case.
#
# @example
# 	$(call lowercase,HeLlO wOrLd) # "hello world"
lowercase = $(shell echo $(call escape-shell,$(1)) | tr '[:upper:]' '[:lower:]')

# Determine the "truthiness" of a value.
#
# @param $(1): The value to determine the truthiness of.
#
# A value is considered to be falsy if it is:
#
#   - empty, or
#   - equal to "0", "N", "NO", "F" or "FALSE" after upper-casing.
#
# If the value is truthy then the value is returned as-is, otherwise no value
# is returned.
#
# @example
#
#     truthy := y
#     truthy-flag := $(call filter-false,$(truthy)) # "y"
#
#     falsy := n
#     falsy-flag := $(call filter-false,$(falsy)) # <empty>
#
filter-false = $(filter-out 0 n no f false,$(call lowercase,$(1)))
