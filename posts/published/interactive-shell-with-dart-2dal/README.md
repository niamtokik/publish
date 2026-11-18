---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/interactive-shell-with-dart-2dal"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2F0lrpcnsb32ivyi8wiz46.jpg"
created_at: "None"
crossposted_at: "None"
description: "Any modern languages should have its REPL, Erlang, Elixir, Haskell, Clojure, Ocaml, Python... All of..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/interactive-shell-with-dart-2dal"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "interactive-shell-with-dart-2dal"
social_image: "None"
title: "Interactive Shell with Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Interactive Shell with Dart

Any modern languages should have its REPL, Erlang, Elixir, Haskell, Clojure, Ocaml, Python... All of them got one shell-like feature to interact with the application in conception phase. That's kinda mandatory to me, it permits to test functions before adding them in the final commit, it can be used to draft quick ideas and so on. When I started learning Dart, I was a bit sad it was not integrated by default... but someone decided to fix that by creating the [`interactive`](https://pub.dev/packages/interactive) package! Let create a new project called `myrepl` just to check that.

```console
$ dart create myrepl
Creating myrepl using template console...

  .gitignore
  analysis_options.yaml
  CHANGELOG.md
  pubspec.yaml
  README.md
  bin/myrepl.dart
  lib/myrepl.dart
  test/myrepl_test.dart

Running pub get...                     0.3s
  Resolving dependencies...
  Downloading packages...
  Changed 48 dependencies!

Created project myrepl in myrepl! In order to get started, run the following commands:

  cd myrepl
  dart run

$ cd myrepl
```

As usual, the new dependency can be added using `dart pub add`. `interactive` depends on 12 dependencies, so, it could be better to add it only in the `dev` environment.

```console
$ dart pub add interactive
Resolving dependencies... 
Downloading packages... 
< _fe_analyzer_shared 85.0.0 (was 100.0.0) (100.0.0 available)
< analyzer 7.7.1 (was 13.0.0) (13.0.0 available)
+ cli_repl 0.2.3
< coverage 1.6.4 (was 1.15.0) (1.15.0 available)
+ interactive 1.4.1
+ js 0.6.7 (0.7.2 available)
< matcher 0.12.17 (was 0.12.20) (0.12.20 available)
< test 1.26.3 (was 1.31.1) (1.31.1 available)
< test_api 0.7.7 (was 0.7.12) (0.7.12 available)
< test_core 0.6.12 (was 0.6.18) (0.6.18 available)
< vm_service 11.10.0 (was 15.2.0) (15.2.0 available)
These packages are no longer being depended on:
- cli_config 0.2.0
Changed 12 dependencies!
9 packages have newer versions incompatible with dependency constraints.
Try `dart pub outdated` for more information
```

Next, `interactive` package must be compiled and activated on the system. It will be installed locally in `${HOME}/.pub-cache/bin` directory.

```console
$ dart pub global activate interactive
Package interactive is currently active at version 1.4.1.
Downloading packages... . 
  _fe_analyzer_shared 85.0.0 (100.0.0 available)
  analyzer 7.7.1 (13.0.0 available)
  js 0.6.7 (0.7.2 available)
> meta 1.18.3 (was 1.18.2)
  vm_service 11.10.0 (15.2.0 available)
Building package executables... (2.5s)
Built interactive:interactive.
Installed executable interactive.
Warning: Pub installs executables into $HOME/.pub-cache/bin, which is not on your path.
You can fix that by adding this to your shell's config file (.bashrc, .bash_profile, .zshrc etc.):

  export PATH="$PATH":"$HOME/.pub-cache/bin"

Activated interactive 1.4.1.

$ file ${HOME}/.pub-cache/bin/interactive 
${HOME}/.pub-cache/bin/interactive: a sh script, ASCII text executable
```

The `${HOME}/.pub-cache/bin/interactive` file is a simple shell script using the dart VM to execute the `interactive` package. The command executed looks like the snippet below. It means this code could be executed anywhere on your system if the `interactive` package is installed (it will produce some errors outside a Dart project directory).

```console
dart pub -v global run interactive:interactive "$@"
```

Anyway, let export the Dart `bin` directory inside our `PATH`.

```console
$ export PATH="${PATH}:${HOME}/.pub-cache/bin"
```

Great! Let execute the `interactive` command (it should be present in our `PATH` now).

```console
$ interactive
Run: /bin/dart [--enable-vm-service=34273, file:///bin/interactive.dart-3.11.5.snapshot, --vm-service-was-enabled]
Workspace: /tmp/dart_interactive_workspace_2026-06-04T163359990891
The Dart VM service is listening on http://127.0.0.1:34273/HveG-LmYIiQ=/
The Dart DevTools debugger and profiler is available at: http://127.0.0.1:34273/HveG-LmYIiQ=/devtools/?uri=ws://127.0.0.1:34273/HveG-LmYIiQ=/ws
>>> 
```

The command invoke a shell with a `>>>` prompt. What will happen if we create some Dart code?

```console
>>> 1+1
2

>>> class Meh { String _meh = ""; Meh(String meh) : this._meh = meh; String toString() => "${_meh}!"; }

>>> Meh("test")
test!

>>> import 'dart:async';

>>> Future<int> t() { return 1; }
[WARNING 2026-06-04 20:25:05.859183] Error: Hot reload failed, maybe because code has syntax error?

>>> Future<int> t() async { return 1; }

>>> t().then((x) => print(x))
Instance of 'Future<void>'
>>> 1
```

It works! `interactive` gives us a way to dynamically create Dart code, like any modern language! That's very cool! It's even possible to execute command from the system itself by prefixing the line to execute with `!`.

```console
>>> !ls
lib
pubspec.lock
pubspec.yaml

>>> !pwd
/tmp/dart_interactive_workspace_2026-06-04T201405364736
```

# Conclusion

This is a great project, and it could be even better to see it be added in the SDK! At this time, it works, but it feels like it's a bit unstable and not finished yet. The shell is working but can be slow sometimes. The fact the `devtools` are already started by default is also another nice feature. What's missing to me? Here a quick list of cool stuff to add:

- adding a successful command line index counter, every time a command is being executed, the counter is increased;

- removing the "..." for the multi line support, it can be annoying when doing a copy/paste;

- integrating the `devtools` directly into the shell, like `@profile` to profile the application or `@memory` to see memory usage; 

- saved session with state and command history restore;

- debugger and tracer integration;

- documentation and manual integration like `help(Object)`;

- class, function and command Auto-completion when pressing tab;

- handlers, hooks and other features to make a custom shell.

As usual, if you want to know more about this project, here some links:

- The [`interactive` package](https://pub.dev/packages/interactive) at pub.dev;

- The [official `interactive` package source code](https://github.com/fzyzcjy/dart_interactive) at Github;

- The [`interactive` API documentation](https://pub.dev/documentation/interactive/latest/)

# Bonus: devtools

While testing `interactive` I discovered the Dart [`devtools` suite](https://dart.dev/tools/dart-devtools). It's a pretty cool way to debug, trace and profile a Dart application, thanks to the Dart virtual machine. This application is working a bit like the different tools we have with the BEAM (e.g. observer, debugger and so on). Here some screenshot from the previous project created.

- http://127.0.0.1:34273/HveG-LmYIiQ=/devtools/home?compiler=wasm


![Connection Page](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/2i5vup0s59rdgjhr6ivj.png)


![Performance Page](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/whzaq4el6fmhorc8free.png)


![CPU Profiler Page](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/rpbnm4lrwzg3wspbjkyy.png)


![Memory Page](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ipv0v6t5le10usx4bbyc.png)


![Network Page](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/00k674eyay48gy1u4scf.png)

A full post on this feature will be required. For now, it's just a quick overview based on screenshots.


----

Cover Image by <a href="https://unsplash.com/@giuliamay?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Giulia May</a> on <a href="https://unsplash.com/photos/a-close-up-of-a-shell-with-a-white-background-cNtMy74-mnI?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>