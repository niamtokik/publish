---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/alpine-linux-post-install-checklist-39fc"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Fzdyebio6nf8on65yzmfi.jpg"
created_at: "None"
crossposted_at: "None"
description: "Alpine Linux is one of my favorite distribution with Void Linux. Both are minimalist and perfect for..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/alpine-linux-post-install-checklist-39fc"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "alpine-linux-post-install-checklist-39fc"
social_image: "None"
title: "Alpine Linux Post-Install Checklist"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Alpine Linux Post-Install Checklist

[Alpine Linux](https://www.alpinelinux.org/) is one of my favorite distribution with [Void Linux](https://voidlinux.org). Both are minimalist and perfect for server usage or embedded projects. Here a quick checklist when configuring/staging/deploying manually a box on Alpine Linux.

The full installation procedure is available on the [Alpine Linux Wiki](https://wiki.alpinelinux.org/wiki/Installation). [Many tutorials and guides](https://wiki.alpinelinux.org/wiki/Tutorials_and_Howtos) can also be found there.

# General Configuration

**Main User Password**. When installing Alpine Linux, it's usually in front of a screen, with a keyboard, or in front of a virtual machine. We all know a default password is always configured, and it is most of the time an easy one. Change it with a stronger one when you can have access to the shell via SSH using the [`passwd`](https://manpages.debian.org/trixie/passwd/passwd.1.en.html) command or use an hash with ansible.

```console
# passwd ${user}
```

See also:

- [Setting up a new user](https://wiki.alpinelinux.org/wiki/Setting_up_a_new_user) from the Alpine Linux Wiki;
- [Users and groups](https://wiki.archlinux.org/title/Users_and_groups) on the ArchLinux Wiki;
- [User Adminitration](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Finalizing#User_administration) on the Gentoo Wiki.

----

**Root Password**. Same than previous point, when Alpine Linux is installed, the root password is usually an easy one. Change it with a strong one. The password can be removed later if the root account is disabled in the future. 

```console
# passwd root
```

See also:

- [Setting a default root password](https://wiki.gentoo.org/wiki/Setting_a_default_root_password) on the Gentoo Wiki;
- [Linux Set Root Password: A Comprehensive Guide](https://linuxvox.com/blog/linux-set-root-password/);
- [Is having root password for sudo considered a best practice or the opposite?](https://unix.stackexchange.com/questions/708115/is-having-root-password-for-sudo-considered-a-best-practice-or-the-opposite).

----

**Main User SSH Public Key**. If you are using an RSA key with SSH, it can be hard to copy/paste it directly from the screen during the installation. If you are lucky, you can have access to a remote repository via the network, but if it's not the case, you will need to install one later.

```console
$ mkdir ${HOME}/.ssh
$ chmod 700 ${HOME}/.ssh

$ touch ${HOME}/.ssh/authorized_keys
$ chmod 600 ${HOME}/.ssh/authorized_keys

$ cat >> ${HOME}/.ssh/authorized_keys << EOF
ssh-ed25519 AAAAC3Nza...
EOF
```

See also:

- [`ssh-keygen(1)` manpage](https://man.openbsd.org/ssh-keygen)

- [`ssh-agent(1)` manpage](https://man.openbsd.org/ssh-agent.1)

- [`ssh-add(1)` manpage](https://man.openbsd.org/ssh-add.1)

- [`ssh-copy-id(1)` manpage](https://manpages.debian.org/trixie/openssh-client/ssh-copy-id.1.en.html)

----

**Install tmux**. [`tmux`](https://tmux.app/) is the best terminal multiplexer, and the best alternative to `screen`.

```console
# apk add tmux
```

- [`tmux(1)` manpage](https://man.openbsd.org/tmux)

- [official tmux website](https://tmux.app/)

----

**Alpine Community Repository**. By default Alpine Linux is using only the `main` repository. This is already a good place where one can found a lot of package. Some packages are only available on `community` repository though, and enabling it can be nice. To do that, the file `/etc/apk/repositories` can be edited. Note: it is also a good idea to enforce `https`, by default, the Alpine repositories configured are using `http`.

```console
# cat > /etc/apk/repositories << EOF
https://dl-cdn.alpinelinux.org/alpine/v3.23/main
https://dl-cdn.alpinelinux.org/alpine/v3.23/communit
EOF
```

See also:

- [Repositories](https://wiki.alpinelinux.org/wiki/Repositories) on the Alpine Linux Wiki;

- [Alpine Package Keeper](https://wiki.alpinelinux.org/wiki/Alpine_Package_Keeper) on the Alpine Linux Wiki;

- [Official Alpine Linux Packages Search Page](https://pkgs.alpinelinux.org/packages);

- [Alpine Linux Packages Mirrors](https://mirrors.alpinelinux.org/).

----

**Install `sudo` or `doas`**. Using [`su`](https://manpages.debian.org/trixie/util-linux/su.1.en.html) is okay-ish, but having access to [`sudo`](https://manpages.debian.org/trixie/sudo-ldap/sudo.8.en.html) or [`doas`](https://manpages.debian.org/trixie/opendoas/doas.1.en.html) to log the commands passed as superuser is always a good idea. Alpine Linux does not install one of these tools by default.

```console
# apk add doas
```

See also:

- [Setting Up a New User, Doas section](https://wiki.alpinelinux.org/wiki/Setting_up_a_new_user#doas) on the Alpine Linux Wiki;

- [Setting Up a New User, Sudo section](https://wiki.alpinelinux.org/wiki/Setting_up_a_new_user#sudo) on the Alpine Linux Wiki

- [Sudo](https://wiki.gentoo.org/wiki/Sudo) on the Gentoo Wiki;

- [Sudo](https://wiki.archlinux.org/title/Sudo) on the Arch Linux Wiki;

- [`doas(1)` manpage](https://man.openbsd.org/doas);

- [`sudo(8)` manpage](https://manpages.debian.org/trixie/sudo-ldap/sudo.8.en.html);

- [`sudoers(5)` manpage](https://manpages.debian.org/trixie/sudo-ldap/sudoers.5.en.html).

----

**Configure `doas`**. As OpenBSD user, [`doas`](https://manpages.debian.org/trixie/opendoas/doas.1.en.html) is my default command to execute command as superuser. Like [`sudo`](https://manpages.debian.org/trixie/sudo-ldap/sudo.8.en.html), it must be configured by editing the [`/etc/doas.conf`](https://manpages.debian.org/trixie/opendoas/doas.conf.5.en.html) file or by creating a new file in [`/etc/doas.d/*.conf`](https://manpages.debian.org/trixie/opendoas/doas.conf.5.en.html). Note: the following configuration is a bit too open, if more than one users have access to a server, better permissions should be defined. For example, users in `dev` groups should never have access to all commands, but only a small subsets of them.

```console
# cat > /etc/doas.d/21-wheel.conf << EOF
permit persist :wheel
EOF
```

See also:

- [`doas(1)` manpage](https://man.openbsd.org/doas);

- [`doas.conf(5)` manpage](https://man.openbsd.org/doas.conf);

----

**SSH Server Hardening**. [`sshd`](https://manpages.debian.org/trixie/openssh-server/sshd.8.en.html) is the daemon/service used to have access to the server remotely. The protocol by itself is already well protected, but the default configuration deployed can be improved. There are so many publications on the internet about making SSH secure, it's perhaps not so important to explain everything, here a quick list of the things to modify though. The configuration file can be found in [`/etc/ssh/sshd_config`](https://manpages.debian.org/trixie/openssh-server/sshd_config.5.en.html) or in [`/etc/ssh/sshd_config.d`](https://manpages.debian.org/trixie/openssh-server/sshd_config.5.en.html) directory.

- disable user access without valid public key
- limit the amount of connections in parallel
- ensure root user can't connect to the box
- disable forwarding
- explicitly enforce allowed users

```console
# cat > /etc/ssh/sshd_config.d/99-local.conf << EOF
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
AllowUsers ${your_user}
PermitEmptyPasswords no
LoginGraceTime 30
MaxAuthTries 3
X11Forwarding no
AllowAgentForwarding no
AllowAgentForwarding no
AllowTcpForwarding no
PermitTunnel no
ClientAliveInterval 100
UseDNS no
Protocol 2
Banner none
PubkeyAuthentication yes
HostbasedAuthentication no
IgnoreRhosts yes
EOF
```

See also:

- [`sshd(8)` man page](https://man.openbsd.org/sshd);

- [`sshd_config(5)` man page](https://man.openbsd.org/sshd_config);

- [Setting up a SSH server](https://wiki.alpinelinux.org/wiki/Setting_up_a_SSH_server) on the Alpine Linux Wiki;

- [SSH Hardening - Securing Your Linux Servers](https://merox.dev/blog/ssh-hardening/);

- [SSH Hardening Guide: Best Practices for Linux Servers](https://linuxize.com/post/ssh-hardening-best-practices/).

----

**SSH Client Hardening**. The default configuration for the [`ssh`](https://manpages.debian.org/trixie/openssh-client/ssh.1.en.html) client can be found in [`/etc/ssh/ssh_config`](https://manpages.debian.org/trixie/openssh-client/ssh_config.5.en.html) or in the [`/etc/ssh/ssh_config.d`](https://manpages.debian.org/trixie/openssh-client/ssh_config.5.en.html) directory. The configuration installed should do the job in 99% of the case, but some things can be improved. Note: except if the server is used as a bastion or a forwarder, it's usually not necessary to modify this configuration.

```console
# cat > /etc/ssh/ssh_config.d/99-local.conf << EOF
VisualHostKey yes
EOF
```

See also:

- [`ssh(1)` manpage](https://man.openbsd.org/ssh);

- [`ssh_config(5)` manpage](https://man.openbsd.org/ssh_config);

- [Introduction to OpenSSH](https://www.openbsd.org/papers/slug2025-dtucker-openssh-intro.pdf).

----

**Network Interface Configuration**. If the server was installed in a VM or in a specific network, it is sometimes necessary to modify the configuration of the network interfaces. This configuration is located in the [`/etc/network/interfaces`](https://manpages.debian.org/trixie/ifupdown-ng-compat/interfaces.5.en.html) file. First, list the available interfaces with the [`ip address`](https://manpages.debian.org/trixie/iproute2/ip-address.8.en.html)  command and configure them respectively.

```console
# cat > /etc/network/interfaces << EOF
auto lo
iface lo inet loopback

auto eth0
        address ${server_ipv4_address}
        network ${ipv4_network}
        broadcast ${ipv4_broadcast}
        gateway ${ipv4_gateway}
EOF
```

See also:

- [Configure Networking](https://wiki.alpinelinux.org/wiki/Configure_Networking) on the Alpine Linux Wiki;

- [`interfaces(5)` manpage](https://manpages.debian.org/trixie/ifupdown-ng-compat/interfaces.5.en.html).

----

**Local DNS Resolver**. DNS is always the issue, or at least, most of the time. On distribution using [`systemd`](https://manpages.debian.org/trixie/systemd/systemd.1.en.html), the [`systemd-resolved`](https://wiki.archlinux.org/title/Systemd-resolved) daemon in charge of the DNS can be sometimes a bit... annoying. In the past, on Ubuntu/Debian, I got many issues because of that, and I now have the habit to simply install `dnsmasq` or `unbound` locally and configure `/etc/resolv.conf` manually. [`dnsmasq`](https://manpages.debian.org/trixie/dnsmasq-base/dnsmasq.8.en.html) configuration can be found in the `/etc/dnsmasq.conf` file  or in the `/etc/dnsmasq.d` directory.

```console
# apk add dnsmasq

# cat > /etc/dnsmasq.d/99-local.conf << EOF
listen-address=127.0.0.1
server=${your_dns_server}
no-resolve
EOF

# rc-update add dnsmasq

# service dnsmasq start

# echo "nameserver 127.0.0.1" > /etc/resolv.conf
```

See also:

- [dnsmasq](https://wiki.archlinux.org/title/Dnsmasq) on the Alpine Linux Wiki;

- [Unbound](https://wiki.archlinux.org/title/Unbound) on the Alpine Linux Wiki;

- [Official DNSmasq Website](https://dnsmasq.org/doc.html);

- [Official Unbound Website](https://www.nlnetlabs.nl/projects/unbound/about/).

----

**Linux Cgroups Configuration**. When using a Linux distribution, most of the time it's about containers, with Docker or another alternative. Cgroups are disabled by default on Alpine Linux and must be enabled in `initrc` by editing the `/etc/rc.conf` file. Note: the `hybrid` value sets both version of cgroups. The service must also be started if you want to use `docker` or `podman`.

```console
# cp /etc/rc.conf /etc/rc.conf.old

# sed -Ei 's/#rc_cgroup_mode="unified"/#rc_cgroup_mode="hybrid"/' /etc/rc.conf 

# cat >> /etc/rc.conf << EOF
rc_cgroup_settings="
memory.max 10485760
pids.max max
"
EOF

# rc-update add cgroups

# service cgroups start
```

- [Docker](https://wiki.alpinelinux.org/wiki/Docker) on the Alpine Linux Wiki;

- [OpenRC Cgroups Section](https://wiki.alpinelinux.org/wiki/OpenRC#Cgroups) on the Alpine Linux Wiki;

- [Control Groups](https://www.kernel.org/doc/html/latest/admin-guide/cgroup-v1/cgroups.html);

- [Control Groups version 1](https://docs.kernel.org/admin-guide/cgroup-v1/index.html);

- [Control Group v2](https://www.kernel.org/doc/html/latest/admin-guide/cgroup-v2.html);

- [Enable CGroups V2 in Alpine Linux](https://liet.me/2022/07/08/enable-cgroups-v2-in-alpine-linux/).

----

**Proxy Configuration**. If you are using a proxy (inside a protected network), don't forget to configure it or them. `HTTP_PROXY` environment variables are supported by most of the applications nowadays.

```console
# cat >> /etc/profile << EOF
# proxy configuration
http_proxy=${my_proxy}
https_proxy=${my_proxy}
HTTP_PROXY=${my_proxy}
HTTPS_PROXY=${my_proxy}

EOF
```

See also:

- [HTTP_PROXY](https://env.dev/variables/HTTP_PROXY) on env.dev;

- [Set up Proxy using http_proxy, https_proxy and no_proxy in Linux](https://www.golinuxcloud.com/set-up-proxy-http-proxy-environment-variable/);

- [Linux Proxy Configuration: The Complete Guide to http_proxy, PAC, and System-Wide Settings (2026)](https://www.fosslinux.com/158631/linux-proxy-configuration-guide.htm).

----

**PAM Userland Tools**. Managing users in Alpine Linux can be challenging at first, because the PAM tools are not installed. They can be installed via the `shadow` package. It will make everything easier when dealing with users and groups.

```console
# apk add shadow
```

See also:

- [`useradd(8)` manpage](https://manpages.debian.org/trixie/passwd/useradd.8.en.html);

- [`userdel(8)` manpge](https://manpages.debian.org/trixie/passwd/userdel.8.en.html);

- [`usermod(8)` manpage](https://manpages.debian.org/trixie/passwd/usermod.8.en.html);

- [`groupadd(8)` manpage](https://manpages.debian.org/trixie/passwd/groupadd.8.en.html);

- [`groupdel(8)` manpage](https://manpages.debian.org/trixie/passwd/userdel.8.en.html);

- [`groupmod(8)` manpage](https://manpages.debian.org/trixie/passwd/usermod.8.en.html).

----

**NTP Configuration**. During the install process, the installer asks which NTP servers should be installed. If in my case, you just press enter to end the process as quick as possible, the default NTP server will be installed. Again, as OpenBSD user, I like [`openntpd`](https://manpages.debian.org/trixie/openntpd/openntpd.8.en.html), it's minimalist and do the job well.

```console
# apk add openntpd

# cat > /etc/ntpd.conf << EOF
listen on 127.0.0.1
servers pool.ntp.org
server time.cloudflare.com
sensor *
constraint from "9.9.9.9"
constraint from "2620:fe::fe"
constraints from "www.google.com"
EOF

# rc-update del ntpd

# rc-update add openntpd

# service openntpd start
```

See also:

- [`ntpd(8)` manpage](https://man.openbsd.org/ntpd);

- [`ntpd.conf(5)` manpage](https://man.openbsd.org/ntpd.conf).

----

**Custom Editor Configuration**. Alpine Linux is already installed with a small version of [`vi`](https://manpages.debian.org/trixie/vis/vi.1.en.html), not even [`ed`](https://manpages.debian.org/trixie/ed/ed.1.en.html) is installed. So, installing [`vim`](https://manpages.debian.org/trixie/vim-common/vim.1.en.html) or any other editor of your choice can be helpful.

```console
# apk add vim
```

See also:

- [`vim(1)` manpage](https://manpages.debian.org/trixie/vim-common/vim.1.en.html);

- [Official VIM website](https://www.vim.org/).

----

**Disable shell history**. Some of you would ask why doing that. Well, as sysadmin, I saw too many confidential informations in the shell history, including passwords, tokens and sometimes sensitive customer informations. Disabling this feature will avoid information leaks. By setting [`HISTFILE`](https://manpages.debian.org/trixie/bash/bash.1.en.html#HISTFILE) to `/dev/null`, the feature will stay available for the current session but the history will never remains in a file (usually in `${HOME}/.ash_history` on Alpine).

```console
# cat >> /etc/profile << EOF
# disable shell logging feature
export HISTFILE=/dev/null

EOF
```

----

# System Hardening

**AppArmor Configuration**. Ensuring applications are doing the right things is important. One can install `selinux` or `apparmor` to enforce those check. Note: configuring those applications can be complex, please read the documentation first and do some tests before deploying in production.

```console
# apk add apparmor apparmor-utils apparmor-profiles

# cat >> /etc/default/grub << EOF
GRUB_CMDLINE_LINUX_DEFAULT="modules=sd-mod,usb-storage,ext4 quiet rootfstype=ext4 apparmor=1 security=apparmor"
EOF

# grub-mkconfig -o /boot/grub/grub.cfg

# cat /sys/kernel/security/lsm

# rc-update add apparmor boot

# service apparmor start

# aa-enabled
```

See also:

- [`apparmor(7)` manpage](https://manpages.debian.org/trixie/apparmor/apparmor.7.en.html);

- [AppArmor](https://wiki.alpinelinux.org/wiki/AppArmor) on the Alpine Linux Wiki;

- [Security Handbook/Linux Security Modules/AppArmor](https://wiki.gentoo.org/wiki/Security_Handbook/Linux_Security_Modules/AppArmor) on the Gentoo Wiki;

- [AppArmor](https://wiki.archlinux.org/title/AppArmor) on the Arch Linux Wiki;

- [Official AppArmor website](https://www.apparmor.net/).

----

**Auto-Update**. Enable auto-update and auto-upgrade (not mandatory).

```console
# cat >> cat /etc/crontabs/root << EOF
# auto-update/auto-upgrade 
0 2 * * * apk update && apk upgrade
EOF
```

See also:

- [Regular Maintenance](https://wiki.alpinelinux.org/wiki/Securing_Alpine_Linux#Regular_maintenance) on the Alpine Linux Wiki.

----

**Full Disk Encryption**. If your server requires FDE, don't forget to configure it during the installation process. It will be the subject of a full article, because it can be challenging to deal with that. The idea is to encrypt the whole disk, and use an USB thumb containing `grub` and the key to decrypt it to boot the kernel. If the USB drive is not plugged, the server can't boot.

See also:

- [Setting up encrypted volumes with LUKS](https://wiki.alpinelinux.org/wiki/Setting_up_encrypted_volumes_with_LUKS) on the Alpine Linux Wiki;

- [Full Disk Encryption From Scratch](https://wiki.gentoo.org/wiki/Full_Disk_Encryption_From_Scratch) on the gentoo Wiki;

- [dm-crypt](https://wiki.gentoo.org/wiki/Dm-crypt) on the Gentoo Wiki;

- [dm-crypt/Encrypting an entire system](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system) on the ArchLinux Wiki;

- [dm-crypt/Device encryption](https://wiki.archlinux.org/title/Dm-crypt/Device_encryption) on the ArchLinux Wiki;

- [dm-crypt](https://www.kernel.org/doc/html/latest/admin-guide/device-mapper/dm-crypt.html) from kernel.org;

- [Encrypted Alpine Linux](https://not.just-paranoid.net/encrypted-alpine-linux/) from just-paranoid.net.

----

**Backup Configuration**. If your server contains critical data, don't forget to do regular backup using [`restic`](https://pkgs.alpinelinux.org/package/edge/community/x86_64/restic), [`rustic`](https://pkgs.alpinelinux.org/package/edge/testing/x86_64/rustic) or any other applications to creates backups on daily basis.

See also:

- [`restic(1)` manpage](https://manpages.debian.org/trixie/restic/restic.1.en.html);

- [Official Rustic website](https://rustic.cli.rs/).

----

**Sysctl System Hardening**. The Linux Kernel offers huge flexibility over its configuration, instead of recompiling the kernel every time with hard coded value, a first step is to configure the parameters available from `sysctl` or from `/sys`.

```console
# cat > /etc/sysctl.d/99-system-hardening.conf << EOF
fs.file-max = 65535
fs.protected_fifos = 2
fs.protected_hardlinks = 1
fs.protected_regular = 2
fs.protected_symlinks = 1
fs.suid_dumpable = 0
kernel.core_pattern=|/bin/false
kernel.core_uses_pid = 1
kernel.ctrl-alt-del = 0
kernel.dmesg_restrict = 1
kernel.kexec_load_disabled = 1
kernel.kptr_restrict = 2
kernel.perf_event_paranoid = 2
kernel.pid_max = 65536
kernel.split_lock_mitigate = 0
kernel.sysrq = 0
kernel.unprivileged_bpf_disabled = 1
kernel.yama.ptrace_scope = 2
net.core.bpf_jit_harden = 2
vm.mmap_rnd_bits = 32
vm.mmap_rnd_compat_bits = 16
EOF

# sysctl -p /etc/sysctl.conf /etc/sysctl.d/*.conf
```

See also:

- https://wiki.alpinelinux.org/wiki/Sysctl.conf

- https://wiki.alpinelinux.org/wiki/Securing_Alpine_Linux

- https://krython.com/post/hardening-alpine-linux-system-security

----

**Custom Hardened Kernel**. Disable unused feature, enable more security features and compile your own kernel. This can also be a challenging topic, and will have its own dedicated publication here.

See also:

- [How to build the Alpine Linux kernel](https://wiki.alpinelinux.org/wiki/How_to_build_the_Alpine_Linux_kernel) on the Alpine Linux website;

- [Linux Hardened Kernel project](https://github.com/anthraxx/linux-hardened) on Github;

- [hardened-kernel](https://www.kicksecure.com/wiki/Hardened-kernel) on KickSecure Wiki.

----

# Network Hardening

**Firewall Configuration**. Install `iptables` or `nftables`. Be careful though, because enabling and starting these services can cut your connections. Always tests the rules first and then deploy. `nftables` configuration can be found in the `/etc/nftables.nft` file or in the `/etc/nftables.d` directory. The `iptables` configuration can be found in `/etc/iptables` directory. The following configuration will only allow connections to the `sshd` daemon from anywhere.

```console
# apk add nftables

# cat > /etc/nftables.d/99-local.nft << EOF
table inet filter {
  chain input {
    tcp dport ssh accept comment "allow sshd connections"
  }
}
EOF

# rc-update add nftables boot

# service nftables start
```

See also:

- [`iptables(8)` manpage](https://manpages.debian.org/trixie/iptables/iptables.8.en.html);

- [`nft(8)` manpage](https://manpages.debian.org/trixie/nftables/nftables.8.en.html)

- [Iptables](https://wiki.alpinelinux.org/wiki/Iptables) on the Alpine Linux Wiki;

- [iptables](https://wiki.gentoo.org/wiki/Iptables) on the Gentoo Linux Wiki;

- [iptables](https://wiki.archlinux.org/title/Iptables) on the Arch Linux Wiki;

- [iptables official website](https://netfilter.org/)

- [Simple stateful firewall](https://wiki.archlinux.org/title/Simple_stateful_firewall) on the Arch Linux Wiki;

- [Nftables](https://wiki.alpinelinux.org/wiki/Nftables) on the Alpine Linux Wiki; 

- [nftables](https://wiki.gentoo.org/wiki/Nftables) on the Gentoo Linux Wiki;

- [nftables](https://wiki.archlinux.org/title/Nftables) on the Arch Linux Wiki;

- [nftables official website](https://wiki.nftables.org/wiki-nftables/index.php/Main_Page)

----

**Sysctl Network Optimization**. Optimize network stack configuration via `sysctl`.

```console
# echo "tcp_bbr" > /etc/modprobe.d/99-tcp.conf

# cat > /etc/sysctl.d/99-tcp-hardening.conf << EOF
net.core.default_qdisc=fq
net.core.rmem_max = 33554432
net.core.wmem_max = 33554432
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_max_syn_backlog=65536
net.ipv4.tcp_rmem = 4096 131072 33554432
net.ipv4.tcp_syn_retries=3
net.ipv4.tcp_synack_retries=3
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_wmem = 4096 131072 33554432
EOF

# cat > /etc/sysctl.d/99-ipv4-hardening.conf << EOF
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.log_martians = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.send_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.ip_forward = 0
EOF

# sysctl -p /etc/sysctl.conf /etc/sysctl.d/*.conf
```

See also:

- [Sysctl](https://wiki.alpinelinux.org/wiki/Sysctl.conf) on the Alpine Linux Wiki;

- [sysctl](https://wiki.archlinux.org/title/Sysctl) on the Arch Linux Wiki;

- [`modprobe(8)` manpage](https://manpages.debian.org/trixie/kmod/modprobe.8.en.html);

- [`modprobe.conf(5)` manpage](https://manpages.debian.org/trixie/kmod/modprobe.conf.5.en.html);

- [`sysctl(8)` manpage](https://manpages.debian.org/trixie/procps/sysctl.8.en.html);

- [IP Sysctl](https://www.kernel.org/doc/html/latest/networking/ip-sysctl.html) from kernel.org;

- [Linux TCP Tuning: Improve Throughput with sysctl Knobs](https://www.commandinline.com/linux-tcp-tuning-throughput-sysctl-knobs/) from commandline.com;

- [Optimizing Linux Network Throughput by Tuning TCP/IP sysctl Parameters](https://devops.aibit.im/en/article/optimizing-linux-network-throughput-tcp-sysctl) from devops.aibit.

----

**Use Only One Network Stack**. If you don't need IPv6, disable it. Using two network stacks can lead to more problem. You can simply disable it using `sysctl` by setting `net.ipv6.conf.all.disable_ipv6` to `1` or by recompiling the kernel and disabling IPv6 directly there.

```console
# sysctl net.ipv6.conf.all.disable_ipv6=1

# echo net.ipv6.conf.all.disable_ipv6=1 > /etc/sysctl.d/99-ipv6-disabled.conf
```

See also:

- [Sysctl Explorer](https://sysctl-explorer.net)

- [Documentation for /proc/sys/net/](https://www.kernel.org/doc/html/v7.3-rc1/admin-guide/sysctl/net.html)

- [How to disable autoconfiguration on IPv6 in Linux?](https://superuser.com/questions/33196/how-to-disable-autoconfiguration-on-ipv6-in-linux)

- [disable_ipv6 - Disable IPv6 on Interface](https://oneuptime.com/blog/post/2026-03-20-proc-sys-net-ipv6-conf-parameters/view#disable-ipv6-disable-ipv6-on-interface)

- [Disabling IPv6 on Linux: Step-by-Step Guide](https://www.systutorials.com/disabling-ipv6-on-fedora-17-linux/)

----

# Monitoring

**Configure a Logger**. By default, a minimalist implementation of syslog from busybox called [`syslogd`](https://manpages.debian.org/jessie/busybox-syslogd/syslogd.8.en.html) is installed. One will probably prefer something a bit more flexible like [`rsyslog`](https://pkgs.alpinelinux.org/package/edge/main/x86_64/rsyslog) or [`syslog-ng`](https://pkgs.alpinelinux.org/package/edge/main/x86_64/syslog-ng) to manage the logs (and forward them for example).

```console
# apk add rsyslog

# rc-update add rsyslog

# service rsyslog start
```

See also:

- [Syslog page](https://wiki.alpinelinux.org/wiki/Syslog) on Alpine Linux Wiki;

- [rsyslog official website](https://www.rsyslog.com/).

----

**Log Rotation**. On a very active servers, logs can be a huge problem, even more if the partitions were not correctly configuration, one badly configured process can easily fill up all the available space in `/` or in `/var` or in `/var/log`. It can be good to configure [`logrorate`](https://manpages.debian.org/trixie/logrotate/logrotate.8.en.html) accordingly. It mostly depends on your applications, so, I will not give you any examples, the manpage should be enough.

See also:

- [`logrotate(8)` manpage](https://manpages.debian.org/trixie/logrotate/logrotate.8.en.html)

----

**Physical Disk Monitoring**. Install `smartmontools` to check the states of the disks.

```console
# apk add smartmontools

# rc-update add smartd

# service smartd start
```

See also:

- [`smartctl(8)` manpage](https://manpages.debian.org/trixie/smartmontools/smartctl.8.en.html)

- [`smartd(8)` manpage](https://manpages.debian.org/trixie/smartmontools/smartd.8.en.html)

- [SmartMonTools official website](https://www.smartmontools.org/)

----

**Monitoring**. Install `monit` to control automatically the state of each services running on the server, reboot them or send a notification in case of issue.

```console
# apk add monit

# rc-update add monit

# service monit start
```

See also:

- [Official Monit website](https://mmonit.com/monit/)

----

**Metrics Collection**. Install something to monitor the system like [`netdata`](https://pkgs.alpinelinux.org/package/edge/community/x86_64/netdata), [`prometheus`](https://pkgs.alpinelinux.org/package/edge/community/x86_64/prometheus) or any other tools to collect the metrics.

```console
# apk add netdata
```

See also:

- [Official Prometheus website](https://prometheus.io/)

- [Official netdata website](https://www.netdata.cloud/)

----

**System Audit**. Install and configure [`audit`](https://pkgs.alpinelinux.org/package/edge/main/x86_64/audit). This package contains [`auditd`](https://manpages.debian.org/trixie/auditd/auditd.8.en.html) and [`auditctl`](https://manpages.debian.org/trixie/auditd/auditctl.8.en.html) executable to audit the logs 

```console
# apk add audit

# rc-update add auditd

# service auditd start
```

See also:

- [`auditctl(8)` manpage](https://manpages.debian.org/trixie/auditd/auditctl.8.en.html)

- [`auditd(8)` manpage](https://manpages.debian.org/trixie/auditd/auditd.8.en.html)

- [`auditd.conf(5)` manpage](https://manpages.debian.org/trixie/auditd/auditd.conf.5.en.html)

- [Install necessary security tools](https://wiki.alpinelinux.org/wiki/Securing_Alpine_Linux#Install_necessary_security_tools) on Alpine Linux Wiki;

- [Audit](https://wiki.gentoo.org/wiki/Audit) on the Gentoo Wiki;

- [Audit framework](https://wiki.archlinux.org/title/Audit_framework) on the Arch Linux Wiki.

----

# Misc

**Tools**. Some packages are required to check if everything is working as expected. the `bind-tools` package contains `dig` used to check if domain name requests are working. The `curl` packages contains `curl` to check if the server can have access to remote HTTP servers.

```console
# apk add curl bind-tools
```

See also:

- [`curl(1)` manpage](https://manpages.debian.org/trixie/curl/curl.1.en.html);

- [`dig(1)` manpage](https://manpages.debian.org/trixie/bind9-dnsutils/dig.1.en.html).

----

**Container Managers**. [`docker`](https://pkgs.alpinelinux.org/package/edge/community/x86_64/docker), [`podman`](https://pkgs.alpinelinux.org/package/edge/community/x86_64/podman), [`lxc`](https://pkgs.alpinelinux.org/package/edge/main/x86_64/lxc) or [`incus`](https://pkgs.alpinelinux.org/package/edge/community/x86_64/incus) can be installed on Alpine Linux. On my side, I prefer the 3 last listed above, `docker` is not open-source enough to me.

```console
# apk add podman
```

See also:

- [Podman](https://wiki.alpinelinux.org/wiki/Podman) on the Alpine Linux Wiki;

- [Podman](https://wiki.gentoo.org/wiki/Podman) on the Gentoo Wiki;

- [Podman](https://wiki.archlinux.org/title/Podman) on the Arch Linux Wiki;

- [Official Podman website](https://podman.io/).

----

# Conclusion

This article contains only the beginning of the life of a server. Indeed, those steps can easily be applied on one or two servers during manually, but when it comes to manage more than few servers, using an Ansible playbook or a Salt Pillar to ensure everything was correctly configured on all the fleet.

Actually, this procedure is also limited to a really simple server configuration, if one need a web server or a database, more specific steps will be required. In fact, it's only the beginning, because every new simple application installed will need its amount of complexity to deal with.

The final configuration presented in this article can also be a good foundation to install something more complex like [k3s](https://k3s.io/) or [nomad](https://developer.hashicorp.com/nomad). It can also be used to be a template for virtual machines exposed directly to the web... Or simply for your own private services at home.

On my side, it will also be used to host my own gitlab/github workers... But we will see that in another post!

Anyway, as usual, have fun and happy hacking!

----

Cover Image by <a href="https://unsplash.com/@misssusanflynn?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Susan Flynn</a> on <a href="https://unsplash.com/photos/snow-covered-mountain-under-blue-sky-during-daytime-QGAasftB9uc?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
