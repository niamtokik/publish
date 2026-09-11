# publish - a low-tech publisher

`publish` is a small project using `pandoc` and `make` to creates
and publish posts. It has been created because the author of the
project was deeply frustrated with the over-complicated solution
to publish content on the web.

# Requirements

```console
```

# Usage

```console
```

# Todo

- core:
  - [ ] add support for configuration file
  - [ ] add support for drafts
  - [ ] add support for published posts
  - [ ] add build cache support for published posts: if a post is published, it should not be built again (or it should be forced)
  - [ ] document the bootstrapping
  - [ ] add dockerfile support
  - [ ] add slug support

- core/indexer:
  - [ ] add auto generated index.html
  - [ ] add cover image support

- core/html:
  - [ ] add support for templates
  - [ ] add support for hardcoded base64 assets in code
  - [ ] add support for cover image
  - [ ] add default metadata support

- core/html:
  - [ ] add support for templates
  - [ ] add support for cover image

- core/epub:
  - [ ] add support for templates
  - [ ] add support for cover image

- core/txt:
  - [ ] add txt/ansi support

- core/djvu:
  - [ ] add support for djvu

- core/checksum:
  - [ ] add support for sha256 checksum via openssl
  - [ ] all produced files must be signed

- core/compilation:
  - [ ] add a way to generate a complete compilation from all posts

- core/category:
  - [ ] add category supports (e.g. `www/categories/${category}/index.html`

- core/keywords:
  - [ ] add keywords indexer supports (e.g. `www/keywords/${keyword}/index.html`

- core/pgp:
  - [ ] add a way to export the public key in www/pkey.pgp
  - [ ] add support for pgp signature
  - [ ] all produced files must signed

- core/ssh:
  - [ ] add a way to export the public key in www/id_ecdsa.pub
  - [ ] add support for ssh signature (signify?)
  - [ ] all produced files must be signed

- core/security:
  - [ ] add support for canary

- modules:
  - [ ] add a way to register them
  - [ ] integrate help
  - [ ] add pre-callback (callback executed before a specific target)
  - [ ] add post-callback (callback executed after a specific target)

- modules/idea:
  - wayback machine module: after a publication, archive it on wayback machine
  - archive.today module: after a publication, archive it on archive.today
  - gist module: after a publication, post it also on gist as markdown
  - humans.txt module: generate humans.txt document
  - robots.txt module: generate robots.txt document
  - pastebin module: after a publiscation, post it also on pastebin
  - gemini module: add gemini format support
  - tarball: generate a tarball of the published files
  - zip: generate a zip of the published files
  - dev.to: publish posts on dev.to
  - wordpress: publish posts on wordpress
  - medium: publish posts on medium

# Bugs and Caveats

# References and Resources
