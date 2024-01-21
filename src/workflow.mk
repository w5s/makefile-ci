.PHONY: all
all: prepare install lint ## Run all targets

.PHONY: prepare .prepare.pre .prepare .prepare.post
prepare: .prepare.pre .prepare .prepare.post ## Install external dependencies
.prepare.pre::
	@:
.prepare::
	@:
.prepare.post::
	@:

.PHONY: dependencies .dependencies.pre .dependencies .dependencies.post
dependencies: .dependencies.pre .dependencies .dependencies.post ## Install all dependencies
.dependencies.pre::
	@:
.dependencies::
	@:
.dependencies.post::
	@:

.PHONY: build .build.pre .build .build.post
build: .build.pre .build .build.post ## Build sources
.build.pre::
	@:
.build::
	@:
.build.post::
	@:

.PHONY: clean .clean.pre .clean .clean.post
clean: .clean.pre .clean .clean.post ## Clean build files
.clean.pre::
	@:
.clean::
	@:
.clean.post::
	@:

.PHONY: lint .lint.pre .lint .lint.post
lint: .lint.pre .lint .lint.post ## Lint all source files
.lint.pre::
	@:
.lint::
	@:
.lint.post::
	@:

.PHONY: format .format.pre .format .format.post
format: .format.pre .format .format.post ## Format all source files
.format.pre::
	@:
.format::
	@:
.format.post::
	@:

.PHONY: test .test.pre .test .test.post
test: .test.pre .test .test.post ## Run unit tests
.test.pre::
	@:
.test::
	@:
.test.post::
	@:

.PHONY: develop .develop.pre .develop .develop.post
develop: .develop.pre .develop .develop.post ## Setups a local development environment
.develop.pre::
	@:
.develop::
	@:
.develop.post::
	@:
