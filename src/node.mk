## NodeJS cache path (default: .cache/node)
NODEJS_CACHE_PATH ?= $(PROJECT_CACHE_PATH)/node

## NodeJS version manager used to install node (asdf, nvm, ...)
NODEJS_VERSION_MANAGER ?= $(call resolve-command,asdf nvm nodenv)

## NodeJS package manager (npm,pnpm,yarn,yarn-berry)
NODEJS_PACKAGE_MANAGER ?=
# Detect nodejs package manager
ifeq ($(NODEJS_PACKAGE_MANAGER),)
	ifneq ($(wildcard yarn.lock),)
		ifneq ($(wildcard .yarnrc.yml),)
			NODEJS_PACKAGE_MANAGER = yarn-berry
			NODEJS_PACKAGE_MANAGER_COMMAND = yarn
		else
			NODEJS_PACKAGE_MANAGER = yarn
			NODEJS_PACKAGE_MANAGER_COMMAND = yarn
		endif
	else ifneq ($(wildcard pnpm-lock.yaml),)
		NODEJS_PACKAGE_MANAGER = pnpm
		NODEJS_PACKAGE_MANAGER_COMMAND = pnpm
	else
		NODEJS_PACKAGE_MANAGER = npm
		NODEJS_PACKAGE_MANAGER_COMMAND = npm
	endif
endif

# Corepack enable command
ifeq ($(NODEJS_VERSION_MANAGER),asdf)
	COREPACK_ENABLE := corepack enable && asdf reshim nodejs
else
	COREPACK_ENABLE := corepack enable
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
ifeq ($(NODEJS_PACKAGE_MANAGER),yarn-berry)
# Yarn berry
	ifeq ($(CI),)
		NODEJS_INSTALL = yarn install
	else
		NODEJS_INSTALL = yarn install --immutable
		YARN_CACHE_FOLDER ?= $(PROJECT_CACHE_PATH)/yarn
		YARN_ENABLE_GLOBAL_CACHE ?= false
	endif
else ifeq ($(NODEJS_PACKAGE_MANAGER),yarn)
# Yarn
	ifeq ($(CI),)
		NODEJS_INSTALL = yarn install
	else
		NODEJS_INSTALL = yarn install --frozen-file
		YARN_CACHE_FOLDER ?= $(PROJECT_CACHE_PATH)/yarn
		YARN_ENABLE_GLOBAL_CACHE ?= false
	endif
else ifeq ($(NODEJS_PACKAGE_MANAGER),pnpm)
# PNPM
	ifeq ($(CI),)
		NODEJS_INSTALL = pnpm install
	else
		NODEJS_INSTALL = pnpm install --frozen-file
		PNPM_CONFIG_CACHE ?= $(PROJECT_CACHE_PATH)/pnpm
	endif
else
# NPM should be used
	ifeq ($(CI),)
		NODEJS_INSTALL = npm install
	else
		NODEJS_INSTALL = npm ci
		NPM_CONFIG_CACHE ?= $(PROJECT_CACHE_PATH)/npm
	endif
endif

# Create make cache directory
$(NODEJS_CACHE_PATH):
	$(Q)${MKDIRP} $(NODEJS_CACHE_PATH)

# A file that contains node required version
$(NODEJS_CACHE_PATH)/node-version: $(NODEJS_CACHE_PATH)
	$(Q)echo $(NODEJS_VERSION) > $@

# A target that will run node install only if lockfile was changed
node_modules/.make-state: $(wildcard yarn.lock package-lock.json pnpm-lock.yaml)
	@$(call log,info,"[NodeJS] Ensure dependencies....",1)
	$(Q)${NODEJS_INSTALL}
	$(Q)${TOUCH} $@

# Install dependencies only if needed
.PHONY: node-dependencies
node-dependencies: node-setup node_modules/.make-state
.dependencies:: node-dependencies

.PHONY: node-setup
node-setup: $(NODEJS_CACHE_PATH)/node-version

# Try installing node using $(NODEJS_VERSION_MANAGER)
ifeq ($(NODEJS_VERSION),)
	@$(call log,warn,"[NodeJS] Cannot install nodejs. Please set NODEJS_VERSION or configure .tools-versions",1)
else ifneq ($(shell node -v 2>/dev/null),v$(NODEJS_VERSION))
	@$(call log,info,"[NodeJS] Install NodeJS with $(NODEJS_VERSION_MANAGER)...",1)

ifeq ($(NODEJS_VERSION_MANAGER),asdf)
	$(Q)$(ASDF) plugin add nodejs
	$(Q)$(ASDF) install nodejs $(NODEJS_VERSION)
else
	@$(call panic,[NodeJS] Unsupported nodejs version manager $(NODEJS_VERSION_MANAGER))
endif

endif

# Try installing package manager
ifneq ($(NODEJS_PACKAGE_MANAGER),npm)
# Only for asdf we have to reshim after corepack
	$(Q)if ! $(NODEJS_PACKAGE_MANAGER_COMMAND) -v &>/dev/null; then \
	  $(call log,info,"[NodeJS] Install $(NODEJS_PACKAGE_MANAGER)...",1); \
		$(COREPACK_ENABLE); \
	fi
endif
.setup:: node-setup # Add to `make setup`

.PHONY: node-install
node-install: node-setup
	$(Q)$(RM) -f node_modules/.make-state
	$(Q)$(MAKE) node-dependencies
.install:: node-install	# Add `npm install` to `make install`

.PHONY: node-lint
node-lint: node-dependencies
	@$(call log,info,"[NodeJS] Lint sources...",1)
	$(Q)npm run lint --if-present
.lint::	node-lint # Add `npm run lint` to `make lint`

.PHONY: node-format
node-format: node-dependencies
	@$(call log,info,"[NodeJS] Format sources...",1)
	$(Q)npm run format --if-present
.format:: node-format # Add `npm run test` to `make test`

.PHONY: node-test
node-test: node-dependencies
	@$(call log,info,"[NodeJS] Test sources...",1);
	$(Q)npm run test
.test:: node-test # Add npm test to `make test`

.PHONY: node-test-e2e
node-test-e2e: node-dependencies
	@$(call log,info,"[NodeJS] Test system...",1)
	$(Q)npm run test:e2e
.test-e2e:: node-test-e2e # Add rspec to `make test-e2e`

.PHONY: node-clean
node-clean: node-dependencies
	@$(call log,info,"[NodeJS] Clean files...",1);
	$(Q)npm run clean --if-present
.clean:: node-clean # Add npm run clean to `make clean`
