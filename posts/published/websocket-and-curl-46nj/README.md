---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/websocket-and-curl-46nj"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fybrg88u5y1aisqtbq1sj.jpg"
created_at: "None"
crossposted_at: "None"
description: "In a previous publication I was talking about the lake of WebSocket support from curl, but it seems I..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/websocket-and-curl-46nj"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "websocket-and-curl-46nj"
social_image: "None"
title: "WebSocket and curl"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# WebSocket and curl

In a previous publication I was talking about the lake of WebSocket support from curl, but it seems I was not using the latest version at this time. I retried that with the [`8.20.0`](https://github.com/stunnel/static-curl/releases/tag/8.20.0) release after reading ["websocket in curl"](https://eissing.org/icing/posts/curl-websocket/) post by [Stefan Eissing](https://github.com/icing/). It's not "perfect" but it works like `netcat`.

The first step is to fetch/install the latest curl version for your system, at this time, the [`8.20.0` release](https://github.com/stunnel/static-curl/releases/tag/8.20.0)

```console
$ wget https://github.com/stunnel/static-curl/releases/download/8.20.0/curl-linux-x86_64-glibc-8.20.0.tar.xz
$ tar xvf curl-linux-x86_64-glibc-8.20.0.tar.xz
$ ./curl --version
curl 8.20.0 (x86_64-pc-linux-gnu) libcurl/8.20.0 OpenSSL/4.0.0 zlib/1.3.2 brotli/1.2.0 zstd/1.5.7 c-ares/1.34.6 libidn2/2.3.8 libpsl/0.21.5 libssh2/1.11.1 nghttp2/1.69.0 ngtcp2/1.22.1 nghttp3/1.15.0
Release-Date: 2026-04-29
Protocols: dict file ftp ftps gopher gophers http https imap imaps ipfs ipns mqtt mqtts pop3 pop3s rtsp scp sftp smtp smtps telnet tftp ws wss
Features: alt-svc asyn-rr AsynchDNS brotli ECH HSTS HTTP2 HTTP3 HTTPS-proxy HTTPSRR IDN IPv6 Largefile libz PSL SSL SSLS-EXPORT threadsafe TLS-SRP UnixSockets zstd
```

Then we can use it against a WebSocket server, let try it with `buckaroo` project.

```console
$ ./curl -T. -kv --no-progress-meter ws://127.0.0.1:8081/ws
*   Trying 127.0.0.1:8081...
* Established connection to 127.0.0.1 (127.0.0.1 port 8081) from 127.0.0.1 port 43194 
* using HTTP/1.x
> GET /ws HTTP/1.1
> Host: 127.0.0.1:8081
> User-Agent: curl/8.20.0
> Accept: */*
> Upgrade: websocket
> Sec-WebSocket-Version: 13
> Sec-WebSocket-Key: Y7nHv/MjumObou+aYHQJTg==
> Connection: Upgrade
> 
* Request completely sent off
< HTTP/1.1 101 Switching Protocols
< connection: Upgrade
< date: Wed, 27 May 2026 13:01:47 GMT
< sec-websocket-accept: nYSHGW+IDHwj5BJCocg6kA6Jsz8=
< server: Cowboy
< upgrade: websocket
< 
* Received 101, Switching to WebSocket
* [WS] Received 101, switch to WebSocket
{ [5 bytes data]
test
heytest
hello!
hello!
* upload completely sent off: 24 bytes
```

It... Works! Curl is still one of the greatest open-source software available on this planet. Having the power to use a WebSocket like `netcat`  with curl is really really cool.

Have fun!

----

Cover Image by <a href="https://unsplash.com/@sschusterphotoart?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Sebastian Schuster</a> on <a href="https://unsplash.com/photos/a-thick-coiled-rope-in-a-spiral-pattern-FofozD3XziQ?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>