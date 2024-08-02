POD_FILE ?= ios/Podfile
POD_LOCKFILE ?= $(POD_FILE).lock
POD_MANIFEST := $(dir $(POD_FILE))/Pods/Manifest.lock
POD_INSTALL := cd $(dir $(POD_FILE)) && bundle exec pod install --repo-update

.PHONY: pod-setup
pod-setup: ruby-check-install

.PHONY: pod-install
pod-install: pod-setup
	@$(call log,info,"[Pod] Install dependencies...",1)
	$(Q)$(POD_INSTALL)
.install:: pod-install	# Add `pod install` to `make install`

$(POD_MANIFEST): $(POD_LOCKFILE)
	@$(call log,info,"[Pod] Ensure dependencies....",1)
	$(Q)$(POD_INSTALL)
	$(Q)touch $(POD_MANIFEST)

# Install dependencies only if needed
.PHONY: pod-check-install
pod-check-install: pod-setup $(POD_MANIFEST)
