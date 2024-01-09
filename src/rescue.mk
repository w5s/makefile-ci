PHONY += rescue
rescue: ## Clean everything in case of problem
	@$(GIT) clean -fdx
	@$(MAKE) install
