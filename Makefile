######################################################################
# Publish Project - GNU Makefile
######################################################################
include ./config/config.mk

######################################################################
# public variables
######################################################################
DATE = $(shell date '+%Y-%m-%d')
RAND8 = $(shell openssl rand -hex 4)

######################################################################
# private variables
######################################################################
# absolute path to make
_MAKE ?= $(shell which make)

# absolute path to pandoc
_PANDOC ?= $(shell which pandoc)

# list of all drafts posts
_DRAFTED := $(shell ls -t $(PUBLISH_DRAFTS_DIRECTORY))

# list of all published posts
_PUBLISHED := $(shell ls -t $(PUBLISH_PUBLISHED_DIRECTORY))

######################################################################
# make templates
######################################################################
define build_common
__SOURCE_$(1) = $$(PUBLISH_PUBLISHED_DIRECTORY)

$$(PUBLISH_WWW_DIRECTORY)/$(1): $$(PUBLISH_WWW_DIRECTORY)
	mkdir $$(@)
endef

# html support
define build_html
_BUILD_HTML += $$(PUBLISH_WWW_DIRECTORY)/$(1)/index.html

$$(PUBLISH_WWW_DIRECTORY)/$(1)/index.html: $$(PUBLISH_WWW_DIRECTORY)/$(1)
	$$(_PANDOC) -o $$(@) $$(__SOURCE_$(1))/$(1)/README.md
endef

# pdf support
define build_pdf
_BUILD_PDF += $$(PUBLISH_WWW_DIRECTORY)/$(1)/$(1).pdf

$$(PUBLISH_WWW_DIRECTORY)/$(1)/$(1).pdf: $$(PUBLISH_WWW_DIRECTORY)/$(1)
	$$(_PANDOC) -o $$(@)  $$(__SOURCE_$(1))/$(1)/README.md
endef

# epub support
define build_epub
_BUILD_EPUB += $$(PUBLISH_WWW_DIRECTORY)/$(1)/$(1).epub

$$(PUBLISH_WWW_DIRECTORY)/$(1)/$(1).epub: $$(PUBLISH_WWW_DIRECTORY)/$(1)
	$$(_PANDOC) -o $$(@)  $$(__SOURCE_$(1))/$(1)/README.md
endef

######################################################################
# default target
######################################################################
.PHONY += help
help:
	@echo "Usage: make [help|build|publish]"
	@echo "  help: display this message"
	@echo "  build: compile the project in ${PUBLISH_BUILD_DIRECTORY}"
	@echo "  publish: build and generate extras data"

######################################################################
# internal targets
######################################################################
$(PUBLISH_BUILD_DIRECTORY):
	make $@

$(PUBLISH_WWW_DIRECTORY): $(PUBLISH_BUILD_DIRECTORY)
	make $@

# 
$(foreach post,$(_PUBLISHED),$(eval $(call build_common,$(post))))
$(foreach post,$(_PUBLISHED),$(eval $(call build_html,$(post))))
$(foreach post,$(_PUBLISHED),$(eval $(call build_pdf,$(post))))
$(foreach post,$(_PUBLISHED),$(eval $(call build_epub,$(post))))

######################################################################
# main targets
######################################################################
.PHONY += draft
draft: draft-build

.PHONY += draft-build
draft-build: draft-build-html draft-build-pdf draft-build-epub

.PHONY += draft-build-html
draft-build-html: $(_BUILD_HTML)

.PHONY += draft-build-pdf
draft-build-pdf: $(_BUILD_PDF)

.PHONY += draft-build-epub
draft-build-epub: $(_BUILD_EPUB)

.PHONY += publish
publish:

.PHONY += clean
clean: 

.PHONY += clean-build
clean-build:

.PHONY += clean-cache
clean-cache:

.PHONY += variables
variables:
	@echo _MAKE: $(_MAKE)
	@echo _PANDOC: $(_PANDOC)
	@echo _DRAFTED: $(_DRAFTED)
	@echo _PUBLISHED: $(_PUBLISHED)


# PHONY RULE.
.PHONY: ${.PHONY}
