######################################################################
# Publish extension for dev.to API - GNU Makefile
######################################################################
DEVTO_DIR ?= ./_devto
DEVTO_CURL_OPTS ?= -sq

HELP_MODULES += devto-help
.PHONY += devto-help
devto-help:
	@echo "devto:"
	@echo "  devto-help: print this help"
	@echo "  devto-export: export all articles from dev.to"

.PHONY += devto-export
devto-export: $(DEVTO_DIR)/articles-me-call.json

$(DEVTO_DIR):
	mkdir -p "$(@)"

$(DEVTO_DIR)/articles-me-call.json: $(DEVTO_DIR)
ifdef DEVTO_API_KEY
	curl $(DEVTO_CURL_OPTS) -o "$(@)" -H "api-key: $(DEVTO_API_KEY)" https://dev.to/api/articles/me/all
else
	@echo DEVTO_API_KEY not set.
endif
