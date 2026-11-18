---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/http3-and-quic-in-erlang-with-cowboy-549o"
comments_count: "1"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fa02a82j74u73g1qrhqj2.jpg"
created_at: "None"
crossposted_at: "None"
description: "Since Cowboy 2.14.0 an experimental implementation of HTTP/3 (or QUIC or RFC9000) has been released...."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/http3-and-quic-in-erlang-with-cowboy-549o"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "http3-and-quic-in-erlang-with-cowboy-549o"
social_image: "None"
title: "HTTP/3 and QUIC in Erlang with Cowboy"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# HTTP/3 and QUIC in Erlang with Cowboy

Since [Cowboy 2.14.0](https://ninenines.eu/articles/cowboy-2.14.0/) an experimental implementation of [HTTP/3](https://www.rfc-editor.org/rfc/rfc9114) (or [QUIC](https://quicwg.org/) or [RFC9000](https://www.rfc-editor.org/rfc/rfc9000)) has been released. That's a pretty good news, and if stable enough, will change a lot on the web ecosystem. Unfortunately, this feature is not documented yet - because unstable - but it's not a good reason to play with it and try to understand how to configure a cowboy server with HTTP/3 and QUIC.

Cowboy does not support natively QUIC and depends on `quicer` application to work correctly. To be clear, this is a **BIG NO-NO** for a deployment in production environment. The list of dependencies directly required by [`quicer`](https://github.com/emqx/quic) is insane, it fetch many python-like modules and recompile OpenSSL from scratch ([OpenSSL 3.1.7+quic](https://github.com/quictls/openssl.git), from an unmaintained and archived repository, with all [security issues](https://openssl-library.org/news/openssl-3.1-notes/) that could implies).

Anyway, the `COWBOY_QUICER` Erlang macro must be set to `1` to compile cowboy with HTTP/3 and QUIC support. Then, the `rebar.config` file will need few modifications. The configuration for the `cowboy` dependency must be overridden and the previous macro must be activated. The `quicer` depency is also required, because this is an experimental feature, cowboy does not include it. To test that, let reuse the [buckaroo project](https://github.com/niamtokik/buckaroo) created in a previous publication.

```erlang
{erl_opts, [
  debug_info
]}.
{deps, [
  cowboy,
  quicer
]}.
{shell, [{apps, [buckaroo]}]}.
{overrides, [
  {add, cowboy, [
    {erl_opts, [
      {d, 'COWBOY_QUICER', 1}
    ]}
  ]}
]}.
```

A cleanup will be also required there with a full recompilation from scratch of all the dependencies.

```console
$ rm -rf _build
$ rebar3 compile
...
```

In theory, after this step, cowboy should now be able to start a QUIC server and use HTTP/3. At least, an Erlang shell can be started without problem, and it seems buckaroo is running correctly.

```console
$ rebar3 shell
===> Verifying dependencies...
===> Analyzing applications...
===> Compiling buckaroo
Erlang/OTP 29 [erts-17.0] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [jit:ns]

Eshell V17.0 (press Ctrl+G to abort, type help(). for help)
===> Booted cowlib
===> Booted ranch
===> Booted cowboy
===> Booted buckaroo
1> 
```

A TLS certificate is required, we don't need to create a clean one, simply generating a self-signed with [`openssl req`](https://man.openbsd.org/openssl#req) for now will do the job.

```console
$ openssl req -x509 -newkey rsa:4096 \
  -keyout key.pem \
  -out cert.pem \
  -sha256 \
  -days 3650 \
  -nodes -subj \
  "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=CommonNameOrHostname"
```

If the certificate has been correctly created, `quicer` can be started via cowboy with the help of [`cowboy:start_quic/3`](https://github.com/ninenines/cowboy/blob/master/src/cowboy.erl#L87) function. This function is not exposed by default and to have access to it, one must compile `cowboy` with [`COWBOY_QUIC`](https://github.com/ninenines/cowboy/blob/master/src/cowboy.erl#L79) macro enabled (what we configured previously). Anyway , to add this step, we can modify the `buckaroo_cowboy` module by creating a new function called `start_quic/3`. Most of the parameters will be reused from the normal way to start `cowboy`.

```erlang
start_quic() ->
  application:ensure_all_started(quicer),
  cowboy:start_quic(
    name(),
    #{
      socket_opts => transport_options() ++ [
        {certfile, "cert.pem"},
        {keyfile, "key.pem"}
      ]
    },
    protocol_options()
  ).
```

Let start the application now.

```console
$ rebar3 shell
===> Verifying dependencies...
===> Analyzing applications...
===> Compiling buckaroo
Erlang/OTP 29 [erts-17.0] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [jit:ns]

Eshell V17.0 (press Ctrl+G to abort, type help(). for help)
===> Booted cowlib
===> Booted ranch
===> Booted cowboy
===> Booted buckaroo
1> buckaroo_cowboy:start_quic().
{ok,#Ref<0.2047991422.1293549576.157826>}
2> 
```

The service started... Okay, that's a good step but we still need to be sure it is listening on the right port and see if it's working correctly. Let use [`ss`](https://manpages.debian.org/trixie/iproute2/ss.8.en.html) (or [`netstat`](https://man.openbsd.org/netstat) if you are using another OS).

```console
$ ss -nlpu sport 8081
State   Recv-Q  Send-Q   Local Address:Port   Peer Address:Port Process                                  
UNCONN  0       0                    *:8081              *:*     users:(("beam.smp",pid=2784595,fd=86))  
UNCONN  0       0                    *:8081              *:*     users:(("beam.smp",pid=2784595,fd=90))  
UNCONN  0       0                    *:8081              *:*     users:(("beam.smp",pid=2784595,fd=94))  
UNCONN  0       0                    *:8081              *:*     users:(("beam.smp",pid=2784595,fd=98))  
UNCONN  0       0                    *:8081              *:*     users:(("beam.smp",pid=2784595,fd=102)) 
UNCONN  0       0                    *:8081              *:*     users:(("beam.smp",pid=2784595,fd=106)) 
UNCONN  0       0                    *:8081              *:*     users:(("beam.smp",pid=2784595,fd=110)) 
UNCONN  0       0                    *:8081              *:*     users:(("beam.smp",pid=2784595,fd=114)) 
UNCONN  0       0                    *:8081              *:*     users:(("beam.smp",pid=2784595,fd=118)) 
UNCONN  0       0                    *:8081              *:*     users:(("beam.smp",pid=2784595,fd=122)) 
UNCONN  0       0                    *:8081              *:*     users:(("beam.smp",pid=2784595,fd=126)) 
UNCONN  0       0                    *:8081              *:*     users:(("beam.smp",pid=2784595,fd=130)) 
UNCONN  0       0                    *:8081              *:*     users:(("beam.smp",pid=2784595,fd=134)) 
UNCONN  0       0                    *:8081              *:*     users:(("beam.smp",pid=2784595,fd=138)) 
UNCONN  0       0                    *:8081              *:*     users:(("beam.smp",pid=2784595,fd=142)) 
UNCONN  0       0                    *:8081              *:*     users:(("beam.smp",pid=2784595,fd=146)) 
```

A QUIC service must listen on UDP, and this is the case. The output of `ss` command returns the what we are looking for, an application (`beam.smp`) listening to all interfaces on UDP/8082.

```console
$ curl -kv --http3-only https://localhost:8081/; echo
* Host localhost:8081 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
* HTTPS-RR: -
*   Trying [::1]:8081...
* SSL Trust: peer verification disabled
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384 / x25519 / RSASSA-PSS
* Server certificate:
*   subject: C=XX; ST=StateName; L=CityName; O=CompanyName; OU=CompanySectionName; CN=CommonNameOrHostname
*   start date: May 27 04:15:27 2026 GMT
*   expire date: May 24 04:15:27 2036 GMT
*   issuer: C=XX; ST=StateName; L=CityName; O=CompanyName; OU=CompanySectionName; CN=CommonNameOrHostname
*   Certificate level 0: Public key type RSA (4096/152 Bits/secBits), signed using sha256WithRSAEncryption
* OpenSSL verify result: 12
*  SSL certificate verification failed, continuing anyway!
* Established connection to localhost (::1 port 8081) from ::1 port 33253 
* using HTTP/3
* [HTTP/3] [0] OPENED stream for https://localhost:8081/
* [HTTP/3] [0] [:method: GET]
* [HTTP/3] [0] [:scheme: https]
* [HTTP/3] [0] [:authority: localhost:8081]
* [HTTP/3] [0] [:path: /]
* [HTTP/3] [0] [user-agent: curl/8.20.0]
* [HTTP/3] [0] [accept: */*]
> GET / HTTP/3
> Host: localhost:8081
> User-Agent: curl/8.20.0
> Accept: */*
> 
* Request completely sent off
< HTTP/3 200 
< content-length: 5
< content-type: text/plain
< date: Wed, 27 May 2026 12:49:14 GMT
< server: Cowboy
< 
* Connection #0 to host localhost:8081 left intact
hello
```

It looks good, cowboy returns the famous `hello` message and curl is correctly using HTTP/3. 

# Conclusion

I would really like to use HTTP/3 and QUIC in production with Erlang and cowboy, but I don't really think this is still a good time to use it. Many things must be improved, and based on the amount of dependencies required, it's a bit scary.

This project example can still be seen on [niamtokik/buckaroo](https://github.com/niamtokik/buckaroo) repository at Github.

Have fun!

----

Cover Image by <a href="https://unsplash.com/@chrisliverani?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Chris Liverani</a> on <a href="https://unsplash.com/photos/white-and-blue-analog-tachometer-gauge-HUJDz6CJEaM?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>