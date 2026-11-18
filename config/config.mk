######################################################################
# General configuration
######################################################################
PUBLISH_INDEX_TITLE=""
PUBLISH_INDEX_SUBTITLE=""
PUBLISH_INDEX_KEYWORDS=""
PUBLISH_INDEX_DESCRIPTION=""

######################################################################
# Meta
# see: https://gist.github.com/lancejpollard/1978404
######################################################################
# PUBLISH_INDEX_META="no"
# PUBLISH_INDEX_META_COPYRIGHT=""
# PUBLISH_INDEX_META_SUBJECT=""
# PUBLISH_INDEX_META_LANGUAGE=""
# PUBLISH_INDEX_META_ROBOTS=""


######################################################################
# Internal configuration
######################################################################
PUBLISH_CONFIG_DIRECTORY = ./config
PUBLISH_TEMPLATES_DIRECTORY = $(PUBLISH_CONFIG_DIRECTORY)/templates

PUBLISH_DRAFTS_DIRECTORY = posts/drafts
PUBLISH_PUBLISHED_DIRECTORY = posts/published

PUBLISH_BUILD_DIRECTORY = _build
PUBLISH_CACHE_DIRECTORY = $(PUBLISH_BUILD_DIRECTORY)/cache
PUBLISH_WWW_DIRECTORY = $(PUBLISH_BUILD_DIRECTORY)/www
PUBLISH_STATE_DIRECTORY = $(PUBLISH_BUILD_DIRECTORY)/state

######################################################################
# Posts
######################################################################
PUBLISH_POSTS_SLUG="$$(DATE)-$$(TITLE)-$$(RAND8)"

######################################################################
# Templates
######################################################################
PUBLISH_TEMPLATE="default"

######################################################################
# Output Formats Configuration
######################################################################
# Formats output when publishing a post
PUBLISH_FORMATS="html pdf epub djvu"

# html format parameters
PUBLISH_FORMATS_HTML_TEMPLATE = $(PUBLISH_TEMPLATES_DIRECTORY)/default.html5
PUBLISH_FORMATS_HTML_PARAMS = --template=$(PUBLISH_FORMATS_HTML_TEMPLATE)

# pdf format parameters
PUBLISH_FORMATS_PDF_TEMPLATE = $(PUBLISH_TEMPLATES_DIRECTORY)/default.latex
PUBLISH_FORMATS_PDF_PARAMS = --template=$(PUBLISH_FORMATS_PDF_TEMPLATE)

# epub format parameters
PUBLISH_FORMATS_EPUB_TEMPLATE = $(PUBLISH_TEMPLATES_DIRECTORY)/default.epub3
PUBLISH_FORMATS_EPUB_PARAMS = --template=$(PUBLISH_FORMATS_PDF_TEMPLATE)

# djvu format parameters
PUBLISH_FORMATS_DJVU_PARAMS=""

######################################################################
# Publish Checksums and Signature
######################################################################
PUBLISH_CHECKSUM="yes"
PUBLISH_CHECKSUM_ALGORITHM="sha256"

PUBLISH_SIGNATURE="yes"
PUBLISH_SIGNATURE_PRIVATE_KEY=""
PUBLISH_SIGNATURE_PUBLIC_KEY=""

PUBLISH_SIGNIFY_KEY = $(PUBLISH_BUILD_DIRECTORY)/signify.key

######################################################################
# Publish Modules
######################################################################
PUBLISH_MODULES = devto
