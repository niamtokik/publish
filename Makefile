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
_PANDOC_OPTS ?= -f markdown \
	--verbose \
  --toc=true \
	--strip-comments=true \
  --embed-resources=true
_PANDOC_OPTS_JSON ?=
_PANDOC_OPTS_HTML ?=
_PANDOC_OPTS_PDF ?= --variable=links-as-notes \
	--variable=colorlinks=true \
	--variable=documentclass=article \
	--variable=papersize=a4 \
	--variable=toc=true \
  --pdf-engine=xelatex
_PANDOC_OPTS_EPUB ?=

# list of all drafts posts
_DRAFTED := $(shell ls -t "$(PUBLISH_DRAFTS_DIRECTORY)")

# list of all published posts
_PUBLISHED := $(shell ls -t "$(PUBLISH_PUBLISHED_DIRECTORY)")

######################################################################
# make templates
######################################################################
define build_common
# variable to help find the source file to build
__SOURCE_$(1) = $$(PUBLISH_PUBLISHED_DIRECTORY)

$$(PUBLISH_WWW_DIRECTORY)/$(1): $$(PUBLISH_WWW_DIRECTORY)
	mkdir -p $$(@)
	touch -am $$(@)

$$(PUBLISH_CACHE_DIRECTORY)/$(1): $$(PUBLISH_CACHE_DIRECTORY)
	mkdir -p $$(@)
	touch -am $$(@)
endef

######################################################################
# state management, a published file MUST NEVER BE REBUILD except
# if it's forced. this project assume the files published will
# rarely modified. On other hand, the draft MUST ALWAYS BE REBUILD,
# to check if everything is fine.
# The same apply to checksums, signatures and so on.
######################################################################
# define state
# $$(PUBLISH_STATE_DIRECTORY)/$(1): $$(PUBLISH_STATE_DIRECTORY)
# 	touch $$(@).state
# endef

######################################################################
# authentication
# every generated files can have their own checksums and/or pgp
# signature.
######################################################################
# checksum feature is using openssl or libressl by default.
#  define checksum
# endef
#
# pgp uses gpg2 for the signature.
#  define pgp
# endef

######################################################################
# JSON Pandoc AST
######################################################################
define json_build
_BUILD_JSON += $$(PUBLISH_CACHE_DIRECTORY)/$(1)/index.json

$$(PUBLISH_CACHE_DIRECTORY)/$(1)/index.json: $$(PUBLISH_CACHE_DIRECTORY)/$(1)
	$$(_PANDOC) \
		$$(_PANDOC_OPTS) \
		$$(_PANDOC_OPTS_JSON) \
		-t json \
		-o $$(@) \
		$$(__SOURCE_$(1))/$(1)/README.md
	touch -am $$(@)
endef

define json
$$(foreach post,$$(_PUBLISHED),$$(eval $$(call json_build,$$(post))))

_BUILD_DRAFTS += draft-build-json
.PHONY += draft-build-json
draft-build-json: $$(_BUILD_JSON)

_BUILD_PUBLISHED += build-json
.PHONY += build-json
build-json: $$(_BUILD_JSON)

# cleaning the files
_CLEAN += clean-json
.PHONY += clean-json
clean-json: $$(_BUILD_JSON)
	rm $$(_BUILD_JSON)
endef

######################################################################
# html support
######################################################################
define html_build
_BUILD_HTML += $$(PUBLISH_WWW_DIRECTORY)/$(1)/index.html

$$(PUBLISH_WWW_DIRECTORY)/$(1)/index.html: $$(PUBLISH_WWW_DIRECTORY)/$(1)
	$$(_PANDOC) \
		$$(_PANDOC_OPTS) \
		$$(_PANDOC_OPTS_HTML) \
		-t html5 \
		-o $$(@) \
		$$(__SOURCE_$(1))/$(1)/README.md
	touch -am $$(@)
endef

define html
$$(foreach post,$$(_PUBLISHED),$$(eval $$(call html_build,$$(post))))

_BUILD_DRAFTS += draft-build-html
.PHONY += draft-build-html
draft-build-html: $$(_BUILD_HTML)

_BUILD_PUBLISHED += build-html
.PHONY += build-html
build-html: $$(_BUILD_HTML)

# cleaning the files
_CLEAN += clean-html
.PHONY += clean-html
clean-html: $$(_BUILD_HTML)
	rm $$(_BUILD_HTML)
endef

######################################################################
# pdf support
######################################################################
define pdf_build
_BUILD_PDF += $$(PUBLISH_WWW_DIRECTORY)/$(1)/$(1).pdf

$$(PUBLISH_WWW_DIRECTORY)/$(1)/$(1).pdf: $$(PUBLISH_WWW_DIRECTORY)/$(1)
	$$(_PANDOC) \
		$$(_PANDOC_OPTS) \
		$$(_PANDOC_OPTS_PDF) \
		-t pdf \
		-o $$(@) \
		$$(__SOURCE_$(1))/$(1)/README.md
	touch -am $$(@)
endef

define pdf
$$(foreach post,$$(_PUBLISHED),$$(eval $$(call pdf_build,$$(post))))

.PHONY += help-pdf
help-pdf:
	@echo "  draft-build-pdf:"
	@echo "  build-pdf:"

_BUILD_DRAFTS += draft-build-pdf
.PHONY += draft-build-pdf
draft-build-pdf: $$(_BUILD_PDF)

_BUILD_PUBLISHED += build-pdf
.PHONY += build-pdf
build-pdf: $$(_BUILD_PDF)

# cleaning the files
_CLEAN += clean-pdf
.PHONY += clean-pdf
clean-pdf: $$(_BUILD_PDF)
	rm $$(_BUILD_PDF)
endef

######################################################################
# epub support
######################################################################
define epub_build 
_BUILD_EPUB += $$(PUBLISH_WWW_DIRECTORY)/$(1)/$(1).epub

# pandoc command to generate epub
$$(PUBLISH_WWW_DIRECTORY)/$(1)/$(1).epub: $$(PUBLISH_WWW_DIRECTORY)/$(1)
	$$(_PANDOC) \
		$$(_PANDOC_OPTS) \
		$$(_PANDOC_OPTS_EPUB) \
		-t epub \
		-o $$(@) \
		$$(__SOURCE_$(1))/$(1)/README.md
	touch -am $$(@)
endef

define epub
# generate targets for all epub
$$(foreach post,$$(_PUBLISHED),$$(eval $$(call epub_build,$$(post))))

# building the drafts epub posts
_BUILD_DRAFTS += draft-build-epub
.PHONY += draft-build-epub
draft-build-epub: $$(_BUILD_EPUB)

# building the published epub post
_BUILD_PUBLISHED += build-epub
.PHONY += build-epub
build-epub: $$(_BUILD_EPUB)

# cleaning the files
_CLEAN += clean-epub
.PHONY += clean-epub
clean-epub: $$(_BUILD_EPUB)
	rm $$(_BUILD_EPUB)
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
	mkdir -p $(@)
	touch -am $(@)

$(PUBLISH_WWW_DIRECTORY): $(PUBLISH_BUILD_DIRECTORY)
	mkdir -p $(@)
	touch -am $(@)

$(PUBLISH_CACHE_DIRECTORY): $(PUBLISH_BUILD_DIRECTORY)
	mkdir -p $(@)
	touch -am $(@)

$(PUBLISH_STATE_DIRECTORY): $(PUBLISH_BUILD_DIRECTORY)
	mkdir -p $(@)
	touch -am $(@)

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
$(eval $(call epub))

######################################################################
# main targets
######################################################################
.PHONY += all
all: draft publish

.PHONY += draft
draft: draft-build

.PHONY += draft-build
draft-build: $(_BUILD_DRAFTS)

.PHONY += publish
publish: publish-pre-callbacks publish-target publish-post-callbacks

.PHONY += publish-pre-callbacks
publish-pre-callbacks: $(PUBLISH_PRE_CALLBACKS)

.PHONY += publish-target
publish-target: $(_BUILD_PUBLISHED)

.PHONY += publish-post-callbacks
publish-post-callbacks: $(PUBLISH_POST_CALLBACKS)

.PHONY += clean
clean: 

.PHONY += clean-build
clean-publish: $(_CLEAN)

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
