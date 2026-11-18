---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/first-steps-with-dart-and-flutter-on-linux-4iid"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fyh4tqwxhevftb3fh1bgy.jpg"
created_at: "None"
crossposted_at: "None"
description: "As you probably already know, my front-end developer competencies are pretty low. Like everyone else,..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/first-steps-with-dart-and-flutter-on-linux-4iid"
public_reactions_count: "1"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "first-steps-with-dart-and-flutter-on-linux-4iid"
social_image: "None"
title: "First steps with Dart and Flutter on Linux"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# First steps with Dart and Flutter on Linux

As you probably already know, my front-end developer competencies are pretty low. Like everyone else, modifying existing HTML/Javascript files/scripts is possible, but creating an application from scratch is kinda hard. My brain is not really wired like application developers, probably due to many years of system/network administrator and backend-only projects.

Creating an application seems to be kinda mandatory today, websites are still quite useful, but most of the market is focused on mobile application for Android and/or iOS. If you have a project in mind, it will probably be developed for one of these platform first, and then ported to others ones like Windows, Linux or MacOS.

After reading few publications and books on this subject during the last weeks, it seems Dart/Flutter is probably the best choice for me. Why? Let list the reasons:

 - One of the project I would like to create will require C/C++ integration for some specific libraries. React Native and Swift can easily do that, but Swift still has some trouble to deal with Android (even if the latest release is offering a decent interface to it) and React Native is mostly in Javascript/Typescript, not a big fan.

 - Dart/Flutter can build application for Android, iOS, Windows, MacOS, Linux but also for Chrome, Firefox, Safari and Edge. One of the project I want to create will be running on mobile but also on Desktop system, so, it looks great. Adding a compatibility layer for browsers could also be a good idea, even if I doubt right now if it will be one of my target.

 - Dart has been created by Google in 2011. It's an object oriented language, but in this field, all other languages are sharing the same foundation. Swift and React Native, even C++ are object oriented. The syntax of all these languages are looking similar

 - Why not Swift? Well, a friend of mine wanted me to learn it. After having reading some publications on it, even if the language looks clean, my goal is to release an application on both Android/iOS quick. Another problem: I'm not an Apple user, managing MacOS servers was already painful, I don't want to deal with that right now.

 - At this time, Flutter is used by 16% of the application on App Store (second place) and on 23% of the application on Google Play (second place as well), based on [The Most Popular Development SDKs](https://appfigures.com/top-sdks/development/all) website. I have the choice to learn Kotlin and Swift or simply learn Dart/Flutter. Not sure if it's the best choice, but because a C++ library will contain most of the logic of the application, if more aggressive optimizations are required, rewriting the application in Swift/Kotlin/c++ entirely should be okay.

# Bootstrapping on Debian-like system

My current development platform is based on [Parrot-Linux](https://www.parrotsec.org/) - a debian-like security-oriented distribution. My other laptops are running on [OpenBSD](https://www.openbsd.org/), but Dart is not compatible there, like Android-studio. The following procedure will use [asdf](https://asdf-vm.com/) and [Android Studio Panda 4](https://androidstudio.googleblog.com/2026/04/android-studio-panda-4-now-available.html).

## Required Software/Libraries

```sh
# Install gtk-3 libs/headers for flutter
# required for Linux desktop application
sudo apt-get install libgtk-3-dev

# Install some asdf plugin
# required for dart/flutter
asdf plugin add ninja
asdf install ninja 1.13.2
asdf plugin add cmake
asdf install cmake 4.0.3
```

## Dart via asdf

```sh
asdf plugin add dart
asdf install dart 3.11.5
```

## Flutter via asdf

```shell
asdf plugin add flutter
asdf install flutter 3.41.7-stable
```

## Install Android Studio

Android studio complete installation procedure can be found on the official [Android documentation](https://developer.android.com/studio/install#linux)

```sh
wget https://edgedl.me.gvt1.com/android/studio/ide-zips/2025.3.4.6/android-studio-panda4-linux.tar.gz

# extract the tarball
tar zxvf android-studio-panda4-linux.tar.gz

# go into extract dir and execute android
# studio
cd android-studio
./bin/studio
```

Default parameters have been configured on every steps of the installation, Android SDK and other tools are installed in `${HOME}/Android`.

## Configure Android Studio Environment Variables

```shell
export ANDROID_HOME="${HOME}/Android/Sdk"
export PATH="${PATH}:${ANDROID_HOME}/tools"
export PATH="${PATH}:${ANDROID_HOME}/tools/bin"
export PATH="${PATH}:${ANDROID_HOME}/platform-tools"
```

## Install Extra Android Tools

Based on [Flutter Documentation](https://docs.flutter.dev/platform-integration/android/setup), few Android tools are required:

 - [Android SDK Build-Tools](https://developer.android.com/tools/releases/build-tools)
 - [Android SDK Command-line Tools](https://developer.android.com/tools/)
 - Android Emulator
 - [Android SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools)
 - CMake
 - [NDK](https://developer.android.com/ndk/)

## Install Android via Emulators

[Flutter](https://docs.flutter.dev/platform-integration/android/setup#set-up-devices) and Android Studio documentations recommends to use the GUI from Android Studio, but it seems one can also use  [`avdmanager`](https://developer.android.com/tools/avdmanager) to install and configure a new emulator. Not sure yet how to use it correctly.

# First Desktop Application

The environment should now be ready and everything should be working. Let create a first application called `birdle` using [the official Flutter tutorial](https://docs.flutter.dev/learn/pathway/tutorial/create-an-app), assuming `~/projects` directory exists.

```sh
cd ~/projects
flutter create birdle --empty
```

Sadly, `flutter create` command does not have a man page available, and only `flutter create --help` can return how to use it. If you want to know more, the source code where the "documentation" can be found is available in [`packages/flutter_tools/lib/src/commands/create.dart`](https://github.com/flutter/flutter/blob/v1.16.3/packages/flutter_tools/lib/src/commands/create.dart). Not sure yet if there is a way to export that as man page though.

Anyway, this command creates a tree containing the following files:

 - [`analysis_options.yaml`](https://dart.dev/tools/analysis#the-analysis-options-file): this file configures Dart static analyzer.

 - [`birdle.iml`](https://www.jetbrains.com/help/idea/configure-modules.html): this file is for the jetbrains IntelliJ Text Editor. Not sure if it's really useful to have it.

 - [`pubspec.yaml`](https://dart.dev/tools/pub/pubspec): project metadata (including dependencies)

 - [`pubspec.lock`](https://dart.dev/tools/pub/versioning#lockfiles): related to pubspec for versioning.

 - `lib/main.dart`: flutter/dart entry-point, where all the magic happens. This can be changed using `flutter run -t lib/my_other_file.dart`

 - `android/`: directory containing default files for android

 - `macos/`: directory containing default files for macos

 - `windows/`: directory containing default files for windows

 - `linux/`: directory containing default files for linux

 - `ios/`: directory containing default files for ios

 - `web/`: : directory containing default files for web user interface

 - [`.metadata`](https://docs.flutter.dev/packages-and-plugins/developing-packages): mostly used by IDEs for package's dependencies

 - [`.dart_tool/`](https://dart.dev/tools/pub/private-files#dart_tool): Used by dart tools

 - `.idea/`: intellij IDE metadata

## Permission issues

When executing `flutter run` on the project directory, I got a permission issue, the same described by [@gaaclarke on Github]( https://github.com/flutter/flutter/issues/115376). The followings commands fixed the issue:

```sh
flutter clean
flutter build linux
```

# Conclusion

Bootstrapping Linux for Dart/Flutter is straightforward. The most complex part is related to the environment to support, and configuring all the small things for Android, iOS, Windows and so on. In this article, only Android and Linux have been configured. I hope I will have time to do the same for both iOS, MacOS and Windows in a near future.

# References and Resources

[Dart Official Documentation](https://dart.dev/learn)

[Flutter Official Documentation](https://docs.flutter.dev/)

[Android Official Documentation](https://developer.android.com/develop)

----

Cover Image by <a href="https://unsplash.com/@erik_brolin?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Erik Brolin</a> on <a href="https://unsplash.com/photos/woman-blowing-paper-strips-in-selective-focus-photography-sp7ir7Xrs9U?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>