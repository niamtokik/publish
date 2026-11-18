---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/first-web-page-with-flutter-dag"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2F2i0aw17g8ik8ghlffw62.jpg"
created_at: "None"
crossposted_at: "None"
description: "Writing programs in OOP after more than 10 years of Erlang, Elixir and other Functional languages is..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/first-web-page-with-flutter-dag"
public_reactions_count: "1"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "first-web-page-with-flutter-dag"
social_image: "None"
title: "First Web Page with Flutter"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# First Web Page with Flutter

Writing programs in OOP after more than 10 years of Erlang, Elixir and other Functional languages is kinda difficult. Instead of starting with a complex project or a simple hello world bullshit program, let start with something that could be useful to me: creating a single web with Dart and Flutter.

The official Flutter documentation includes a [quick tutorial](https://docs.flutter.dev/platform-integration/web/building) to start a web application from scratch, but before doing anything, a list of requirements could be nice to have. So, what the plan?

 - I would like to learn a bit how Dart/Flutter generates the website
 - I would like to have a single page made of multi pane/frame
 - I would like to have an easy way to create each pane/frame using for example Markdown or Asciidoc format (or in the worst case scenario, YAML)
 - I would like to have a responsive page by default
 - I would like to have a non-exhaustive list of packages/libraries doing this kind projects
 - I would like to have a list of open-source templates/examples to study the code

# Bootstrapping Flutter for Web Development

"[Building a web application with Flutter
](https://docs.flutter.dev/platform-integration/web/building)" is the main documentation and give us a good introduction to setup an environment.

```sh
# create a new flutter project
flutter create www --platforms web
cd www
```

The previous command generates a new flutter project with a [default demo template](https://github.com/flutter/flutter/blob/master/packages/flutter_tools/templates/app/web/index.html.tmpl) for the web platform. Source code directly related to this kind of project can be found in the `web` directory. Let start the server with `flutter run` command.

```sh
# start the server
flutter run
```

After a small delay (for the compilation), your browser should be launched or a new tab should be open containing the demo website from localhost. You can see below a screenshot from this page on Chromium.

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/j98719fkdtoul1ykl8qe.png)

Okay, that's great, but I would like to see what kind of artifacts flutter creates. Let build the project using `flutter build` command.

```sh
flutter build
```

All artifacts can be found in `build/web` directory, including the index file and all assets (images, fonts, scripts and other custom stuff).

```console
$ cd build/web
$ tree 
.
├── assets
│   ├── AssetManifest.bin
│   ├── AssetManifest.bin.json
│   ├── FontManifest.json
│   ├── fonts
│   │   └── MaterialIcons-Regular.otf
│   ├── NOTICES
│   ├── packages
│   │   └── cupertino_icons
│   │       └── assets
│   │           └── CupertinoIcons.ttf
│   └── shaders
│       ├── ink_sparkle.frag
│       └── stretch_effect.frag
├── canvaskit
│   ├── canvaskit.js
│   ├── canvaskit.js.symbols
│   ├── canvaskit.wasm
│   ├── chromium
│   │   ├── canvaskit.js
│   │   ├── canvaskit.js.symbols
│   │   └── canvaskit.wasm
│   ├── skwasm_heavy.js
│   ├── skwasm_heavy.js.symbols
│   ├── skwasm_heavy.wasm
│   ├── skwasm.js
│   ├── skwasm.js.symbols
│   ├── skwasm.wasm
│   ├── wimp.js
│   ├── wimp.js.symbols
│   └── wimp.wasm
├── favicon.png
├── flutter_bootstrap.js
├── flutter.js
├── flutter_service_worker.js
├── icons
│   ├── Icon-192.png
│   ├── Icon-512.png
│   ├── Icon-maskable-192.png
│   └── Icon-maskable-512.png
├── index.html
├── main.dart.js
├── manifest.json
└── version.json
```

Hmm. Lot of files have been generated indeed. I'm not coming from web development, and the last time I created a website from scratch was... years ago. In this situation, I need a bit of definition and understand what are all those new files.

What `canvaskit` and `skwasm` are? Based on [Flutter documentation](https://docs.flutter.dev/platform-integration/web/renderers), these are renderers used by flutter to create a flutter compatible engine in WASM. CanvasKit is used by default. skwasm is a smaller version of [Skia](https://skia.org/) (a graphic library).

One of these 2 renderers can be used depending of the application, again, the [documentation](https://docs.flutter.dev/platform-integration/web/renderers#choosing-which-build-mode-to-use) is giving us few hints to select the correct one for our project.

Now, how to "release" it? It seems a web server is required by default, the example provided by the [documentation](https://docs.flutter.dev/deployment/web#building-the-app-for-release) is using `python` with the command below. Unfortunately, opening directly the `index.html` file from the filesystem does not work, probably due to default CORS configuration.

```sh
cd build/web
python -m http.server 8000
```

What does it means? If one wants to release its Flutter application, one can simply create a tarball from `build/web` or using `rsync`? Well, it looks like it's a complex process just for a single page. We'll probably have an answer to this question later.

---- 

Cober Image by <a href="https://unsplash.com/@evgenit?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Evgeni Tcherkasski</a> on <a href="https://unsplash.com/photos/boat-on-calm-water-near-mountain-during-daytime-hoKgCD9kfTE?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
      