---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/flutter-and-web-browser-configuration-3510"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2F8n9dzmciwlqywtdaixa4.jpg"
created_at: "None"
crossposted_at: "None"
description: "When it comes to programming with Dart and Flutter, one should probably expect to also have support..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/flutter-and-web-browser-configuration-3510"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "flutter-and-web-browser-configuration-3510"
social_image: "None"
title: "Flutter and Web Browser Configuration"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Flutter and Web Browser Configuration

When it comes to programming with Dart and Flutter, one should probably expect to also have support for web programming using WASM for example. In some case, like on my side, my browser was not detected. [Flutter documentation](https://docs.flutter.dev/platform-integration/web/setup) does not clearly explain how to set the browser in case of issue. Let try to investigate a bit.

Flutter and Dart have been installed using `asdf` on my side, using the latest version available. My OS is a Debian-like (Parrot Linux). My default browser on this system is Brave, but I sometimes use Firefox or Chromium as well depending on my needs, in particular when few specific addons are required.

Anyway, when using `flutter devices`, the browser should be present in the list of available device, but, surprise, it was not the case on my side.

```console
$ flutter devices
Found 2 connected devices:
  Linux (desktop) • linux  • linux-x64      • Parrot Security 7.2 (echo) 6.19.13+parrot7-amd64
```

The next part of the message is mostly about hints in case of problem:

> If you expected another device to be detected, please run "flutter doctor" to diagnose potential issues. You may also try increasing the time to wait for connected devices with the
"--device-timeout" flag. Visit https://flutter.dev/setup/ for troubleshooting tips.

Let try `flutter doctor` command.

```console
$ flutter doctor                                                                          
Doctor summary (to see all details, run flutter doctor -v):                                    
[✓] Flutter (Channel stable, 3.41.7, on Parrot Security 7.2 (echo) 6.19.13+parrot7-amd64, locale en_US.UTF-8)                                                                                 
[✓] Android toolchain - develop for Android devices (Android SDK version 37.0.0)          
[✗] Chrome - develop for the web (Cannot find Chrome executable at google-chrome)              
    ! Cannot find Chrome. Try setting CHROME_EXECUTABLE to a Chrome executable.                                                                                                               
[✓] Linux toolchain - develop for Linux desktop                                                                                                                                               
[✓] Connected device (1 available)                                                             
[✓] Network resources                                                                          
                                                                                               
! Doctor found issues in 1 category.
```

Ah! Some Chrome is cannot be found on my system. It seems normal, because I don't use the official version of Chrome offered by Google, but the open-source version (Chromium) or a fork (Brave). By setting `CHROME_EXECUTABLE` environment variable with the path of the browser used, it should fix the issue.

```shell
$ export CHROME_EXECUTABLE=$(which chromium)
```

Again, let reinvoke `flutter doctor`.

```console
$ flutter doctor                                                                                                                                                                         
Doctor summary (to see all details, run flutter doctor -v):                                  
[✓] Flutter (Channel stable, 3.41.7, on Parrot Security 7.2 (echo) 6.19.13+parrot7-amd64, locale en_US.UTF-8)                                                                                 
[✓] Android toolchain - develop for Android devices (Android SDK version 37.0.0)   
[✓] Chrome - develop for the web                                                               
[✓] Linux toolchain - develop for Linux desktop                                                
[✓] Connected device (2 available)                                                             
[✓] Network resources                                                                                                                                                                         
                                                                                               
• No issues found! 
```

Perfect! No more issues from this command! What about `flutter devices`?

```console
$ flutter devices                                                                                                                                                                        
Found 2 connected devices:                                                                     
  Linux (desktop) • linux  • linux-x64      • Parrot Security 7.2 (echo) 6.19.13+parrot7-amd64                                                                                                
  Chrome (web)    • chrome • web-javascript • Chromium 147.0.7727.137 built on Debian GNU/Linux 13 (trixie)
```

Great, my browser can now be used with flutter! In short, if one wants to use a different browser during development process for doing some test, one can change `CHROME_EXECUTABLE` variable. To save this configuration, this environment variable can be put in `~/.bashrc` or `~/.profile` depending of the shell used.

```sh
# which is used and will automatically
# return the full path of chromium.
# a different path can be set if needed.
echo 'export CHROME_EXECUTABLE=$(which chromium)' >> ~/.bashrc
```

Looks better, I'm now able to create Flutter applications using Chrome, Chromium or even Brave (this last one needs to be tested though).

----

Cover Image by <a href="https://unsplash.com/@willianjusten?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Willian Justen de Vasconcellos</a> on <a href="https://unsplash.com/photos/traditional-ornate-temple-gate-with-modern-buildings-behind-Nyrj6APV38g?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
      