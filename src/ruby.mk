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
	@$(call log,info,"[Ruby] Ensure dependencies....",1)
	@bundle check

# Add `bundle install` to `make install`
.PHONY: ruby-install
ruby-install:
	@$(call log,info,"[Ruby] Install dependencies....",1)
	@if [ -z "$(BUNDLE_PATH)" ]; then \
		${BUNDLE} config unset --local path; \
	else \
		${BUNDLE} config set --local path $(BUNDLE_PATH); \
	fi
	@${BUNDLE_INSTALL}
.dependencies:: ruby-install # Add `bundle install` to `make install`

# Rubocop targets
ifneq ($(RUBOCOP_ENABLED),)

.PHONY: ruby-lint
ruby-lint: _bundle-install-required
	@$(call log,info,"[Ruby] Lint sources...",1)
	@${RUBOCOP}
.lint:: ruby-lint # Add rubocop to `make lint`

.PHONY: ruby-format
ruby-format: _bundle-install-required
	@$(call log,info,"[Ruby] Format sources...",1)
	@${RUBOCOP} -a
.format:: ruby-format # Add rubocop to `make format`

endif

.PHONY: ruby-test
ruby-test: _bundle-install-required
	@$(call log,info,"[Ruby] Test sources...",1)
	@${RAKE} db:migrate || echo "Warning: Migration failed"
	@${RAKE} spec
.test:: ruby-test # Add rspec to `make test`

endif
