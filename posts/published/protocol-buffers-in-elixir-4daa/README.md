---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/protocol-buffers-in-elixir-4daa"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2F3pg4dqvavuqtrv9pv094.jpg"
created_at: "None"
crossposted_at: "None"
description: "Serializing data is an important topic. The main goal is to convert some kind of data in another..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/protocol-buffers-in-elixir-4daa"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "protocol-buffers-in-elixir-4daa"
social_image: "None"
title: "Protocol Buffers in Elixir"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Protocol Buffers in Elixir

Serializing data is an important topic. The main goal is to convert some kind of data in another format compatible for some tasks, usually, to send them over the network. JSON is probably one of the most used serializer, but because of its simplicity, can be slow and can lead to other issues. Indeed, JSON is using a text-like format, and disallow usage of binary in any form - except if they are converted in base64 string for example. Furthermore, JSON does not optimize its payload and does not care by default of the data containing in it.

Today, we will talk a bit of Protocol Buffer or protobuf, a binary serializer format created by Google for their internal use. Instead of JSON, protobuf payload is using a binary format and its data format is specified. One can't add a new field in the payload without having created the specification for it.

# Requirements

[`protoc`](https://manpages.debian.org/trixie/protobuf-compiler/protoc.1.en.html) is required. One can install it from [the latest release on Github](https://github.com/protocolbuffers/protobuf/releases/tag/v35.1), or use one's package manager distribution. `protoc` is used to compile protocol buffer data structure definition in a specific language. In our case, we will need to install an external plugins to help `protoc` to generate Elixir modules.

```console
$ mix escript.install hex protobuf 0.16.0
...
```

# Bootstrapping

```console
$ mix new pb
* creating README.md
* creating .formatter.exs
* creating .gitignore
* creating mix.exs
* creating lib
* creating lib/pb.ex
* creating test
* creating test/test_helper.exs
* creating test/pb_test.exs

Your Mix project was created successfully.
You can use "mix" to compile it, test it, and more:

    cd pb
    mix test

Run "mix help" for more commands

$ cd pb

$ cat > mix.exs <<EOF
defmodule Pb.MixProject do
  use Mix.Project

  def project do
    [
      app: :pb,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application, do: [extra_applications: [:logger]]

  defp deps, do: [{:protobuf, "~> 0.17.0"}]
end

$ mix deps.get
Resolving Hex dependencies...
Resolution completed in 0.024s
New:
  protobuf 0.17.0
* Getting protobuf (Hex package)
EOF
```

```console
$ mix escript.install hex protobuf 0.16.0
...

$ export PATH=${PATH}:${HOME}/.mix/escripts
```

# Payload Specification

Let reuse again the rock-paper-scissors idea to design a new protobuf data-structure. The file will be stored in `./proto/v1/rps.proto`, but it could be perhaps better to store it in `./priv/proto/v1/rps.proto`, not sure yet. Actually, we don't really care for now, because this protocol buffer file will be compiled into Elixir module. The first step is to define the syntax we are using, in our case, [`proto3`](https://protobuf.dev/programming-guides/proto3/).

```protobuf
syntax = "proto3";
```

Then, we use the [`package`](https://protobuf.dev/programming-guides/proto3/#packages) keyword to create a new namespace. In our case, it will create an Elixir module prefixed by `Rps`.

```protobuf
package rps;
```

We have 3 shapes to create, an [`enum`](https://protobuf.dev/programming-guides/proto3/#enum) should do the job. By convention, the enumerated values should be [prefixed](https://protobuf.dev/programming-guides/proto3/#prefixing-values) to avoid naming conflict. When we will create a new Shape enum, the default value used will be `SHAPE_UNKNOWN`, because it's the [first one defined](protobuf.dev/programming-guides/proto3/#enum-default).

```protobuf
enum Shape {
  SHAPE_UNKNOWN = 0;
  SHAPE_ROCK = 1;
  SHAPE_PAPER = 2;
  SHAPE_SCISSORS = 3;
}
```

Our second main object we will use is the result of the game. We have 3 values to define, `win`, `draw` and `loss`; they can be defined as another `enum` following the same previously shown conventions.

```protobuf
enum Result {
  RESULT_UNKNOWN = 0;
  RESULT_WIN = 1;
  RESULT_DRAW = 2;
  RESULT_LOSS = 3;
}
```

Raw `enum`s are kinda useless without using them inside messages. The first one we can create is the data-structure sent by a player to a server, it will only contain - for now - a `Shape`. If you are not familiar with the protobuf syntax, like me when I started this publication, the type of the data is on far-left followed by the name of the field. The assignment is not an integer value, but the field number used by the [protocol buffer wire format](https://protobuf.dev/programming-guides/encoding/). In this case, the `shape` field will have the number `1` assigned.

```protobuf
message Play {
  Shape shape = 1;
}
```

Now, let try to define another data-structure for a player. A player will have an `id` as `integer`, and an optional name as `string`. Protobuf is offering a [wide range of scalar types](https://protobuf.dev/programming-guides/encoding/), the best one(s) will mostly depend of our needs.

```protobuf
message Player {
  int64 id = 1;
  optional string name = 2;
}
```

When a client is asking for an opponent, the servers should return a list of available players. Protocol buffer does not define something like a list of an array, instead, it uses the [`repeated` keyword](https://protobuf.dev/programming-guides/proto3/#other) to create a pseudo-list of objects while encoding or decoding the payload.

```protobuf
message Players {
  repeated Player players = 1;
}
```

The client select one player from the previous list and start to play with an other player as opponent. The data-structure will then contain a `player` object and a `shape` object.

```protobuf
message Play {
  Player player = 1;
  Shape shape = 2;
}
```

Finally, the server is returning the result, containing an unique `id` as `string`, player's informations and the final result for the player. I don't think this is the best data-structure to return because the `result` can lead to some confusion (who's the winner or loser?) but it will do the job for this example.

```protobuf
message PlayResult {
  string id = 1;
  Player player = 2;
  Player opponent = 3;
  Result result = 4;
}
```

If everything looks good, we can compile this protocol buffer file into an Elixir module with `protoc`. It will create the `./lib/proto/v1/rps.pb.ex` file.

```console
$ protoc --elixir_out=./lib proto/v1/rps.proto
```

Let invoke `iex` to play with these structures. To encode a `struct` in protobuf, we can use [`Protobuf.encode/1`](https://protobuf.hexdocs.pm/Protobuf.html#encode/1), it will return a `binary`. Here few examples from the message specifications defined above.

```console
$ iex -S mix
iex(1)> encoded_player = Protobuf.encode(
  %Rps.Player{
    id: 1,
    name: "test" 
  })
<<8, 1, 18, 4, 116, 101, 115, 116>>

iex(2)> Protobuf.encode(
  %Rps.Player{
    id: 2 
  })
<<8, 2>>

iex(3)> Protobuf.encode(
  %Rps.Players{
    players: []
  })
""

iex(4)> encoded_players = Protobuf.encode(
  %Rps.Players{
    players: [
      %Rps.Player{id: 1},
      %Rps.Player{id: 2, name: "test"}
    ]
  })
<<10, 2, 8, 1, 10, 8, 8, 2, 18, 4, 116, 101, 115, 116>>

iex(5)> encoded_play = Protobuf.encode(
  %Rps.Play{
    player: %Rps.Player{ id: 1},
    shape: 1 
  })
<<10, 2, 8, 1, 16, 1>>

iex(6)> encoded_play = Protobuf.encode(
  %Rps.Play{
    player: %Rps.Player{ id: 1},
    shape: :SHAPE_ROCK
  })
<<10, 2, 8, 1, 16, 1>>

iex(7)> encoded_playresult = Protobuf.encode(
  %Rps.PlayResult{
    id: "random_string",
    result: :RESULT_WIN,
    player: %Rps.Player{id: 1},
    opponent: %Rps.Player{id: 2}
  })
<<10, 13, 114, 97, 110, 100, 111, 109,
  95, 115, 116, 114, 105, 110, 103, 18,
  2, 8, 1, 26, 2, 8, 2, 32, 1>>
```

When it comes to decode, one can use [`Protobuf.decode/2`](https://protobuf.hexdocs.pm/Protobuf.html#decode/3) or [`Protobuf.decode/3`](https://protobuf.hexdocs.pm/Protobuf.html#decode/3). The first argument is the encoded binary and the second is the Elixir module required to decode the payload.

```console
iex(8)> Protobuf.decode(encoded_player, Rps.Player)
%Rps.Player{
  id: 1,
  name: "test",
  __unknown_fields__: [],
  __protobuf__: true
}

iex(9)> Protobuf.decode(encoded_players, Rps.Players)
%Rps.Players{
  players: [
    %Rps.Player{id: 1, name: nil, __unknown_fields__: [], __protobuf__: true},
    %Rps.Player{id: 2, name: "test", __unknown_fields__: [], __protobuf__: true}
  ],
  __unknown_fields__: [],
  __protobuf__: true
}

iex(10)> Protobuf.decode(encoded_playresult, Rps.PlayResult)
%Rps.PlayResult{
  id: "random_string",
  player: %Rps.Player{
    id: 1,
    name: nil,
    __unknown_fields__: [],
    __protobuf__: true
  },
  opponent: %Rps.Player{
    id: 2,
    name: nil,
    __unknown_fields__: [],
    __protobuf__: true
  },
  result: :RESULT_WIN,
  __unknown_fields__: [],
  __protobuf__: true
}
```

Finally, Here the generated Elixir module by `protoc` you can find in `./lib/proto/v1/rps.pb.ex`:

```elixir
defmodule Rps.Shape do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "rps.Shape",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :SHAPE_UNKONWN, 0
  field :SHAPE_ROCK, 1
  field :SHAPE_PAPER, 2
  field :SHAPE_SCISSORS, 3
end

defmodule Rps.Result do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "rps.Result",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :RESULT_UNKONWN, 0
  field :RESULT_WIN, 1
  field :RESULT_DRAW, 2
  field :RESULT_LOSS, 3
end

defmodule Rps.Player do
  @moduledoc false

  use Protobuf, full_name: "rps.Player", protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  field :id, 1, type: :int64
  field :name, 2, proto3_optional: true, type: :string
end

defmodule Rps.Play do
  @moduledoc false

  use Protobuf, full_name: "rps.Play", protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  field :player, 1, type: Rps.Player
  field :shape, 2, type: Rps.Shape, enum: true
end

defmodule Rps.PlayResult do
  @moduledoc false

  use Protobuf, full_name: "rps.PlayResult", protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  field :id, 1, type: :string
  field :player, 2, type: Rps.Player
  field :opponent, 3, type: Rps.Player
  field :result, 4, type: Rps.Result, enum: true
end

defmodule Rps.Players do
  @moduledoc false

  use Protobuf, full_name: "rps.Players", protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  field :players, 1, repeated: true, type: Rps.Player
end
```

# Layered Design

While doing all those tests, I was thinking if it was a "good practices" or even possible to use protobuf with layers, a bit like a network packet. For example, a first payload is containing a protobuf header with the last part encoded as bytes. This header could then be used to help the decoder to know what kind of data is stored.

```protobuf
package layer;

message header {
  // checksum = "sha256-checksum"
  required string checksum = 1;

  // type = "application/protobuf/players"
  required string type = 2;

  // payload = protobuf binary for players object
  required bytes payload = 3;
}
```

Let compile it...

```console
$ protoc --elixir_out=./lib/ proto/v1/layer.proto
```

... And start a new shell to play with that.

```console
iex(1)> encoded_players = Protobuf.encode(%Rps.Players{ players: [%Rps.Player{ id: 1}] })
<<10, 2, 8, 1>>

iex(2)> encoded_headers =  Protobuf.encode(
  %Layer.Header{
    checksum: Base.encode64(
      :crypto.hash(:sha256, encoded_players)
    ),
    type: "application/protobuf/players",
    payload: encoded_players
  })
<<10, 44, 87, 90, 83, 69, 79, 81, 90, 102, 75, 87, 71, 101, 57, 66, 75, 65, 121,
  55, 107, 121, 118, 108, 76, 70, 98, 90, 110, 70, 108, 109, 116, 108, 52, 66,
  69, 83, 79, 102, 67, 89, 117, 43, 56, 61, 18, 28, 97, 112, 112, 108, 105, 99,
  97, 116, 105, 111, 110, 47, 112, 114, 111, 116, 111, 98, 117, 102, 47, 112,
  108, 97, 121, 101, 114, 115, 26, 4, 10, 2, 8, 1>>
```

With this kind of structure, we can then encapsulate different kind of data without parsing them. In fact, we can also put more metadata in the headers to help the application to know what kind of format is stored in the payload. Even more, one could also add some encryption feature there. Unfortunately, I don't know if it's a good practice, because it can probably make things a bit confusing, but also more flexible. Here the code generated in `lib/proto/v1/layer.pb.ex`:

```elixir
defmodule Layer.Header do
  @moduledoc false

  use Protobuf, full_name: "layer.header", protoc_gen_elixir_version: "0.16.0", syntax: :proto2

  field :checksum, 1, required: true, type: :string
  field :type, 2, required: true, type: :string
  field :payload, 3, required: true, type: :bytes
end
```

# Conclusion

This article was just a warmup, a kind of sandbox to see the capabilities of Protocol Buffer. At the same time, I was also looking to the [FlatBuffers](https://flatbuffers.dev/) protocol trying to identify the difference between both format. I would prefer to use [CBOR](https://cbor.io/) for my projects, but I would also like to avoid using too much dependencies from unknown repositories. Furthermore, `protobuf` Dart package is already used by Dart and Flutter (for metrics IIRC), it can also be used for messaging as well.

The previous code is containing a lot of design flaws, they can be "easily" fixed by redesigning a bit the data-structures and adding few of them. The procedure should look like that:

1. A connected client (with an active session) to the server list the available `Players`;

2. The client ask the server to create a new `Arena` for with one available `Player`;

3. The server returns an `Arena` containing an unique identifier, the name of the two players and arena's state (`waiting`, `declined`, `ready`, `active`, `done`). A `waiting` state is when the arena is waiting for the 2 players to become ready. A `ready` state is when both player are `ready` and can start playing together. An `active` state is when both players are playing. A `done` state is when the game is over, and one player won. A `declined` state is when the opponent declined the invitation;

4. When the server is in `ready` or `active` state, both players can send their `Shape`. The server returns a `Result`. If one win, the Arena's state switch to `done`.

Designing even a small game is not easy, but it can lead to really interesting result. We have a concrete example of distributed complexity there, with one user sending some data, waiting for result, and one actor (the server) keeping a private state to deal with both users.

Anyway, it was the first article on Protobuf and probably not the last one. I know you would like to dig a bit more on this topic, as usual, a list of resources:

- [`protobuf` Elixir module](https://hex.pm/packages/protobuf) on hex.pm;

- [`protobuf` Elixir source code](https://github.com/elixir-protobuf/protobuf) on Github;

- [`protobuf` Elixir module test source code](https://github.com/elixir-protobuf/protobuf/tree/main/test);

- [Official Protobuf Best Practices](https://protobuf.dev/best-practices/dos-donts/);

- [Official Protobuf Google Group](https://groups.google.com/g/protobuf/);

- [`erlang_protobuffs` Erlang module](https://github.com/basho/erlang_protobuffs) on github;

- [Protocol Buffer Best Practices](https://jsontotable.org/blog/protobuf/protobuf-best-practices) on JsonToTable.org;

- [Roadmap to Learning Protobuf & Best Practices](https://medium.com/@yusufss/roadmap-to-learning-protobuf-best-practices-5b5b60781997) by [Yusuf Savaş](https://medium.com/@yusufss) at Medium;

- [How to Handle Protocol Buffer Evolution](https://oneuptime.com/blog/post/2026-01-24-protocol-buffer-evolution/view) from OneUptime.com;

- [Protocol Buffers](https://link.springer.com/content/pdf/10.1007/978-3-030-98467-0_9.pdf) by Chris Currier from [Mobile Forensics – The File Format Handbook](https://link.springer.com/book/10.1007/978-3-030-98467-0);

- [Cheatsheet - Protocol Buffers (Protobuf)](https://www.hackingnote.com/en/cheatsheets/protobuf/) from Hacking Notes;

- [Protocol Buffers for (Coding) Dummies](https://github.com/codethecoffee/proto-cheatsheet) on Github

- [Protocol Buffers Handbook](https://www.packtpub.com/en-fr/product/protocol-buffers-handbook-9781805127215) by Clément Jean.

Happy Hack and Have Fun!

----

Cover Image by <a href="https://unsplash.com/@mszerszynski?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Mateusz Szerszyński</a> on <a href="https://unsplash.com/photos/two-puffins-are-close-to-each-other-Da9wCD1-Rus?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>