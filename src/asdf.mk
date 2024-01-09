ASDF := asdf

ifneq ($(ASDF_ENABLED),)

## Ruby version
RUBY_VERSION ?= $(shell cat .tool-versions | grep ruby | awk '{print $$2}')
export RUBY_VERSION

## NodeJS version
NODEJS_VERSION ?= $(shell cat .tool-versions | grep nodejs | awk '{print $$2}')
export NODEJS_VERSION

# Run node install only if yarn.lock or package-lock.json has changed
$(MAKE_CACHE_PATH)/asdf-install: $(MAKE_CACHE_PATH) .tool-versions
	$(info Install ASDF tools...)
	@${ASDF} install
	@${TOUCH} $@

PHONY += asdf-install-cached
asdf-install-cached: $(MAKE_CACHE_PATH)/asdf-install
	@:

# Add `asdf install` to `make prepare`
PHONY += prepare__asdf
prepare__asdf: asdf-install-cached
endif
