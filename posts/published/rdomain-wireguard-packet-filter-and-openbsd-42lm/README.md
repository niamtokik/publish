---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/rdomain-wireguard-packet-filter-and-openbsd-42lm"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Fboa8gui5dkbs1k5yxvnn.jpg"
created_at: "None"
crossposted_at: "None"
description: "rdomain is an interesting feature present on OpenBSD to create isolated routing domain. I rarely used..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/rdomain-wireguard-packet-filter-and-openbsd-42lm"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "rdomain-wireguard-packet-filter-and-openbsd-42lm"
social_image: "None"
title: "rdomain, wireguard, packet filter and OpenBSD"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# rdomain, wireguard, packet filter and OpenBSD

`rdomain` is an interesting feature present on OpenBSD to create isolated routing domain. I rarely used this one - except for testing - but it was never deployed in production. In fact, it was pretty rare to have an OpenBSD router/firewall running outside of my own lab. A previous post was showing how to isolate a pool of workers and forward all their traffic through using onion routing using proxies. In this post, the workers traffic will be routed to a remote server using a wireguard tunnel. Both the firewall and the remote server are running on OpenBSD.

A picture is worse thousand of words, then, the infrastructure schema below should give you an idea of the network structure and the connections between the different devices. Not everything is presented though, because my network is a bit more complex than that, but this is a big picture.

![Infrastructure Schema for Wireguard and rdomain on OpenBSD](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/6wbmwfrme29d8ph78qcd.png)

Before doing anything, we should probably start to learn what is an `rdomain` and how to use it properly.

# It's All About Isolation and Routing

`rdomain` appeared for the first time in OpenBSD 4.9. This goal was to offer a way to have isolated routing tables. By default, all routes are put in the `rdomain 0`, and it can lead to some issues when dealing with complex network. With an `rdomain`, an operator is able to create dynamically a new routing table isolated from the rest of the system, even if it is limited to 255 `rdomain`, it shold be enough for most of the use case.

Processes can be started in their own `rdomain` with the help of the [`route`](https://man.openbsd.org/route) command and its `exec` subcommand without forgetting the [`-T`](https://man.openbsd.org/route#T) flag. A way to check in which domain a process is in, is to use [`ps`](https://man.openbsd.org/ps) command with the [`rtable`](https://man.openbsd.org/ps#rtable) option. Let first checks the output of the `ps` command.

```console
$ ps -o rtable,pid,ppid,%cpu,%mem,command
RTABLE   PID  PPID %CPU %MEM COMMAND
     0 59603 14917  0.0  0.0 -ksh (ksh)
     0 13501 59603  0.0  0.2 tmux: client (/tmp/tmux-1000/default) (tmux)
     0 68852 66599  0.0  0.0 -ksh (ksh)
     0 73792 66599  0.0  0.0 -ksh (ksh)
     0 75757 66599  0.0  0.0 -ksh (ksh)
     0 85484 75757  0.0  0.1 ps -o rtable
     0 47120 66599  0.0  0.0 -ksh (ksh)
     0 86889 66599  0.0  0.0 -ksh (ksh)
```

AS you can see, all processes are currently running in the default `rdomain 0`. To use another `rdomain`, the `route` command can be used, like it has been seen previously. Let check that by spawning a [`sleep`](https://man.openbsd.org/man1/sleep.1) in the background for 10 seconds in the `rdomain 1`.

```console
$ route -T1 exec sleep 10 &
[1] 96416

$ ps -o rtable,pid,ppid,%cpu,%mem,command
RTABLE   PID  PPID %CPU %MEM COMMAND
     0 59603 14917  0.0  0.0 -ksh (ksh)
     0 13501 59603  0.0  0.2 tmux: client (/tmp/tmux-1000/default) (tmux)
     0 68852 66599  0.0  0.0 -ksh (ksh)
     0 73792 66599  0.0  0.0 -ksh (ksh)
     0 46155 73792  0.0  0.0 sleep 1
     0 75757 66599  0.0  0.0 -ksh (ksh)
     1 96416 75757  0.0  0.0 sleep 10
     0 26428 75757  0.0  0.1 ps -o rtable
     0 47120 66599  0.0  0.0 -ksh (ksh)
     0 86889 66599  0.0  0.0 -ksh (ksh)
```

The `sleep` process is correctly using the `rtable 1`, but what kind of differences are existing between all of those routing tables? Well, the default routing table is initialized during the startup of the system, but all other `rdomain` should be empty. Again, the `route` command can be used to show that or the [`netstat`](https://man.openbsd.org/netstat.1) command can be used instead, it is offering more filtering options.

```console
$ netstat -rnT0 -finet
Routing tables

Internet:
Destination        Gateway            Flags   Refs      Use   Mtu  Prio Iface
default            192.168.123.254      UGS        9 10038979     -     8 re0
224/4              127.0.0.1          URS        0        0 32768     8 lo0
10.255.255.240/28  10.255.255.253     UCn        1        0     -     
...
```

An existing `rdomain 1` is currently present on my test example. As you can see, the output returned by `netstat` is totally different than the one from the `rdomain 1`.

```console
$ netstat -rnT1 -f inet
Routing tables

Internet:
Destination        Gateway            Flags   Refs      Use   Mtu  Prio Iface
default            172.17.0.1         UGS        0    17202     -     8 wg0
10.255.255.240/28  10.255.255.254     UCn        1        0     -     4 pair1
10.255.255.253     fe:e1:ba:d5:62:48  UHLch      1        6     -     3 pair1
10.255.255.254     fe:e1:ba:d6:4a:44  UHLl       0        4     -     1 pair1
10.255.255.255     10.255.255.254     UHb        0        0     -     1 pair1
127.0.0.1          127.0.0.1          UHl        0      315 32768     1 lo1
...
```

The `rdomain 2` does not exist though, and when trying to show its content, an error is returned by `netstat`. The same error is returned to any unitialized `rdomains`.

```console
$ netstat -rnT2
netstat: routing table 2: No such file or directory
```

```console
$ netstat -rnT3
netstat: routing table 3: No such file or directory
```

`rdomain`s can be created when dealing with network interfaces and pseudo devices. For example, let created `rdomain 2` and `rdomain 3` by defining `lo2` and `lo3` loopback interfaces.

```console
$ doas ifconfig lo2 create rdomain 2 alias 127.0.0.1 up

$ doas ifconfig lo2
lo2: flags=2008049<UP,LOOPBACK,RUNNING,MULTICAST,LRO> rdomain 2 mtu 32768
        index 26 priority 0 llprio 3
        groups: lo
        inet6 ::1 prefixlen 128
        inet6 fe80::1%lo2 prefixlen 64 scopeid 0x1a
        inet 127.0.0.1 netmask 0xff000000
```

```console
$ doas ifconfig lo3 create rdomain 3 alias 127.0.0.1 up

$ doas ifconfig lo3
lo3: flags=2008049<UP,LOOPBACK,RUNNING,MULTICAST,LRO> rdomain 3 mtu 32768
        index 27 priority 0 llprio 3
        groups: lo
        inet6 ::1 prefixlen 128
        inet6 fe80::1%lo3 prefixlen 64 scopeid 0x1b
        inet 127.0.0.1 netmask 0xff000000
```

Both interfaces are totally isolated in their own address space, with its own routing table, this is why the same IP address (here `127.0.0.1`) can be set. To extend the example, 2 `vether` interfaces can be created as well.

```console
$ doas ifconfig vether2 create alias 10.0.0.1/24 rdomain 2 up

$ ifconfig vether2
vether2: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> rdomain 2 mtu 1500
        lladdr fe:e1:ba:d9:1b:6c
        index 30 priority 0 llprio 3
        groups: vether
        media: Ethernet autoselect
        status: active
        inet 10.0.0.1 netmask 0xffffff00 broadcast 10.0.0.255
```

```console
$ doas ifconfig vether3 create alias 10.0.1.1/24 rdomain 3 up

$ ifconfig vether3
vether3: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> rdomain 3 mtu 1500
        lladdr fe:e1:ba:da:b5:73
        index 31 priority 0 llprio 3
        groups: vether
        media: Ethernet autoselect
        status: active
        inet 10.0.1.1 netmask 0xffffff00 broadcast 10.0.1.255
```

To interconnect those networks 2 `pair` interfaces can be created. A  small subnet will be create to route the packets between both networks.

```console
$ doas ifconfig pair2 create alias 172.31.255.253/30 rdomain 2 up

$ ifconfig pair2
pair2: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> rdomain 2 mtu 1500
        lladdr fe:e1:ba:de:a4:28
        index 35 priority 0 llprio 3
        groups: pair
        media: Ethernet autoselect
        inet 172.31.255.253 netmask 0xfffffffc broadcast 172.31.255.255
```

```console
$ doas ifconfig pair3 create alias 172.31.255.254/30 rdomain 3 up 

$ ifconfig pair3
pair3: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> rdomain 3 mtu 1500
        lladdr fe:e1:ba:df:34:e5
        index 36 priority 0 llprio 3
        groups: pair
        media: Ethernet autoselect
        inet 172.31.255.254 netmask 0xfffffffc broadcast 172.31.255.255
```

The `pair` interfaces must be patched together.

```console
$ doas ifconfig pair2 patch pair3

$ ifconfig pair2
pair2: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> rdomain 2 mtu 1500
        lladdr fe:e1:ba:de:a4:28
        index 35 priority 0 llprio 3
        patch: pair3
        groups: pair
        media: Ethernet autoselect
        status: active
        inet 172.31.255.253 netmask 0xfffffffc broadcast 172.31.255.255

$ ifconfig pair3
pair3: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> rdomain 3 mtu 1500
        lladdr fe:e1:ba:df:34:e5
        index 36 priority 0 llprio 3
        patch: pair2
        groups: pair
        media: Ethernet autoselect
        status: active
        inet 172.31.255.254 netmask 0xfffffffc broadcast 172.31.255.25
```

It should now be possible to reach `pair2` network from `pair3` and vice versa. The best way to check that is to use the `route exec` command.

```console
$ route -nT2 exec ping -c 3 172.31.255.254
PING 172.31.255.254 (172.31.255.254): 56 data bytes
64 bytes from 172.31.255.254: icmp_seq=0 ttl=255 time=0.615 ms
64 bytes from 172.31.255.254: icmp_seq=1 ttl=255 time=0.369 ms
64 bytes from 172.31.255.254: icmp_seq=2 ttl=255 time=0.382 ms

--- 172.31.255.254 ping statistics ---
3 packets transmitted, 3 packets received, 0.0% packet loss
round-trip min/avg/max/std-dev = 0.369/0.455/0.615/0.113 ms

$ route -nT3 exec ping -c3 172.31.255.253
PING 172.31.255.253 (172.31.255.253): 56 data bytes
64 bytes from 172.31.255.253: icmp_seq=0 ttl=255 time=0.352 ms
64 bytes from 172.31.255.253: icmp_seq=1 ttl=255 time=0.364 ms
64 bytes from 172.31.255.253: icmp_seq=2 ttl=255 time=0.378 ms

--- 172.31.255.253 ping statistics ---
3 packets transmitted, 3 packets received, 0.0% packet loss
round-trip min/avg/max/std-dev = 0.352/0.364/0.378/0.011 ms

$ route -nT3 exec ping -c1 10.0.0.1
PING 10.0.0.1 (10.0.0.1): 56 data bytes
ping: sendmsg: Can't assign requested address
ping: wrote 10.0.0.1 64 chars, ret=-1
```

The `10.0.0.1/24` and `10.0.1.0/24` networks are not reachable yet, because no routes have been configured. Let fix that.

```console
$ doas route -nT2 add 10.0.1.0/24 172.31.255.254
add net 10.0.1.0/24: gateway 172.31.255.254

$ netstat -rnfinet -T2
Routing tables

Internet:
Destination        Gateway            Flags   Refs      Use   Mtu  Prio Iface
10.0.0/24          10.0.0.1           UCn        0        0     -     4 vether2
10.0.0.1           fe:e1:ba:d9:1b:6c  UHLl       0        8     -     1 vether2
10.0.0.255         10.0.0.1           UHb        0        0     -     1 vether2
10.0.1/24          172.31.255.254     UGS        0        0     -     8 pair2
127.0.0.1          127.0.0.1          UHl        0        0 32768     1 lo2
172.31.255.252/30  172.31.255.253     UCn        1        0     -     4 pair2
172.31.255.253     fe:e1:ba:de:a4:28  UHLl       0       10     -     1 pair2
172.31.255.254     fe:e1:ba:df:34:e5  UHLch      1       13     -     3 pair2
172.31.255.255     172.31.255.253     UHb        0        0     -     1 pair2
```

```console
$ doas route -nT3 add 10.0.0.0/24 172.31.255.253
add net 10.0.0.0/24: gateway 172.31.255.253

$ netstat -rnfinet -T3
Routing tables

Internet:
Destination        Gateway            Flags   Refs      Use   Mtu  Prio Iface
10.0.0/24          172.31.255.253     UGS        0        2     -     8 pair3
10.0.1/24          10.0.1.1           UCn        0        0     -     4 vether3
10.0.1.1           fe:e1:ba:da:b5:73  UHLl       0        0     -     1 vether3
10.0.1.255         10.0.1.1           UHb        0        0     -     1 vether3
127.0.0.1          127.0.0.1          UHl        0        0 32768     1 lo3
172.31.255.252/30  172.31.255.254     UCn        1        0     -     4 pair3
172.31.255.253     fe:e1:ba:de:a4:28  UHLch      1        7     -     3 pair3
172.31.255.254     fe:e1:ba:df:34:e5  UHLl       0       14     -     1 pair3
172.31.255.255     172.31.255.254     UHb        0        0     -     1 pair3
```

After having added these routes, both network are available.

```console
$ route -nT3 exec ping -c3 10.0.0.1
PING 10.0.0.1 (10.0.0.1): 56 data bytes
64 bytes from 10.0.0.1: icmp_seq=0 ttl=255 time=0.476 ms
64 bytes from 10.0.0.1: icmp_seq=1 ttl=255 time=0.371 ms
64 bytes from 10.0.0.1: icmp_seq=2 ttl=255 time=0.272 ms

--- 10.0.0.1 ping statistics ---
3 packets transmitted, 3 packets received, 0.0% packet loss
round-trip min/avg/max/std-dev = 0.272/0.373/0.476/0.083 ms

$ route -nT2 exec ping -c3 10.0.1.1
PING 10.0.1.1 (10.0.1.1): 56 data bytes
64 bytes from 10.0.1.1: icmp_seq=0 ttl=255 time=0.477 ms
64 bytes from 10.0.1.1: icmp_seq=1 ttl=255 time=0.355 ms
64 bytes from 10.0.1.1: icmp_seq=2 ttl=255 time=0.271 ms

--- 10.0.1.1 ping statistics ---
3 packets transmitted, 3 packets received, 0.0% packet loss
round-trip min/avg/max/std-dev = 0.271/0.368/0.477/0.085 ms
```

Managing one or two `rdomain` can easily be done with packet-filter, but if you have more than that, it could become rapidly a complex task. While looking for more examples and use cases from the *BSD users, many authors were recommending using [packet-filter anchors](https://man.openbsd.org/pf.conf#ANCHORS) to make the configuration easier to understand and to control. Let check that, if you don't know, packet-filter configuration file is located in `/etc/pf.conf`, but before editing this file, two new `pflog` interfaces will be required to log the packets from these domains.

```console
$ doas ifconfig pflog2 create up

$ doas ifconfig pflog3 create up
```

The `rdomain 2` ruleset will be managed by the `rd2` anchor and the `rdomain 3` will be managed by the `rd3` anchor. Both of them will only have one rule for now, to log all packets in transit respectively to `pflog2` and `pflog3` pseudo interfaces.

```config
anchor "rd2" on rdomain 2 {
  match log (all, to pflog2)
}

anchor "rd3" on rdomain 3 {
  match log (all, to pflog3)
}
```

```console
$ doas pfctl -f /etc/pf.conf
```

This is another great feature available by default with packet-filter, instead of having text logs output, the typical logs messages when using [`iptables`](https://manpages.debian.org/trixie/iptables/iptables.8.en.html) or [`nftables`](https://manpages.debian.org/trixie/nftables/nftables.8.en.html) on Linux systems, the packets are directly duplicated to a dedicated interfaces, compatible with [`tcpdump`](https://man.openbsd.org/tcpdump) and giving us the possibility to export them in PCAP format.

```console
$ doas tcpdump -i pflog2
tcpdump: listening on pflog2, link-type PFLOG
13:49:03.419153 172.31.255.253 > 10.0.1.1: icmp: echo request
13:49:03.419380 10.0.1.1 > 172.31.255.253: icmp: echo reply
```

```console
$ doas tcpdump -i pflog3
tcpdump: listening on pflog3, link-type PFLOG
13:49:03.419267 172.31.255.253 > 10.0.1.1: icmp: echo request
13:49:03.419330 10.0.1.1 > 172.31.255.253: icmp: echo reply
```

The packets displayed in the `tcpdump` output have been generated by a simple `ping` command. As you can see, we have know a way to understand more deeply what can happen on each `rdomain` previously created.

```console
$ route -nT2 exec ping -c1 10.0.1.1
PING 10.0.1.1 (10.0.1.1): 56 data bytes
64 bytes from 10.0.1.1: icmp_seq=0 ttl=255 time=0.479 ms

--- 10.0.1.1 ping statistics ---
1 packets transmitted, 1 packets received, 0.0% packet loss
round-trip min/avg/max/std-dev = 0.479/0.479/0.479/0.000 ms
```

One question to ask is if it is possible to forward packets from one `rdomain` to another via packet-filter. Indeed, the configuration support `on rdomain NUMBER` and `rtable NUMBER` parameters, so, it should be possible to achieve. To test this the `pair` interfaces previously created must be destroyed.

```console
$ doas ifconfig pair2 destroy

$ doas ifconfig pair3 destroy
```

Be sure the loopback interfaces (`lo2` and `lo3` in this example) are not skipped, the firewall must have the control on all traffic on these `rdomain`s. When an ICMP packet is sent on `rdomain 2`, it will be redirected to `rdomain 3`. 

```config
anchor "rd2" on rdomain 2 {
  match log (all, to pflog2)
  pass out inet proto icmp \
    to 10.0.0.1 \
    rtable 3 \
    rdr-to 10.0.1.1
}

anchor "rd3" on rdomain 3 {
  match log (all, to pflog3)
}
```

```console
$ doas pfctl -f /etc/pf.conf
```

```console
$ route -nT2 exec ping -c 1 10.0.0.1
PING 10.0.0.1 (10.0.0.1): 56 data bytes
...
```

```console
$ doas tcpdump -i pflog2
14:17:19.787826 10.0.0.1 > 10.0.0.1: icmp: echo request
```

```console
$ doas tcpdump -i pflog3
14:17:19.788009 10.0.0.1 > 10.0.1.1: icmp: echo request
```

Without a route to ` 10.0.1.1/24`, previously removed alongside the `pair` interfaces, it fails. Packet-filter will do the redirection anyway because it can switch from different routing tables and domains. It means the packet from `10.0.0.1` is correctly forwarded to the `10.0.1.1` address. Unfortunately, `10.0.1.1` can't reply to `10.0.0.1` because it does not have it in its own table. ICMP is perhaps not the best protocol to do those kind of redirection because it is stateless, and it can become very complex to manage the redirection. It is possible to generate an ICMP reply quite easily though, even without a correct routing table.

```config
anchor "rd2" on rdomain 2 {
  match log (all, to pflog2)
  pass out inet proto icmp \
    to 10.0.0.1 \
    icmp-type echoreq \
    rtable 3 \
    rdr-to 10.0.1.1
}

anchor "rd3" on rdomain 3 {
  match log (all, to pflog3)
  pass in inet proto icmp \
    from 10.0.0.1 to 10.0.1.1 \
    icmp-type echoreq \
    rtable 2 \
    rdr-to 10.0.0.1
}
```

```console
$ route -nT2 exec ping -c 1 10.0.0.1
PING 10.0.0.1 (10.0.0.1): 56 data bytes
```

```console
$ doas tcpdump -i pflog2
14:55:06.725461 10.0.0.1 > 10.0.0.1: icmp: echo request
```

```console
$ doas tcpdump -i pflog3
14:55:06.725640 10.0.0.1 > 10.0.1.1: icmp: echo request
14:55:06.725780 10.0.1.1 > 10.0.0.1: icmp: echo reply
```

With this last example, it is possible to redirect a packet from one `rdomain` to another, but it is probably not the best idea to that in this way, because the rules will become quickly hard to understand. Regarding the anchors, one can also use another alternative syntax by passing the `rdomain` to each rules, like the code snippet below.

```config
match log (all, to pflog2) on rdomain 2
pass out on rdomain 2 inet proto icmp \
  to 10.0.0.1 \
  icmp-type echoreq \
  rtable 3 \
  rdr-to 10.0.1.1
```

# VPN Server Configuration

The VPN server will act as the default router for the workers present behind the firewall they are connected to. This server is already quite busy, many services like OpenVPN, Tinc, and few others are already present and running. The private network attributed to all those services were taken randomly, and it's a small mess. To avoid confusion, only the rules for the VPN using Wireguard will be presented, in their own `rdomain`.

```console
$ doas ifconfig lo1 create rdomain 1 alias 127.0.0.1 up

$ cat | doas tee /etc/hostname.lo1 < EOF
rdomain 1
alias 127.0.0.1
up
EOF
```

Because `rdomain 1` is totally isolated from `rdomain 0` where the `vio0` interface is present, it is necessary to create an interconnection network between them. The best way is to create 2 `pair` interfaces. The subnet will be set to `10.255.255.250/30`. `pair0` will stay in `rdomain 0`, and will give knowledge to the routes available on `rdomain 1`.

```console
$ doas ifconfig pair0 create rdomain 0 up

$ cat | doas tee /etc/hostname.pair0 < EOF
inet 10.255.255.253/30
patch pair1
up
!route add 172.17.0.0/24 10.255.255.254
!route add 172.16.0.0/24 10.255.255.254
EOF
```

`pair1` will be pushed in `rdomain 1` and like `pair0`, it will announce the route available on its side.

```console
$ doas ifconfig pair1 create rdomain 1 up

$ cat | doas tee /etc/hostname.pair1 < EOF
rdomain 1
inet 10.255.255.254/30
up
!route -T1 add default 10.255.255.253
EOF
```

With this pseudo interface configured, it is now possible to reach the network(s) present in `rdomain 1`. Let configures the VPN with a wireguard pseudo interface. The following snippet hides the private information to avoid leaks, but the idea is quite simple.

1. generate a private key using `openssl` from a random integer encoded in base64;

2. use a new random port (let say it will be 12345 for the rest of the configuration) using `openssl` as well;

3. add the public key from the firewall (it will be shown in the next part)

4. configure the end-point, in our case, it will be the public address of my firewall, let say 1.2.3.4 for now;

5. creates the `wg0` interface using `ifconfig` containing the previously created parameters. Set also the `wgaip` to explicitly allow the IP address from the firewall;

6. finally, create the `/etc/hostname.wg0` file containing the very same information to recreate automatically the VPN after a reboot.

```console
$ server_wgkey=$(openssl rand -base64 32)

$ server_wgport=$(printf "%d\n" "0x$(openssl rand -hex 2)")

$ server_wgpeer="${firewall_public_key}"

$ server_wgendpoint="${firewall_ip_address}"

$ doas ifconfig wg0 create wgport ${server_wgport} \
  wgkey ${server_wgkey} \
  wgpeer ${server_wgpeer} \
  wgaip 172.17.0.2/32 \
  wgaip 172.16.0.0/24 \
  wgendpoint ${server_wgendpoint} \
  172.17.0.1/24 \
  rdomain 1 \
  up

$ cat | doas tee /etc/hostname.wg0 < EOF
wgport ${server_wgport} wgkey ${server_wgkey}
wgpeer ${server_wgpeer} wgaip 172.17.0.2/32 wgaip 172.16.0.0/24
wgendpoint ${server_wgendpoint}
172.17.0.1/24
rdomain 1
up
!route -T1 add 172.16.0.0/24 172.17.0.2
EOF
```

Having a dedicated `pflog` interface for this `rdomain` can also be helpful, so, one can create the `pflog1` interface.

```console
$ doas ifconfig pflog1 create up

$ cat | doas tee /etc/hostname.pflog1 < EOF
up
EOF
```

The configuration is practically over, packet-filter configuration will be the last step. The first part of this configuration will ensure the packets from the VPN are correctly translated to the public address set on the `vio0` interface. In short, addresses from the worker network will use the public address of this server.

```config
match out on rdomain 0 \
  from 10.255.255.253/28 \
  nat-to (vio0) static-port

match out on rdomain 1 \
  from 172.17.0.0/24 \
  rtable 0 \
  nat-to (vio0) static-port

match out on rdomain 1 \
  from 172.16.0.0/24 \
  rtable 0 \
  nat-to (vio0) static-port
```

DNS resolution can be a problem, and to avoid DNS leaks, all packets from the worker network will be redirected to a local `unbound` instance, in charge of doing the domain resolution. It will also be easier to see what kind of queries are sent to domain servers and to filter them in one place.

```config
match in log (to pflog1) on rdomain 1 \
  proto {tcp, udp} \
  to port 53 \
  rtable 0 \
  rdr-to 127.0.0.1
```

Packet-filter is blocking all traffic by default. Wireguard needs to have its port accessible to other nodes though, then, the port previously create will be opened.

```config
pass in on vio0 proto udp \
  to port 12345 \
  label "wireguard vpn"
```

Finally, the last rules are only for `rdomain 1`. All packets are blocked and logged by default in this `rdomain`. ICMP and few TCP ports are allowed though, for SSH, HTTP and HTTPS.

```config
anchor "workers" on rdomain 1 {
  block log (to pflog1)
  pass inet proto icmp
  pass inet proto tcp to port {22, 80, 443} keep state
}
```

Packet-filter configuration can be reloaded or restarted.

```console
$ doas pfctl -nf /etc/pf.conf

$ doas pfctl -f /etc/pf.conf
```

With this configuration, any nodes connected to wireguard will use the IP address of the server instead of their own (or the IP address of their routers). Especially useful if your workers are running in private place and you don't want to share your real IP address to Gitlab (or any other provider).

Fixing the right access to the hostname.if files can also be a good idea.

```console
$ doas chmod 600 /etc/hostname.*
```

# Firewall Configuration

The firewall will be way easier to configure, the process will be similar than the one for the server. At first, creating a loopback interface for `rdomain 1` can help.

```console
$ cat | doas tee /etc/hostname.lo1 < EOF
rdomain 1
alias 127.0.0.1
up
EOF
```

The main physical interface called `re1` will be put in `rdomain 1`, and will not be configured. The IP address will be set on a `vether` pseudo interface created during the next step.

```console
$ cat | doas tee /etc/hostname.re1 < EOF
rdomain 1
up
EOF
```

`vether0` is the main interface for `rdomain 1`. It is the gateway for the workers' network and will be put in `rdomain 1`.

```console
$ cat | doas tee /etc/hostname.vether0 < EOF
rdomain 1
inet 172.16.0.1/24
up
EOF
```

A bridge called `bridge0` will be used to interconnect `vether0` and `re1`, and will be put also in `rdomain 1`.

```console
$ cat | doas tee /etc/hostname.bridge0 < EOF
add vether0
add re1
rdomain 1
up
EOF
```

My private network should have access to the workers' network, for monitoring and maintenance purpose. The workers will not be allowed to pass there though, this rule will be enforced in packet filter. Anyway, a small interconnection network will be created and set on `pair0`.

```console
$ cat | doas tee /etc/hostname.pair0 < EOF
inet 10.255.255.253/30
rdomain 0
patch pair1
up
!route add 172.16.0/24 10.255.255.254
EOF
```

`pair1` will also be created and connected to `pair0`. This time, `pair1` will be put in `rdomain 1`.

```console
$ cat | doas tee /etc/hostname.pair1 < EOF
inet 10.255.255.254/30
rdomain 1
up
!route -T1 add ${local_private_network} 10.255.255.253
EOF
```

A wireguard `wg0` speudo interface is also required to connect the firewall to the VPN. The procedure is the very same than before, except the information are created for the firewall this time, and not for the server. `wgaip` parameter is also set to `0.0.0.0/0` to allow any network to pass through the VPN, very useful if the VPN will be set as default gateway.

```console
$ fw_wgkey=$(openssl rand -base64 32)

$ fw_wgport=$(printf "%d\n" "0x$(openssl rand -hex 2)")

$ fw_wgpeer="${server_public_key}"

$ fw_wgendpoint="${server_ip_address}"

$ cat | doas tee /etc/hostname.wg0 < EOF
wgport ${fw_wgport} wgkey ${server_wgkey}
wgpeer ${fw_wgpeer} wgaip 0.0.0.0/0
wgendpoint ${server_wgendpoint}
172.17.0.2/24
rdomain 1
up
!route -T1 add default 172.17.0.1
EOF
```

Finally, the packet-filter configuration present in `/etc/pf.conf`. The first part defines the macros. Classic.

```config
worker_if = "{ re1, bridge0, vether0 }"
worker_network = "172.16.0.0/24"
worker_gateway = "172.16.0.1
```

To avoid leaks, all packets from the workers' network will be dropped and not allowed to pass through the outgoing interface `re0`. This is probably not necessary here, because in the full configuration a `block log` is also present, and should block these connections.

```config
block drop log \
  on $worker_if \
  from $worker_network \
  to (re0)
```

The connections from the private network (here set to `! $worker_network` but it could be set with a network) are allowed to reach the workers' network with a small subset of protocols, including ICMP, SSH, HTTP and HTTPS.

```config
pass on pair inet proto icmp \
  from ! $worker_network \
  to $worker_network

pass on pair inet proto tcp \
  from ! $worker_network \
  to $worker_network port {22, 80, 443}
```

Finally, the core configuration for `rdomain 1` contains the rules filter the connections for the workers:

1. an explicit `block` is redefined, so, by default, everything is blocked;

2. the private network is allowed to use SSH, HTTP and HTTPS in the workers' network;

3. the workers are allowed to use ICMP

4. the workers are allowed to use SSH, HTTP and HTTPS;

5. only worker nodes are allowed to use `bridge0`;

6. only worker nodes are allowed to use `wg0`;

7. workers nodes have the right to connect to the gateway via HTTP;

8. all DNS queries are forwarded automatically to the VPN via the VPN gateway (`172.17.0.1`);

9. NTP connections are locally forwarded to an instance of `ntpd` running on the firewall.

```config
anchor "workers" on rdomain 1 {
  block log (to pflog1)

  pass inet proto tcp \
    from ! $worker_network \
    to $worker_network port {22, 80, 443}

  pass inet proto icmp

  pass inet proto tcp \
    from $worker_network \
    to port {22, 80, 443} \
    keep state

  pass on bridge0 \
    from $worker_network

  pass on wg0 \
    from $worker_network

  pass inet proto tcp \
    from $worker_network \
    to $worker_gateway port 80

  pass in inet proto {tcp, udp} \
    from 172.16.0.0/24 \
    to port domain rdr-to 172.17.0.1

  pass in inet proto udp \
    from 172.16.0.0/24 \
    to port ntp \
    rtable 0 \
    rdr-to 127.0.0.1
}
```

Let fix the access rights on the files previously created.

```console
$ doas chmod 600 /etc/hostname.* /etc/pf.conf
```

The network can be started or restarted. If other interfaces are configured, it is also possible to start them one by one or by giving a list of them as parameters for the `netstart` script.

```console
$ doas sh /etc/netstart
```

If everything looks good... Packet filter can be restarted.

```console
$ doas pfctl -nf /etc/pf.conf

$ doas pfctl -f /etc/pf.conf
```

The firewall should now be connected to the server using wireguard. Let check that with a simple ping to `openbsd.org`. Unfortunately, because `lo1` has been created and set with `127.0.0.1`, it is not possible to resolve a domain name locally on this firewall, but, it is still possible to use any other ip addresses. Indeed, a redirection is done on the VPN side, and any connections to DNS are forwarded on a local `unbound` instance. Let's try that.

```console
$ route -nT1 exec dig @1.2.3.4 google.fr +short
142.251.142.195

$ route -nT1 exec ping -c3 142.251.142.195
PING 142.251.142.195 (142.251.142.195): 56 data bytes
64 bytes from 142.251.142.195: icmp_seq=0 ttl=118 time=24.746 ms
64 bytes from 142.251.142.195: icmp_seq=1 ttl=118 time=25.723 ms
64 bytes from 142.251.142.195: icmp_seq=2 ttl=118 time=25.193 ms

--- 142.251.142.195 ping statistics ---
3 packets transmitted, 3 packets received, 0.0% packet loss
round-trip min/avg/max/std-dev = 24.746/25.221/25.723/0.399 ms

$ route -nT1 exec nc -zv 142.251.142.195 80
Connection to 142.251.142.195 80 port [tcp/www] succeeded!

$ route -nT1 exec nc -zv 142.251.142.195 443
Connection to 142.251.142.195 443 port [tcp/https] succeeded!
```

It seems the firewall is correctly using the VPN and the packets are correctly routed to some public IP addresses. To be sure, one can also use `tcpdump` to see what's happening on `wg0`.

```console
$ tcpdump -ni wg0
tcpdump: listening on wg0, link-type LOOP
14:51:40.154762 172.17.0.2.31538 > 142.251.142.195.443: SWE 4156193580:4156193580(0) win 16384 <mss 1452,nop,nop,sackOK,nop,wscale 6,nop,nop,timestamp 2865047363 0> (DF)
14:51:40.180844 142.251.142.195.443 > 172.17.0.2.31538: S 1448631416:1448631416(0) ack 4156193581 win 65535 <mss 1412,sackOK,timestamp 728224899 2865047363,nop,wscale 8> (DF) [tos 0x80]
14:51:40.180995 172.17.0.2.31538 > 142.251.142.195.443: . ack 1 win 256 <nop,nop,timestamp 2865047383 728224899> (DF)
14:51:40.182406 172.17.0.2.31538 > 142.251.142.195.443: F 1:1(0) ack 1 win 256 <nop,nop,timestamp 2865047383 728224899> (DF)
14:51:40.206851 142.251.142.195.443 > 172.17.0.2.31538: F 1:1(0) ack 2 win 1050 <nop,nop,timestamp 728224925 2865047383> [tos 0x80]
14:51:40.207024 172.17.0.2.31538 > 142.251.142.195.443: . ack 2 win 256 <nop,nop,timestamp 2865047413 728224925> (DF)
14:51:40.987301 172.16.0.2.48148 > 172.65.251.78.443: . ack 2499027552 win 78 <nop,nop,timestamp 674758452 2705939126>
14:51:41.013134 172.65.251.78.443 > 172.16.0.2.48148: . ack 1 win 19 <nop,nop,timestamp 2705969587 674743439> (DF)
14:51:41.333030 172.65.251.78.443 > 172.16.0.2.48148: . ack 1 win 19 <nop,nop,timestamp 2705969908 674743439> (DF)
14:51:41.334165 172.16.0.2.48148 > 172.65.251.78.443: . ack 1 win 78 <nop,nop,timestamp 674758799 2705969587>
14:51:42.840018 172.65.251.78.443 > 172.16.0.3.40668: . ack 1758166881 win 16 <nop,nop,timestamp 2453064192 1968171036> (DF)
14:51:42.840607 172.16.0.3.40668 > 172.65.251.78.443: . ack 1 win 78 <nop,nop,timestamp 1968186512 2453048737>
```

It is now confirmed, the traffic is going into the VPN!

# Workers Configuration

The last part of this infrastructure is directly related to the "workers". Those workers will host gitlab-runners and probably other services like `podman` or even `k3s` to build, test and release my own private application locally. Those servers are old laptops, and other small devices connected in their dedicated switch, behind the firewall. Most of them will use Alpine Linux. So, first, the network configuration.

```console
$ cat | doas tee /etc/network/interfaces < EOF
auto lo
iface lo inet loopback

auto eth0
        address 172.16.0.2/24
        network 172.16.0.0
        broadcast 172.16.0.255
        gateway 172.16.0.1
EOF
```

To apply the configuration, simple invoke the `service` command.

```console
$ doas service networking restart
```

Then the `dnsmasq` configuration, in the previous article, it was used to worked the domain name requests to the Tor DNS service. In this case, it will be used to forward the requests to the gateway, then the gateway will forward them to the VPN.

```console
$ cat | doas tee /etc/dnsmasq.conf < EOF
no-resolv
server=172.16.0.1
local-service
listen-address=127.0.0.1
conf-dir=/etc/dnsmasq.d/,*.conf
EOF
```

Be sure `dnsmasq` is started during boot and start the service if it's not already done.

```console
$ doas rc-update add dnsmasq default

$ doas service dnsmasq start
```

Ensure `/etc/resolv.conf` is correctly configured to ask `dnsmasq`.

```console
$ cat | doas tee /etc/resolv.conf < EOF
nameserver 127.0.0.1
EOF
```

Voilà. A worker is configured! The idea was to have something really simple on this side to deploy many workers when needed. The `dnsmasq` is a bonus, because simply configuring the `/etc/resolv.conf` would have been way enough.

# Testing

One of the most important section of this article... Testing the configuration from the workers point of view. First, the DNS resolution is mandatory and must work. Checked.

```console
$ dig +short openbsd.org
199.185.178.80
```

All packets must be forwarded through the VPN and not locally. As one can see, the packets are passing to the gateway, then, to the VPN and go out from the server (the IP addresse(s) have been replaced by `x.x.x.x`). Checked.

```console
$ traceroute openbsd.org -nI
traceroute to openbsd.org (199.185.178.80), 30 hops max, 46 byte packets
 1  172.16.0.1  0.591 ms  0.179 ms  0.434 ms
 2  172.17.0.1  24.231 ms  25.197 ms  24.946 ms
 3  x.x.x.x  25.732 ms  26.328 ms  28.007 ms
 4  x.x.x.y  24.522 ms  26.557 ms  25.837 ms
 5  x.x.y.z  25.012 ms  24.913 ms  25.359 ms
 6  80.249.213.240  26.202 ms  26.065 ms  31.208 ms
 7  64.125.20.28  145.869 ms  *  146.492 ms
 8  64.125.29.184  145.833 ms  145.111 ms  146.056 ms
 9  *  64.125.31.110  146.041 ms  *
10  *  *  *
11  *  *  *
12  64.125.30.199  147.083 ms  145.227 ms  145.968 ms
13  64.125.31.158  145.922 ms  146.089 ms  146.342 ms
14  64.125.18.179  145.466 ms  145.984 ms  145.082 ms
15  64.125.18.180  148.951 ms  147.816 ms  146.111 ms
16  64.125.18.210  145.243 ms  146.458 ms  146.015 ms
17  208.185.75.98  146.226 ms  146.872 ms  146.485 ms
18  204.209.252.4  146.952 ms  148.495 ms  147.707 ms
19  199.185.230.2  147.111 ms  147.041 ms  147.363 ms
20  199.185.178.80  145.313 ms  144.660 ms  145.852 m
```

HTTP connections should work. It can be verified with `nc`. Checked.

```console
$ nc -zv openbsd.org 80
Connection to openbsd.org (199.185.178.80) 80 port [tcp/http] succeeded!
```

HTTPS connections must work. This one is important because some repository will be cloned using HTTPS. Checked.

```console
$ nc -zv openbsd.org 443
Connection to openbsd.org (199.185.178.80) 443 port [tcp/https] succeeded!
```

Another important service to check is SSH. Most of the repositories are using Git over SSH, usually listening on port TCP/22 by default. The workers must have access to that as well. Checked!

```console
$ nc -zv ftp.eu.openbsd.org 22
Connection to ftp.eu.openbsd.org (193.156.13.178) 22 port [tcp/ssh] succeeded!
```

Finally, let check if Alpine Linux can be updated and upgraded... Checked!

```console
$ doas apk update
v3.23.7-30-g7a9ffafb21a [https://mirror.leaseweb.com/alpine/v3.23/main]
v3.23.7-29-gecf474a05c5 [https://mirror.leaseweb.com/alpine/v3.23/community]
OK: 27586 distinct packages available

$ doas apk upgrade
OK: 1146.9 MiB in 302 packages
```

My own local workers/builders infrastructure is now running behind a firewall and a VPN. The IP address seen by gitlab is not the one from my place, but from another server.

# Troubleshooting and Improvements

Managing `rdomain` can become very complex, and one must be disciplined to manage packet-filter rules but also the pseudo devices created. `tcpdump` will be the best tool to investigate a routing issue and will quickly give an idea of the root cause. `route` and `netstat` commands will also be really useful to inspect the state of the network stack. Finally, creating `pflog` interfaces to log and follow the packet flow will also be of a great help.

Another point to improve in this design is about trusting the traffic. The workers will use gitlab-runners, and based on the news, supply-chain attacks or 0days are kinda dangerous. The previous configuration using Tor was interesting because a proxy was required. In the current situation an HTTP proxy would have been a good idea to deploy, to filter and log all outgoing connections. A bastion for ssh (or an ssh proxy) would have been great as well. Indeed, to avoid an attack, restricting the access to a small subset of allowed IP addresses or domains is the bare minimum.

# Conclusion

Coming back to my roots was pretty great. Configuring VPN, routes and other kind of network stuff on OpenBSD is always a fun experience. `rdomain` is a furtive technology mostly known by some OpenBSD wizards and other hardcore system/network administrators. The number of publications on this topic is pretty low, but the OpenBSD documentation is here to save our life.

Anyway, `rdomain` is a great tool to isolate networks and avoid leaks. Configuring it correctly can be challenging though, and testing it is also another layer of complexity, but the result is - as usual with OpenBSD - rock solid. This article is already huge, and having a list of resources/references can also probably help you to deal with all of that.

- The [**`rdomain(4)`**](https://man.openbsd.org/rdomain.4) man page, explaining how `rdomain` is working with few examples;

- The [**`pfctl(8)`**](https://man.openbsd.org/pfctl) command man page, where you will find how to use `pfctl`, mainly to reload the firewall rules;

- The [**`pf.conf(5)`**](https://man.openbsd.org/pf.conf) configuration page man page, where you will find more about `rdomain` and `rtable`;

- The [**`route(8)`**](https://man.openbsd.org/route) command mange page, where you will learn how to use the `route` command to switch between `rdomain`s;

- The [**`netstart(8)`**](https://man.openbsd.org/netstart) script man page, to restart/reload interfaces;

- The [**`hostname.if(5)`**](https://man.openbsd.org/hostname.if) configuration file man page, where the configuration of the interfaces will be stored;

- The [**`wg(4)`**](https://man.openbsd.org/wg) pseudo device man page, where you will find more information about how to create, configure and maintain a wireguard interface;

- The [**`pair(4)`**](https://man.openbsd.org/pair) pseudo device man page, where you will understand how to use `pair` to connect different `rdomain` together;

- The [**`vether(4)`**](https://man.openbsd.org/vether.4) pseudo device man page, where you will learn how to use the virtual ethernet interface;

- The [**`bridge(4)`**](https://man.openbsd.org/bridge.4) pseudo device man page, useful to link many interfaces together;

- The [**`ifconfig(8)`**](https://man.openbsd.org/ifconfig) command man page, to deal with the pseudo devices and network interfaces;

- The [**`pflog(4)`**](https://man.openbsd.org/pflog) pseudo interface man page to see what kind of data one can collect and how to use it with [`tcpdump`](https://man.openbsd.org/tcpdump);

- [**Implementing Routing Domains on an OpenBSD workstation for use with WireGuard**](https://indico.bsdcan.org/event/1/contributions/31/attachments/7/7/wg.pdf) talk presented in 2024, with the recording available on [youtube](https://www.youtube.com/watch?v=ipbPcNXeDj4&pp=ygVNSW1wbGVtZW50aW5nIFJvdXRpbmcgRG9tYWlucyBvbiBhbiBPcGVuQlNEIHdvcmtzdGF0aW9uIGZvciB1c2Ugd2l0aCBXaXJlR3VhcmQ%3D);

- [**Introduction to global anycast using OpenBSD (on a budget)**](https://thelongcon.ca/slides/2024/Robert%20Keizer%20-%20Introduction%20to%20global%20anycast%20using%20OpenBSD%20(on%20a%20budget)%20-%20The%20Long%20Con%202024.pdf) live streaming talk presented in 2024, with the recording available on [youtube](https://www.youtube.com/watch?v=JpxpjzUfQpg&pp=ygU6SW50cm9kdWN0aW9uIHRvIGdsb2JhbCBhbnljYXN0IHVzaW5nIE9wZW5CU0QgKG9uIGEgYnVkZ2V0KQ%3D%3D);

- [**Practical use of OpenBSD routing domains with redundant
firewalls**](https://www.openbsd.org/papers/eurobsdcon2023-matthieu-pf-rdomain.pdf) talk presented in 2023, with the recorded session available on [youtube](https://www.youtube.com/watch?v=c81bS9u1A6Q&pp=ygVBUHJhY3RpY2FsIHVzZSBvZiBPcGVuQlNEIHJvdXRpbmcgZG9tYWlucyB3aXRoIHJlZHVuZGFudCBmaXJld2FsbHM%3D);

- [**Installation de pare-feux redondants avec OpenBSD**](https://www.openbsd.org/papers/jres2021-matthieu-tuto-pf.pdf) talk slides presented in 2021 (but in French);

- [**Mininet on OpenBSD Using rdomains for Interactive SDN Testing and Development**](https://www.openbsd.org/papers/asiabsdcon2018-mininet-slides.pdf) talk presented in 2018, with the [youtube video](https://www.youtube.com/watch?v=Vg9Czjm9aV8&pp=ygVNTWluaW5ldCBvbiBPcGVuQlNEIFVzaW5nIHJkb21haW5zIGZvciBJbnRlcmFjdGl2ZSBTRE4gVGVzdGluZyBhbmQgRGV2ZWxvcG1lbnTSBwkJMgwBhyohjO8%3D) and its [paper](https://www.openbsd.org/papers/asiabsdcon2018-mininet-paper.pdf);

- [**pf+rdomains create splendid multi-tenancy firewalls**](https://www.bsdcan.org/2017/schedule/attachments/415_bsdcan2017-talk.pdf) talk presented in 2017, with the [youtube video](https://www.youtube.com/watch?v=5Cni50vnlto&pp=ygUzcGYrcmRvbWFpbnMgY3JlYXRlIHNwbGVuZGlkIG11bHRpLXRlbmFuY3kgZmlyZXdhbGxz0gcJCTIMAYcqIYzv);

- [**Branch VPN Solution with OpenBSD**](https://undeadly.org/features/2018/02/eurobsdcon2017-branch-vpn.pdf) talk slides presented in 2017;

- [**using routing domains/routing tables in a production network**](https://www.openbsd.org/papers/bsdcan2015-rdomains.pdf) talk slides presented in 2015;

- [**OpenBSD Routing Tables and Routing Domains**](https://www.unfriendlygrinch.info/posts/openbsd-routing-tables-and-routing-domains/) by the Unfriendly Grinch, offering a great `rdomain` usage example;

- [**Secure torrenting with OpenBSD rdomains**](https://insec.sh/secure-torrenting-with-openbsd-rdomains/), a post showing us how to isolate/secure torrenting using `rdomain`;

- [**OpenVPN on OpenBSD in its own rdomain to prevent data leak**](https://dataswamp.org/~solene/2021-12-16-openbsd-openvpn-exit.html), another post where `rdomain` is used with OpenVPN;

- [**Full WireGuard setup with OpenBSD**](https://dataswamp.org/~solene/2021-10-09-openbsd-wireguard-exit.html), probably one of the first post available on the web about wireguard and `rdomain` on OpenBSD;

- [**Configuring PF to route between routing domains**](https://serverfault.com/questions/821306/configuring-pf-to-route-between-routing-domains) on ServerFault;

- [**OpenBSD PF rdr-to across rdomains**](https://www.linuxquestions.org/questions/%2Absd-17/openbsd-pf-rdr-to-across-rdomains-4175657966/) on Linux Questions;

Happy hacking and have fun!

EDIT(20261103): adding a missing route in `/etc/hostname.wg0`

----

Cover Image by <a href="https://unsplash.com/@rafaelpeier?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Rafael Peier</a> on <a href="https://unsplash.com/photos/a-dead-pufferfish-lies-on-the-sandy-beach-FoVu-YEHj2Y?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>