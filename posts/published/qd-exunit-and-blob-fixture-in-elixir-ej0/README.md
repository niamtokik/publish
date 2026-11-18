---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/qd-exunit-and-blob-fixture-in-elixir-ej0"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2F7v5s9raqgwbnahc76y7p.jpg"
created_at: "None"
crossposted_at: "None"
description: "Another quick and dirty post regarding Elixir. This one will be really quick, but I was working on..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/qd-exunit-and-blob-fixture-in-elixir-ej0"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "qd-exunit-and-blob-fixture-in-elixir-ej0"
social_image: "None"
title: "Q&D: ExUnit and Blob Fixture in Elixir"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Q&D: ExUnit and Blob Fixture in Elixir

Another quick and dirty post regarding Elixir. This one will be really quick, but I was working on test unit recently, and was stuck for few minutes about where I could put my fixtures, and especially... some raw blobs. In Erlang, with `common_test`, the path is directly passed in the options and it is easy to use. In Elixir, it's a bit different, the relative path of the test suite is stored in the [`__DIR__`](https://elixir.hexdocs.pm/1.12/Kernel.SpecialForms.html#__DIR__/0) macro. This small trick get lost in my mind. Here an example.

```console
$ mix new blob
* creating README.md
* creating .formatter.exs
* creating .gitignore
* creating mix.exs
* creating lib
* creating lib/blob.ex
* creating test
* creating test/test_helper.exs
* creating test/blob_test.exs

Your Mix project was created successfully.
You can use "mix" to compile it, test it, and more:

    cd blob
    mix test

Run "mix help" for more commands.

$ cd blob
```

A fixtures directory can be helpful, let creates one.

```console
$ mkdir -p test/fixtures
```

To do the test, let create also a file called `blob.txt` containing an encoded string in base64 via [`openssl`](https://man.openbsd.org/openssl#enc).

```console
$ printf "this is a test" | openssl enc -base64 > test/fixture/blob.txt
```

The project created for this example is a simple library, the project configuration file [`mix.exs`](https://elixir.hexdocs.pm/introduction-to-mix.html#project-compilation) must be updated to allow other files to be loaded during the test execution. This is configured in [`:test_load_filters`](https://mix.hexdocs.pm/Mix.Tasks.Test.html#module-configuration) section, all files ending with `_test.exs` and `_fixtures.exs` must be loaded.

```elixir
defmodule Blob.MixProject do
  use Mix.Project

  def project do
    [
      app: :blob,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_load_filters: [
        &String.ends_with?(&1, "_test.exs"),
        &String.ends_with?(&1, "_fixtures.exs")
      ]
    ]
  end
  # ...
end
```

An helper function to have access to the fixtures can be created. It's not mandatory, but it's easier to call something like `BlobFixtures.read_blob/1` instead of recreating the same procedure everytime. DRY.

```elixir
defmodule BlobFixtures do
  def read_blob(relative_path) do
    [__DIR__, "fixtures", relative_path]
    |> Path.join()
    |> File.read!()
  end
end
```

The test suite can now be updated. The blob is read from the file system and pushed in the test suite.

```elixir
defmodule BlobTest do
  use ExUnit.Case
  doctest Blob

  # ...

  test "read from file" do
    assert "this is a test" ==
      BlobFixtures.read_blob("blob.txt")
      |> String.trim()
      |> Base.decode64!()
      # only for the example
      |> IO.inspect()
  end
end
```

Finally, [`mix test`](https://mix.hexdocs.pm/Mix.Tasks.Test.html) can be called, and it should be green. The decoded message should be printed as well.

```console
$ mix test
Running ExUnit with seed: 423336, max_cases: 16

"this is a test"
...
Finished in 0.04 seconds (0.00s async, 0.04s sync)
1 doctest, 2 tests, 0 failures
```

Indeed, it was a quick note! As usual, have fun and happy hacking!

----

Cover Image by <a href="https://unsplash.com/@connorgan?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Connor Gan</a> on <a href="https://unsplash.com/photos/glowing-potion-bottle-lamp-and-blocks-F7zCI2jTR2A?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>