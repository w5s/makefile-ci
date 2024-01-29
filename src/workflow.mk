.PHONY: all
all: prepare dependencies lint ## Run all targets

#-------------
# PREPARE
#-------------
.PHONY: prepare prepare.ci prepare.default .prepare.pre .prepare .prepare.post
prepare: .workflow-run-prepare ## Install external dependencies
prepare.default: .prepare.pre .prepare .prepare.post
# prepare.ci: prepare.default # TODO: implement this
.prepare.pre::
	@:
.prepare::
	@:
.prepare.post::
	@:

#-------------
# DEPENDENCIES
#-------------
.PHONY: dependencies dependencies.ci dependencies.default .dependencies.pre .dependencies .dependencies.post
dependencies: .workflow-run-dependencies ## Install all dependencies
dependencies.default: .dependencies.pre .dependencies .dependencies.post
# dependencies.ci: dependencies.default # TODO: implement this
.dependencies.pre::
	@:
.dependencies::
	@:
.dependencies.post::
	@:

#-------------
# BUILD
#-------------
.PHONY: build build.ci build.default .build.pre .build .build.post
build: .workflow-run-build ## Build sources
build.default: .build.pre .build .build.post
# build.ci: .build.default
.build.pre::
	@:
.build::
	@:
.build.post::
	@:

#-------------
# CLEAN
#-------------
.PHONY: clean clean.ci clean.default .clean.pre .clean .clean.post
clean: .workflow-run-clean ## Clean build files
clean.default: .clean.pre .clean .clean.post
# clean.ci: .clean.default # TODO: implement this
.clean.pre::
	@:
.clean::
	@:
.clean.post::
	@:

#-------------
# LINT
#-------------
.PHONY: lint lint.ci lint.default .lint.pre .lint .lint.post
lint: .workflow-run-lint ## Lint all source files
lint.default: .lint.pre .lint .lint.post
# lint.ci: lint.default # TODO: implement this
.lint.pre::
	@:
.lint::
	@:
.lint.post::
	@:

#-------------
# FORMAT
#-------------
.PHONY: format format.ci format.default .format.pre .format .format.post
format: .workflow-run-format ## Format all source files
format.default: .format.pre .format .format.post
# format.ci: format.default # TODO: implement this
.format.pre::
	@:
.format::
	@:
.format.post::
	@:

#-------------
# TEST
#-------------
.PHONY: test test.ci test.default .test.pre .test .test.post
test: .workflow-run-test ## Run unit tests
test.default: .test.pre .test .test.post
# test.ci: test.default # TODO: implement this
.test.pre::
	@:
.test::
	@:
.test.post::
	@:

#-------------
# DEVELOP
#-------------
.PHONY: develop develop.ci develop.default .develop.pre .develop .develop.post
develop: .workflow-run-develop ## Setups a local development environment
develop.default: .develop.pre .develop .develop.post
develop.ci:
	@${MAKE} develop.default
.develop.pre::
	@:
.develop::
	@:
.develop.post::
	@:

# This job will run
.PHONY: .workflow-run-%
ifneq ($(CI),)
.workflow-run-%:
	$(call log,info,"[Make] $* \(CI\)")
	@${MAKE} $*.ci
else
.workflow-run-%:
	$(call log,info,"[Make] $* \(Local\)")
	@${MAKE} $*.default
endif
