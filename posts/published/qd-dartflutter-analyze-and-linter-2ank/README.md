---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/qd-dartflutter-analyze-and-linter-2ank"
comments_count: "1"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2F6g54z2l6wxnv4slhz9k1.jpg"
created_at: "None"
crossposted_at: "None"
description: "A clean project following conventions is way better than a crappy project containing yolo code. In..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/qd-dartflutter-analyze-and-linter-2ank"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "qd-dartflutter-analyze-and-linter-2ank"
social_image: "None"
title: "Q&D: Dart/Flutter Formatter, Linter and Analyzer"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Q&D: Dart/Flutter Formatter, Linter and Analyzer

A clean project following conventions is way better than a crappy project containing yolo code. In Dart and Flutter, everything is already available to make your life easier.

# Formatter

A formatter is already present with the Dart SDK. The command `dart format` will do the job. If one wants to see only the modification without applying them:

```console
$ dart format show
```

The `dart format` is a shortcut for `dart format write`, meaning it will apply all changes by default.

```console
$ dart format write
```

More information can be available here:

- [Dart Format](https://dart.dev/tools/dart-format) from the official Dart Documentation;

- [Flutter Formatting](https://docs.flutter.dev/tools/formatting) from the official Flutter documentation

- [Dart Style FAQ](https://github.com/dart-lang/dart_style/wiki/FAQ) from the Official Dart Wiki.

# Analyzer

An analyzer is also present by default with the SDK. The command `dart analyze` will analyze the code and print all potentials issues to fix.

```console
$ dart analyze
```

The same command is available with Flutter, only the output will change a bit.

```console
$ flutter analyze
```

More information can be found there:

- [Dart Analyze](https://dart.dev/tools/dart-analyze) from the Official Dart Documentation;

- [Dart Analyzer Package](https://pub.dev/packages/analyzer) on pub.dev;

- [Dart Analyze Source Code](https://github.com/dart-lang/sdk/tree/main/pkg/analyzer) from the official Dart Github Repository.

# Auto Fix

It's also possible to auto-fix the issues by using the `dart fix` command. It was never a good idea to apply those kind of commands in the past, and to be honest, I am not a big fan of that, but here how to use them anyway:

```console
$ dart fix --dry-run
```

```console
$ dart fix --apply
```

More information can be found on the [Dart Fix page](https://dart.dev/tools/dart-fix) from the Official Dart Documentation website.

# Execution

Unfortunately, it seems Dart and Flutter cannot create command aliases or shortcut via the `pubspec.yaml` to execute recurrent commands like it can be found on `Mix`, `rebar3` or even `npm`. In this case, using a `Makefile` can do the job. Here the one created for my project:

```make
# GNU Makefile
EMULATOR_ANDROID ?= NameOfTheAndroidEmulator

.PHONY += all
all: test run-android

.PHONY += format
format:
        dart format .

.PHONY += analyze
analyze:
        flutter analyze .

.PHONY += test
test: format analyze
        flutter test

.PHONY += run-android
run-android:
        flutter emulators --launch $(EMULATOR_ANDROID)

.PHONY: $(.PHONY)
```

To format the code:

```console
$ make format
```

To analyze the code:

```console
$ make analyze
```

To test the code:

```console
$ make test
```

# Github pre-commit Hook

Before doing a git commit, it is also nice to check if everything is correct. Here a short script to execute the previous command:

```console
$ touch .git/hooks/pre-commit

$ chmod +x .git/hooks/pre-commit

$ cat > .git/hooks/pre-commit <<EOF
#!/bin/sh
set -e

make test
EOF
```

Have fun and happy hacking!

----

Cover Image by <a href="https://unsplash.com/@fotomicha?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Foto Micha</a> on <a href="https://unsplash.com/photos/white-smoke-billows-from-a-rusty-barrel-outdoors-9YHfIOC1LtQ?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>