---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/qd-dart-on-alpine-linux-33n7"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Fxodzzn1zs3fkn61t5tzw.jpg"
created_at: "None"
crossposted_at: "None"
description: "Running Dart outside of the main distribution can be challenging. In fact, my first idea was to..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/qd-dart-on-alpine-linux-33n7"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "qd-dart-on-alpine-linux-33n7"
social_image: "None"
title: "Q&D: Dart on Alpine Linux"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Q&D: Dart on Alpine Linux

Running Dart outside of the main distribution can be challenging. In fact, my first idea was to compile it from sources, but it seems most of the projects are simply using the binaries from Google instead of building the sources directly from the official Dart repository. That's a shame from an "open-source" language but anyway... Here some methods to use Dart on Alpine Linux.

# Using a Container

The Dart Team offers a [Docker image](https://hub.docker.com/_/dart) with the latest version of Dart from the Google Dart binaries. This is probably the easiest way to use Dart on Alpine Linux without adding a lot of useless dependencies in your system.

```console
# podman run -it dart sh
```

See also:

- [Official Dart Docker Image source code](https://github.com/dart-lang/dart-docker);

- [Official Dart Docker Image](https://hub.docker.com/_/dart).

# Using `asdf` or `mise`

`asdf` and `mise` can be used to bootstrap your systems. As usual, the Dart binaries are from Google.

```console
# asdf plugin add dart
```

See also:

- [asdf plugins](https://asdf-vm.com/manage/plugins.html)

- [asdf dart plugin](https://github.com/PatOConnor43/asdf-dart)

# Using Google Binaries

Then, why not downloading ourselves the binaries from Google and installing it on Alpine Linux directly. It will require "only" `gcompat`.

```console
# apk update

# apk add curl gcompat

# curl -Lo dartsdk-linux-x64-release.zip https://storage.googleapis.com/dart-archive/channels/stable/release/3.13.3/sdk/dartsdk-linux-x64-release.zip

# unzip dartsdk-linux-x64-release.zip

# cd dart-sdk

# ./bin/dart --version
Dart SDK version: 3.13.3 (stable) (Tue Sep 1 01:07:17 2026 -0700) on "linux_x64"

# export PATH=${PATH}:$(pwd)/bin

# dart create t && cd t

# dart run
Building package executable... 
Built t:t.
Hello world: 42!
```

The binaries are running on Alpine Linux, but we should be careful, they have been made on Debian-like system (trixie). For example, `ldd` is not really happy due to `__cxa_thread_atexit_impl` missing symbol.

```console
# ldd dart
        /lib64/ld-linux-x86-64.so.2 (0x7925aad9e000)
        libdl.so.2 => /lib64/ld-linux-x86-64.so.2 (0x7925aad9e000)
        libpthread.so.0 => /lib64/ld-linux-x86-64.so.2 (0x7925aad9e000)
        libm.so.6 => /lib64/ld-linux-x86-64.so.2 (0x7925aad9e000)
        libc.so.6 => /lib64/ld-linux-x86-64.so.2 (0x7925aad9e000)
        ld-linux-x86-64.so.2 => /lib/ld-linux-x86-64.so.2 (0x7925aa81f000)
Error relocating dartaotruntime: __cxa_thread_atexit_impl: symbol not found
```

See also:

- [Dart SDK archive Stable channel](https://dart.dev/get-dart/archive#stable-channel)

# Compiling From Sources

What a mess. I thought it would have been easy to compile Dart from sources, but it's not the case, especially on Alpine Linux. I started to work on it, but it's not ready yet, mostly due to the [google tools](https://chromium.googlesource.com/chromium/tools/depot_tools.git) required for the compilation, producing a shit-ton of errors. Anyway, here a quick list of the dependencies

```console
# apk update

# apk add git python3 curl xz gn clang make py3-virtualenv py3-setuptools py3-pip bash
```

See also:

- [Building dart sdk](https://github.com/dart-lang/sdk/issues/36018) on Github issues

# Conclusion

I need a recent version of Dart, Flutter and Android SDK in a container. Unfortunately, the only ones have found are old, unmaintained or unofficial (it means trusting people I don't know).

- [Docker image for Android SDK](https://github.com/MobileDevOps/android-sdk-image): a docker image with the latest android sdk ONLY (no dart, no flutter);

- [AndroidSDK](https://github.com/thyrlian/AndroidSDK): another docker image containing the latest android SDK;

- [Kosmos](https://github.com/davils-com/kosmos): another docker image with android SDK;

- [docker-android-sdk](docker-android-sdk): again, another docker image with android SDK;

- [Docker Android Build Box](https://github.com/mingchen/docker-android-build-box): docker image containing android SDK, JDK, and Flutter. This is the closed ones, but it is huge (5.5GB). I would like to avoid fetching the whole universe;

- [image.flutter](https://github.com/its-me/image.flutter): a docker image containing flutter and the android sdk. Perhaps the good catch, but it uses an old version of flutter, and not even sure it works correctly (I like the `localhost/android-sdk` source image). To be tested.

Anyway, building and releasing mobile application is a PITA. I understand why so many companies are selling a full build effortless pipeline, that's business.

As usual, have fun and happy hacking!

----

Cover Image by <a href="https://unsplash.com/@camila_mof?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Camila Mofsovich</a> on <a href="https://unsplash.com/photos/darts-drinks-and-jars-on-a-table-KyjXWDV6TIA?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>

