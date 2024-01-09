PHONY += all
all: prepare install lint ## Run all targets

PHONY += prepare
prepare: $(filter prepare__%, $(PHONY)) ## Install external dependencies

PHONY += dependencies
dependencies: $(filter dependencies__%, $(PHONY)) ## Install all dependencies

PHONY += build
build: $(filter build__%, $(PHONY)) ## Build sources

PHONY += clean
clean: $(filter clean__%, $(PHONY)) ## Clean build files

PHONY += lint
lint: $(filter lint__%, $(PHONY)) ## Lint all source files

PHONY += format
format: $(filter format__%, $(PHONY)) ## Format all source files

PHONY += test
test: $(filter test__%, $(PHONY)) ## Run unit tests

PHONY += develop
develop: prepare $(filter develop__%, $(PHONY)) ## Setups a local development environment
