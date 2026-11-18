---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/missing-libraries-on-openbsd-2n4p"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fczz02fe6kp3v7p0v643d.jpg"
created_at: "None"
crossposted_at: "None"
description: "Sometimes, shit happens, and if you are unlucky, it can be many time in a short period of time!..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/missing-libraries-on-openbsd-2n4p"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "missing-libraries-on-openbsd-2n4p"
social_image: "None"
title: "Missing Libraries on OpenBSD"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Missing Libraries on OpenBSD

Sometimes, shit happens, and if you are unlucky, it can be many time in a short period of time! Anyway, following the upgrade of [OpenBSD](https://www.openbsd.org/) to 7.9 on one of my laptop, I got another issue with missing libraries. I still don't know what happened, but I suspect a problem with [`pkg_add`](https://man.openbsd.org/pkg_add). While installing a package, this one crashed. Anyway, I will give you a way to fix that. First, let describe the problem.

I wanted to use [`ffmpeg`](https://openports.pl/path/graphics/ffmpeg) to extract audio from a video file, but when executing it, here the message I got:

```console
$ ffmpeg
ld.so: ffmpeg: can't load library 'libavfilter.so'
```

Ah! That's annoying. Where this library come from? Let use [`pkglocate`](https://man.openbsd.org/pkglocate) to have our answer.

```console
$ pkglocate libavfilter.so
ffmpeg-8.0.1p1v1:graphics/ffmpeg:/usr/local/lib/libavfilter.so.13.
```

Ah! This is even more annoying, this library is coming from [`ffmpeg`](https://openports.pl/path/graphics/ffmpeg) package, but it seems [`ffmpeg`](https://openports.pl/path/graphics/ffmpeg) is installed, right? Let check that with `pkg_info` (just to confirm).

```console
$ pkg_info -l | grep ffmpeg
```

Indeed. The package is correctly installed. Let investigate a bit with [`kdump`](https://man.openbsd.org/kdump) and [`ktrace`](https://man.openbsd.org/ktrace), the equivalent version of [`strace`](https://manpages.debian.org/trixie/strace/strace.1.en.html) for OpenBSD. This part is simply for fun, because I was already aware of the problem, but it will give you an idea of the procedure I would have use if I was looking for something weird.

```console
$ ktrace ffmpeg
$ kdump
 75640 ktrace   RET   ktrace 0
 75640 ktrace   CALL  mmap(0,0xd7,0x3<PROT_READ|PROT_WRITE>,0x1002<MAP_PRIVATE|MAP_ANON>,-1,0)
 75640 ktrace   RET   mmap 6423225446400/0x5d786123000
 75640 ktrace   CALL  execve(0x73aa771e3d40,0x73aa771e4340,0x73aa771e4350)
 75640 ktrace   NAMI  "/bin/ffmpeg"
 75640 ktrace   RET   execve -1 errno 2 No such file or directory
 75640 ktrace   CALL  execve(0x73aa771e3d40,0x73aa771e4340,0x73aa771e4350)
 75640 ktrace   NAMI  "/bin/ffmpeg"
 75640 ktrace   RET   execve -1 errno 2 No such file or directory
 75640 ktrace   CALL  execve(0x73aa771e3d40,0x73aa771e4340,0x73aa771e4350)
 75640 ktrace   NAMI  "/sbin/ffmpeg"
 75640 ktrace   RET   execve -1 errno 2 No such file or directory
 75640 ktrace   CALL  execve(0x73aa771e3d40,0x73aa771e4340,0x73aa771e4350)
 75640 ktrace   NAMI  "/usr/bin/ffmpeg"
 75640 ktrace   RET   execve -1 errno 2 No such file or directory
 75640 ktrace   CALL  execve(0x73aa771e3d40,0x73aa771e4340,0x73aa771e4350)
 75640 ktrace   NAMI  "/usr/sbin/ffmpeg"
 75640 ktrace   RET   execve -1 errno 2 No such file or directory
 75640 ktrace   CALL  execve(0x73aa771e3d40,0x73aa771e4340,0x73aa771e4350)
 75640 ktrace   NAMI  "/usr/X11R6/bin/ffmpeg"
 75640 ktrace   RET   execve -1 errno 2 No such file or directory
 75640 ktrace   CALL  execve(0x73aa771e3d40,0x73aa771e4340,0x73aa771e4350)
 75640 ktrace   NAMI  "/usr/local/bin/ffmpeg"
 75640 ktrace   ARGS  
        [0] = "ffmpeg"
 75640 ffmpeg   NAMI  "/usr/libexec/ld.so"
 75640 ffmpeg   NAMI  "/var/run/ld.so.hints"
 75640 ffmpeg   RET   open 3
 75640 ffmpeg   CALL  fstat(3,0x7183b3383150)
 75640 ffmpeg   STRU  struct stat { dev=66628, ino=984995, mode=-r--r--r-- , nlink=1, uid=0<"root">, gid=0<"wheel">, rdev=3943528, atime=1780508371<"Jun  3 17:39:31 2026">.216788585, mtime=1780508368<"Jun  3 17:39:28 2026">.926794253, ctime=1780508368<"Jun  3 17:39:28 2026">.926794253, size=11270, blocks=24, blksize=16384, flags=0x0, gen=0x0 }
 75640 ffmpeg   RET   fstat 0
 75640 ffmpeg   CALL  mmap(0,0x2c06,0x1<PROT_READ>,0x2<MAP_PRIVATE>,3,0)
 75640 ffmpeg   RET   mmap 6587275476992/0x5fdb8370000
 75640 ffmpeg   CALL  mmap(0,0x1000,0x3<PROT_READ|PROT_WRITE>,0x1002<MAP_PRIVATE|MAP_ANON>,-1,0)
 75640 ffmpeg   RET   mmap 6585773539328/0x5fd5eb14000
 75640 ffmpeg   CALL  mimmutable(0x5fdb8370000,0x2c06)
 75640 ffmpeg   RET   mimmutable 0
 75640 ffmpeg   CALL  close(3)
 75640 ffmpeg   RET   close 0
 75640 ffmpeg   CALL  open(0x5fd5eb14150,0x30000<O_RDONLY|O_CLOEXEC|O_DIRECTORY>)
 75640 ffmpeg   NAMI  "/usr/lib"
 75640 ffmpeg   RET   open 3
...
 75640 ffmpeg   GIO   fd 2 wrote 15 bytes
       "ld.so: ffmpeg: "
 75640 ffmpeg   RET   write 15/0xf
 75640 ffmpeg   CALL  write(2,0x5fcc3339190,0x23)
 75640 ffmpeg   GIO   fd 2 wrote 35 bytes
       "can't load library 'libavfilter.so'"
 75640 ffmpeg   RET   write 35/0x23
 75640 ffmpeg   CALL  write(2,0x5fcc3237b0c,0x1)
 75640 ffmpeg   GIO   fd 2 wrote 1 bytes
       "
       "
 75640 ffmpeg   RET   write 1
 75640 ffmpeg   CALL  thrkill(0,SIGKILL,0)
 75640 ffmpeg   PSIG  SIGKILL SIG_DFL
```

Interesting. It looks like `ld.hints` is having only `/usr/lib` configured, let check that with [`ldconfig`](https://man.openbsd.org/ldconfig.8) and the `-r` flag.

```console
$ ldconfig -r
ldconfig -r                                                               
/var/run/ld.so.hints:                           
        search directories: /usr/lib
```

Doh. The problem is from `/var/run/ld.so.hints`, this file should contain a list of libraries available on the system, here, it returns literally nothing. Let fix that by reusing [`ldconfig`](https://man.openbsd.org/ldconfig.8) but this time to recreate the file correctly with the help of the `-m` and `-R` flags.

```console
$ doas ldconfig -mR /usr/lib /usr/X11R6/lib /usr/local/lib
```

Let check if the `ld.so.hints` file now contain more libraries.

```console
$ ldconfig -r
/var/run/ld.so.hints:
        search directories: /usr/lib
        0:-liberty.12.0 => /usr/lib/libiberty.so.12.0
...
        1055:-lhogweed.3.1 => /usr/local/lib/libhogweed.so.3.1
        1056:-latkmm-1.6.10.1 => /usr/local/lib/libatkmm-1.6.so.10.1
...
        1168:-lpixman-1.46.4 => /usr/X11R6/lib/libpixman-1.so.46.4
        1169:-lpoppler.101.0 => /usr/local/lib/libpoppler.so.101.0
```

It's way better like that! Okay, let run [`ffmpeg`](https://openports.pl/path/graphics/) another time.

```console
$ $ ffmpeg -version
ffmpeg version 8.0.2 Copyright (c) 2000-2025 the FFmpeg developers
built with OpenBSD clang version 19.1.7
configuration: --enable-shared --arch=amd64 --cc=cc --cxx=c++ --enable-debug --disable-stripping --disable-indev=jack --disable-vulkan --enable-fontconfig --enable-frei0r --enable-gpl --enable-ladspa --enable-libaom --enable-libass --enable-libdav1d --enable-libfontconfig --enable-libfreetype --enable-libfribidi --enable-libgsm --enable-libharfbuzz --enable-libmp3lame --enable-libopus --enable-libspeex --enable-libsvtav1 --enable-libtheora --enable-libv4l2 --enable-libvorbis --enable-libvpx --enable-libwebp --enable-libx264 --enable-libx265 --enable-libxml2 --enable-libxvid --enable-libzimg --enable-nonfree --enable-openssl --enable-libvidstab --extra-cflags='-I/usr/local/include -I/usr/X11R6/include' --extra-libs='-L/usr/local/lib -L/usr/X11R6/lib' --extra-ldsoflags= --mandir=/usr/local/man --objcc=/usr/bin/false --optflags='-O2 -pipe -g -Wno-redundant-decls'
libavutil      60.  8.102 / 60.  8.102
libavcodec     62. 11.102 / 62. 11.102
libavformat    62.  3.102 / 62.  3.102
libavdevice    62.  1.102 / 62.  1.102
libavfilter    11.  4.102 / 11.  4.102
libswscale      9.  1.102 /  9.  1.102
libswresample   6.  1.102 /  6.  1.102

Exiting with exit code 0
```

Nice! A last check to be sure everything is fine on the system, it's to execute [`pkg_check`](https://man.openbsd.org/pkg_check.8). It will verify if the packages have been correctly installed and if nothing wrong happened to them. If this issue happens again, it could be due to a misconfiguration, or a bug.

```console
$ doas pkg_check                                                                                                   
Packing-list sanity: ok                                                                                                                                       
Direct dependencies: ok                                                                                                                                       
Reverse dependencies: ok                                                                                                                                      
Files from packages: ok
```

Everything looks good at first glance. Anyway, I think I did something wrong during the last upgrade. That's great! It gives me more opportunities to write publication about [OpenBSD](https://www.openbsd.org/)! Debugging and fixing problems on OpenBSD is a real pleasure, thanks to the documentation and all the simple Unix-like procedures used everywhere.

Have fun!

----

Cover Image by <a href="https://unsplash.com/@chuttersnap?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">CHUTTERSNAP</a> on <a href="https://unsplash.com/photos/cardboard-box-lot-fyaTq-fIlro?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>