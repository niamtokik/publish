---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/flashing-a-xiaomi-mi-a3-phone-1bcc"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fi9zulcaru632hb2aywk7.jpg"
created_at: "None"
crossposted_at: "None"
description: "This post is coming from my unpublished archive. It's quite an old one, but I think it would be..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/flashing-a-xiaomi-mi-a3-phone-1bcc"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "flashing-a-xiaomi-mi-a3-phone-1bcc"
social_image: "None"
title: "Flashing a Xiaomi Mi A3 Phone"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Flashing a Xiaomi Mi A3 Phone

This post is coming from my unpublished archive. It's quite an old one, but I think it would be interesting to share it. This is a summary of the different steps used to flash a Xiaomi Mi A3 phone and install another Android version (e.g. Lineage OS, Kali, /e/...). A part of the links are gone unfortunately, but I think the most important ones are still available. Have fun!

# Bootstrapping

This installation was done on Ubuntu 21.04 due to compatibility with other system.

- install latest android sdk from official website from https://developer.android.com/studio/#downloads

- Download all required assets to flash your phone

# Procedure

This image is open-source but was built by [Harukey](https://xdaforums.com/t/rom-11-unofficial-laurel_sprout-oss-lineageos-18-1.4240953/). This is a good method to root your android phone though.

- Ensure ADB is correctly installed on your PC

- Ensure Fastboot is correctly installed on your PC

- Enable developer mode

- Enable debugging throught USB

- Connect your USB cable to your phone

- Reboot your phone and press volume down

- When fastboot prompt appears you can flash your phone with the [recovery image](https://sourceforge.net/projects/harukeys-roms/files/laurel/LineageOS18/LinageOSRecovery20210917.img)

```shell
wget https://downloads.sourceforge.net/project/harukeys-roms/laurel/LineageOS18/LinageOSRecovery20210917.img
fastboot flash boot LinageOSRecovery20210917.img
```

- Reboot into normal mode and check if everything was correctly set and configured. You should have your old Android version. (unplug your phone).

```shell
fastboot reboot
```

- Reboot in recovery mode

```shell
adb reboot recovery
```

- In recovery mode apply the latest partitions an update with ADB

```shell
adb sideload copy-partitions-20200903_1329.zip
```

- Do a factory reset (present at the first menu page)

- Apply another update, this time, with the lineageOS rom

```shell
wget https://downloads.sourceforge.net/project/harukeys-roms/laurel/LineageOS18/lineage-18.1-20211128-UNOFFICIAL-laurel_sprout.zip
adb sideload lineage-18.1-20211128-UNOFFICIAL-laurel_sprout.zip
```

- Reboot in normal mode

- Reboot in recovery mode

```shell
adb reboot recovery
```

- Download and install [Magisk](https://github.com/topjohnwu/Magisk/)

```shell
wget https://github.com/topjohnwu/Magisk/releases/download/v24.3/Magisk-v24.3.apk
cp Magisk-v24.3.apk Magisk-v24.3.zip
adb sideload Magisk-v24.3.zip
```

- Reboot in normal mode and check if you can have access to LineageOS and Magisk.

- Configure your system as desired (set developer mode and USB debugging).

- Reboot in recovery mode

- Download and install [nethunter](https://kali.download/nethunter-images/kali-2022.1/nethunter-2022.1-laurel_sprout-eleven-kalifs-full.zip)

```shell
adb sideload nethunter-2022.1-laurel_sprout-eleven-kalifs-full.zip
```

- reboot your system and configure nethunter.

The procedure to install this image is available on xda-developer forum: https://forum.xda-developers.com/t/rom-11-unofficial-laurel_sprout-oss-lineageos-18-1.4240953/

# Unbrick Xiaomi Mi A3

Shit happens sometime. Xiaomi Mi A3 can be bricked if you do a wrong configuration or don't follow the good process when trying to install LineageOS or any kind of alternative to android. Fortunately, this phone can easily be unbricked by using few tools. Here the requirement:

- windows 10 (at this time, it's a requirement unfortunately)

- [qpsttool](https://androidmtk.com/download-qpst-flash-tool) (version I used was [2.7.480](https://qpsttool.com/qpst-tool-v2-7-480/) but the latest was [2.7.496](https://qpsttool.com/qpst-tool-v2-7-496/))

- [service rom](https://mega.nz/file/Fh1k2RjZ#t1gmUVReLaNJTOVyQlCRHIvVYcJgNoJKZDpNdYd1Nws) by @nullby

Other steps are explained in depth in Mi A3 unbrick guide by @nullby. It takes around 30/45 minutes to unbrick your phone, and start with a fresh version of android one installed.

# Fixing a bootloop

You can use TWPRP image, in my case `twrp-3.3.1-17-laurel_sprout-Q-mauronofrio.img` worked. Go into advanced settings and "fix bootloop".

# References and Resources

- https://forum.xda-developers.com/t/rom-12-1-crdroid-for-xiaomi-mi-a3-laurel_sprout-official-beta.4443071/

- https://www.getdroidtips.com/how-to-unlock-bootloader-of-xiaomi-mi-a3/

- https://forum.xda-developers.com/t/recovery-3-3-1-17-laurel_sprout-unofficial-twrp-recovery-for-xiaomi-mi-a3-test.3963428/ 

- https://androidmtk.com/download-qpst-flash-tool

- https://c.mi.com/forum.php?mod=viewthread&tid=3527044

- https://forum.xda-developers.com/t/mi-a3-bricked-blackscreen-not-turning-on.4214225/

- https://forum.xda-developers.com/t/rom-official-fastboot-xiaomi-mi-a3-laurel_sprout.3962489/

- https://forum.xda-developers.com/t/rom-stable-lineageos-18-0-mi-a3-laurel_sprout.4174895/

- https://germowp.blogspot.com/2021/01/mi-m1803e6g-test-point-7reboot-device.html

- https://github.com/pixelExperience-Devices/kernel_xiaomi_laurel_sprout

- https://mirror.codebucket.de/firmware/laurel_sprout/

- https://qfiltool.com/

- https://qpsttool.com/qpst-tool-v2-7-480

- https://qpsttool.com/qpst-tool-v2-7-496

- https://www.mobilerdx.com/2019/07/xiaomi-mi-a3-edl-mode-pinout-mi-a3-test-point.html

- https://xiaomitools.com/how-to-use-qualcomm-flash-image-loader-tool-qfil/

- https://www.youtube.com/watch?v=8EAZwCivOCA

- https://www.youtube.com/watch?v=KTXo91KlpWc

- https://www.youtube.com/watch?v=hKtWUALCZXE

- https://www.youtube.com/watch?v=BlLqaRrHm-Y

----

Cover Image by <a href="https://unsplash.com/@madeyes?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Eric Han</a> on <a href="https://unsplash.com/photos/bokeh-light-Gc4wAF09JZY?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
      