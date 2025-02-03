# @see https://github.com/xeol-io/xeol
XEOL := xeol

# Fake target to setup xeol
$(MAKE_CACHE_PATH)/job/xeol-setup: $(MAKE_CACHE_PATH)
	$(Q)command -v xeol >/dev/null 2>&1 || { \
		$(call log,info,"[Xeol] Install CLI...",1); \
		if command -v brew >/dev/null 2>&1; then \
			brew tap xeol-io/xeol && \
			brew install xeol; \
		else \
			curl -sSfL https://raw.githubusercontent.com/xeol-io/xeol/main/install.sh | sh -s -- -b /usr/local/bin; \
		fi \
	}

#
# Install xeol cli if not present
#
.PHONY: xeol-setup
xeol-setup: $(MAKE_CACHE_PATH)/job/xeol-setup

#
# Scan sources with xeol
#
.PHONY: xeol-scan
xeol-scan: xeol-setup
	@$(call log,info,"[Xeol] Scanning sources...",1)
	$(Q)$(XEOL) "dir:." --fail-on-eol-found

.scan:: xeol-scan # Register xeol as a target for .scan task
