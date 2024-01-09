## Make cache path (default: .cache/make)
MAKE_CACHE_PATH ?= $(PROJECT_CACHE_PATH)/make

# Create make cache directory
$(MAKE_CACHE_PATH):
	@${MKDIRP} $(MAKE_CACHE_PATH)

# make should not remove these files
.PRECIOUS: $(MAKE_CACHE_PATH)/%

# Add clear cache to `make clean` target
PHONY += clean__cache
clean__cache:
	$(info Clean cache...)
	@$(RM) -rf $(MAKE_CACHE_PATH)
