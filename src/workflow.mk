.PHONY: all
all: setup dependencies lint ## Run all targets

#-------------
# HOOKS
#-------------

# This will be run before each workflow job
#
# Example:
# before_each::
# 	@echo Before each !
#
before_each::
	@$(call log,debug,[Make] before_each hook,0)

# This will be run after each workflow job
#
# Example:
# after_each::
# 	@echo After each !
#
after_each::
	@$(call log,debug,[Make] after_each hook,0)

#-------------
# SETUP
#-------------
.PHONY: setup setup.default setup.local setup.ci .setup.before .setup .setup.after
setup: setup.workflow-run ## Install global dependencies and setup the project
setup.default: .setup.workflow-hooks
setup.local: setup.default
setup.ci: setup.default
.setup.before::
	@:
.setup::
	@:
.setup.after::
	@:

#-------------
# INSTALL
#-------------
.PHONY: install install.default install.local install.ci .install.before .install .install.after
install: install.workflow-run ## Install project dependencies (force installation)
install.default: .install.workflow-hooks
install.local: install.default
install.ci: install.default
.install.before::
	@:
.install::
	@:
.install.after::
	@:

#-------------
# DEPENDENCIES
#-------------
.PHONY: dependencies dependencies.default dependencies.local dependencies.ci .dependencies.before .dependencies .dependencies.after
dependencies: dependencies.workflow-run ## Ensure project dependencies are present (install only if needed)
dependencies.default: .dependencies.workflow-hooks
dependencies.local: dependencies.default
dependencies.ci: dependencies.default
.dependencies.before::
	@:
.dependencies::
	@:
.dependencies.after::
	@:

#-------------
# BUILD
#-------------
.PHONY: build build.default build.local build.ci .build.before .build .build.after
build: build.workflow-run ## Build sources
build.default: .build.workflow-hooks
build.local: build.default
# build.ci: build.default # TODO: implement this
.build.before::
	@:
.build::
	@:
.build.after::
	@:

#-------------
# CLEAN
#-------------
.PHONY: clean clean.default clean.local clean.ci .clean.before .clean .clean.after
clean: clean.workflow-run ## Clean build files
clean.default: .clean.workflow-hooks
clean.local: clean.default
clean.ci: clean.default
.clean.before::
	@:
.clean::
	@:
.clean.after::
	@:

#-------------
# LINT
#-------------
.PHONY: lint lint.default lint.local lint.ci .lint.before .lint .lint.after
lint: dependencies lint.workflow-run ## Lint all source files
lint.default: .lint.workflow-hooks
lint.local: lint.default
lint.ci: lint.default
.lint.before::
	@:
.lint::
	@:
.lint.after::
	@:

#-------------
# FORMAT
#-------------
.PHONY: format format.default format.local format.ci .format.before .format .format.after
format: dependencies format.workflow-run ## Format all source files
format.default: .format.workflow-hooks
format.local: format.default
format.ci: format.default
.format.before::
	@:
.format::
	@:
.format.after::
	@:

#-------------
# TEST
#-------------
.PHONY: test test.default test.local test.ci .test.before .test .test.after
test: dependencies test.workflow-run ## Run unit tests
test.default: .test.workflow-hooks
test.local: test.default
test.ci: test.default
.test.before::
	@:
.test::
	@:
.test.after::
	@:

#-------------
# TEST SYSTEM (E2E)
#-------------
.PHONY: test-e2e test-e2e.default test-e2e.local test-e2e.ci .test-e2e.before .test .test-e2e.after
test-e2e: dependencies test-e2e.workflow-run ## Run system tests (e2e)
test-e2e.default: .test-e2e.workflow-hooks
test-e2e.local: test-e2e.default
test-e2e.ci: test-e2e.default
.test-e2e.before::
	@:
.test-e2e::
	@:
.test-e2e.after::
	@:

#-------------
# DEVELOP
#-------------
.PHONY: develop develop.default develop.local develop.ci .develop.before .develop .develop.after
develop: dependencies develop.workflow-run ## Setups a local development environment
develop.local: .develop.workflow-hooks
develop.ci:
	@$(call log,warn,"[Develop] Job disabled in CI mode",0)
.develop.before::
	@:
.develop::
	@:
.develop.after::
	@:

#-------------
# SCAN
#-------------
#
# To add a new target to scan
#
# my-target-scan:
# 	@echo 'Scan!'
#
# MAKEFILE_SCAN_TARGETS += my-target-scan
#
.PHONY: scan scan.default scan.local scan.ci .scan.before .scan .scan.after
scan: scan.workflow-run ## Scan code for potential issues
scan.default: .scan.workflow-hooks
scan.ci: scan.default
scan.local: scan.default
.scan.before::
	@:
.scan:
	$(Q)FAILS=0; \
	for target in $(MAKEFILE_SCAN_TARGETS); do \
		$(MAKE) $$target || FAILS=1; \
	done; \
	if [ $$FAILS -eq 0 ]; then \
		$(call log,info,"🎉 Everything is OK",1); \
	else \
		$(call log,fatal,"❌ Some problems need to be fixed",1); \
		exit 1; \
	fi
.scan.after::
	@:

# A list of variable names that will be displayed before deployment
DEPLOY_VARIABLES := \
	CI_ENVIRONMENT_URL

#-------------
# DEPLOY
#-------------
.PHONY: deploy deploy.default deploy.local deploy.ci .deploy.before .deploy .deploy.after
deploy: deploy.workflow-run ## Deploy the application to the given environment
deploy.default: .deploy.workflow-hooks
deploy.local: .deploy-check
	$(Q)$(call log,warn,WARNING! This will deploy local files,1)
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
	@$(call log,error,CI_ENVIRONMENT_NAME=$(CI_ENVIRONMENT_NAME) (forbidden value, use CI_ENVIRONMENT_NAME=<environment> make deploy),1);
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

.deploy.before::
	@:
.deploy::
	@:
.deploy.after::
	@:

#-------------
# RESCUE
#-------------
.PHONY: rescue rescue.default rescue.local rescue.ci .rescue.before .rescue .rescue.after
rescue: rescue.workflow-run ## Clean everything in case of problem
rescue.default: rescue.workflow-hooks
rescue.local: rescue.default
rescue.ci:
	@$(call log,warn,"[Rescue] Job disabled in CI mode",0)

.rescue.before::
	@:
.rescue::
	@:
.rescue.after::
	@:

# Reinstall after rescue
.rescue.before::
	@$(call log,info,"[Git] Clean all local changes...",1)
	$(Q)$(call log,warn,WARNING! This will remove all non commited git changes.,1)
	$(Q)read -r -p "Continue? [y/N]" REPLY;echo; \
	if [[ "$$REPLY" =~ ^[Yy]$$ ]]; then \
		$(GIT) clean -fdx; \
	fi
.rescue.after:: dependencies

# This generic job allow to easily switch implementation between local and CI mode
#
# Example :
# job: job.workflow-run
# 	-> Will run job.ci when $(CI) is set
#   -> Will run job.local when $(CI) is not set
#
ifneq ($(call filter-false,$(CI)),)
%.workflow-run:
	@$(call log,info,"[Make] $* \(mode=CI\)")
	@${MAKE} $*.ci
else
%.workflow-run:
	@$(call log,info,"[Make] $* \(mode=Local\)")
	@${MAKE} $*.local
endif

# This generic job trigger the hooks before and after the job
#
# Example :
# job: .job.workflow-hooks
# 	-> 1. Run before_each
# 	-> 2. Run .job.before
# 	-> 3. Run .job
# 	-> 4. Run .job.after
# 	-> 5. Run after_each
#
%.workflow-hooks: before_each %.before % %.after after_each
	@:
