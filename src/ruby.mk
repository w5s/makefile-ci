ifneq ($(wildcard .rubocop.yml),)
	RUBOCOP_ENABLED := true
endif

ifneq ($(RUBY_ENABLED),)

# BUNDLE_PATH ?= ${PROJECT_VENDOR_PATH}/bundle
## Bundle `install` will exit with error if Gemfile.lock is not up to date
BUNDLE_FROZEN ?=
ifeq ($(CI),)
	BUNDLE_FROZEN ?= true
else
	BUNDLE_FORCE_RUBY_PLATFORM ?= true
endif
BUNDLE_INSTALL := ${BUNDLE} install
RUBOCOP := ${BUNDLE} exec rubocop
RAKE := ${BUNDLE} exec rake

# export
export BUNDLE_FORCE_RUBY_PLATFORM

${BUNDLE_CACHE_PATH}:
	@[ ! -z "${BUNDLE_CACHE_PATH}" ] && ${MKDIRP} "${BUNDLE_CACHE_PATH}"

${BUNDLE_PATH}: ${BUNDLE_CACHE_PATH}
	@[ ! -z "${BUNDLE_PATH}" ] && ${MKDIRP} "${BUNDLE_PATH}"

# Run bundle install only if yarn.lock or package-lock.json has changed
$(MAKE_CACHE_PATH)/bundle-install: $(MAKE_CACHE_PATH) ${BUNDLE_CACHE_PATH} ${BUNDLE_PATH} $(MAKEFILE_LIST) $(wildcard Gemfile*)
	@if [ -z "$(BUNDLE_PATH)" ]; then \
		${BUNDLE} config unset --local path; \
	else \
		${BUNDLE} config set --local path $(BUNDLE_PATH); \
	fi
	@${BUNDLE_INSTALL}
	@${TOUCH} $@

# Shortcut to bundle install
PHONY += bundle-install-cached
bundle-install-cached: $(MAKE_CACHE_PATH)/bundle-install
	@:

# Add `bundle install` to `make install`
PHONY += dependencies__ruby
dependencies__ruby:
	$(info Install Ruby dependencies...)
# 	@${RM} $(MAKE_CACHE_PATH)/bundle-install
	@${MAKE} bundle-install-cached

# Add rubocop to `make lint`
PHONY += lint__rubocop
lint__rubocop: bundle-install-cached
	$(info Lint Ruby sources...)
	@${RUBOCOP}

# Add rubocop to `make format`
PHONY += format__rubocop
format__rubocop: bundle-install-cached
	$(info Format Ruby sources...)
	@${RUBOCOP} -a

# Add rspec to `make test`
PHONY += test__rspec
test__rspec: bundle-install-cached
	$(info Test Ruby sources...)
	@${RAKE} spec

endif
