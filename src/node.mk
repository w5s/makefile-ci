# Include target only if enabled
ifneq ($(NODEJS_ENABLED),)

## Make cache path (default: .cache/node)
NODEJS_CACHE_PATH ?= $(PROJECT_CACHE_PATH)/node

## NodeJS package manager (yarn,npm)
NODEJS_PACKAGE_MANAGER ?=
# Detect nodejs package manager
ifeq ($(NODEJS_PACKAGE_MANAGER),)
	NODEJS_ENABLED := true
	ifneq ($(wildcard yarn.lock),)
		NODEJS_PACKAGE_MANAGER = yarn
	else
		NODEJS_PACKAGE_MANAGER = npm
	endif
endif

## NodeJS version
NODEJS_VERSION ?=
# Detect nodejs version
ifeq ($(NODEJS_VERSION),)
	ifneq ($(wildcard .tool-versions),)
		NODEJS_VERSION = $(shell cat .tool-versions | grep nodejs | awk '{print $$2}')
	else ifneq ($(wildcard .node-version),)
		NODEJS_VERSION = $(shell cat .node-version)
	else ifneq ($(wildcard .nvmrc),)
		NODEJS_VERSION = $(shell cat .nvmrc)
	endif
endif
export NODEJS_VERSION

# Define install command
ifeq ($(NODEJS_PACKAGE_MANAGER),yarn)
# Yarn package manager should be used
	ifeq ($(CI),)
		NODEJS_INSTALL = yarn install
	else
		NODEJS_INSTALL = yarn install --immutable
	endif
else
# NPM should be used
	ifeq ($(CI),)
		NODEJS_INSTALL = npm install
	else
		NODEJS_INSTALL = npm ci
	endif
endif

_node-install-required:
	@$(call log,info,"[NodeJS] Ensure dependencies....",1)
	@$(call log,debug,"Not Implemented yet....",2)
# TODO: implement this

# Create make cache directory
$(NODEJS_CACHE_PATH):
	$(Q)${MKDIRP} $(NODEJS_CACHE_PATH)

$(NODEJS_CACHE_PATH)/node-version: $(NODEJS_CACHE_PATH)
	$(Q)echo $(NODEJS_VERSION) > $@

.PHONY: node-setup
node-setup:
ifneq ($(NODEJS_PACKAGE_MANAGER),npm)
	@$(call log,info,"[NodeJS] Install package manager...",1)
	$(Q)corepack enable
endif
.setup:: node-setup # Add to `make setup`

.PHONY: node-install
node-install:
	@$(call log,info,"[NodeJS] Install dependencies...",1)
	$(Q)${NODEJS_INSTALL}
.dependencies:: node-install	# Add `npm install` to `make install`

.PHONY: node-lint
node-lint: _node-install-required
	@$(call log,info,"[NodeJS] Lint sources...",1)
	$(Q)npm run lint --if-present
.lint::	node-lint # Add `npm run lint` to `make lint`

.PHONY: node-format
node-format: _node-install-required
	@$(call log,info,"[NodeJS] Format sources...",1)
	$(Q)npm run format --if-present
.format:: node-format # Add `npm run test` to `make test`

.PHONY: node-test
node-test: _node-install-required
	@$(call log,info,"[NodeJS] Test sources...",1);
	$(Q)npm run test
.test:: node-test # Add npm test to `make test`

.PHONY: node-test-e2e
node-test-e2e: _node-install-required
	@$(call log,info,"[NodeJS] Test system...",1)
	$(Q)npm run test:e2e
.test-system:: node-test-e2e # Add rspec to `make test-system`

endif
