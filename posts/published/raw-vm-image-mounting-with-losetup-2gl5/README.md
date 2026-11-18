---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/raw-vm-image-mounting-with-losetup-2gl5"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fyalm3uave39rm0o2c7n9.jpg"
created_at: "None"
crossposted_at: "None"
description: "I use Qemu/KVM for most of my custom virtual machine, and sometime, I need to do some backup or to..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/raw-vm-image-mounting-with-losetup-2gl5"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "raw-vm-image-mounting-with-losetup-2gl5"
social_image: "None"
title: "Raw VM Image Mounting with losetup"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Raw VM Image Mounting with losetup

I use Qemu/KVM for most of my custom virtual machine, and sometime, I need to do some backup or to check the filesystem from the host point of view. The process is quite simple, the virtual disk is used as a virtual storage device and then we mount the partition on the host. On FreeBSD, we use [`mdconfig`](https://man.freebsd.org/cgi/man.cgi?query=mdconfig), on OpenBSD we use [`vmconfig`](https://man.openbsd.org/vnconfig) and on Linux, we are using [`losetup`](https://manpages.debian.org/trixie/mount/losetup.8.en.html). Both of these commands have the same goal: allocate a special device pointing to a file present on a filesystem. Here an example with `losetup`.

First we want to mount the image `/path/to/your/image.raw` on a free `losetup` device (usually present in `/dev/loop*`). The `--find` flag will look for the next available loop device, the `--show` will print it to stdout and `-P` will reload the partition table.

```sh
# use available loop device, and attach image.raw to it
loop=$(losetup --find --show -P /path/to/your/image.raw)
```

Then, we can check if the partitions are present (or not). The attached device has been put into the `loop` variable.

```shell
# check the loop devices partition
ls -l ${loop}*
```

If you are using lvm (it was my case for this note), simply use [`lvscan`](https://manpages.debian.org/trixie/lvm2/lvscan.8.en.html) command and automatically enable the logical volume found.

```shell
lvscan -a y 
```

[`mount`](https://manpages.debian.org/trixie/mount/mount.8.en.html) the logical volume on your and do what you have to do.

```shell
mount /dev/vg/lv /mnt

# Do your stuff here.
```

When you have done, you can simply `umount` the partition...

```shell
umount /mnt
```

... and finally detach the loop device.

```shell
losetup --detach ${loop}
```

Note: this procedure can be used only for raw qemu image. If you are using qcow format or another one, you will first need to convert it with [`qemu-img`](https://manpages.debian.org/trixie/qemu-utils/qemu-img.1.en.html) or use a tool like [`mount-qcow2-image`](https://www.baeldung.com/linux/mount-qcow2-image).

----

Cover Image by <a href="https://unsplash.com/@5tep5?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Aleksandr Popov</a> on <a href="https://unsplash.com/photos/a-roller-coaster-lit-up-at-night-with-red-lights-aW50su5Dwek?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>