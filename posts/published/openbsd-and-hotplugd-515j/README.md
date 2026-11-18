---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/openbsd-and-hotplugd-515j"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fku8d82d437c6ufpcgqz6.jpg"
created_at: "None"
crossposted_at: "None"
description: "Heads-up: this is a pretty old post I have published on one of my previous wiki/blog as notes. It is..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/openbsd-and-hotplugd-515j"
public_reactions_count: "1"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "openbsd-and-hotplugd-515j"
social_image: "None"
title: "OpenBSD and hotplugd"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# OpenBSD and hotplugd

**Heads-up**: this is a pretty old post I have published on one of my previous wiki/blog as notes. It is using an old version of OpenBSD, but `hotplugd` is a stable project and should not have been modified a lot since then.

[`hotplugd(8)`](https://man.openbsd.org/hotplugd) is a really smalland useful utility looking for device events on OpenBSD. This tool is equivalent to [`devd(8)`](https://www.freebsd.org/cgi/man.cgi?query=devd) on FreeBSD and a bit similar to [`udev(7)`](https://manpages.debian.org/buster/udev/udev.7.en.html) on Linux. [`hotplugd(8)`](https://man.openbsd.org/hotplugd) will listen for the kernel events (based on the special file[`/dev/hotplug`](https://man.openbsd.org/hotplug) and execute aparticular script with information about the device as arguments. When the device is attached, hotplugd will execute `/etc/hotplug/attach` and when the same device detach, it will execute
`/etc/hotplug/detach`.

So, why this is really useful? Because you can create your own action based on the desired device! Furthermore, you can use any kind of language... If you want to use a shell, a perl or a python script, you can. Just be careful, hotplugd is running as `root` user by default, it means all your script can do bad things without protection.                                           

Well, I will give you an example. I am using a 4G device (and sometime my smartphone) as router. When I plug the USB cable on my computer, and when I decide to share the connection, a [`urndis(4)`](https://man.openbsd.org/urndis) interface is automatically created. This new interface name is a combination of the driver name and an index (as integer). In my case, it will create `urndis0` interface.                                

`hotplugd` will offer you all required information about the device by sharing them directly as command arguments. The idea here is to use `attach` and `detach` scripts as command router. When the device is attached/detached, attach script will look linearly on different scripts and if one of them exists, it will execute it. 

By priority order:                                                                                       

 * `/etc/hotplug/device/${interface_name}`                                                                                                                                                                         
 * `/etc/hotplug/device/${driver_name}`            
 * `/etc/hotplug/class/${class_id}`                 

Firstly, we will initialize the tree:                                                                    

```sh
mkdir /etc/hotplug
mkdir /etc/hotplug/device
mkdir /etc/hotplug/class

# attach script
touch /etc/hotplug/attach
chmod 700 /etc/hotplug/attach

# detach script
touch /etc/hotplug/detach
chmod 700 /etc/hotplug/detach

# urndis0 script
touch /etc/hotplug/device/urndis0
chmod 700 /etc/hotplug/device/urndis0
```

We will create `attach` script located in `/etc/hotplug/attach`.

```sh
#!/bin/sh

DEVCLASS="${1}"
DEVNAME="${2}"
DEVDRIVER=$(echo ${DEVNAME} | sed -E 's/^([a-z]+)([0-9]+$)/\1/')
DEVINDEX=$(echo ${DEVNAME} | sed -E 's/^([a-z]+)([0-9]+$)/\2/')

if test -x /etc/hotplug/device/${DEVNAME}
then
    logger execute /etc/hotplug/device/${DEVNAME}
    /etc/hotplug/device/${DEVNAME} attach ${*}
elif test -x /etc/hotplug/device/${DEVDRIVE}
then
    logger execute /etc/hotplug/device/${DEVDRIVER}
    /etc/hotplug/device/${DEVDRIVER} attach ${*}
elif test -x /etc/hotplug/class/${DEVCLASS}
then
    logger execute /etc/hotplug/class/${DEVCLASS}
    /etc/hotplug/class/${DEVCLASS} attach ${*}
fi
```

Now the `detach` script located in `/etc/hotplug/detach`.

```sh
#!/bin/sh

DEVCLASS="${1}"
DEVNAME="${2}"
DEVDRIVER=$(echo ${DEVNAME} | sed -E 's/^([a-z]+)([0-9]+$)/\1/')
DEVINDEX=$(echo ${DEVNAME} | sed -E 's/^([a-z]+)([0-9]+$)/\2/')

if test -x /etc/hotplug/device/${DEVNAME}
then
    logger execute /etc/hotplug/device/${DEVNAME}
    /etc/hotplug/device/${DEVNAME} detach ${*}
elif test -x /etc/hotplug/device/${DEVDRIVE}
then
    logger execute /etc/hotplug/device/${DEVDRIVER}
    /etc/hotplug/device/${DEVDRIVER} detach ${*}
elif test -x /etc/hotplug/class/${DEVCLASS}
then
    logger execute /etc/hotplug/class/${DEVCLASS}
    /etc/hotplug/class/${DEVCLASS} detach ${*}
fi
```

We can now create ou script to manage `urndis0` interface located in `/etc/hotplug/device/urndis0`. This script will assume we have configured `urndis0` by creating [`/etc/hostname.urndis0`](https://man.openbsd.org/hostname.if) file.

```sh
#!/bin/sh

EVENT="${1}"
DEVCLASS="${2}"
DEVNAME="${3}"

_attach() {
    logger attach ${DEVNAME}
    sh /etc/netstart ${DEVNAME}
}
     
case "${EVENT}"
in
    attach) _attach;;
esac
```

Well, now it's the time to test it by enabling and starting
[`hotplugd(8)`](https://man.openbsd.org/hotplugd).

```sh
rcctl enable hotplugd
rcctl start hotplugd
```

Branch your device and follow `/var/log/message` log file.

```sh
tail -f /var/log/message
```

You should see something like that.

```txt
Jan 11 10:07:12 kin user: execute /etc/hotplug/device/urndis0
Jan 11 10:07:12 kin user: attach urndis0
Jan 11 10:07:13 kin dhclient[75457]: urndis0: 192.168.1.2 lease accepted from 192.168.1.1 (0a:6c:4b:1a:6d:35)
```

You can check directly with
[`ifconfig(8)`](https://man.openbsd.org/ifconfig) if it's right...

```sh
$ ifconfig urndis0
urndis0: flags=808843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST,AUTOCONF4> mtu 1500
        lladdr 02:16:13:45:ac:de
        index 27 priority 0 llprio 3
        groups: egress
        inet 192.168.1.2 netmask 0xffffff00 broadcast 192.168.1.1
```

It works! But... What if I don't have the good device name? Okay, by default, I assume `urndis` devices are safe and plugged by me (damn, this is not the paranoid method). I will create another script called `urndis` located in `/etc/hotplug/device/urndis`. This one will execute [`dhclient(8)`](https://man.openbsd.org/dhclient) directly on the interface without using
[`netstart(8)`](https://man.openbsd.org/netstart).

```sh
#!/bin/sh

EVENT="${1}"
DEVCLASS="${2}"
DEVNAME="${3}"

_attach() {
    logger attach ${DEVNAME}
    dhclient ${DEVNAME}
}
     
case "${EVENT}"
in
    attach) _attach;;
esac
       
```

And when we disable temporarily `/etc/hotplug/device/urndis0` by
removing the execute mode...

```sh
chmod -x /etc/hotplug/device/urndis0
```

...we can now see that in `/var/log/message`.

```txt
Jan 11 10:54:11 kin user: urndis0 urndis 0
Jan 11 10:54:11 kin user: execute /etc/hotplug/device/urndis
Jan 11 10:54:11 kin /bsd: urndis0 at uhub0 port 1 configuration 1 interface 0 "Android" rev 2.00/ff.ff addr 3
Jan 11 10:54:11 kin /bsd: urndis0: using RNDIS, address 02:b6:13:63:74:6a
Jan 11 10:54:11 kin user: attach urndis0
Jan 11 10:54:11 kin dhclient[45455]: urndis0: 192.168.1.2 lease accepted from 192.168.11 (0a:12:ef:17:7d:23)
```

It seems to works! This is a simple way to connect device without any
security and control.

----

Cover Image by <a href="https://unsplash.com/@tugceertas?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Tuğçe Ertaş Al</a> on <a href="https://unsplash.com/photos/two-electrical-sockets-decorated-as-faces-with-flowers-ai_4jl907OY?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>