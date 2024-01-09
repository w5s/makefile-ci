# Create githooks path
${PROJECT_GITHOOKS_PATH}/.keep:
	@${MKDIRP} ${PROJECT_GITHOOKS_PATH}
	@${TOUCH} ${PROJECT_GITHOOKS_PATH}/.keep

# Install githooks during `make prepare`
PHONY += prepare__githooks
prepare__githooks: ${PROJECT_GITHOOKS_PATH}/.keep
ifneq ($(shell ${GIT} config core.hooksPath), $(PROJECT_GITHOOKS_PATH))
	$(info Install Git hooks...)
	@${GIT} config core.hooksPath ${PROJECT_GITHOOKS_PATH}
endif

