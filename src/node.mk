
## NodeJS package manager (yarn,npm)
NODEJS_PACKAGE_MANAGER ?=

# Include target only if enabled
ifneq ($(NODEJS_ENABLED),)

# Detect nodejs package manager
ifeq ($(NODEJS_PACKAGE_MANAGER),)
	NODEJS_ENABLED := true
	ifneq ($(wildcard yarn.lock),)
		NODEJS_PACKAGE_MANAGER = yarn
	else
		NODEJS_PACKAGE_MANAGER = npm
	endif
endif

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
# TODO: implement this
	@:


PHONY += prepare__yarn
prepare__yarn:
	@if ! command yarn --version &>/dev/null; then \
		echo "Installing yarn..."; \
		npm install -g yarn; \
	fi

# Add `npm install` to `make install`
PHONY += dependencies__node
dependencies__node:
	$(info [NodeJS] Install dependencies...)
	@${NODEJS_INSTALL}

# Add `npm run lint` to `make lint`
PHONY += lint__node
lint__node: _node-install-required
	$(info [NodeJS] Lint sources...)
	@npm run lint --if-present

# Add `npm run test` to `make test`
PHONY += format__node
format__node: _node-install-required
	$(info [NodeJS] Format sources...)
	@npm run format --if-present

# Add npm test to `make test`
PHONY += test__node
test__node: _node-install-required
	$(info [NodeJS] Test sources...)
	@npm run test

endif
