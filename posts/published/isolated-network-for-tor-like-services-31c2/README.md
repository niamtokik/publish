---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/isolated-network-for-tor-like-services-31c2"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Fcaakc1dvzxkutwhjarnc.jpg"
created_at: "None"
crossposted_at: "None"
description: "The first part of my career in IT was to be network technician/administrator, configuring firewalls,..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/isolated-network-for-tor-like-services-31c2"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "isolated-network-for-tor-like-services-31c2"
social_image: "None"
title: "Isolated Network for Tor-like Services"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Isolated Network for Tor-like Services

The first part of my career in IT was to be network technician/administrator, configuring firewalls, routers and switches for companies. Since this time, few devices are always ready to do some interesting stuff related to network, one of them is a pretty old [pcengine apu2 firewall](https://pcengines.ch/apu2.htm) using the latest OpenBSD release. It was mostly a canary-like computer to check if everything was fine during an OpenBSD update/upgrade. Since one of my project is being entirely coded in Dart/Flutter, and because this language is not yet supported by OpenBSD, it would have been good to have a dedicated [CI/CD gitlab runner](https://docs.gitlab.com/runner/) running somewhere... Why not using an old laptop and isolating it behind this firewall?

# Configuring OpenBSD

My APU2 is having 3 Gigabit Ethernet port called `re0`, `re1`, and `re2`. All of them are using the [`re`](https://man.openbsd.org/re) driver. `re0` is the main interface with a direct connect to another router.

```console
$ doas cat /etc/hostname.re0
dhcp
inet6 autoconf
inet alias ${gateway_address}
up
```

`re1` is the interface where the server(s) hosting the worker(s) will be connected. Even if this interface will be used, it will not be set with an IP address but put in a bridge. All interfaces can be started using the [`netstart`](https://man.openbsd.org/netstart) script.

```console
$ doas cat /etc/hostname.re1
up

$ doas ksh /etc/netstart re1
```

A virtual interface [`vether`](https://man.openbsd.org/vether) will be created to deal with the private network dedicated for the workers.

```console
$ doas cat /etc/hostname.vether0
inet 172.16.0.1/24
up

$ doas ksh /etc/netstart vether0
```

[`bridge0`](https://man.openbsd.org/bridge) is also created to connect `re1` and `vether`. Based on the current configuration, a [`veb`](https://man.openbsd.org/veb.4) interface would have probably be also another correct choice.

```console
$ doas cat /etc/hostname.bridge0
destroy
add vether0
add re1
up

$ doas ksh /etc/netstart bridge0
```

The router configuration is ready. All workers will use `172.16.0.1` as default route, and packet filter will be in charge to filter which part of the traffic is right or not.

# Tor Bootstrapping

Tor is easy to install, but can be challenging to configure. Let install it first via [`pkg_add`](https://man.openbsd.org/pkg_add).

```console
$ doas pkg_add tor
```

The main Tor configuration is located in [`/etc/tor/torrc`](https://man.freebsd.org/cgi/man.cgi?query=tor) and also in `/etc/torrc.d/` directory. The first thing to configure is the DNS resolution to avoid leaks.

```console
$ doas touch /etc/torrc.d/dns.conf

$ echo "AutomapHostsOnResolve 1" \
  | doas tee /etc/torrc.d/dns.conf

$ echo "AutomapHostsSuffixes .exit,.onion" \
  | doas tee /etc/torrc.d/dns.conf
```

Then, because our workers will mostly be connected to servers in North America or Europe, it can be nice to define the geolocation of the exit nodes. In the following case, the workers will use exit nodes from USA, UK, Europe, and Japan.

```console
$ doas touch /etc/torrc.d/exit_nodes.conf

$ echo 'ExitNodes {us},{uk},{eu},{ez},{jp} StrictNodes 1' \
  | doas tee /etc/torrc.d/exit_nodes.conf
```

The last step is to allow Tor to listen on the correct interface, in this case, `re1` with the IP address `172.16.0.1`. A first instance will listen on TCP/9080 and allow only onion routing to the standard internet. A second instance will be dedicated for onion traffic only and will listen on TCP/9081. Both of them will be used as HTTP Proxies.

```console
$ cat | doas tee /etc/torrc.d/workers.conf << EOF
HTTPTunnelPort 172.16.0.1:9080 IsolateDestAddr IsolateDestPort NoOnionTraffic ClientUseIPv4
HTTPTunnelPort 172.16.0.1:9081 IsolateDestAddr IsolateDestPort OnionTrafficOnly ClientUseIPv4
EOF
```

Another instance will use a SOCK Proxy this time, and will listen on TCP/9050.

```console
$ cat | doas tee -a /etc/torrc.d/workers.conf << EOF
SOCKSPort 127.0.0.1:9050 IsolateDestAddr IsolateDestPort ClientUseIPv4 SafeSocks 1
EOF
```

Finally, all the DNS requests must be resolved via Tor and not any other kind of DNS to avoid DNS requests leaks. To do that, Tor will listen on TCP/9053 and will use its own DNS resolver.

```console
$ cat | doas tee -a /etc/torrc.d/workers.conf << EOF
DNSPort 172.16.0.1:9053
EOF
```

The configuration looks good. Let enable Tor via [`rcctl`](https://man.openbsd.org/rcctl)...

```console
$ doas rcctl enable tor
```

... And start it.

```console
$ doas rcctl start tor
```

Regarding this configuration, one could also configure packet filter to forward the packet directly to a Tor instance on the loopback interface, but it can make the firewall configuration a bit more complex. Another idea is to use another proxy server like Privoxy to do the relay.

# Packet Filter Configuration

Tor is ready, it should listen on the correct interface, but the firewall must be configure to avoid leaks. Let defines the macros first, to help us deal with the different parameters. Packet filter configuration is located in [`/etc/pf.conf`](https://man.openbsd.org/pf.conf).

```plaintext
tor_if = "{ re1, bridge0, vether0 }"
tor_network = "172.16.0.0/24"
tor_gateway = "172.16.0.1"
tor_proxy_ports = "{ 9050, 9080, 9081 }"
tor_dns = 9053
```

Using Tor can already be painful due to the speed of the connection, so, packet filter can be optimized a bit to win few milliseconds (sometimes). The loopback interface is also ignored, at this time, it's not necessary to filter packet from it.

```plaintext
set optimization aggressive
set skip on lo
```

Let configure the anti spoofing features and scrub all packets coming into the firewall.

```plaintext
antispoof for re0
antispoof for $tor_if
match in all scrub (no-df random-id)
```

The default rule is to drop everything. The next part of the configuration will allow only which packets are authorized to pass through the firewall.

```vcl
block drop log on re0 
block drop log on re0 from $tor_network
block drop log on $tor_if
```

Nobody wants to lose access to its firewall, then, the TCP/22 port (ssh) is explicitly authorized from the main interface (`re0`). All packets going out on this interface are also allowed. For debugging and maintenance purpose, ICMP and ICMPv6 protocols are allowed as well.

```plaintext
pass in quick on re0 proto tcp to port 22 
pass out quick on re0 keep state
pass on re0 proto icmp 
pass on re0 proto icmp6
```

Here the first part of the Tor firewall configuration. Firstly, to help see if the workers are up or down, ICMP are allowed only in one way, the workers are not allowed to send ICMP, but other servers and equipments from other part of the network are.

```plaintext
pass in proto icmp \
  from ! $tor_network \
  to $tor_network tag \
  tor_icmp
pass on $tor_if proto icmp \
  from $tor_network \
  to $tor_gateway \
  tag tor_icmp
pass on $tor_if proto icmp \
  from $tor_gateway \
  to $tor_network \
  tag tor_icmp
pass out proto icmp tagged tor_icmp
```

The workers are allowed to communicate between them. Indeed, it can be useful especially if the workers can share some data, or if a server is installed to cache the artifacts. A fine grained list of host can eventually be created here. The second rules explicitly block all packets coming from the Tor network to any other network different than this network. It means workers' packets will not be able to traverse the router.

```plaintext
pass on $tor_if inet proto tcp \
  from $tor_gateway \
  to $tor_network \
  keep state

pass on $tor_if inet proto tcp \
  from ! $tor_network \
  to $tor_network \
  keep state
```

When configuring a CI/CD, it always nice to have a correct time from all the workers, if possible returning an UTC timestamp. Unfortunately, bare-metal servers can slowly be inaccurate regarding their local time, and having access to an NTP server can be helpful. Instead of allowing all workers to connect directly to a remote NTP server, the firewall - in this case - will act as a relay. Indeed, an `ntpd` daemon will also listen on `re1` interface and will offer the correct time.

```plaintext
pass in on $tor_if inet proto udp \
  from $tor_network \
  to $tor_gateway port ntp \
  keep state
```

DNS is also another part of a network, but workers can't be allowed to request unknown server from internet. So, Tor has been previously configured to listen on port UDP/9053 for its DNS resolver. The workers must be able to reach this port and do the DNS resolution.

```plaintext
pass on $tor_if inet proto udp \
  from $tor_network \
  to $tor_gateway port $tor_dns \
  keep state
```

Finally, the Tor proxies are also allowed to receive the connections from the workers.

```plaintext
pass on $tor_if inet proto tcp \
  from $tor_network \
  to $tor_gateway port $tor_proxy_ports \
  keep state
```

A bonus step, because my configuration for the workers required some extra-data, the workers can also reach out the firewall on the port TCP/80 (HTTP) to fetch some kind of information. The firewall here will act as a simple HTTP server.

```plaintext
pass in on $tor_if inet proto tcp \
  from $tor_network \
  to $tor_gateway port http \
  keep state
```

Let check packet filter configuration to see if everything is correct with the help of [`pfctl`](https://man.openbsd.org/pfctl).

```console
$ doas pfctl -nf /etc/pf.conf
```

If all is good, the firewall can be started.

```console
$ doas pfctl -ef /etc/pf.conf
```

The configuration presents on my firewall is a bit more complex, but this one should work correctly.

# From the Workers

With the previous configuration, the workers are easily reachable by adding a static route from any other part of my network to the firewall.

```console
$ doas route add 172.16.0.0/24 ${gateway_ip}
add net 172.16.0.0/24: gateway ${gateway_ip}
```

From my laptop, the firewall interface for the Tor network is answering to the pings, that's a good sign.

```console
$ ping -c 3 172.16.0.1
PING 172.16.0.1 (172.16.0.1): 56 data bytes
64 bytes from 172.16.0.1: icmp_seq=0 ttl=255 time=2.865 ms
64 bytes from 172.16.0.1: icmp_seq=1 ttl=255 time=2.782 ms
64 bytes from 172.16.0.1: icmp_seq=2 ttl=255 time=1.974 ms

--- 172.16.0.1 ping statistics ---
3 packets transmitted, 3 packets received, 0.0% packet loss
round-trip min/avg/max/std-dev = 1.974/2.540/2.865/0.402 ms
```

It seems the worker present on the Tor network (running on alpine linux) is also answering to the pings.

```console
$ ping -c 3 172.16.0.2 
PING 172.16.0.2 (172.16.0.2): 56 data bytes
64 bytes from 172.16.0.2: icmp_seq=0 ttl=63 time=4.281 ms
64 bytes from 172.16.0.2: icmp_seq=1 ttl=63 time=3.336 ms
64 bytes from 172.16.0.2: icmp_seq=2 ttl=63 time=4.176 ms

--- 172.16.0.2 ping statistics ---
3 packets transmitted, 3 packets received, 0.0% packet loss
round-trip min/avg/max/std-dev = 3.336/3.931/4.281/0.423 ms
```

The TCP/22 port is working as well.

```console
$ nc -zv 172.16.0.2 22
Connection to 172.16.0.2 22 port [tcp/ssh] succeeded
```

This is the time to connect to this worker and check the firewall configuration.

```console
$ ssh 172.16.0.2
...
```

From the worker, it is possible to ping the default route `172.16.0.1` without problems.

```console
$ ping -c 3 172.16.0.1
PING 172.16.0.1 (172.16.0.1): 56 data bytes
64 bytes from 172.16.0.1: seq=0 ttl=42 time=0.617 ms
64 bytes from 172.16.0.1: seq=1 ttl=42 time=0.669 ms
64 bytes from 172.16.0.1: seq=2 ttl=42 time=0.758 ms

--- 172.16.0.1 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.617/0.681/0.758 ms
```

Public IP addresses, like `8.8.8.8` are not reachable, the firewall is blocking these packets.

```console
$ ping -c 3 8.8.8.8
PING 8.8.8.8 (8.8.8.8): 56 data bytes

--- 8.8.8.8 ping statistics ---
3 packets transmitted, 0 packets received, 100% packet loss
```

DNS resolution is important though, and all workers must have a local DNS server to use the Tor resolver. In this scenario, [`dnsmasq`](https://dnsmasq.org/doc.html) is used here.

```console
$ cat /etc/dnsmasq.conf
no-resolv
server=172.16.0.1#9053
local-service
listen-address=127.0.0.1
conf-dir=/etc/dnsmasq.d/,*.conf
```

Then, `/etc/resolv.conf` must be updated.

```console
$ cat /etc/resolv.conf 
nameserver 127.0.0.1
```

With this new configuration, workers are allowed to resolve domain names via the Tor network.

```console
$ host google.com
google.com has address 172.253.63.139
google.com has IPv6 address 2607:f8b0:4006:819::200e
Host google.com not found: 4(NOTIMP)
Host google.com not found: 4(NOTIMP)
```

All workers should also configure their environment with the correct proxies, usually `HTTP_PROXY` and `HTTPS_PROXY` variables.

```console
$ set | grep -i proxy
HTTPS_PROXY='http://172.16.0.1:9080'
HTTP_PROXY='http://172.16.0.1:9080'
http_proxy='http://172.16.0.1:9080'
https_proxy='http://172.16.0.1:9080'
```

[`curl`](https://curl.se/docs/manpage.html) is looking for those variables by default, and should use them. It can be checked by checking the public IP address used via [`api.ipify.org`](https://www.ipify.org/).

```console
$ curl https://api.ipify.org; echo
204.8.96.80
```

Indeed, it returns an IP address way different than the one configured on my main router.

# What About Privoxy?

Most of the time, [Privoxy](https://www.privoxy.org/) is configured alongside Tor to use it as relay. Indeed, privoxy is way more flexible than Tor itself and can offer a better control. In our case, it will not really be necessary to use it, because nothing will be filtered from the network where the workers are present. Only the firewall needs to be correctly configured to avoid data leaks.

# Conclusion

It was an interesting project, but not a really great idea in the end. Most of the tor exit-nodes are blocked by Google, even more, with the recent certificate issues, using a worker always connected to Gitlab to fetch the latest version through an untrusted highly-risky network is perhaps not the best thing to do right now. This idea can be improved though, and instead of using tor, one can create a VPN and force the server to use it instead of using your public IP address.

The same kind of configuration can also be used for the i2p services, it will perhaps be a bit different because i2p does not have an onion routing service... but it should work if one wants to force the workers or the servers connected to the network to only use i2p. Another cool stuff would be to create a server relay between tor and i2p.

A bigger article on Tor is planned, but it is a really huge one and take time to write it. This one is just a quick note regarding the configuration of the workers from my CI/CD infrastructure. Below a schema to help you understand how it works.

![Network Schema](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/3usfozbqh6lj97bkyy7e.png)

As usual, have fun and happy hacking!

----

Cover image by <a href="https://unsplash.com/@jorok?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Georgi Kalaydzhiev</a> on <a href="https://unsplash.com/photos/silhouette-of-person-looking-at-blurred-city-lights-at-night-fVmneYIIcc0?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>