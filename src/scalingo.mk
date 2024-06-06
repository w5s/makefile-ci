
SCALINGO := scalingo
SCALINGO_CACHE_PATH := $(PROJECT_CACHE_PATH)/scalingo
SCALINGO_ARCHIVE_FILE := $(SCALINGO_CACHE_PATH)/scalingo-app.tar.gz
## Scalingo region (default: osc-fr1)
SCALINGO_REGION ?= osc-fr1
## Scalingo default app prefix (default: $(CI_PROJECT_NAME))
SCALINGO_APP_PREFIX ?= $(CI_PROJECT_NAME)
## Scalingo default app suffix (default: -$(CI_ENVIRONMENT_NAME))
SCALINGO_APP_SUFFIX ?= -$(CI_ENVIRONMENT_NAME)
## Scalingo app name (default: $(SCALINGO_APP_PREFIX)$(SCALINGO_APP_SUFFIX))
SCALINGO_APP ?= $(SCALINGO_APP_PREFIX)$(SCALINGO_APP_SUFFIX)

.PHONY: scalingo-archive
scalingo-archive:
	@$(call log,info,"[Scalingo] Bundle $(SCALINGO_APP)...",1)
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
	@$(call log,info,"[Scalingo] Deploy $(SCALINGO_APP)...",1)
	@$(call log,info,"SCALINGO_APP=$(SCALINGO_APP)...",2)
	@$(call log,info,"SCALINGO_REGION=$(SCALINGO_REGION)...",2)
	$(Q)$(SCALINGO) --app $(SCALINGO_APP) --region=$(SCALINGO_REGION) deploy ${SCALINGO_ARCHIVE_FILE}
.deploy::scalingo-deploy
