---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/qd-anonymous-recursive-functions-in-elixir-4oop"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Fgio8o0ubioga5f3hwyny.jpg"
created_at: "None"
crossposted_at: "None"
description: "Some people prefer Elixir syntax over Erlang syntax, that's their opinion, but if you are like me,..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/qd-anonymous-recursive-functions-in-elixir-4oop"
public_reactions_count: "1"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "qd-anonymous-recursive-functions-in-elixir-4oop"
social_image: "None"
title: "Q&D: Anonymous Recursive Functions in Elixir"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Q&D: Anonymous Recursive Functions in Elixir

Some people prefer Elixir syntax over Erlang syntax, that's their opinion, but if you are like me, you probably knows how Erlang explicitness and conciseness make everything better. I recently needed to quickly debug a piece of code on a running node using Elixir, and while doing that, spawning processes can be helpful to store information, simulate stuff and so on. In Erlang, a recursive anonymous function looks like that:

```console
1> F = fun F() ->
  receive
    exit -> ok;
    Msg -> io:format("~p~n", [Msg]),
    F()
  end
end.
#Fun<erl_eval.20.113135111>

2> P = spawn(F).
<0.151.0>

3> P ! {self(), test}.
{<0.113.0>,test}
{<0.113.0>,test}
```

The same is a bit different in Elixir, due to the syntax. Based on the documentation, it is not fixed, but if I'm wrong, don't hesitate to comment. Anyway, here the solution:

```console
iex> f = fn (f) ->
  receive do
    :exit -> :ok
    msg -> 
      IO.inspect(msg)
      f.(f)
  end
end
#Function<42.113135111/1 in :erl_eval.expr/6>

iex> p = spawn(fn -> f.(f) end)
#PID<0.725.0>

iex> send(p, {self(), :test})
{#PID<0.724.0>, :test}
{#PID<0.724.0>, :test}
```

Just to be clear, the same idea can also be done in Erlang, but with the syntactic sugar around the anonymous function, it's way easier to create recursive loop.

```console
1> F2 = fun (F2) ->
  receive
    exit -> ok;
    Msg -> io:format("~p~n", [Msg]),
    F2(F2)
  end
end.
#Fun<erl_eval.42.113135111>

2> P2 = spawn(fun() -> F2(F2) end).
<0.157.0>

3> P2 ! {self(), test}.
{<0.113.0>,test}
{<0.113.0>,test}
```

This method can be a bit more flexible though, because the state of the recursive function, is a function, one can create an interface to update it dynamically during code execution. 

```elixir
iex> f2 = fn (f2) ->
  receive do
    :exit -> :ok
    {:update, fup} when is_function(fup) ->
      fup.(fup)
    msg -> 
      IO.inspect(msg)
      f2.(f2)
  end
end
#Function<42.113135111/1 in :erl_eval.expr/6>

iex> f3 = fn (f3) ->
  receive do
    :exit -> :ok
    {:update, fup} when is_function(fup) ->
      fup.(fup)
    msg -> 
      IO.puts("f3: #{inspect msg}")
      f3.(f3)
  end
end
#Function<42.113135111/1 in :erl_eval.expr/6>

iex> p = spawn(fn() -> f2.(f2) end)
#PID<0.733.0>

iex> send(p, {self(), :test})
{#PID<0.724.0>, :test}
{#PID<0.724.0>, :test}

iex> send(p, {:update, f3})
{:update, #Function<42.113135111/1 in :erl_eval.expr/6>}

iex>  send(p, {self(), :test})
{#PID<0.724.0>, :test}
f3: {#PID<0.724.0>, :test}
```

As you can see, the main loop can be updated on demand, useful when we need to debug or trace something quick, and insert receive patterns.

----

Cover Image by <a href="https://unsplash.com/@rokkon?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Jan Ranft</a> on <a href="https://unsplash.com/photos/clear-glass-bottles-in-brown-wooden-box-oduOp0RlPf8?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>