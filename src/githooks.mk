# Create githooks path
${PROJECT_GITHOOKS_PATH}/.keep:
	$(Q)${MKDIRP} ${PROJECT_GITHOOKS_PATH}
	$(Q)${TOUCH} ${PROJECT_GITHOOKS_PATH}/.keep

.PHONY: githooks-install
githooks-install: ${PROJECT_GITHOOKS_PATH}/.keep
ifneq ($(shell ${GIT} config core.hooksPath), $(PROJECT_GITHOOKS_PATH))
	@$(call log,info,"[Git] Install hooks...",1)
	$(Q)${GIT} config core.hooksPath ${PROJECT_GITHOOKS_PATH}
endif

.setup:: githooks-install # Install githooks during `make setup`
