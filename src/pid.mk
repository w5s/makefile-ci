# Path to the file containing pid
MAKE_PIDFILE := $(MAKE_CACHE_PATH)/pid

# Add this target as dependency of another target to regenerate only when new make command
#
# Example
# my-target: $(MAKE_PIDFILE)
#   <- This will be executed only on new command
#
.PHONY: $(MAKE_PIDFILE)
$(MAKE_PIDFILE):
# Write pid file only if changed.
	$(Q)echo "$(MAKE_PID)" | cmp -s - $@ || echo "$(MAKE_PID)" > $@


# Create or update make pid file before each job.
# This will ensure that the file exists before each job
before_each:: $(MAKE_PIDFILE)
	@:
