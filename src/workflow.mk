.PHONY: all
all: setup dependencies lint ## Run all targets

#-------------
# SETUP
#-------------
.PHONY: setup setup.default setup.local setup.ci .setup.pre .setup .setup.post
setup: .workflow-run-setup ## Install global dependencies and setup the project
setup.default: .setup.pre .setup .setup.post
setup.local: setup.default
setup.ci: setup.default
.setup.pre::
	@:
.setup::
	@:
.setup.post::
	@:

#-------------
# INSTALL
#-------------
.PHONY: install install.default install.local install.ci .install.pre .dependencies .install.post
install: .workflow-run-dependencies ## Install project dependencies (force installation)
install.default: .install.pre .dependencies .install.post
install.local: install.default
install.ci: install.default
.install.pre::
	@:
.install::
	@:
.install.post::
	@:

#-------------
# DEPENDENCIES
#-------------
.PHONY: dependencies dependencies.default dependencies.local dependencies.ci .dependencies.pre .dependencies .dependencies.post
dependencies: .workflow-run-dependencies ## Ensure project dependencies are present (install only if needed)
dependencies.default: .dependencies.pre .dependencies .dependencies.post
dependencies.local: dependencies.default
dependencies.ci: dependencies.default
.dependencies.pre::
	@:
.dependencies::
	@:
.dependencies.post::
	@:

#-------------
# BUILD
#-------------
.PHONY: build build.default build.local build.ci .build.pre .build .build.post
build: .workflow-run-build ## Build sources
build.default: .build.pre .build .build.post
build.local: build.default
# build.ci: build.default # TODO: implement this
.build.pre::
	@:
.build::
	@:
.build.post::
	@:

#-------------
# CLEAN
#-------------
.PHONY: clean clean.default clean.local clean.ci .clean.pre .clean .clean.post
clean: .workflow-run-clean ## Clean build files
clean.default: .clean.pre .clean .clean.post
clean.local: clean.default
clean.ci: clean.default
.clean.pre::
	@:
.clean::
	@:
.clean.post::
	@:

#-------------
# LINT
#-------------
.PHONY: lint lint.default lint.local lint.ci .lint.pre .lint .lint.post
lint: .workflow-run-lint ## Lint all source files
lint.default: .lint.pre .lint .lint.post
lint.local: lint.default
lint.ci: lint.default
.lint.pre::
	@:
.lint::
	@:
.lint.post::
	@:

#-------------
# FORMAT
#-------------
.PHONY: format format.default format.local format.ci .format.pre .format .format.post
format: .workflow-run-format ## Format all source files
format.default: .format.pre .format .format.post
format.local: format.default
format.ci: format.default
.format.pre::
	@:
.format::
	@:
.format.post::
	@:

#-------------
# TEST
#-------------
.PHONY: test test.default test.local test.ci .test.pre .test .test.post
test: .workflow-run-test ## Run unit tests
test.default: .test.pre .test .test.post
test.local: test.default
test.ci: test.default
.test.pre::
	@:
.test::
	@:
.test.post::
	@:

#-------------
# TEST SYSTEM (E2E)
#-------------
.PHONY: test-e2e test-e2e.default test-e2e.local test-e2e.ci .test-e2e.pre .test .test-e2e.post
test-e2e: .workflow-run-test-e2e ## Run system tests (e2e)
test-e2e.local: .test-e2e.pre .test-e2e .test-e2e.post
test-e2e.ci: test-e2e.default
.test-e2e.pre::
	@:
.test-e2e::
	@:
.test-e2e.post::
	@:

#-------------
# DEVELOP
#-------------
.PHONY: develop develop.default develop.local develop.ci .develop.pre .develop .develop.post
develop: .workflow-run-develop ## Setups a local development environment
develop.local: .develop.pre .develop .develop.post
develop.ci:
	@$(call log,warn,"[Develop] Job disabled in CI mode",0)
.develop.pre::
	@:
.develop::
	@:
.develop.post::
	@:

# A list of variable names that will be displayed before deployment
DEPLOY_VARIABLES := \
	CI_ENVIRONMENT_URL

#-------------
# DEPLOY
#-------------
.PHONY: deploy deploy.default deploy.local deploy.ci .deploy.pre .deploy .deploy.post
deploy: .workflow-run-deploy ## Deploy the application to the given environment
deploy.default: .deploy.pre .deploy .deploy.post
deploy.local: .deploy-check
	$(Q)echo "WARNING! This will deploy local files"
	$(Q)read -r -p "Continue? [y/N]" REPLY;echo; \
	if [[ "$$REPLY" =~ ^[Yy]$$ ]]; then \
		$(MAKE) deploy.default; \
	fi
deploy.ci: .deploy-check
	$(Q)$(MAKE) deploy.default;

.deploy-check:
# Display CI_PROJECT_NAME
	@$(call log,info,CI_PROJECT_NAME=$(CI_PROJECT_NAME),1);
# Check CI_ENVIRONMENT_NAME
ifeq ($(CI_ENVIRONMENT_NAME),local)
	@$(call log,error,CI_ENVIRONMENT_NAME=$(CI_ENVIRONMENT_NAME) (invalid value, only available for local),1);
else
	@$(call log,info,CI_ENVIRONMENT_NAME=$(CI_ENVIRONMENT_NAME),1);
endif
# Display important deploy variables
	@$(foreach V,$(sort $(DEPLOY_VARIABLES)), \
		$(call log,info,$V=$($V),1); \
	)
# Stop program if error
ifeq ($(CI_ENVIRONMENT_NAME),local)
	@$(call log,fatal,Deployment stopped,1);
	$(Q)exit 1;
endif

.deploy.pre::
	@:
.deploy::
	@:
.deploy.post::
	@:

#-------------
# RESCUE
#-------------
.PHONY: rescue rescue.default rescue.local rescue.ci .rescue.pre .rescue .rescue.post
rescue: .workflow-run-rescue ## Clean everything in case of problem
rescue.default: .rescue.pre .rescue .rescue.post
rescue.local: rescue.default
rescue.ci:
	@$(call log,warn,"[Rescue] Job disabled in CI mode",0)

.rescue.pre::
	@:
.rescue::
	@:
.rescue.post::
	@:

# Reinstall after rescue
.rescue.post::
	@$(call log,info,"[Git] Clean all local changes...",1)
	$(Q)echo "WARNING! This will remove all non commited git changes."
	$(Q)read -r -p "Continue? [y/N]" REPLY;echo; \
	if [[ "$$REPLY" =~ ^[Yy]$$ ]]; then \
		$(GIT) clean -fdx; \
	fi
.rescue.post:: prepare dependencies

# This job will run
.PHONY: .workflow-run-%
ifneq ($(CI),)
.workflow-run-%:
	@$(call log,info,"[Make] $* \(mode=CI\)")
	@${MAKE} $*.ci
else
.workflow-run-%:
	@$(call log,info,"[Make] $* \(mode=Local\)")
	@${MAKE} $*.local
endif
