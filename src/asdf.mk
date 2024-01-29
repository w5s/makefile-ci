ASDF := asdf
# Variables defined by this asdf script
ASDF_VARIABLES := \
	RUBY_VERSION \
	NODEJS_VERSION

ifneq ($(RUBY_ENABLED),)
## Bundler gem version
BUNDLER_VERSION ?= $(shell if [ -e Gemfile.lock ]; then grep "BUNDLED WITH" Gemfile.lock -A 1 | grep -v "BUNDLED WITH" | tr -d "[:space:]"; else echo ""; fi)
ASDF_VARIABLES += BUNDLER_VERSION
endif

ifneq ($(ASDF_ENABLED),)

## Ruby version
RUBY_VERSION ?= $(shell cat .tool-versions | grep ruby | awk '{print $$2}')
export RUBY_VERSION

## NodeJS version
NODEJS_VERSION ?= $(shell cat .tool-versions | grep nodejs | awk '{print $$2}')
export NODEJS_VERSION

# Run node install only if yarn.lock or package-lock.json has changed
$(MAKE_CACHE_PATH)/asdf-install: $(MAKE_CACHE_PATH) .tool-versions
	$(call log,info,"[ASDF] Install tools...",1)
	@${ASDF} install
	@${TOUCH} $@

.PHONY: asdf-install-cached
asdf-install-cached: $(MAKE_CACHE_PATH)/asdf-install
	@:

# Add `asdf install` to `make prepare`
.PHONY: .prepare
.prepare:: asdf-install-cached
endif
