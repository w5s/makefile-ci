
DEVCONTAINER := devcontainer

ifneq ($(wildcard .devcontainer),)
	DEVCONTAINER_ENABLED := true
endif

ifneq ($(DEVCONTAINER_ENABLED),)
## DevContainer flags added for each command
DEVCONTAINER_FLAGS ?= --workspace-folder .

devcontainers-cli:
	@if ! command devcontainer --version &>/dev/null; then \
		echo "Installing Dev Containers CLI..."; \
		npm install -g @devcontainers/cli; \
	fi

devcontainer-build: devcontainers-cli
	@${DEVCONTAINER} build $(DEVCONTAINER_FLAGS)

devcontainer-up: devcontainers-cli
	@${DEVCONTAINER} up $(DEVCONTAINER_FLAGS)

devcontainer-start: devcontainer-up
	@${DEVCONTAINER} exec $(DEVCONTAINER_FLAGS) /bin/zsh

# Add `@devcontainers/cli` to `make prepare`
.PHONY: .prepare
.prepare:: devcontainers-cli
endif

