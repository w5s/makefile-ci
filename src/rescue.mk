.PHONY: rescue
rescue: .rescue-init .rescue-git .rescue-docker .rescue-reinstall ## Clean everything in case of problem

.PHONY: .rescue-init
.rescue-init:
	@$(call log,info,"[Make] Rescue")

.PHONY: .rescue-git
.rescue-git:
	@$(call log,info,"[Git] Clean all local changes...",1)
	$(Q)echo "WARNING! This will remove all non commited git changes."
	$(Q)read -r -p "Continue? [y/N]" REPLY;echo; \
	if [[ "$$REPLY" =~ ^[Yy]$$ ]]; then \
		$(GIT) clean -fdx; \
	fi

ifneq ($(DOCKER_ENABLED),)
.PHONY: .rescue-docker
.rescue-docker:
	@$(call log,info,"[Docker] Clean all unused docker images...",1)
	$(Q)docker image prune -a
endif

.PHONY: .rescue-reinstall
.rescue-reinstall:
	$(Q)$(MAKE) dependencies
