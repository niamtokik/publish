---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/qd-flutter-app-and-android-sdk-2ncm"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2F55rqua053q9khurwsdmt.jpg"
created_at: "None"
crossposted_at: "None"
description: "After having upgraded few tools on machine, one of my application was totally unable to run. I got a..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/qd-flutter-app-and-android-sdk-2ncm"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "qd-flutter-app-and-android-sdk-2ncm"
social_image: "None"
title: "Q&D: Flutter App and Android-SDK"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Q&D: Flutter App and Android-SDK

After having upgraded few tools on machine, one of my application was totally unable to run. I got a lot of warnings, especially this one:

```console
Warning: Flutter support for your project's Gradle version (8.14.0) will soon be dropped. Please upgrade your Gradle version to a version of at least 9.1.0 soon.                             
Alternatively, use the flag "--android-skip-build-dependency-validation" to bypass this check
```

and finally...

```console
FAILURE: Build failed with an exception.                                                                                                                                                      
                                                                                                                                                                                              
* What went wrong:                                                                                                                                                                            
Execution failed for task ':app:compileFlutterBuildDebug'.                                                                                                                                    
> A problem occurred starting process 'command '/home/user/.local/share/mise/http-tarballs/dd5ae32abcea719e3c351c56a28308b91e2ce97fb5702bf2710c2527dde522af_strip_1/bin/flutter''             
                                                                                                                                                                                              
* Try:                                                                                                                                                                                        
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 1s
Running Gradle task 'assembleDebug'...                           1,270ms
Error: Gradle build failed due to Java/Gradle incompatibility.
The Java version used for the build is 25.0.3, which is incompatible with Gradle 8.14.
To fix this, you can either:
  1. Upgrade your project's Gradle version (typically in gradle-wrapper.properties to a version matching the range: compatible Gradle versions for Java 25.0.3 are 9.1.0 or newer).
  2. Use a different Java version for Flutter by running `flutter config --jdk-dir=<path>`.
```

Annoying right? In fact, many other warnings were displayed, but what happened there? The last time, it was working without problem. Let have a look on the android sdk

# Android SDK Upgrade

The "old" latest version of the android-sdk called [Panda 4](https://developer.android.com/studio/releases/past-releases/as-panda-4-release-notes) was used, instead of the new latest version called [Quail 4](https://developer.android.com/studio/releases).

```console
$ cd Downloads

$ wget https://edgedl.me.gvt1.com/android/studio/ide-zips/2026.1.4.7/android-studio-quail4-linux.tar.gz

$ tar zxf android-studio-quail4-linux.tar.gz

$ cd android-studio

$ ls bin
appletviewer.policy  game-tools.sh    lldb         studio              studio.svg
brokenPlugins.db     helpers          ltedit.sh    studio64.vmoptions
format.sh            idea.properties  profiler.sh  studio.png
fsnotifier           inspect.sh       restarter    studio.sh
```

# Android SDK Platforms and Tools Upgrade

The latest android-studio version is now installed, but the SDK Platforms and the SDK Tools needs to be upgraded as well. It can be done via android studio directly in `Menu > Tools > SDK Managers`. The versions to upgrade to should be displayed with the installed one as well. If needed, install some latest versions or missing tools.

```console
$ ./bin/studio
```

The upgraded versions should have been extracted in the `${HOME}/Android` directory. It can also be done using the `sdkmanager` tool.

```console
$ sdkmanager --update
```

# Flutter and Dart upgrade

My development machine is using `mise` to have the latest version of flutter and dart. The version of these applications are usually stored in the `.tool-versions`. It can be upgraded using the `upgrade` subcommand.

```console
$ cd ~/project

$ cat .tool-versions
flutter latest
dart latest

$ mise upgrade
...
```

# Environment Variables

My environment was a mess, because many tools were living together and usually, because you want to do something quick, you put everything in your `~/.bashrc`. Here the new conf.

```sh
# recreates a full clean path from scratch
export PATH=/bin:/usr/bin:/usr/local/bin
export PATH=/sbin:/usr/sbin:/usr/local/sbin:$PATH
export PATH=${HOME}/bin:$PATH

# enable mise
eval "$(~/mise/bin/mise activate bash)"

# set android configuration
export ANDROID_HOME=${HOME}/Android/Sdk
export PATH=$ANDROID_HOME/tools:$PATH
export PATH=$ANDROID_HOME/tools/bin:$PATH
export PATH=$ANDROID_HOME/platform-tools:$PATH
export PATH=$ANDROID_HOME/cmake/4.1.2/bin:$PATH
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH

export CHROME_EXECUTABLE=$(which chromium)
export EDITOR=vim
```

# Flutter and Gradle

Gradle was crying because of an old version unsupported to some new versions installed. To be honest, my android application version is still quite simple, so, I fixed the issue by recreating the `android` directory from the flutter project root.

```console
$ cd ~/project

$ mv android android.old

$ flutter create . --platforms=android
Recreating project .... 
...
Resolving dependencies...                                                                                                                                                                     
Downloading packages...                                                                                                                                                                       
Got dependencies.                                                                                                                                                                             
Wrote 26 files.                                                                                                                                                                               
                                                                                                                                                                                              
All done!                                                                                                                                                                                     
You can find general documentation for Flutter at: https://docs.flutter.dev/                                                                                                                  
Detailed API documentation is available at: https://api.flutter.dev/                                                                                                                          
If you prefer video documentation, consider: https://www.youtube.com/c/flutterdev                                                                                                             
                                                                                                                                                                                              
In order to run your application, type:                                                                                                                                                       
                                                                                                                                                                                              
  $ flutter run                                                                                                                                                                               
                                                                                                                                                                                              
Your application code is in ./lib/main.dart.
```

The application can now be restarted again.

```console
$ flutter run
```

Here the [`flutter` command reference](https://docs.flutter.dev/reference/flutter-cli).

# Another Gradle issue

```console
WARNING: A restricted method in java.lang.System has been called                                                                                                                              
WARNING: java.lang.System::load has been called by net.rubygrapefruit.platform.internal.NativeLibraryLoader in an unnamed module (file:/home/user/.gradle/wrapper/dists/gradle-9.3.1-all/9ot9r
568e8zfvvd4mn8rbu1j0/gradle-9.3.1/lib/native-platform-0.22-milestone-29.jar)                                                                                                                  
WARNING: Use --enable-native-access=ALL-UNNAMED to avoid a warning for callers in this module                                                                                                 
WARNING: Restricted methods will be blocked in a future release unless native access is enabled 
```

This one is a bit tricky. On the latest android-studio version, the bundled version of JDK is 25+. Let check that with `flutter doctor`.

```console
$ flutter doctor --verbose
...
[✓] Android toolchain - develop for Android devices (Android SDK version 37.0.0) [248ms]                                                                                                      
    • Android SDK at /home/user/Android/Sdk                                                                                                                                                   
    • Emulator version 37.1.11.0 (build_id 15917651) (CL:N/A)                                                                                                                                 
    • Platform android-37.2, build-tools 37.0.0                                                                                                                                               
    • ANDROID_HOME = /home/user/Android/Sdk                                                                                                                                                   
    • Java binary at: /home/user/Downloads/android-studio/jbr/bin/java                                                                                                                        
      This is the JDK bundled with the latest Android Studio installation on this machine.                                                                                                    
      To manually set the JDK path, use: `flutter config --jdk-dir="path/to/jdk"`.                                                                                                            
    • Java version OpenJDK Runtime Environment (build 25.0.3+-15898627-b508.16)                                                                                                               
    • All Android licenses accepted.
...
```

Indeed, it looks like it uses OpenJDK25+... Just to confirm, let execute `java` directly.

```console
$ ~/Downloads/android-studio/jbr/bin/java -version
openjdk version "25.0.3" 2026-04-21
OpenJDK Runtime Environment (build 25.0.3+-15898627-b508.16)
OpenJDK 64-Bit Server VM (build 25.0.3+-15898627-b508.16, mixed mode)
```

It seems this version is not supported correctly with flutter applications, requiring JDK 21. To remove temporarily this warning message, instead of adding a flag, one can install an old version of the JDK from the system package manage for example.

```console
$ sudo apt-get install openjdk-21-{jre,jdk}
```

Then, the project can be configured to use this one instead of the latest version available from the android studio.

```console
$ flutter config --jdk-dir=/usr/lib/jvm/java-21-openjdk-amd64

$ flutter doctor --verbose
...
[✓] Android toolchain - develop for Android devices (Android SDK version 37.0.0) [235ms]                                                                                                      
    • Android SDK at /home/user/Android/Sdk                                                                                                                                                   
    • Emulator version 37.1.11.0 (build_id 15917651) (CL:N/A)                                                                                                                                 
    • Platform android-37.2, build-tools 37.0.0                                                
    • ANDROID_HOME = /home/user/Android/Sdk                                                    
    • Java binary at: /usr/lib/jvm/java-21-openjdk-amd64/bin/java                                                                                                                             
      This JDK is specified in your Flutter configuration.                                                                                                                                    
      To change the current JDK, run: `flutter config --jdk-dir="path/to/jdk"`.                                                                                                               
    • Java version OpenJDK Runtime Environment (build 21.0.12.1+1-1-deb13u1-Debian)                                                                                                           
    • All Android licenses accepted.
...
```

Thanks to this [post](https://startdebugging.net/2026/08/fix-a-restricted-method-in-java-lang-system-has-been-called-in-a-flutter-gradle-build/) from startdebugging.net, it helped me a lot to debug this issue.

# Storage Issue

```console
Failure [INSTALL_FAILED_INSUFFICIENT_STORAGE: Failed to override installation
location]
Error launching application on sdk gphone64 x86 64.
```

It simply means the virtual machine used for android (the device used by flutter) is full and there is no enough free space available to install the application. This one is kinda easy to fix, in android-studio go to `Menu` > `Tools` > `Devices Manager`, select the device to edit. In the `Additional settings` tabs, below the `Storage` section, one can expand both the internal or global storage. Note: It will reset the data on the device.

# Conclusion

Modern programming is a huge pile of shit. Every time you do a small update/upgrade on one module or package, or on the core language to have the latest security patches, it breaks. That's annoying and explain why most of the applications are not safe. Developers don't really care about security, they wants to deliver quick. To do that, they will bypass all safety. Sadly, nothing changed during the last 10 or 20 years to build a mobile app easily. I've lost half a day to figure out what was the root cause... The good side? It's another confirmation about the whole ecosystem, it's a miracle everything is working correctly.

As usual, hack it and try to have some fun!

----

Cover Image by <a href="https://unsplash.com/@tin1023565?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Ticka Kao</a> on <a href="https://unsplash.com/photos/yellow-robot-toy-on-black-table-NGqWbKcjgJ4?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>