---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/dart-library-and-cli-project-30k1"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2F4st69s0soclovuvree4e.jpg"
created_at: "None"
crossposted_at: "None"
description: "Creating a library is great, in particular if one wants to avoid doing duplicated code, but the..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/dart-library-and-cli-project-30k1"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "dart-library-and-cli-project-30k1"
social_image: "None"
title: "Dart Library and CLI Project"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Dart Library and CLI Project

Creating a library is great, in particular if one wants to avoid doing duplicated code, but the library can also be released with a command line interface for simple tasks (or tests).

A Dart package (or library) can be created using `dart create` command, the `--template` flag define which kind of skeleton will be used for the project, in this case, it will be a `package` project.

```sh
dart create --template package mycli
```

The tree generated is straightforward and contains only the required files to do a successful build.

```shell
$ tree
.
├── analysis_options.yaml
├── CHANGELOG.md
├── example
│   └── mycli_example.dart
├── lib
│   ├── mycli.dart
│   └── src
│       └── mycli_base.dart
├── pubspec.lock
├── pubspec.yaml
├── README.md
└── test
    └── mycli_test.dart

5 directories, 9 files
```

Let try to run the code with `dart run`.

```console
$ dart run
Resolving dependencies in `/home/user/tmp/dart/mycli`... 
Downloading packages... 
Got dependencies in `/home/user/tmp/dart/mycli`.
Could not find `bin/mycli.dart` in package `mycli`.
```

It fails. Why? Because no executables entry-points have been defined somewhere. Let creates `./bin/main.dart` file, simply containing a `main()` function.

```sh
mkdir bin
cat > bin/mycli.dart << EOF
void main() {
  print("hello");
}
EOF
```

Now, we can try to run it. It should not fail.

```console
$ dart run
hello
```

It works! If you want to define custom command line application, a list of [executables](https://dart.dev/tools/pub/pubspec#executables) can be defined in `pubspec.yaml`.

----

Image Cover by <a href="https://unsplash.com/@clemono?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Clem Onojeghuo</a> on <a href="https://unsplash.com/photos/person-picking-dart-pins-on-board-8AiDiLLGmJs?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>    