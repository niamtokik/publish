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
_PANDOC_OPTS ?= -f markdown

# list of all drafts posts
_DRAFTED := $(shell ls -t "$(PUBLISH_DRAFTS_DIRECTORY)")

# list of all published posts
_PUBLISHED := $(shell ls -t "$(PUBLISH_PUBLISHED_DIRECTORY)")

######################################################################
# make templates
######################################################################
# create common directories
define build_common
__SOURCE_$(1) = $$(PUBLISH_PUBLISHED_DIRECTORY)

$$(PUBLISH_WWW_DIRECTORY)/$(1): $$(PUBLISH_BUILD_DIRECTORY)
	make $$(@)

$$(PUBLISH_CACHE_DIRECTORY)/$(1): $$(PUBLISH_BUILD_DIRECTORY)
	mkdir $$(@)
endef

######################################################################
# JSON Pandoc AST
######################################################################
define json_build
_BUILD_JSON += $$(PUBLISH_CACHE_DIRECTORY)/$(1)/index.json

$$(PUBLISH_CACHE_DIRECTORY)/$(1)/index.json: $$(PUBLISH_CACHE_DIRECTORY)/$(1)
	$$(_PANDOC) $$(_PANDOC_OPTS) -t json -o $$(@) $$(__SOURCE_$(1))/$(1)/README.md
endef

define json
$$(foreach post,$$(_PUBLISHED),$$(eval $$(call json_build,$$(post))))

.PHONY += draft-build-json
draft-build-json: $$(_BUILD_JSON)

.PHONY += build-json
build-json: $$(_BUILD_JSON)
endef

######################################################################
# html support
######################################################################
define html_build
_BUILD_HTML += $$(PUBLISH_WWW_DIRECTORY)/$(1)/index.html

$$(PUBLISH_WWW_DIRECTORY)/$(1)/index.html: $$(PUBLISH_WWW_DIRECTORY)/$(1)
	$$(_PANDOC) $$(_PANDOC_OPTS) -t html5 -o $$(@) $$(__SOURCE_$(1))/$(1)/README.md
endef

define html
$$(foreach post,$$(_PUBLISHED),$$(eval $$(call html_build,$$(post))))

.PHONY += draft-build-html
draft-build-html: $$(_BUILD_HTML)

.PHONY += build-html
build-html: $$(_BUILD_HTML)
endef

######################################################################
# pdf support
######################################################################
define pdf_build
_BUILD_PDF += $$(PUBLISH_WWW_DIRECTORY)/$(1)/$(1).pdf

$$(PUBLISH_WWW_DIRECTORY)/$(1)/$(1).pdf: $$(PUBLISH_WWW_DIRECTORY)/$(1)
	$$(_PANDOC) $$(_PANDOC_OPTS) -t pdf -o $$(@)  $$(__SOURCE_$(1))/$(1)/README.md
endef

define pdf
$$(foreach post,$$(_PUBLISHED),$$(eval $$(call pdf_build,$$(post))))

.PHONY += help-pdf
help-pdf:
	@echo "  draft-build-pdf:"
	@echo "  build-pdf:"

.PHONY += draft-build-pdf
draft-build-pdf: $$(_BUILD_PDF)

.PHONY += build-pdf
build-pdf: $$(_BUILD_PDF)
endef

######################################################################
# epub support
######################################################################
define build_epub
_BUILD_EPUB += $$(PUBLISH_WWW_DIRECTORY)/$(1)/$(1).epub

$$(PUBLISH_WWW_DIRECTORY)/$(1)/$(1).epub: $$(PUBLISH_WWW_DIRECTORY)/$(1)
	$$(_PANDOC) $$(_PANDOC_OPTS) -t epub -o $$(@)  $$(__SOURCE_$(1))/$(1)/README.md
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
	make $$(@)

# create the required directories and other required targets
# for each posts
$(foreach post,$(_PUBLISHED),$(eval $(call build_common,$(post))))

# json support
$(eval $(call json))

# html support
$(eval $(call html))

# pdf support
$(eval $(call pdf))

# epub support
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

# publish targets
.PHONY += publish
publish: publish-pre-callbacks publish-target publish-post-callbacks

.PHONY += publish-pre-callbacks
publish-pre-callbacks: $(PUBLISH_PRE_CALLBACKS)

.PHONY += publish-target
publish-target:

.PHONY += publish-post-callbacks
publish-post-callbacks: $(PUBLISH_POST_CALLBACKS)

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
	@echo .PHONY: $(.PHONY)


# PHONY RULE.
.PHONY: ${.PHONY}
