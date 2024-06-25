.editorconfig: $(MAKEFILE_CI_TEMPLATE_PATH)/.editorconfig.template
	$(Q)$(MKDIRP) $(dir $@)
	$(Q)cp -f $< $@

.circleci/config.yml: $(MAKEFILE_CI_TEMPLATE_PATH)/.circleci/config.yml.template
	$(Q)$(MKDIRP) $(dir $@)
	$(Q)cp -f $< $@

.docker/compose-common.yaml: $(MAKEFILE_CI_TEMPLATE_PATH)/.docker/compose-common.yaml.template
	$(Q)$(MKDIRP) $(dir $@)
	$(Q)cp -f $< $@

.docker: .docker/compose-common.yaml
