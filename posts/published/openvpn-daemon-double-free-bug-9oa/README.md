---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/openvpn-daemon-double-free-bug-9oa"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Fhypic3y22tss59dbn9m1.jpg"
created_at: "None"
crossposted_at: "None"
description: "Since 2016, I started manage my own VPN infrastructure for my own usage and also for testing purpose...."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/openvpn-daemon-double-free-bug-9oa"
public_reactions_count: "2"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "openvpn-daemon-double-free-bug-9oa"
social_image: "None"
title: "OpenVPN Daemon Double Free Bug"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# OpenVPN Daemon Double Free Bug

Since 2016, I started manage my own VPN infrastructure for my own usage and also for testing purpose. My VPN is not always started, in fact, I use it rarely. After the latest upgrade of [OpenBSD](https://www.openbsd.org/) to 7.9, I started to see the [`openvpn`](https://manpages.debian.org/trixie/openvpn/openvpn.8.en.html) vanishing after few minutes of usage. It was not really important, but recently, I needed someone else to use the VPN for debugging purpose and... Every 3 or 4 minutes, the service crashed. Not really cool for a debugging session, fortunately, having [`tmux`](https://man.openbsd.org/tmux) (or [`tmate`](https://manpages.debian.org/trixie/tmate/tmate.1.en.html)) running on the other side is life saving. Let stop the openvpn service and invoke it as a standalone service instead of a daemon.

```console
$ doas openvpn --config /etc/openvpn/server.conf
2026-06-20 08:27:44 us=727112 TCP/UDP: Closing socket                                                                                                        
2026-06-20 08:27:46 us=638261 MULTI: multi_create_instance called                                                                                            
openvpn(90124) in free(): double free 0x3626945d540
Abort trap
```

Indeed, something bad is happening with this application. It's not a good thing to see an `Abort trap` or a `double free` exception. Let check the [release note from OpenBSD 7.9](https://www.openbsd.org/79.html), but it did not mention anything regarding OpenVPN, is some case, OpenBSD team put some notes their if something really important about a package needs to be updated. Maybe this information can be found in the [package's README](github.com/openbsd/ports/blob/master/net/openvpn/pkg/README) but it was not the case. I already using most of the recommendations from this file.

OpenVPN package on OpenBSD supports some flavors, like the mbedTLS one. Perhaps installing this version could fix the issue, it could be an easy workaround. (installing a flavor with `pkg_add` can be done by postfix the package name with `--` followed by a list of flavors separated by commas).

```console
$ doas pkg_delete openvpn
...

$ doas pkg_add openvpn--mbedtls
...
```

Let start it again.

```console
$ openvpn --configuration myconfig.conf
2026-06-20 09:09:43 us=709832 TCP/UDP: Closing socket                                                                                                       
openvpn(87978) in free(): double free 0x1957f910620                                                                                                           
Abort trap
```

Hmm, this is not a problem with this part of the application then. Let cleanup the openvpn configuration to see if we can find the culprit by removing all extra parameters and only keeping the mandatory ones.

```config
ca /...
cert /...
chroot /var/openvpn
client-config-dir ccd
dev tun0
dh /...
dhcp-option DNS 10.1.0.1
dhcp-option DOMAIN ...
group _openvpn
key /...
local 1.2.3.4
port 1194
proto udp
server 10.1.0.0 255.255.255.0
tls-auth /... 0
topology subnet
user _openvpn
verb 11
```

This is basically the smallest configuration I can have for this service and it still crashes. Another great thing, we can install a debug version of openvpn on OpenBSD, so, why not?

```console
$ doas pkg_delete openvpn--mbedtls
...

$ doas pkg_add openvpn debug-openvpn
...

$ doas openvpn --config /etc/openvpn/server.conf
2026-06-21 17:10:47 us=495655 Connection Attempt UDPv4 WRITE [54] to [AF_INET]1.2.3.4:32858: DATA ...
2026-06-21 17:10:47 us=496625 Connection Attempt UDPv4 write returned 54
2026-06-21 17:10:47 us=497180 Connection Attempt PO_CTL rwflags=0x0001 ev=4 arg=0xe6d6ae83e28
2026-06-21 17:10:47 us=497204 Connection Attempt PO_CTL rwflags=0x0001 ev=3 arg=0x00000002
2026-06-21 17:10:47 us=529222 Connection Attempt PO_WAIT[0,0] fd=4 rev=0x00000001 rwflags=0x0001 arg=0xe6d6ae83e28 [scalable]
openvpn(34334) in free(): double free 0xe6d6ae97000
2026-06-21 17:10:47 us=529957 Connection Attempt UDPv4 read returned 1222
2026-06-21 17:10:47 us=530561 Connection Attempt ACK read ID 1 (buf->len=1168)
2026-06-21 17:10:47 us=530609 Connection Attempt Valid packet (P_CONTROL_V1) with HMAC challenge from peer ([AF_INET]1.2.3.4:32858), accepting new connection.
2026-06-21 17:10:47 us=530628 Connection Attempt MULTI: multi_create_instance called
Abort trap
```

After this last issue, I decided to test the configuration on another server running on OpenBSD as well. Same behavior. I currently don't have any servers on Linux to install OpenVPN on it and do the correct configuration, but I assume this is a bug from OpenVPN. Let have a look at the version.

```console
$ openvpn --version
OpenVPN 2.7.2 x86_64-unknown-openbsd7.9 [SSL (mbed TLS)] [LZO] [LZ4] [MH/RECVDA] [AEAD]
library versions: mbed TLS 3.6.6, LZO 2.10
Originally developed by James Yonan
Copyright (C) 2002-2026 OpenVPN Inc <sales@openvpn.net>
Compile time defines: enable_async_push=no enable_comp_stub=no enable_crypto_ofb_cfb=yes enable_dco=no enable_debug=yes enable_dlopen=unknown enable_dlopen_self=unknown enable_dlopen_self_static=unknown enable_dns_updown_by_default=yes enable_fast_install=needless enable_fragment=yes enable_gtk_doc=no enable_iproute2=no enable_libtool_lock=yes enable_lz4=yes enable_lzo=yes enable_management=yes enable_ntlm=yes enable_pam_dlopen=no enable_pedantic=no enable_pkcs11=no enable_plugin_auth_pam=no enable_plugin_down_root=yes enable_plugins=yes enable_port_share=yes enable_selinux=no enable_shared=yes enable_shared_with_static_runtimes=no enable_silent_rules=no enable_small=no enable_static=yes enable_strict=no enable_strict_options=no enable_systemd=no enable_werror=no enable_win32_dll=yes enable_wolfssl_options_h=yes with_aix_soname=aix with_crypto_library=mbedtls with_gnu_ld=yes with_mem_check=no with_openssl_engine=no with_sysroot=no
```

Now, we can create an issue on [OpenVPN bugtracker](https://github.com/OpenVPN/openvpn/issues/) on Github. Thanks to [@cron2](https://github.com/cron2), he asked me to use [`gdb`](https://man.openbsd.org/gdb) to see what's happening.

```console
$ doas gdb openvpn
GNU gdb 6.3                                                                                                                                                   
Copyright 2004 Free Software Foundation, Inc.                                                                                                                                                                                                                                                                               
GDB is free software, covered by the GNU General Public License, and you are                                                                                                                                                                                                                                                
welcome to change it and/or distribute copies of it under certain conditions.
Type "show copying" to see the conditions.
There is absolutely no warranty for GDB.  Type "show warranty" for details.
This GDB was configured as "amd64-unknown-openbsd7.9"...(no debugging symbols found)

(gdb) run /etc/openvpn/server.conf
Starting program: /usr/local/sbin/openvpn /etc/openvpn/server.conf
(no debugging symbols found)
(no debugging symbols found)
(no debugging symbols found)
...
2026-06-21 18:08:29 us=538009 Connection Attempt MULTI: multi_create_instance called
openvpn(83681) in free(): double free 0xcd8b677f2a0

Program received signal SIGABRT, Aborted.

(gdb) where
2026-06-21 18:08:29 us=538009 Connection Attempt MULTI: multi_create_instance called
openvpn(83681) in free(): double free 0xcd8b677f2a0

Program received signal SIGABRT, Aborted.
thrkill () at /tmp/-:2
2       /tmp/-: No such file or directory.
        in /tmp/-
Current language:  auto; currently asm
#0  thrkill () at /tmp/-:2
#1  0x87e238fe7c29df29 in ?? ()
#2  0x00000cd91200f8bb in _libc_abort () at /usr/src/lib/libc/stdlib/abort.c:51
#3  0x00000cd912014714 in wrterror (d=Variable "d" is not available.
) at /usr/src/lib/libc/stdlib/malloc.c:378
#4  0x00000cd91201a681 in find_chunknum (d=Variable "d" is not available.
) at include/machine/tcb.h:43
#5  0x00000cd912015cb0 in ofree (argpool=0x7e622a409040, p=0xcd8b677f2a0, clear=Variable "clear" is not available.
) at /usr/src/lib/libc/stdlib/malloc.c:1659
#6  0x00000cd912015933 in _libc_free (ptr=0xcd8b677f2a0) at /usr/src/lib/libc/stdlib/malloc.c:1729
#7  0x00000cd6a5471978 in x_gc_free () from /usr/local/sbin/openvpn
#8  0x00000cd6a54b1bb8 in pre_connect_restore () from /usr/local/sbin/openvpn
#9  0x00000cd6a548d7a9 in init_instance () from /usr/local/sbin/openvpn
#10 0x00000cd6a548fc21 in inherit_context_child () from /usr/local/sbin/openvpn
#11 0x00000cd6a54a1b94 in multi_create_instance () from /usr/local/sbin/openvpn
#12 0x00000cd6a54a0a06 in multi_get_create_instance_udp () from /usr/local/sbin/openvpn
#13 0x00000cd6a54a39e0 in multi_process_incoming_link () from /usr/local/sbin/openvpn
#14 0x00000cd6a54a0d12 in multi_process_io_udp () from /usr/local/sbin/openvpn
#15 0x00000cd6a54a9626 in multi_io_process_io () from /usr/local/sbin/openvpn
#16 0x00000cd6a54a7181 in tunnel_server () from /usr/local/sbin/openvpn
#17 0x00000cd6a54ad978 in main () from /usr/local/sbin/openvpn
```

After an investigation by [cron2](https://github.com/OpenVPN/openvpn/issues/1060#issuecomment-4762931539), it seems the bug was from the DHCP/DNS options management.

```c
   3186
   3187         /* Free DNS options and reset them to pre-pull state */
   3188         gc_free(&o->dns_options.gc);
   3189         struct gc_arena dns_gc = gc_new();
   3190         o->dns_options = clone_dns_options(&pp->dns_options, &dns_gc);
   3191         o->dns_options.gc = dns_gc;
```

Great! We have found a bug, and the OpenVPN team already [fixed it](http://gerrit.openvpn.net/c/openvpn/+/1715). Regarding the workarounds, for now... I don't have a lot of solutions:

- configure dhcpd instead of using the DHCP service from OpenVPN

- configure a local DNS server on the client configuration side

- configure transparent DNS connections forwarding via a firewall (e.g. pf in this case).

In fact, this is a great timing, I need to upgrade my VPN infrastructure, too many useless services are running on it and I would like to have something lean. I would also like to remove [`tinc`](https://manpages.debian.org/experimental/tinc/tinc.8.en.html) (it was used to interconnect others servers) and use [`wireguard`](https://man.openbsd.org/wg) instead. The whole story of this bug can be seen on [Github issue @1060](https://github.com/OpenVPN/openvpn/issues/1060).

Happy Hack and have fun!

----

Cover Image by <a href="https://unsplash.com/@carlaquario31?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Carla Quario</a> on <a href="https://unsplash.com/photos/green-and-pink-flower-bud-RbOT5aMbTsE?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>