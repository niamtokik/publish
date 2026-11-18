---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/serial-console-on-alpine-linux-4cj9"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Fan93wnvsp5di1d3l90bd.jpg"
created_at: "None"
crossposted_at: "None"
description: "Most of my firewalls are on OpenBSD or FreeBSD. While deploying github runners on Alpine Linux, I..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/serial-console-on-alpine-linux-4cj9"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "serial-console-on-alpine-linux-4cj9"
social_image: "None"
title: "Serial Console on Alpine Linux"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Serial Console on Alpine Linux

Most of my firewalls are on OpenBSD or FreeBSD. While deploying github runners on Alpine Linux, I thought it could have been a great idea to install Alpine Linux on a firewall, just to see if this distribution can do this job.

# Syslinux Boot

[Syslinux](https://wiki.syslinux.org/wiki/index.php?title=The_Syslinux_Project) is using all available [`tty`](https://manpages.debian.org/trixie/coreutils/tty.1.en.html) by default, including `ttyS0`. It means, when booting on a live-image of Alpine Linux, if a serial cable is plugged to the device, a prompt should appear and offers a way to modify the Linux kernel parameters.

```console
boot> /boot/vmlinuz-lts initrd=/boot/initramfs-lts modules=loop,squashfs,sd-mod,usb-storage quiet console=ttyS0,115200
```

The default console for this installation should now use the serial console. The setup via [`setup-alpine`](https://docs.alpinelinux.org/user-handbook/0.1a/Installing/setup_alpine.html) process can be executed as usual after a successful login to the `root` user.

```console
# setup-alpine
```

Don't reboot the firewall right now though, [Syslinux](https://wiki.syslinux.org/wiki/index.php?title=The_Syslinux_Project) is not yet configured.

# Persistent Configuration

Just after the installation, before rebooting, to keep the serial console the default way to use your device (or at least, to be able to use it in case of issue), [Syslinux](https://wiki.syslinux.org/wiki/index.php?title=The_Syslinux_Project) must be configured. Let create first our root with some useful mounted filesystems to avoid configuration issues.

```console
# mount /dev/sda2 /mnt
# mount /dev/sda1 /mnt/boot
# mount -t proc proc /mnt/proc
# mount -t devtmpfs devtmpfs /mnt/dev
# mount -t sysfs sysfs /mnt/sys
```

Great, the disk is correctly mounted and the new root should have all me need to create a [`chroot`](https://www.man7.org/linux/man-pages/man2/chroot.2.html).

```console
# chroot /mnt
```

Syslinux configuration is located in `/etc/update-extlinux.conf`. Three new values must be updated to keep the serial console active: `default_kernel_opts`, `serial_port` and `serial_baud`.

```console
# cat >> /etc/update-extlinux.conf << EOF
default_kernel_opts="quiet rootfstype=ext4 console=ttyS0,115200"
serial_port=0
serial_baud=115200
EOF
```

`update-extlinux` command must be invoked to generate the correct configuration in `/boot/boot/extlinux.conf`.

```console
# update-extlinux
```

Then, `sync` the data to the disk to ensure everything has been correctly written and reboot the system.

```console
# sync
# reboot
```

After the reboot, your firewall should give you access to a prompt via the serial console.

# Conclusion

Alpine Linux is one of the most simple Linux distribution on the market. On many other alternative, configuring the serial console can quickly become complex. There, the configuration is really simple. The biggest complexity is when the parameters are passed to the kernel on the boot prompt (mostly due to the serial console itself). More information can be found here:

- [**Official Syslinux Wiki**](https://wiki.syslinux.org/);

- [**Enable Serial Console on Boot**](https://wiki.alpinelinux.org/wiki/Enable_Serial_Console_on_Boot#Enabling_two_consoles_during_boot) from the Official Alpine Linux documentation;

- [**The kernel’s command-line parameters**](https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html) from kernel.org;

- [**Bootloaders**](https://wiki.alpinelinux.org/wiki/Bootloaders) from the Official Alpine Linux documentation.

Anyway, as usual, have fun and happy hacking!

----

Cover Image by <a href="https://unsplash.com/@poli_graphy?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Christopher Politano</a> on <a href="https://unsplash.com/photos/wooden-chapel-on-grassy-mountain-hill-0GZSfzz2Z2c?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>