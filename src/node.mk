
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


.PHONY: prepare
.prepare::
	@if ! command yarn --version &>/dev/null; then \
		echo "Installing yarn..."; \
		npm install -g yarn; \
	fi

.PHONY: node-install
node-install:
	$(info [NodeJS] Install dependencies...)
	@${NODEJS_INSTALL}
.dependencies:: node-install	# Add `npm install` to `make install`

.PHONY: node-lint
node-lint: _node-install-required
	$(info [NodeJS] Lint sources...)
	@npm run lint --if-present
.lint::	node-lint # Add `npm run lint` to `make lint`

.PHONY: node-format
node-format: _node-install-required
	$(info [NodeJS] Format sources...)
	@npm run format --if-present
.format:: node-format # Add `npm run test` to `make test`

.PHONY: node-test
node-test: _node-install-required
	$(info [NodeJS] Test sources...)
	@npm run test
.test:: node-test # Add npm test to `make test`

endif
