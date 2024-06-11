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
