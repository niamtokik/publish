---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/http-server-in-erlang-with-cowboy-28g0"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2F1su03boiqtfm827b2o1l.jpg"
created_at: "None"
crossposted_at: "None"
description: "Finally, a bit of Erlang! Instead of writing the same 101 introduction to this marvelous language, we..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/http-server-in-erlang-with-cowboy-28g0"
public_reactions_count: "1"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "http-server-in-erlang-with-cowboy-28g0"
social_image: "None"
title: "HTTP Server in Erlang with Cowboy"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# HTTP Server in Erlang with Cowboy

Finally, a bit of Erlang! Instead of writing the same 101 introduction to this marvelous language, we will switch directly on the most used HTTP Web Server on this ecosystem: Cowboy. The goal will be to create a flexible module letting us configuring [HTTP/1.1](https://www.rfc-editor.org/info/rfc2616/), [HTTP/2](https://httpwg.org/specs/rfc7540.html), [HTTP/3](https://datatracker.ietf.org/doc/html/rfc9114) and [WebSocket](https://www.rfc-editor.org/rfc/rfc6455.html) easily. Why do I need that? For some of my local test, especially for Dart/Flutter.

Anyway, it's time to create a new fresh project to explain that, let call it Buckaroo.

# Project Bootstrapping with rebar3

Just a quick reminder for the newcomers who never tried Erlang, below, the command to generate a new app project.

```console
$ rebar3 new app name=buckaroo
```

All the magic will happen in the `src/` directory but cowboy must be added in the dependencies list in `rebar.config`.

```erlang
{erl_opts, [debug_info]}.
{deps, [cowboy]}.
{shell, [{apps, [buckaroo]}]}.
```

Let fetch everything.

```erlang
$ rebar3 get-deps
$ rebar3 compile
```

# Starting Cowboy

To make things easier, a dedicated module to manage cowboy called `buckaroo_cowboy` is created. And to avoid too much complexity, only 2 functions will be exported

- `start_link/0` to start the cowboy listener;

- `stop/0` to stop the cowboy listener.

```erlang
-module(buckaroo_cowboy).
-export([start_link/0, stop/0]).
```

A `cowboy` listener needs a name, let create a function called `name/0` to deal with that. It will return the listener name.

```erlang
name() ->
  buckaroo_listener.
```

Now, the HTTP API routes are required, the [cowboy routing documentation](https://ninenines.eu/docs/en/cowboy/2.15/guide/routing/) is complete and should be way enough to understand how to routes requests with cowboy. 2 routes will be created there, the default one (`/`) will be used for HTTP requests, and (`/ws`) for the WebSockets. In both case, the last element of the tuple passed by the router will be a `map()`, this value will be used as connection state.

```erlang
routes() ->
  [
    {'_', [
      {"/", buckaroo_handler, #{}},
      {"/ws", buckaroo_websocket_handler, #{}}
    ]
  }].
```

The routes, then, must be compiled with the help of the [`cowboy_router:compile/1`](https://ninenines.eu/docs/en/cowboy/2.15/manual/cowboy_router.compile/) function.

```erlang
dispatch() ->
  cowboy_router:compile(
    routes()
  ).
```

A cowboy listener will also require 2 kinds of options, the [transport options](https://ninenines.eu/docs/en/ranch/2.1/manual/ranch/#_transport_opts_socketopts) (TCP) and the [protocol options](https://ninenines.eu/docs/en/cowboy/2.15/manual/cowboy/#_opts) (including [HTTP](https://ninenines.eu/docs/en/cowboy/2.15/manual/cowboy_http/) and [HTTP/2](https://ninenines.eu/docs/en/cowboy/2.15/manual/cowboy_http2/) options). In our case, only the listening port (TCP/8081) will be set.

```erlang
transport_options() ->
  [
    {port, 8081}
  ].
```

The protocol options can be defined, in this case, only the routing will be configured via the `dispatch` key.

```erlang
protocol_options() ->
  #{
    env => #{
      dispatch => dispatch()
    }
  }.
```

To start a cowboy listener, the (`cowboy:start_clear/3`)(https://ninenines.eu/docs/en/cowboy/2.15/manual/cowboy.start_clear/) function can be used. If a TLS certificate is configured, the [`cowboy:start_tls/3`](https://ninenines.eu/docs/en/cowboy/2.14/manual/cowboy.start_tls/) must be used instead. The first argument is the name of the listener, the second the transport options and the last one the protocol options.

```erlang
start_link() ->
  cowboy:start_clear(
    name(),
    transport_options(),
    protocol_options()
  ).
```

Finally, the `stop()` function can be created to help shutdown cowboy, using simply the name previously configured and with the [`cowboy:stop_listener/1`](https://ninenines.eu/docs/en/cowboy/2.15/manual/cowboy.stop_listener/) function.

```erlang
stop() ->
    cowboy:stop_listener(name()).
```

A quick remark regarding my coding style. I like creating really small functions and call them in some part of the code. It can help to document but also to test the module. We will see that in another publication about finite state machines.

The final modification, is to add the cowboy listener in the supervision tree by editing `src/buckaroo_sup.erl`.

```erlang
-module(buckaroo_sup).
-behavior(supervisor).
-export([start_link/0, init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_) ->
  {ok, {supervisor_flags(), child_specs()}}.

supervisor_flags() ->
  #{
    strategy => one_for_all,
    intensity => 0,
    period => 1
  }.

child_specs() ->
  [
    #{
      id => buckaroo_cowboy,
      start => {buckaroo_cowboy, start_link, []}
    }
  ].
```

Now, the application can be started, for development and debug purpose only, it will be started with an Erlang shell.

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
```

Well done, but it will not work correctly, because the handlers are missing... Let fix that in the next sections of this article.

# Dealing with HTTP Requests

An handler can usually deal with HTTP requests but also with WebSocket ones. Let

```erlang
-module(buckaroo_handler).
-export([init/2]).
-include_lib("kernel/include/logger.hrl").
```

```erlang
init(Req, State) ->
  Reply = cowboy_req:reply(200,
    #{
      <<"content-type">> => <<"text/plain">>
    },
    <<"hello">>,
    Req
  ),
  {ok, Reply, State}.
```

The cowboy request object is the core data structure used by any handlers, here a quick view of its content when using `curl` locally.

```erlang
#{
  pid => <0.1260.0>,
  port => 8081,
  scheme => <<"http">>,
  version => 'HTTP/1.1',
  path => <<"/">>,
  host => <<"localhost">>,
  peer => {{127,0,0,1},50986},
  bindings => #{},
  cert => undefined,
  headers => #{
    <<"accept">> => <<"*/*">>,
    <<"host">> => <<"localhost:8081">>,
    <<"user-agent">> => <<"curl/8.14.1">>
  },
  ref => buckaroo_listener,
  host_info => undefined,
  path_info => undefined,
  streamid => 1,
  method => <<"GET">>,
  body_length => 0,
  has_body => false,
  qs => <<>>,
  sock => {{127,0,0,1},8081}}
}.
```

As you can see, this is a simple `map()` containing specific keys. The value of those keys can be retrieved using Erlang pattern matching, or by using the cowboy functions helpers from the module `cowboy_req`. This data structure will be used to route the request and alter the final response, so, let check them one by one.

- `pid` is the process id of the process in charge of the request;

- `port` is the port from the listener and can also be extracted using [`cowboy_req:port/1`](https://ninenines.eu/docs/en/cowboy/2.14/manual/cowboy_req.port/) function;

- `scheme` is the scheme using, usually `http` or `https`. This information can be obtained using [`cowboy_req:scheme/1`](https://ninenines.eu/docs/en/cowboy/2.14/manual/cowboy_req.scheme/) function as well;

- `version` is the protocol version used, it can be `HTTP/1.0`, `HTTP/1.1`, `HTTP/2` or `HTTP/3`. It can be extracted with the help of [`cowboy_req:version/1`](https://ninenines.eu/docs/en/cowboy/2.14/manual/cowboy_req.version/) function;

- `path` represents the full path requested by the client, this value is more or less related to the routing defined when starting cowboy, it can be extracted using [`cowboy_req:path/1`](https://ninenines.eu/docs/en/cowboy/2.14/manual/cowboy_req.path/) function;

- `host` represents the host name requested by the client, it is also a part of the routing configuration, this value can also be extracted using [`cowboy_req:host/1`](https://ninenines.eu/docs/en/cowboy/2.14/manual/cowboy_req.host/) function;

- `peer` contains the IP address/port of the client, it can also be extracted using [`cowboy_req:peer/1`](https://ninenines.eu/docs/en/cowboy/2.14/manual/cowboy_req.peer/) function;

- `bindings` is set when the route is configured with pattern matching, if it was the case, the variables defined in the route would have been converted into bindings;

- `cert` is set when a certificate is sent by the client, it can be extracted using [`cowboy_req:cert/1`](https://ninenines.eu/docs/en/cowboy/2.14/manual/cowboy_req.cert/) function;

- `headers` are the HTTP Headers sent by the client, an header value can be extracted using [`cowboy_req:header/2`](https://ninenines.eu/docs/en/cowboy/2.14/manual/cowboy_req.header/) or  [`cowboy_req:header/3`](https://ninenines.eu/docs/en/cowboy/2.14/manual/cowboy_req.header/) functions;

- `ref` (internal usage) stores the name of the listener;

- `host_info` returns the routing pattern matching result, it can also be accessed using [`cowboy_req:host_info/1`](https://ninenines.eu/docs/en/cowboy/2.14/manual/cowboy_req.host_info/) function;

- `path_info` returns the routing pattern matching result, it can also be extracted using [`cowboy_req:path_info/1`](https://ninenines.eu/docs/en/cowboy/2.14/manual/cowboy_req.path_info/) function;

- `streamid` (internal usage) defines the stream id of the connection;

- `method` defines the HTTP method used by the client for the request, it can also be retrieved using [`cowboy_req:method/1`](https://ninenines.eu/docs/en/cowboy/2.14/manual/cowboy_req.method/) function;

- `body_length` defines the size of the data sent by the client in the HTTP body, the value of this key can be also fetched using [`cowboy_req:body_length/1`](https://ninenines.eu/docs/en/cowboy/2.14/manual/cowboy_req.body_length/) function;

- `has_body` defines if the request contains a body or not. Mostly used with `POST`, `PUT` and other HTTP methods sending data. It can also be checked using [`cowboy_req:has_body/1`](https://ninenines.eu/docs/en/cowboy/2.14/manual/cowboy_req.has_body/) function;

- `qs` is the raw query string, it should be parsed using [`uri_string:dissect_query/1`](https://www.erlang.org/doc/apps/stdlib/uri_string.html#dissect_query/1) function or with your own method. The value can also be retrieved using [`cowboy_req:qs/1`](https://ninenines.eu/docs/en/cowboy/2.14/manual/cowboy_req.qs/);

- `sock` contains the IP address and port of the server, it can be extracted using [`cowboy_req:sock/1`](https://ninenines.eu/docs/en/cowboy/2.14/manual/cowboy_req.sock/) function.

The handler is done, it's a really simple one, but just to check if it's working, we can use `curl`.

```console
$ curl -kv http://localhost:8081/; echo
* Host localhost:8081 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
* HTTPS-RR: -
*   Trying [::1]:8081...
* connect to ::1 port 8081 from ::1 port 48828 failed: Connection refused
*   Trying 127.0.0.1:8081...
* Established connection to localhost (127.0.0.1 port 8081) from 127.0.0.1 port 48800 
* using HTTP/1.x
> GET / HTTP/1.1
> Host: localhost:8081
> User-Agent: curl/8.20.0
> Accept: */*
> 
* Request completely sent off
< HTTP/1.1 200 OK
< content-length: 5
< content-type: text/plain
< date: Wed, 27 May 2026 12:20:21 GMT
< server: Cowboy
< 
* Connection #0 to host localhost:8081 left intact
hello
```

# Dealing with WebSockets

Cowboy can also managed [WebSocket connections](https://ninenines.eu/docs/en/cowboy/2.14/guide/ws_handlers/) using [websocket handlers](http://ninenines.eu/docs/en/cowboy/2.14/manual/cowboy_websocket/). The idea is to create 4 callback functions, one for the HTTP request and three for the WebSocket events.

```erlang
-module(buckaroo_websocket_handler).
-export([init/2]).
-export([websocket_init/1, websocket_handle/2, websocket_info/2]).
-include_lib("kernel/include/logger.hrl").
```

When a client wants to use WebSocket protocol, it will first send an HTTP request with some specific information, then the server will start the negotiation, this step, is mostly done in `init/2` callback.

```erlang
init(Req, State) ->
  WebSocketOpts = #{
    active_n => 1,
    compress => false,
    data_delivuery => stream_handlers,
    data_delivery_flow => 1,
    deflate_opts => #{},
    dynamic_buffer => {1024, 131_072},
    idle_timeout => 60_000,
    max_frame_size => 120_000,
    req_filter => fun(Req) -> Req end,
    validate_utf8 => true
  },
  ?LOG_DEBUG("~p:~p: ~p~n", [
    ?MODULE,
    ?FUNCTION_NAME,
    WebSocketOpts,
    Req
  ]),
  {cowboy_websocket, Req, State, WebSocketOpts}.
```

At the end of the negociation, the server can do some initialization state using the `websocket_init/1` callback. In our case, the text event `hey\n` will send to the client by the server.

```erlang
websocket_init(State) ->
  ?LOG_DEBUG("~p:~p: ~p~n", [?MODULE, ?FUNCTION_NAME]),
  {[{text, <<"hey\n">>}], State}.
```

To handle messages sent by the client, a `websocket_handle/2` function must be created and exported by the module. The first argument received is a tuple containing the type of data (defined in the [`websocket_handle` callback](https://github.com/ninenines/cowboy/blob/2.15.0/src/cowboy_websocket.erl#L60) and also defined as [`cow_ws:frame()`](https://ninenines.eu/docs/en/cowboy/2.15/manual/cowboy_websocket/#_cow_ws_frame) type), and its content. The second argument is the connection state.

```erlang
websocket_handle(Frame = {text, Message}, State) ->
  ?LOG_DEBUG("~p:~p: ~p, ~p~n", [?MODULE, ?FUNCTION_NAME, Frame]),
  {[{text, Message}], State};
websocket_handle(Frame = {binary, Message}, State) ->
  ?LOG_DEBUG("~p:~p: ~p, ~p~n", [?MODULE, ?FUNCTION_NAME, Frame]),
  {[{binary, Message}], State};
websocket_handle(Frame, State) ->
  ?LOG_DEBUG("~p:~p: ~p, ~p~n", [?MODULE, ?FUNCTION_NAME, Frame]),
  {[Frame], State}.
```

The websocket handler is running in a process, and this process can receive message from another running process from the system. In this case, the message will be handled by `websocket_info/2` function callback.

```erlang
websocket_info(Event, State) ->
  ?LOG_DEBUG("~p:~p: ~p, ~p~n", [?MODULE, ?FUNCTION_NAME, Event]),
  {ok, State}.
```

Let check that with `curl` to see what will happen.

```console
$ curl -N -T. --no-progress-meter -v ws://localhost:8081/ws
* Host localhost:8081 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
* HTTPS-RR: -
*   Trying [::1]:8081...
* connect to ::1 port 8081 from ::1 port 45396 failed: Connection refused
*   Trying 127.0.0.1:8081...
* Established connection to localhost (127.0.0.1 port 8081) from 127.0.0.1 port 43458 
* using HTTP/1.x
> GET /ws HTTP/1.1
> Host: localhost:8081
> User-Agent: curl/8.20.0
> Accept: */*
> Upgrade: websocket
> Sec-WebSocket-Version: 13
> Sec-WebSocket-Key: +t+tuHiQUK6MMQySUqDGtQ==
> Connection: Upgrade
> 
* Request completely sent off
< HTTP/1.1 101 Switching Protocols
< connection: Upgrade
< date: Wed, 27 May 2026 12:21:53 GMT
< sec-websocket-accept: F87i2EOBLl+kwTQ3PCdZqjjcxuA=
< server: Cowboy
< upgrade: websocket
< 
* Received 101, Switching to WebSocket
* [WS] Received 101, switch to WebSocket
{ [5 bytes data]
hey

hello!
hello!
test1
test1
* upload completely sent off: 32 bytes
```

The websocket handler correctly acts as an echo server, it looks good!

# Conclusion

It's always a pleasure to write Erlang code, even more after many weeks where I passed all my time learning Dart/Flutter. Erlang code is concise and efficient. Cowboy is following the same philosophy there, and give us a good idea how to manage requests.

This project example can be seen on [niamokik/buckaroo](https://github.com/niamtokik/buckaroo) repository at Github.

Have fun!

# References and Resources

- [Cowboy Source Code](https://github.com/ninenines/cowboy) on Github

----

Cover Image by <a href="https://unsplash.com/@jjying?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">JJ Ying</a> on <a href="https://unsplash.com/photos/purple-and-blue-light-digital-wallpaper-8bghKxNU1j0?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>