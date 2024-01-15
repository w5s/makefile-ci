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

_bundle-install-required:
	@bundle check

# Add `bundle install` to `make install`
PHONY += dependencies__ruby
dependencies__ruby:
	$(info Install Ruby dependencies...)
	@if [ -z "$(BUNDLE_PATH)" ]; then \
		${BUNDLE} config unset --local path; \
	else \
		${BUNDLE} config set --local path $(BUNDLE_PATH); \
	fi
	@${BUNDLE_INSTALL}

# Rubocop targets
ifneq ($(RUBOCOP_ENABLED),)
# Add rubocop to `make lint`
PHONY += lint__rubocop
lint__rubocop: _bundle-install-required
	$(info Lint Ruby sources...)
	@${RUBOCOP}

# Add rubocop to `make format`
PHONY += format__rubocop
format__rubocop: _bundle-install-required
	$(info Format Ruby sources...)
	@${RUBOCOP} -a
endif

# Add rspec to `make test`
PHONY += test__rspec
test__rspec: _bundle-install-required
	$(info Test Ruby sources...)
	@${RAKE} spec

endif
