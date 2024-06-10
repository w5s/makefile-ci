ASDF := asdf

ifneq ($(ASDF_ENABLED),)

# Run node install only if yarn.lock or package-lock.json has changed
$(MAKE_CACHE_PATH)/asdf-install: $(MAKE_CACHE_PATH) .tool-versions
	@$(call log,info,"[ASDF] Install tools...",1)
	$(Q)${ASDF} install
	$(Q)${TOUCH} $@

.PHONY: asdf-install-cached
asdf-install-cached: $(MAKE_CACHE_PATH)/asdf-install
	@:

endif
