---
cached_tag_list: "qubeos, security, syadmin, xen"
cached_user_name: "Mathieu Kerjouan"
cached_user_username: "niamtokik"
canonical_url: "None"
comments_count: "0"
created_at: "2026-07-01T19:01:42.485Z"
crossposted_at: "None"
description: "Foreword: these notes are coming from a draft. I was planning to create an article on QubeOS for a..."
edited_at: "2026-09-10T18:19:34.175Z"
feed_source_url: "None"
last_comment_at: "2026-07-09T10:00:00.000Z"
main_image: "https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/ykl7es13f7kix4k0gan6.jpg"
main_image_background_hex_color: "#dddddd"
path: "/niamtokik/qubeos-tips-and-tricks-399h"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "False"
show_comments: "True"
slug: "qubeos-tips-and-tricks-399h"
social_image: "None"
title: "QubeOS Tips and Tricks"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# QubeOS Tips and Tricks

Foreword: these notes are coming from a draft. I was planning to create an article on QubeOS for a secure business oriented environment. Unfortunately, because of the complex upgrade procedure, I thought it was not the right system for doing business. The following sections have been taken from the FAQ part.

----

QubeOS was my professional operating system for 2 years. I did not have great experience. In fact, it works, but when it comes to update/upgrade, it's painful. I still own one laptop running with QubeOS for test purpose only and also to see if the upgrade process is evolving in the right way... It's not the case.

Anyway, here few tips and tricks I used in the past.

# Copying files between dom0 to domU

A file can be copied from dom0 to domU using the `qvm-copy-to-vm` command.

```sh
qvm-copy-to-vm
```

# Copying files between domU

A file can be copied from domU to domU using the `qvm-copy` command.

```sh
qvm-copy
```

# Executing Commands in Minimal Qubes as root

In minimal template, only `user` user is created, without any kind of right. To install/upgrade software or configure `sudo` you will need to have shell with root access. Here an example:

``` sh
qube=debian-11-minimal
qvm-run --user=root ${qube} xterm
# or with short flags -u
# qvm-run -u root ${qube} xterm
```

# Xen Store Dom0 view

Xen Store is a shared environment containing meta-data and other cool stuff. This store can be managed with the `xenstore-*` commands.

``` sh
xenstore-ls
xenstore-read
xenstore-write
```

# Xen Store DomU view

Xen Store is not only available from dom0 but also from domU, even if the view can change a bit.

``` sh
# return local vm information based on uuid
xenstore-ls /vm/${uuid}

# return global domain information
xenstore-ls /local/domain/${domain}

# return vbd information
xenstore-ls /local/domain/${vbd}/backend/vif/${domain}/0

# information can be read/write using:
xenstore-read
xenstore-write
```

# Qubesdb

Qubesdb is an interface to xenstore, it gives you all required information by using only `/` key without looking for other keys/values in the store. You can get ip address, netmask or gateway.

``` sh
qubesdb-list /
qubesdb-read /type
qubesdb-read /qubes-ip
qubesdb-read /qubes-netmask
```

# Restarting the Network

Network interfaces are isolated from other qubes in dedicated virtual machine called `sys-net`. Sometime, wireless interfaces can be stuck due to `NetworkManager` application. In this case, you can run this command to restart the service from dom0:

``` sh
qvm-run -u root sys-net "systemctl restart NetworkManager"
```

This will also restart XFCE widgets and should solve simple network issues.

# Local Network Script with rc.local

You can set a local network configuration using `/rw/rc.local`. This script will be executed at startup ONLY for your current qubes.

``` sh
# set network stack
ip set link dev eth0 up
qubesdb-read /qubes-ip \
  | xargs -I%d ip address add %d/32 dev eth0
qubesdb-read /qubes-gateway\
  | xargs -I%g \
sh -c 'ip route add %g dev eth0 scope link; \
  ip route add default via %g'
```

# Global Network Script

ou can also enable `/etc/rc.local` with systemd. Take the previous script and enable it following this procedure:

``` sh
chmod +x /etc/rc.local
systemctl daemon-reload
systemctl start rc-local
systemctl enable rc-local
```

# Creating Ubuntu Template

Note: you will need to execute these commands in a qube set with fedora.

``` sh
# install required dependencies
dnf install gnupg git createrepo rpm-build make wget rpmdevtools python3-sh dialog rpm-sign dpkg-dev debootstrap python3-pyyaml devscripts perl-Digest-MD5 perl-Digest-SHA

# clone qubes-builder repository from QubeOS official repository
git clone https://github.com/QubesOS/qubes-builder
cd qubes-builder

# install dependencies
./setup
make install-deps
make get-sources
make qubes-vm
make template
```

You will need to edit few of the generated packages due to missing dependencies. In my case, `qubes-src/meta-packages/debian/control` required to be edited and some dependencies needed to be removed.

It is now possible to install this template on dom0.

``` sh
qubes-src/meta-packages/debian/control
```

# Starting a disposable VM from standard VM

A disposable VM can be started on a standard Qube with the help of the `qvm-run-vm` command.

``` sh
qvm-run-vm --disp ${disp_vm} xterm
```

# Starting a disposable VM from Dom0

A disposable VM can be started from Dom0 using the `qvm-run` command.

``` sh
qvm-run --disp ${disp_vm} xterm
```

# Conclusion

These commands have been collected during a small period of times. I'm not an active QubeOS user anymore, OpenBSD is still and will remain my favorite Operating System.

----

Cover Image by <a href="https://unsplash.com/@sfkopstein?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">shraga kopstein</a> on <a href="https://unsplash.com/photos/a-close-up-of-a-bunch-of-pencils-XeRGWOAr53c?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>

