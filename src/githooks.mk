# Create githooks path
${PROJECT_GITHOOKS_PATH}/.keep:
	@${MKDIRP} ${PROJECT_GITHOOKS_PATH}
	@${TOUCH} ${PROJECT_GITHOOKS_PATH}/.keep

.PHONY: githooks-install
githooks-install: ${PROJECT_GITHOOKS_PATH}/.keep
ifneq ($(shell ${GIT} config core.hooksPath), $(PROJECT_GITHOOKS_PATH))
	$(call log,info,"[Git] Install hooks...",1)
	@${GIT} config core.hooksPath ${PROJECT_GITHOOKS_PATH}
endif

.prepare:: githooks-install # Install githooks during `make prepare`
