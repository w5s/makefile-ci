ifneq ($(wildcard .rubocop.yml),)
	RUBOCOP_ENABLED := true
endif

ifneq ($(wildcard .rubycritic.yml),)
	RUBYCRITIC_ENABLED := true
endif

ifneq ($(RUBY_ENABLED),)

## Ruby cache path (default: .cache/ruby)
RUBY_CACHE_PATH ?= $(PROJECT_CACHE_PATH)/ruby

## Ruby version
RUBY_VERSION ?=
# Detect ruby version
ifeq ($(RUBY_VERSION),)
	ifneq ($(wildcard .tool-versions),)
		RUBY_VERSION = $(shell cat .tool-versions | grep ruby | awk '{print $$2}')
	else ifneq ($(wildcard .ruby-version),)
		RUBY_VERSION = $(shell cat .ruby-version)
	else
		RUBY_VERSION =
	endif
endif
export RUBY_VERSION

## Bundler gem version
BUNDLER_VERSION ?= $(shell if [ -e Gemfile.lock ]; then grep "BUNDLED WITH" Gemfile.lock -A 1 | grep -v "BUNDLED WITH" | tr -d "[:space:]"; else echo ""; fi)

# BUNDLE_PATH ?= ${PROJECT_VENDOR_PATH}/bundle
BUNDLE_INSTALL := ${BUNDLE} install
RUBOCOP := ${BUNDLE} exec rubocop
RUBYCRITIC := ${BUNDLE} exec rubycritic
# RUBYCRITIC_FLAGS :=
RAKE := ${BUNDLE} exec rake

## Bundle `install` will exit with error if Gemfile.lock is not up to date
BUNDLE_FROZEN ?=
## Bundle `install` will force platform
BUNDLE_FORCE_RUBY_PLATFORM ?=
ifeq ($(CI),)
# do nothing
else
	BUNDLE_FROZEN ?= true
	RUBYCRITIC_FLAGS += --mode-ci
endif

# export
export BUNDLE_FORCE_RUBY_PLATFORM

# Create make cache directory
$(RUBY_CACHE_PATH):
	$(Q)${MKDIRP} $(RUBY_CACHE_PATH)

$(RUBY_CACHE_PATH)/ruby-version: $(RUBY_CACHE_PATH)
	$(Q)echo $(RUBY_VERSION) > $@

${BUNDLE_CACHE_PATH}:
	@[ ! -z "${BUNDLE_CACHE_PATH}" ] && ${MKDIRP} "${BUNDLE_CACHE_PATH}"

${BUNDLE_PATH}: ${BUNDLE_CACHE_PATH}
	@[ ! -z "${BUNDLE_PATH}" ] && ${MKDIRP} "${BUNDLE_PATH}"

_bundle-install-required:
	@$(call log,info,"[Ruby] Ensure dependencies....",1)
	$(Q)bundle check

# ruby-setup
.PHONY: ruby-setup
ruby-setup: $(RUBY_CACHE_PATH)/ruby-version
ifneq ($(shell ruby -v),v$(RUBY_VERSION))
	@$(call log,info,"[Ruby] Install Ruby...",1)
	$(Q)$(ASDF) plugin add ruby
	$(Q)$(ASDF) install ruby
endif
.setup:: ruby-setup # Add to `make setup`

# ruby-install
.PHONY: ruby-install
ruby-install: ruby-setup
	@$(call log,info,"[Ruby] Install dependencies....",1)
	$(Q)if [ -z "$(BUNDLE_PATH)" ]; then \
		${BUNDLE} config unset --local path; \
	else \
		${BUNDLE} config set --local path $(BUNDLE_PATH); \
	fi
	$(Q)${BUNDLE_INSTALL}
.dependencies:: ruby-install # Add `bundle install` to `make install`

# Rubocop targets
ifneq ($(RUBOCOP_ENABLED),)

.PHONY: ruby-lint
ruby-lint: _bundle-install-required
	@$(call log,info,"[Ruby] Lint sources...",1)
	$(Q)${RUBOCOP}
.lint:: ruby-lint # Add rubocop to `make lint`

.PHONY: ruby-format
ruby-format: _bundle-install-required
	@$(call log,info,"[Ruby] Format sources...",1)
	$(Q)${RUBOCOP} -a
.format:: ruby-format # Add rubocop to `make format`

endif

# RubyCritic targets
ifneq ($(RUBYCRITIC_ENABLED),)

.PHONY: ruby-critic
ruby-critic: _bundle-install-required
	@$(call log,info,"[Ruby] Rubycritic...",1)
#   $(Q)$(GIT) fetch origin $(CI_DEFAULT_BRANCH):$(CI_DEFAULT_BRANCH)
	$(Q)$(RUBYCRITIC) $(RUBYCRITIC_FLAGS)
endif

.PHONY: ruby-test
ruby-test: _bundle-install-required
	@$(call log,info,"[Ruby] Test sources...",1)
	$(Q)${RAKE} db:migrate || echo "Warning: Migration failed"
	$(Q)${RAKE} spec
.test:: ruby-test # Add rspec to `make test`

endif
