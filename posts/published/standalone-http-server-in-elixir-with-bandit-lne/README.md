---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/standalone-http-server-in-elixir-with-bandit-lne"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fnnqeodjd663b0an5g9tq.jpg"
created_at: "None"
crossposted_at: "None"
description: "Writing Elixir code is not really exciting to me, but, to be honest, if someone today wants to create..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/standalone-http-server-in-elixir-with-bandit-lne"
public_reactions_count: "3"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "standalone-http-server-in-elixir-with-bandit-lne"
social_image: "None"
title: "Standalone HTTP Server in Elixir with Bandit"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Standalone HTTP Server in Elixir with Bandit

Writing [Elixir](https://elixir-lang.org/) code is not really exciting to me, but, to be honest, if someone today wants to create an application from scratch and is looking for a big pool developers and a battle tested distributed infrastructure (the [BEAM VM](https://www.erlang-solutions.com/blog/the-beam-erlangs-virtual-machine/)), Elixir is probably one of the best choice nowadays. The community is active, the documentation is great, the language looks like a mix between Ruby and Python, without the annoying object part and with all the good feature from [Erlang](https://erlang.org/). This is why, today, we will use [Elixir](https://elixir-lang.org/) with [`bandit`](https://hex.pm/packages/bandit) to create a minimal web server supporting both HTTP and WebSockets.

[`bandit`](https://github.com/mtrudel/bandit) has been created as an alternative to [`cowboy`](https://github.com/ninenines/cowboy), fully coded in Elixir and designed to be integrated and highly compatible with the [Phoenix framework](https://www.phoenixframework.org/). When it came out few years ago, the community did a lot of noise and I never find a moment to test it. [`bandit`](https://github.com/mtrudel/bandit)  supports [HTTP/1.1](https://www.rfc-editor.org/info/rfc2616) and [HTTP/2](https://www.rfc-editor.org/info/rfc7540/) natively. [WebSockets](https://www.rfc-editor.org/rfc/rfc6455.html) protocols support can be added with the help of [`WebSock`](https://github.com/phoenixframework/websock) and [`WebSockAdapter`](https://github.com/phoenixframework/websock_adapter) modules. At this time, it does not support [HTTP/3](https://datatracker.ietf.org/doc/html/rfc9114) (yet?).

The idea here is not to follow blindly the [Phoenix framework documentation](https://phoenix.hexdocs.pm/overview.html) and to create yet another website-like-project, but just to learn how to use [`bandit`](https://github.com/mtrudel/bandit) API, a bit like I did in a [previous publication on `cowboy`](https://dev.to/niamtokik/http-server-in-erlang-with-cowboy-28g0). Let start our journey by creating a new [Elixir library](https://elixir.hexdocs.pm/main/library-guidelines.html) called [`desperados`](https://github.com/niamtokik/desperados). It will contain all our experiments.

# Bootstrapping

[Elixir](https://elixir-lang.org/) is using [Mix](https://hexdocs.pm/elixir/introduction-to-mix.html) as project manager. To create a new library-like project, one can simply call [`mix new`](https://hexdocs.pm/mix/Mix.Tasks.New.html) command

```console
$ mix new desperados
```

A library template project should have been generated into the `desperados` directory. I will not create an application or an umbrella for now, I just want something minimalist to break. It also means the application will be started manually, usually with a `start` like function.

# Starting Bandit

The first file to modify is `lib/desperados.ex`, it will contain the methods to start and stop the application. Let simply implement `start_link/1` and `start_link/0` for now.

```elixir
defmodule Desperados do
  def start_link do
    start_link([
      {:plug, Desperados.Plugs},
      {:scheme, :http},
      {:port, 8082},
      {:ip, :any},
      {:startup_log, :debug}
    ])
  end

  def start_link(opts) do
    Bandit.start_link(opts)
  end
end
```

`bandit` is using [`thousand_island`](https://github.com/mtrudel/thousand_island) to manage the transport layer (TCP). This project is also a rewrite of [`ranch`](https://github.com/ninenines/ranch) in pure Erlang and designed for the Phoenix framework. The function to start a new `bandit` server is [`Bandit.start_link/1`](https://hexdocs.pm/bandit/Bandit.html#start_link/1). The unique argument passed to it contains the [`options()`](https://hexdocs.pm/bandit/Bandit.html#t:options/0) to configure the server.

The smallest configuration is to only set a [`Plug`](https://hexdocs.pm/plug/1.19.1/Plug.html) handler.  This Plug callback is mandatory. In fact, when using `bandit` with Phoenix, this callback can be seen as the [Phoenix router](https://hexdocs.pm/phoenix/Phoenix.Router.html). Anyway, to work correctly, a `Plug` handler is required, so let call it `Desperados.Plug` for now. The rest of the options are for configuring the server itself

# Anatomy of a `Plug`

A [`Plug`](https://hexdocs.pm/plug/1.19.1/Plug.html)  is a piece of code containing mandatory callback functions ([behaviours](https://elixir.hexdocs.pm/1.4.5/behaviours.html)) to manage initialization, connections, requests and events. These callbacks functions are following a contract (specification) and must return a certain kind of value. If you are more familiar with Erlang, one can think of a [`middleware`](https://ninenines.eu/docs/en/cowboy/2.15/guide/middlewares/) in `cowboy`. The `Plug` concept is the foundation of any Phoenix application.

Why `Plug`s are great? Well, because they are following a contract, those modules can be connected together using a pipeline. The output of one `Plug` can be the input of another one. This kind of concept makes everything easier. You can see that a bit like a layer of features, where every `Plug` will deal with only with one request passing through one `Plug` at a time (e.g. authentication, sanitization...) and the "final" value returned by one of those `Plug` will be the response to the client.

Let create the most simple `Plug` possible, `Desperados.Plugs.Inspect`, a simple `Plug` to inspect the [`%Plug.Conn{}`](https://hexdocs.pm/plug/1.19.1/Plug.Conn.html#t:t/0) data structure passed in the first argument of the `call/2` function callback. This file will be created under `lib/desperados/plugs` directory and called `inspect.ex`.

```elixir
defmodule Desperados.Plugs.Inspect do
  @behaviour Plug

  def init(_args), do: {:ok, %{}}

  def call(conn, _state) do
    IO.inspect(conn)
  end
end
```

A `Plug` is a concise module, when a request is coming to the server from a client, the first callback executed is [`init/1`](https://hexdocs.pm/plug/1.19.1/Plug.html#c:init/1), it will simply initialize the the `Plug` using some kind of arguments passed previously. In this step, a [state](https://plug.hexdocs.pm/1.19.2/Plug.html#t:opts/0) can be defined, in our case, an empty [`Map`](https://hexdocs.pm/elixir/1.12/Map.html) is returned. This state will be then be passed to other callback functions.

If the initialization phase was a success, then the server will call the [`call/2`](https://hexdocs.pm/plug/1.19.1/Plug.html#c:call/2) function callback with the full request in the first argument using a [`%Plug.Conn{}`](https://hexdocs.pm/plug/1.19.1/Plug.Conn.html) data structure and the state previously returned by the `init/1` function.

This new plug can be directly used in the `Bandit.start_link/1` options but well, I told you previously we can pipeline `Plugs` together. This feature is already available by default in Phoenix when using the [`Router plugs`](https://hexdocs.pm/phoenix/plug.html#router-plugs) feature. We are not using Phoenix, but, we can use [`Plug.Builder`](https://hexdocs.pm/plug/1.19.1/Plug.Builder.html) to create our own Plug router using [`Plug.Builder`](https://hexdocs.pm/plug/1.19.1/Plug.Builder.html). Let create a new modules called `Desperados.Plugs` in `lib/desperados/plugs.ex`. It will contain the following code:

```elixir
defmodule Desperados.Plugs do
  use Plug.Builder
  plug Desperados.Plugs.Inspect
end
```

The `Plug.Builder` module offers the `plug` macro. After compilation, all the plugs defined are then put together in a pipeline, where the first defined will be executed at first and the last one, executed during the last step. Let start our minimal configuration right now using `iex`.

```console
$ iex -S mix
Erlang/OTP 28 [erts-16.0.1] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [jit:ns]

Interactive Elixir (1.19.5) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> Desperados.start_link

13:31:27.131 [debug] Running Desperados.Plugs with Bandit 1.11.1 at 0.0.0.0:8082 (http)
{:ok, #PID<0.214.0>}
```

It seems good, the server is started. We can now use `curl` to check that.

```console
$ curl -svfq http://localhost:8082/test; echo $?
* Host localhost:8082 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
* HTTPS-RR: -
*   Trying [::1]:8082...
* connect to ::1 port 8082 from ::1 port 38724 failed: Connection refused
*   Trying 127.0.0.1:8082...
* Established connection to localhost (127.0.0.1 port 8082) from 127.0.0.1 port 42484 
* using HTTP/1.x
> GET /test HTTP/1.1
> Host: localhost:8082
> User-Agent: curl/8.20.0
> Accept: */*
> 
* Request completely sent off
< HTTP/1.1 500 Internal Server Error
< connection: close
* The requested URL returned error: 500
< 
* closing connection #0
22
```

Ah! It returns an error an error 500! Let check the console on `iex` to see what happened...

```console
%Plug.Conn{
  adapter: {Bandit.Adapter, :...},
  assigns: %{},
  body_params: %Plug.Conn.Unfetched{aspect: :body_params},
  cookies: %Plug.Conn.Unfetched{aspect: :cookies},
  halted: false,
  host: "localhost",
  method: "GET",
  owner: nil,
  params: %Plug.Conn.Unfetched{aspect: :params},
  path_info: ["test"],
  path_params: %{},
  port: 8082,
  private: %{},
  query_params: %Plug.Conn.Unfetched{aspect: :query_params},
  query_string: "",
  remote_ip: {127, 0, 0, 1},
  req_cookies: %Plug.Conn.Unfetched{aspect: :cookies},
  req_headers: [
    {"host", "localhost:8082"},
    {"user-agent", "curl/8.20.0"},
    {"accept", "*/*"}
  ],
  request_path: "/test",
  resp_body: nil,
  resp_cookies: %{},
  resp_headers: [{"cache-control", "max-age=0, private, must-revalidate"}],
  scheme: :http,
  script_name: [],
  secret_key_base: nil,
  state: :unset,
  status: nil
}

13:32:18.749 [error] ** (Plug.Conn.NotSentError) a response was neither set nor sent from the connection
    (bandit 1.11.1) lib/bandit/pipeline.ex:169: Bandit.Pipeline.commit_response!/1
    (bandit 1.11.1) lib/bandit/pipeline.ex:46: Bandit.Pipeline.run/5
    (bandit 1.11.1) lib/bandit/http1/handler.ex:13: Bandit.HTTP1.Handler.handle_data/3
    (bandit 1.11.1) lib/bandit/delegating_handler.ex:18: Bandit.DelegatingHandler.handle_data/3
    (bandit 1.11.1) lib/bandit/delegating_handler.ex:8: Bandit.DelegatingHandler.handle_continue/2
    (stdlib 7.0.1) gen_server.erl:2424: :gen_server.try_handle_continue/3
    (stdlib 7.0.1) gen_server.erl:2291: :gen_server.loop/4
    (stdlib 7.0.1) proc_lib.erl:333: :proc_lib.init_p_do_apply/3

iex(2)> 
```

It "works", at least, the `conn` argument is printed to stdout but the application print also an error. In fact, this is normal, the request does not return a response to the client and then, `bandit` throw an [`Plug.Conn.NotSentError`](https://plug.hexdocs.pm/1.19.2/Plug.Conn.NotSentError.html) error. To avoid this kind of issue, a `Plug` must give a response to a client. Let fix that in the next section.

Quick note regarding a `Plug`, it's also possible to create one using a function, in this case, the first argument passed must be a [`%Plug.Conn{}`](https://hexdocs.pm/plug/1.19.1/Plug.Conn.html) and the second argument can be anything (options).

Anyway, if you want to know a bit more about a plug, check those links:

- The official [`Plug` documentation API](https://hexdocs.pm/plug/1.19.1/Plug.html) where you will find great example and the description of the behavior;

- The official phoenix [`Plug` tutorial](https://hexdocs.pm/phoenix/plug.html), wwhere you will find how plugs are working when using them in a Phoenix project;

- [`Plug`](https://github.com/elixir-plug/plug/blob/v1.19.2/lib/plug.ex#L1) source code on Github, where you will understand how the plug's macros have been implemented;

- [`Plug.Router`](https://github.com/elixir-plug/plug/blob/v1.19.1/lib/plug/router.ex#L1) source code on Github, where you will understand how the router has been implemented using mostly Elixir macros;

- [`Plug.Builder`](https://github.com/elixir-plug/plug/blob/v1.19.1/lib/plug/builder.ex) source code on Github where you will learn how the Plug Builder has been created and how the pipeline is working under the hood.

# Dealing with HTTP Requests

We can print the connections/requests received with `Desperados.Plugs.Inspect` `Plug`, but it's a bit useless. It returns an error to the client and except for debugging purpose, there are no real values. Let create a new module called `Desperados.Endpoints.HTTP` to deal with the HTTP requests. A new file in `lib/desperados/endpoints/http.ex` can be created.

```elixir
defmodule Desperados.Endpoints.HTTP do
  @behaviour Plug
  import Plug.Conn

  def init(_opts), do: {:ok, %{}}

  def call(conn, _state) do
    send_resp(conn, 404, "not found")
  end
end
```

The Plug structure is the very same than the previous one we just created. We have the `init/1` function callback doing mostly nothing and then we have the `call/2` function doing something interesting. When a request is received, this plug will call [`Plug.Conn.send_resp/3`](https://plug.hexdocs.pm/1.19.2/Plug.Conn.html#send_resp/3) function to reply a message to the client. In our case, this code is simply returning the code `404` with the message `"not found"`. Let add this in our `Desperados.Plugs` "pipeline".

```elixir
defmodule Desperados.Plugs do
  use Plug.Builder
  plug Desperados.Plugs.Inspect
  plug Desperados.Endpoints.HTTP
end
```

The project can now be recompiled in live using `recompile` function inside the `iex` shell.

```console
iex(2)> recompile
:ok
```

Great. `curl` can now be used to request the server with a `GET` method. If it works, it should return a 404 not found.

```console
$ curl -v http://localhost:8082/test
* Host localhost:8082 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
* HTTPS-RR: -
*   Trying [::1]:8082...
* connect to ::1 port 8082 from ::1 port 34846 failed: Connection refused
*   Trying 127.0.0.1:8082...
* Established connection to localhost (127.0.0.1 port 8082) from 127.0.0.1 port 35288 
* using HTTP/1.x
> GET /test HTTP/1.1
> Host: localhost:8082
> User-Agent: curl/8.20.0
> Accept: */*
> 
* Request completely sent off
< HTTP/1.1 404 Not Found
< date: Sat, 30 May 2026 11:57:36 GMT
< content-length: 9
< vary: accept-encoding
< cache-control: max-age=0, private, must-revalidate
< 
* Connection #0 to host localhost:8082 left intact
not found
```

No more errors, `Desperados.Endpoints.HTTP` is returning an "awesome" 404 not found.

```console
%Plug.Conn{
  adapter: {Bandit.Adapter, :...},
  assigns: %{},
  body_params: %Plug.Conn.Unfetched{aspect: :body_params},
  cookies: %Plug.Conn.Unfetched{aspect: :cookies},
  halted: false,
  host: "localhost",
  method: "GET",
  owner: nil,
  params: %Plug.Conn.Unfetched{aspect: :params},
  path_info: ["test"],
  path_params: %{},
  port: 8082,
  private: %{},
  query_params: %Plug.Conn.Unfetched{aspect: :query_params},
  query_string: "",
  remote_ip: {127, 0, 0, 1},
  req_cookies: %Plug.Conn.Unfetched{aspect: :cookies},
  req_headers: [
    {"host", "localhost:8082"},
    {"user-agent", "curl/8.20.0"},
    {"accept", "*/*"}
  ],
  request_path: "/test",
  resp_body: nil,
  resp_cookies: %{},
  resp_headers: [{"cache-control", "max-age=0, private, must-revalidate"}],
  scheme: :http,
  script_name: [],
  secret_key_base: nil,
  state: :unset,
  status: nil
}
iex(3)>
```

No crashes on the server side anymore as well. The `conn` variable is still correctly printed to STDOUT and everything is working correctly. Is it? Well, perhaps not, what about WebSocketd support?

```console
$ curl -v ws://localhost:8082/test
* Host localhost:8082 was resolved.                                                                     * IPv6: ::1
* IPv4: 127.0.0.1
* HTTPS-RR: -
*   Trying [::1]:8082...
* connect to ::1 port 8082 from ::1 port 52100 failed: Connection refused
*   Trying 127.0.0.1:8082...
* Established connection to localhost (127.0.0.1 port 8082) from 127.0.0.1 port 43686 
* using HTTP/1.x
> GET /test HTTP/1.1
> Host: localhost:8082
> User-Agent: curl/8.20.0
> Accept: */*
> Upgrade: websocket
> Sec-WebSocket-Version: 13
> Sec-WebSocket-Key: mkqOjlvEfpDPU53U0uVnHw==
> Connection: Upgrade
> 
* Request completely sent off
< HTTP/1.1 404 Not Found
< date: Sat, 30 May 2026 11:59:43 GMT
< content-length: 9
< vary: accept-encoding
< cache-control: max-age=0, private, must-revalidate
* Refused WebSocket upgrade: 404
< 
* closing connection #0
curl: (22) Refused WebSocket upgrade: 404
```

Ah! It does not work... Let fix that in the next section then. Anyway, if you want to know more about managing HTTP requests with `Plug`s, you should also check those links:

- [`Plug.Conn` module documentation](https://plug.hexdocs.pm/1.19.2/Plug.Conn.html)

- [`Plug.Conn` source code](https://github.com/elixir-plug/plug/blob/v1.19.2/lib/plug/conn.ex#L3) on Github

# Dealing with WebSockets

`bandit` does not offer WebSockets natively and depends of 2 modules for doing that: `WebSock` and `WebSockAdapter`. The first one is used to deal with the events by "extending" the `Plug` behavior, the second one is used to initialize the WebSocket link with the client. The creation of a small `Plug` in charge of WebSockets connection still remains easy to implement. Let create a new endpoint called `Desperados.Endpoints.Websocket`.

```elixir
defmodule Desperados.Endpoints.Websocket do
  @behaviour Plug

  def init(_opts) do
    state = %{count: 0}
    {:ok, state}
  end

  def call(conn, _state) do
    WebSockAdapter.upgrade(conn, __MODULE__, %{}, timeout: 60_000)
    |> Plug.Conn.halt()
  end
  def call(conn, _opts), do: IO.inspect(conn)

  def handle_in(_event = {"ping\n", [opcode: opcode]}, state) do
    {:reply, :ok, {opcode, "pong\n"},
      state 
      |> Map.update(:count, 0, fn value ->
        value+1
      end)
    }
  end
  def handle_in(_event = {data, opcode: opcode}, state) do
    {:reply, :ok, {opcode, data}, state}
  end
end
```

This `Plug` assumes the client is starting to upgrade the HTTP connection to a WebSocket one. During the [`call/2`](https://plug.hexdocs.pm/1.19.2/Plug.html#c:call/2) callback, the [`WebSockAdapter.upgrade/4`](https://websock-adapter.hexdocs.pm/WebSockAdapter.html#upgrade/4) function is called to acknowledge the upgrade. The first argument is the connection, the second one is the module callback (in our case the name of the current module), the third argument is a state and fourth arguments are websocket connection options. If the handshake is valid, this function will give the control to this connection to a `WebSock` process.

In this situation, every time an events (e.g. messages) are received, they are transmitted to the [`handle_in/2`](https://websock.hexdocs.pm/WebSock.html#c:handle_in/2) function callback. The Plug router can be modified,

```elixir
defmodule Desperados.Plugs do
  use Plug.Builder
  plug Desperados.Plugs.Inspect
  plug Desperados.Endpoints.Websocket
end
```

The `Desperados.Endpoints.HTTP` has been removed there, because the pipeline cannot support both HTTP and WebSockets at the same time (for now). Again, let recompile the project.

```console
iex (3)> recompile
:ok
```

`curl` can now be used again, this time as a WebSocket client.

```console
$ curl -vT. --no-progress-meter ws://localhost:8082/test
* Host localhost:8082 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
* HTTPS-RR: -
*   Trying [::1]:8082...
* connect to ::1 port 8082 from ::1 port 36962 failed: Connection refused
*   Trying 127.0.0.1:8082...
* Established connection to localhost (127.0.0.1 port 8082) from 127.0.0.1 port 56496 
* using HTTP/1.x
> GET /test HTTP/1.1
> Host: localhost:8082
> User-Agent: curl/8.20.0
> Accept: */*
> Upgrade: websocket
> Sec-WebSocket-Version: 13
> Sec-WebSocket-Key: GIPpTnAnww9DUOoZGJSiYg==
> Connection: Upgrade
> 
* Request completely sent off
< HTTP/1.1 101 Switching Protocols
< date: Sat, 30 May 2026 18:12:50 GMT
< upgrade: websocket
< connection: Upgrade
< sec-websocket-accept: aMzngyTPS2svr8fgKowmhG9vb44=
< cache-control: max-age=0, private, must-revalidate
< 
* Received 101, Switching to WebSocket
* [WS] Received 101, switch to WebSocket
test
} [11 bytes data]
test
test
test
* upload completely sent off: 22 bytes
```

It works as expected, the WebSocket server is returning the messages we are sending. Now, I would like to also implement something neat, a plug to detect if the client wants to upgrade the connection and assign a `:websocket` tag to it if it's the case. In short: one path with HTTP and WebSocket support. Let create that in the next section.

If you want to know more about WebSockets in Elixir, here few links to read:

- [`WebSockAdapter` API documentation](https://websock-adapter.hexdocs.pm/WebSockAdapter.html), where you will learn how to upgrade an HTTP connection to a `WebSocket` one, including all available parameters;

- [`WebSock` API documentation](https://websock.hexdocs.pm/WebSock.html), where you will learn how to create a WebSocket callback module using the `WebSock` behavior;

- [`WebSockAdapter` module source code](https://github.com/phoenixframework/websock_adapter/blob/main/lib/websock_adapter.ex#L1) where all the transition between HTTP to WebSocket happens;

- [`WebSock` module source code](https://github.com/phoenixframework/websock/blob/main/lib/websock.ex#L1) where the `WebSock` behavior is implemented;

- The [Hello world websockets](https://plug.hexdocs.pm/1.19.2/readme.html#hello-world-websockets) Plug example for Phoenix framework application

# HTTP/WebSockets Multi Protocol Endpoint

Usually, one path only is set with WebSocket support. On many examples, one can see `/ws` endpoint is dedicated for this task but what if one is able to bypass this convention and let a path be compatible with both HTTP and WebSockets? Yeah, it's a bit dirty, but it's also a good way to learn how WebSockets is working.

The [WebSockets protocol](https://datatracker.ietf.org/doc/html/rfc6455) is starting with the client requesting a connection upgrade containing at least 3 mandatory HTTP headers:

- [`Upgrade`](https://datatracker.ietf.org/doc/html/rfc6455#section-11.2) set with the string `websocket`;

- [`Sec-WebSocket-Version`](https://datatracker.ietf.org/doc/html/rfc6455#section-11.3.5) set with the version (or the list of versions) of the WebSocket protocol to use;

- [`Sec-WebSocket-key`](https://datatracker.ietf.org/doc/html/rfc6455#section-11.3.1) set with a random string (usually a base64 one) and mostly used to ensure this is a correct WebSocket connection requested by the client.

With this information, a `Plug` can be created to check if those headers are present in the request. If it's the case, we can be pretty sure this is a WebSocket request from a client, else, this is probably a simple HTTP request. Let create a new `Plug` called `Desperados.Plugs.Websocket` to help us identify those kind of connections.

```elixir
defmodule Desperados.Plugs.Websocket do
  @behaviour Plug
  import Plug.Conn

  def init(_args), do: {:ok, %{}}

  def call(conn, state), do: header_upgrade(conn, state)

  defp header_upgrade(conn, state) do
    case get_req_header(conn, "upgrade") do
      [v = "websocket"] ->
        conn
        |> assign(:ws_info, [v])
        |> header_version(state)
      _ ->
        conn
    end
  end

  defp header_version(conn = %Plug.Conn{assigns: %{ws_info: ws}}, state) do
    case get_req_header(conn, "sec-websocket-version") do
      [v] ->
        conn
        |> assign(:ws_info, [v|ws])
        |> header_key(state)
      _ ->
        conn
    end
  end
  defp header_version(conn, _state), do: conn

  defp header_key(conn = %Plug.Conn{assigns: %{ws_info: ws}}, state) do
    case get_req_header(conn, "sec-websocket-key") do
      [k] ->
        conn
        |> assign(:ws_info, [k|ws])
        |> final(state)
      _ ->
        conn
    end
  end
  defp header_key(conn, _state), do: conn

  defp final(conn = %Plug.Conn{assigns: %{ws_info: [_,_,_]}}, _state) do
    assign(conn, :websocket, true)
  end
  defp final(conn, _state), do: conn
end
```

This is not a really complex `Plug`, every functions are acting like a waterfall, the first one is looking for the `Upgrade` header, if it's present, then it will call the second function. This one will look for the `Sec-Websocket-Version` header, if it's present, then it will call the third function to check if the `Sec-Websocket-Key` can be found. If those 3 headers are present, the `:websocket` key set to `true` is assigned to the connection.

The `Desperados.Endpoints.Websocket` needs a small patch now, to only start the upgrading process when a connection has the `:websocket` key assigned.

```elixir
defmodule Desperados.Endpoints.Websocket do
  @behaviour Plug

  def init(_opts) do
    state = %{count: 0}
    {:ok, state}
  end

  def call(conn = %Plug.Conn{assigns: %{websocket: true}}, _state) do
    WebSockAdapter.upgrade(conn, __MODULE__, %{}, timeout: 60_000)
    |> Plug.Conn.halt()
  end
  def call(conn, _opts), do: IO.inspect(conn)

  def handle_in(_event = {"ping\n", [opcode: opcode]}, state) do
    {:reply, :ok, {opcode, "pong\n"},
      state 
      |> Map.update(:count, 0, fn value ->
        value+1
      end)
    }
  end
  def handle_in(_event = {data, opcode: opcode}, state) do
    {:reply, :ok, {opcode, data}, state}
  end
end
```

The magic in the `call/2` callback function, with the pattern `%Plug.Conn{assigns: %{websocket: true}}`. If it matches, then the connection will be upgraded, else, it will simply returns the raw connection to the pipeline.

# Plug Pipeline

This is mostly done, one of the last section of this post. We have previously created a `Plug` to print the connection data-structure to stdout, then, a `Plug` to deal with HTTP requests and another one to deal with WebSockets. Another one was created to alter the connection data-structure and identify if a client is trying to initiate a WebSocket connection. Let update our pipeline.

```elixir
defmodule Desperados.Plugs do
  use Plug.Builder

  plug Desperados.Plugs.Websocket
  plug Desperados.Endpoints.Websocket
  plug Desperados.Endpoints.HTTP
end
```

Lean, isn't it? The first `Plug` will check the client request to see if it's a WebSocket upgrade, if it's the case, the second `Plug` will deal with it, else, the HTTP `Plug` will do the job. `Desperados.Plugs.Inspect` as be removed, it's currently not necessary to have it, but it can be added whenever needed.

# Final Test

This is the final part of this post, and it's now the time to test all the features. A test suite would have been the best thing to do, but this publication is already too long. Let just restart the application from scratch and play with `curl`.

```console
$ iex -S mix
Erlang/OTP 28 [erts-16.0.1] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [jit:ns]

Interactive Elixir (1.19.5) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> Desperados.start_link()

20:11:42.808 [debug] Running Desperados.Plugs with Bandit 1.11.1 at 0.0.0.0:8082 (http)
{:ok, #PID<0.245.0>}
```

Let run the `curl` WebSocket test:

```console
$ curl -vT. --no-progress-meter ws://localhost:8082/test
* Host localhost:8082 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
* HTTPS-RR: -
*   Trying [::1]:8082...
* connect to ::1 port 8082 from ::1 port 43916 failed: Connection refused
*   Trying 127.0.0.1:8082...
* Established connection to localhost (127.0.0.1 port 8082) from 127.0.0.1 port 39416 
* using HTTP/1.x
> GET /test HTTP/1.1
> Host: localhost:8082
> User-Agent: curl/8.20.0
> Accept: */*
> Upgrade: websocket
> Sec-WebSocket-Version: 13
> Sec-WebSocket-Key: 7S1xZKpgqoGgC+gI3dtKyQ==
> Connection: Upgrade
> 
* Request completely sent off
< HTTP/1.1 101 Switching Protocols
< date: Sat, 30 May 2026 18:42:15 GMT
< upgrade: websocket
< connection: Upgrade
< sec-websocket-accept: jLWCKodpG0BsuWJT39MhgZTNLq8=
< cache-control: max-age=0, private, must-revalidate
< 
* Received 101, Switching to WebSocket
* [WS] Received 101, switch to WebSocket
test
} [11 bytes data]
test
test
test
* upload completely sent off: 22 bytes
```

Let run the `curl` HTTP test:

```console
$ curl -v http://localhost:8082/test
* Host localhost:8082 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
* HTTPS-RR: -
*   Trying [::1]:8082...
* connect to ::1 port 8082 from ::1 port 40422 failed: Connection refused
*   Trying 127.0.0.1:8082...
* Established connection to localhost (127.0.0.1 port 8082) from 127.0.0.1 port 34666 
* using HTTP/1.x
> GET /test HTTP/1.1
> Host: localhost:8082
> User-Agent: curl/8.20.0
> Accept: */*
> 
* Request completely sent off
< HTTP/1.1 404 Not Found
< date: Sat, 30 May 2026 18:42:54 GMT
< content-length: 9
< vary: accept-encoding
< cache-control: max-age=0, private, must-revalidate
< 
* Connection #0 to host localhost:8082 left intact
not found
```

This is working! More is needed to make it production ready, but a client can use both HTTP or WebSockets protocol with the same endpoint! Yeah, that's not really useful, but it was a small objective just to demonstrate how `Plug`s can be used.

# Conclusion

The code required to create a really small HTTP/WebSocket server is incredibly lean. That's a good thing. Even more, if we are trusting the documentation, `bandit` is faster than `cowboy`. If we add the Elixir/Phoenix ecosystem, one can create a strong backend in a short amount of time with a huge ton of features.

Have fun!

----

Cover Image by <a href="https://unsplash.com/@richiemortis?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Richie Bettencourt</a> on <a href="https://unsplash.com/photos/a-close-up-of-a-spider-web-on-a-green-background-dtL0ElIr6Po?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>