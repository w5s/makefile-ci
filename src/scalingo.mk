
SCALINGO := scalingo
SCALINGO_CACHE_PATH := $(PROJECT_CACHE_PATH)/scalingo
SCALINGO_ARCHIVE_FILE := $(SCALINGO_CACHE_PATH)/scalingo-app.tar.gz
## Scalingo region (default: osc-fr1)
SCALINGO_REGION ?= osc-fr1
## Scalingo app name (default: $(CI_PROJECT_NAME)-$(CI_ENVIRONMENT_NAME))
SCALINGO_APP_NAME ?= $(CI_PROJECT_NAME)-$(CI_ENVIRONMENT_NAME)

.PHONY: scalingo-archive
scalingo-archive:
	@$(call log,info,"[Scalingo] Bundle $(SCALINGO_APP_NAME)...",1)
	$(Q)$(MKDIRP) $(dir $(SCALINGO_ARCHIVE_FILE))
	$(Q)$(GIT) archive --prefix=master/ HEAD | gzip > ${SCALINGO_ARCHIVE_FILE}

.PHONY: scalingo-clean
scalingo-clean:
	@$(call log,info,"[Scalingo] Clean cache...",1)
	$(Q)$(RM) -rf $(SCALINGO_ARCHIVE_FILE)
	$(Q)$(RM) -rf $(SCALINGO_CACHE_PATH)
.clean:: scalingo-clean

.PHONY: scalingo-deploy
scalingo-deploy: scalingo-archive
	@$(call log,info,"[Scalingo] Deploy $(SCALINGO_APP_NAME)...",1)
	$(Q)$(SCALINGO) --app $(SCALINGO_APP_NAME) --region=$(SCALINGO_REGION) deploy ${SCALINGO_ARCHIVE_FILE}
.deploy::scalingo-deploy
