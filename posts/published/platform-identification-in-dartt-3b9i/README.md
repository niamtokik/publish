---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/platform-identification-in-dartt-3b9i"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fq6qufz3swlheaq0pfyal.jpg"
created_at: "None"
crossposted_at: "None"
description: "During the last weeks, I tried to learn a lot from Dart and Flutter, but even after a bit less than 1..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/platform-identification-in-dartt-3b9i"
public_reactions_count: "1"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "platform-identification-in-dartt-3b9i"
social_image: "None"
title: "Platform Identification in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Platform Identification in Dart

During the last weeks, I tried to learn a lot from Dart and Flutter, but even after a bit less than 1 month, I still don't know some basic stuff. When I was dealing with command line arguments parsing, I was thinking "how to get the goddamn program name". You know, the string you can simply have with `argv[0]` [^ansi-c] in C or with the functions exported by the [`init`](https://www.erlang.org/doc/apps/erts/init.html) module in Erlang. In Dart, you will require `dart:io` package and the [`Platform`](https://api.dart.dev/dart-io/Platform-class.html) class.

Let write a small program to print out what kind of information this class store.

```dart
import 'dart:io' show Platform;

void main(List<String> arguments) {
  final info = systemInfo();
  for (final key in info.keys) {
    print("Platform.${key}: ${info[key]}");
  }
}

Map<String, dynamic> systemInfo() {
  return {
    "environment": Platform.environment,
    "executable": Platform.executable,
    "executableArguments": Platform.executableArguments,
    "isAndroid": Platform.isAndroid,
    "isFuchsia": Platform.isFuchsia,
    "isIOS": Platform.isIOS,
    "isLinux": Platform.isLinux,
    "isWindows": Platform.isWindows,
    "lineTerminator": Platform.lineTerminator,
    "localeName": Platform.localeName,
    "localHostname": Platform.localHostname,
    "numberOfProcessors": Platform.numberOfProcessors,
    "operatingSystem": Platform.operatingSystem,
    "operatingSystemVersion": Platform.operatingSystemVersion,
    "packageConfig": Platform.packageConfig,
    "pathSeparator": Platform.pathSeparator,
    "resolvedExecutable": Platform.resolvedExecutable,
    "script": Platform.script,
    "version": Platform.version
  };
}
```

The function `systemInfo()` returns a `Map<String, dynamic>` where the keys of the maps are simply a reference to the name of the `Platform` class attributes. Nothing complex there. When executed it will print the content of all attributes line by line. 

- [`Platform.environment`](https://api.dart.dev/dart-io/Platform/environment.html) returns the environment in a `Map<String, String>`;

```console
Platform.environment: {
  SHELL: /bin/bash,
  ...
}
```

- [`Platform.executable`](https://api.dart.dev/dart-io/Platform/executable.html) returns the name of the executable used to execute the application as a `String`, in our case, I am using `dart run` command (and then use the Dart VM);

```console
Platform.executable: /.asdf/installs/flutter/3.41.7-stable/bin/cache/dart-sdk/bin/dart
```

- [Platform.executableArguments](https://api.dart.dev/dart-io/Platform/executableArguments.html) returns the arguments passed to the application as a `List<String>`, again, in our case, we are using the Dart VM, most of the arguments directly related to it;

```console
Platform.executableArguments: [
  --resolved_executable_name=/.asdf/installs/flutter/3.41.7-stable/bin/cache/dart-sdk/bin/dart, 
  --executable_name=/.asdf/installs/flutter/3.41.7-stable/bin/cache/dart-sdk/bin/dart,
  --packages=.dart_tool/package_config.json
]
```

- [`Platform.isLinux`](https://api.dart.dev/dart-io/Platform/isLinux.html) returns a `Bool`, it's true if it's a Linux system, else it's false. Other attributes like that are exposed to check easily what kind of systems is being used;

```console
Platform.isLinux: true
```

- [`Platform.localeName`](https://api.dart.dev/dart-io/Platform/localeName.html) returns the locale environment as `String`, useful for the localization;

```console
Platform.localeName: en_US.UTF-8
```

- [`Platform.localHostname`](https://api.dart.dev/dart-io/Platform/localHostname.html) returns the name of the host (defined in `/etc/hosts` or in `/etc/hostname`) as `String`;

```console
Platform.localHostname: localhost
```

- [`Platform.numberOfProcessors`](https://api.dart.dev/dart-io/Platform/numberOfProcessors.html) returns the number of available CPU as `int`, no distinctions between a real CPU or a core;

```console
Platform.numberOfProcessors: 16
```

- [`Platform.operatingSystem`](https://api.dart.dev/dart-io/Platform/operatingSystem.html) returns the code name of the system as a `String`;

```console
Platform.operatingSystem: linux
```

- [`Platform.operatingSystemVersion`](https://api.dart.dev/dart-io/Platform/operatingSystemVersion.html) returns the version of the system used as `String`, for Linux, it will be the version of the kernel, the same kind of string that could be returned by [`uname`](https://manpages.debian.org/trixie/coreutils/uname.1.en.html);

```console
Platform.operatingSystemVersion: Linux 6.19.13+parrot7-amd64 #1 SMP PREEMPT_DYNAMIC Parrot 6.19.13-1parrot1 (2026-04-30)
```

- [`Platform.resolvedExecutable`](https://api.dart.dev/dart-io/Platform/resolvedExecutable.html) returns the full path of the executable as a `String`;

```console
Platform.resolvedExecutable: /.asdf/installs/flutter/3.41.7-stable/bin/cache/dart-sdk/bin/dart
```

- [`Platform.script`](https://api.dart.dev/dart-io/Platform/script.html) returns the script (Dart application) running in the current isolate (in our the default one) as `String`;

```console
Platform.script: file:///tmp/dart/system_info/.dart_tool/pub/bin/system_info/system_info.dart-3.11.5.snapshot
```

- [`Platform.version`](https://api.dart.dev/dart-io/Platform/version.html) returns the Dart version used for this application as `String`

```console
Platform.version: 3.11.5 (stable) (Wed Apr 15 00:36:32 2026 -0700) on "linux_x64"
```

Sadly, one will not find a lot of resources about platform detection, at least, directly on Dart. Some posts can be found on the web regarding Flutter integration on different platform, but not so much when it comes to create a command line interface tool. Here a list containing other resources.

- [`Platform` class API Documentation](https://api.dart.dev/dart-io/Platform-class.html) from `dart:io` module;

- [Flutter: Understanding dart:io Platform, defaultTargetPlatform, and kIsWeb (and When to Use Each)](https://medium.com/@abhishek17600031/flutter-understanding-dart-io-platform-defaulttargetplatform-and-kisweb-and-when-to-use-each-bac1a5d10f73) on Medium

- [How do you detect the host platform from Dart code?](https://medium.com/@chetan.akarte/how-do-you-detect-the-host-platform-from-dart-code-d0694529ac51) on Medium

- [Dart Platform](https://www.zetcode.com/dart/platform/) on ZetCode

Happy hack and have fun!

----

Cover Image by <a href="https://unsplash.com/@goraivis?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">GoRaivis Photography</a> on <a href="https://unsplash.com/photos/a-black-and-white-photo-of-a-train-platform-Jsus4t5Q2Mc?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>

[^ansi-c]: The function called at program startup is named main. The implementation declares no prototype for this function. It can be defined with no parameters or with two parameters (referred to here as `argc` and `argv`, though any names may be used, as they are local to the function in which they are declared). [...] The value of `argc` shall be nonnegative. `argv[argc]` shall be a null pointer. From [ANSI-C Specification](http://flash-gordon.me.uk/ansi.c.txt)