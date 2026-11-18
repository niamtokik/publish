---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/kanell0-yet-another-pipeline-like-library-2epo"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2F3uzkq2zwun7uuflth91s.jpg"
created_at: "None"
crossposted_at: "None"
description: "When I started to work with Dart and Flutter, few weeks ago, I was looking for something like Erlang..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/kanell0-yet-another-pipeline-like-library-2epo"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "kanell0-yet-another-pipeline-like-library-2epo"
social_image: "None"
title: "Kanell/0, Yet Another Pipeline-like Library"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Kanell/0, Yet Another Pipeline-like Library

When I started to work with Dart and Flutter, few weeks ago, I was looking for something like [Erlang](https://www.erlang.org/) finite state machine or [Elixir](https://elixir-lang.org/) [`Plug`](https://plug.hexdocs.pm/readme.html). The first one is most about dealing with state change and events, the second is to easily compose data-structures over functions. In both case, when a developer starts to use one of them, it is impossible to come back, and one will try to reproduce it in any language (in my case, I tried to reimplement them in [Perl](https://www.perl.org/) and [Prolog](https://www.swi-prolog.org/)).

What's the plan then? Well, if you are reading my publications, you probably saw few posts on reverse engineering. While I was writing them, I was also looking for functional oriented programming in Dart to make my life easier. I discovered a lot of nice libraries I will show you soon, but, I did not find something close to Erlang/Elixir design patterns. Indeed, it's fascinating how reverse engineering protocols is easy with Erlang and Elixir - mostly due to the syntax - and having a way to manage a state easily could be really helpful.

# Erlang Pipeline

Every Unix/Linux user should already know what a [pipeline](https://man.openbsd.org/pipe) is, the output of a function is the input of the next one. When using Unix/Linux and a shell, input or output are generally strings, but when you switch to another languages, you can have different kind of data-structure. My own definition of pipeline in [Erlang](https://www.erlang.org/) is perhaps not the same than other developers, and is coming from the KISS (Keep It Simple Stupid) philosophy from Unix early days. Before showing you an example in Dart, I will show you an Erlang snippet to explain how I see a pipeline. First, let define a module called `pipeline` which will be used as behavior later.

```erlang
-module(pipeline).
-export([run/2, run/3]).
-export([start/2, start/3]).
-export([start_link/2, start_link/3]).
```

Type definitions can make our life easier when creating behaviors in Erlang, it's not mandatory though.

```erlang
-type args() :: term().
-type state() :: term().
-type reason() :: term().
-type result() :: {ok, state()}
                | {keep, state()}
                | {next, function(), state()}
                | {next, module(), function(), state()}
                | {stop, reason(), state()}.
-callback init(args()) -> result().
-callback 'StateName'(state()) -> result().
-optional_callback(['StateName'/1]).
```

A way to start the pipeline is required, two functions will be created for that, `run/2` and `run/3`. Those functions will run the pipeline in the current process.

```erlang
-spec run(Module, Args) -> Return when
  Module :: module(),
  Args :: term(),
  Return :: result().

run(Module, Args) ->
  run(Module, init, Args).

-spec run(Module, Function, Args) -> Return when
  Module :: module(),
  Function :: atom(),
  Args :: term(),
  Return :: result().

run(Module, Function, Args) ->
  do_loop(Module, Function, Args).
```

Erlang is great to isolate things inside processes, let create new functions called `start/2` and `start/3` to start the pipeline in an isolated process, outside of the main one.

```erlang
-spec start(Module, Args) -> Return when
  Module :: module(),
  Args :: term(),
  Return :: result().

start(Module, Args) ->
  start(Module, init, Args).

-spec start(Module, Function, Args) -> Return when
  Module :: module(),
  Function :: atom(),
  Args :: term(),
  Return :: result().

start(Module, Function, Args) ->
  spawn(fun() ->
    run(Module, Function, Args)
  end).
```

We can eventually do the same with a linked or monitored process, let call those functions `start_link/2` and `start_link/3`.

```erlang
-spec start_link(Module, Args) -> Return when
  Module :: module(),
  Args :: term(),
  Return :: any().

start_link(Module, Args) ->
  start_link(Module, init, Args).

-spec start_link(Module, Function, Args) -> Return when
  Module :: module(),
  Function :: atom(),
  Args :: term(),
  Return :: any().

start_link(Module, Function, Args) ->
  spawn_link(fun() ->
    run(Module, Function, Args)
  end).
```

A router for the returned data from the callback functions is now required, this function will be called `do_route/3`. When a valid returned value is returned by `do_loop/3`, a new function is called with the updated state.

```erlang
-spec do_route(Module, Function, Result) -> Return when
  Module :: module(),
  Function :: atom(),
  Result :: result(),
  Return :: result().

do_route(_Module, _Function, {ok, NewState}) ->
  {ok, NewState};
do_route(_Module, _Function, {stop, Reason, NewState}) ->
  {stop, Reason, NewState};
do_route(Module, Function, {keep, NewState}) ->
  do_loop(Module, Function, NewState);
do_route(Module, _Function, {next, NewFunction, NewState}) ->
  do_loop(Module, NewFunction, NewState);
do_route(_Module, _Functon, {next, NewModule, NewFunction, NewState}) ->
  do_loop(NewModule, NewFunction, NewState);
do_route(Module, Function, Result) ->
  throw({Module, Function, Result}).
```

Finally, the `do_loop/3` function will use [`erlang:apply/3`](https://www.erlang.org/doc/apps/erts/erlang.html#apply/3) function to execute the module/function returned by a function callback, with the state provided.

```erlang
-spec do_loop(Module, Function, State) -> Return when
  Module :: module(),
  Function :: atom(),
  State :: term(),
  Return :: result().

do_loop(Module, Function, State) ->
  Result = erlang:apply(Module, Function, [State]),
  do_route(Module, Function, Result).
```

If you don't have the habit to code with Erlang or dynamic language, the idea is really let the developer creating a flow of actions. But an example is probably a better way to understand the concept. The `checker` module is using the `pipeline` behavior previously defined, and will export few functions. The `run/1` function is a wrapper around `pipeline:run/1`. The `init/1` is the function entry-point for the pipeline, it will decide which will be the next function callback to call. Finally the `increment/1`, `decrement/1` and `final/1` are the callback functions, they will receive the state and modify it until the end of the pipeline.

```erlang
-module(checker).
-behavior(pipeline).
-export([run/1]).
-export([init/1]).
-export([increment/1, decrement/1, final/1]).

run(Args) ->
  pipeline:run(?MODULE, Args).

init(_Args) ->
  io:format("init~n"),
  {next, increment, 0}.

increment(State) ->
  io:format("increment~n"),
  {next, decrement, State+1}.

decrement(State) ->
  io:format("decrement~n"),
  {next, final, State-1}.

final(State) ->
  io:format("final~n"),
  {ok, State}.
```

What's happening when the `checker:run/1` function is called?

```console
1> c(pipeline).
{ok, pipeline}

2> c(checker).
{ok, checker}

3> checker:run(0).
init
increment
decrement
final
{ok,0}
```

As you can see, every functions are executed in order, and the final result is returned. Can you see the power of these modules? One small function for one small action, returning one structured data-structure. It will help to create better specification, documentation, test coverage and better understanding of the whole code. If the procedure needs to be updated, creating a new function and modifying the routing will be the only task to do. Here an extended version of the `checker` module.

```erlang
%%%===================================================================
%%% @doc A simple pipeline-like module, inspired by `gen_statem'.
%%% @end
%%%===================================================================
-module(checker).
-behavior(pipeline).
-export([run/1]).
-export([init/1]).
-export([increment/1, decrement/1, final/1]).
-include_lib("eunit/include/eunit.hrl").

%%--------------------------------------------------------------------
%% @doc A wrapper around `pipeline:run/2'.
%% @end
%%--------------------------------------------------------------------
-spec run(Args) -> Return when
  Args :: term(),
  Return :: pipeline:result().

run(Args) ->
  pipeline:run(?MODULE, Args).

%%--------------------------------------------------------------------
%% @doc Entry-point.
%% @end
%%--------------------------------------------------------------------
-spec init(Args) -> Return when
  Args :: term(),
  Return :: pipeline:result().

init(_Args) ->
  io:format("init~n"),
  {next, increment, 0}.

init_test() ->
  ?assertEqual({next, increment, 0}, init([])).

%%--------------------------------------------------------------------
%% @doc An increment function to increment an `integer()'.
%% @end
%%--------------------------------------------------------------------
-spec increment(State) -> Return when
  State :: integer(),
  Return :: {next, decrement, State}.

increment(State) ->
  io:format("increment~n"),
  {next, decrement, State+1}.

increment_test() ->
  ?assertEqual({next, decrement, 1}, increment(0)).

%%--------------------------------------------------------------------
%% @doc A decrement function to decrement an `integer()'.
%% @end
%%--------------------------------------------------------------------
-spec decrement(State) -> Return when
  State :: integer(),
  Return :: {next, final, State}.

decrement(State) ->
  io:format("decrement~n"),
  {next, final, State-1}.

decrement_test() ->
  ?assertEqual({next, final, 0}, decrement(1)).

%%--------------------------------------------------------------------
%% @doc The final function, returning the final state (as `integer()').
%% @end
%%--------------------------------------------------------------------
-spec final(State) -> Return when
  State :: term(),
  Return :: {ok, State}.

final(State) ->
  io:format("final~n"),
  {ok, State}.

final_test() ->
  ?assertEqual({ok, 0}, final(0)).
```

Just to be sure, we can compile it and run the test suite.

```console
4> c(checker).
{ok,checker}

5> checker:test().
  All 4 tests passed.
ok
```

All successful, but the idea is to have one function doing one small tasks and enough place to document it. To me, this is the cleanest way of coding one can do. It's elegant, self-documented, and specified. Mocking features is also easy, because the input and the output are fully in-control. It's flexible, one can easily create a loop between those functions... So, is it possible to create something similar with Dart?

# Kanell Pipeline

Dart is statically typed, it will be hard to have the same flexibility than Erlang or Elixir, but it's still possible to do cool stuff. Before starting with a complex implementation including routing or asynchronous call, a simple linear pipeline should do the job.

Most of the steps of the pipeline will be defined during compile time, while in Erlang, it could be possible to define them during runtime (even if the previous example does not show that, it's possible to do it). I would like to also avoid unnecessary object creation, then, static functions or lambda function will be used. Only the state will pass between the different stage of the pipeline, and - at this time - only the pipeline will be instantiated at the beginning. An example can be seen below. 

```dart
import 'package:kanell/kanell.dart';

void main() {
  var pipeline = Pipeline();

  pipeline.add(_increment);
  pipeline.add(_increment);
  pipeline.add(_increment);

  Flow flow = Flow(data: 0);

  var result = pipeline.apply(flow);
  print(result)
}

Flow _increment(Flow flow) {
  flow.data += 1;
  return flow;
}
```

As you can see, the code is quite different. I'm currently trying to deal with the feature itself, without types (I find the Dart types annotation annoying and confusing), but the idea is already present. Let explain a bit this code.

A `pipeline` is created using the `Pipeline` class from `kanell` module (be careful, Dart already got a class called [`Pipe`](https://api.dart.dev/dart-io/Pipe-class.html)). This object is a simple wrapper around a list defined by `List<Function(Flow)>` (a list containing functions accepting `Flow` object).

A function can be added to the pipeline with the `pipeline.add()` method. In this example, `_increment()` static function is added three time.

A `Flow` object is also required, this is the equivalent of the `State` variable in the Erlang example. It will contain a `Status`, mimicking the Erlang atoms `ok`, `error` or `stop`, and the data to be passed through the pipeline (via the `data` parameter).

When the pipeline is ready, one can call `pipeline.apply()` method with a `Flow` object, it will then return the final value as result. This is not like what we have in Erlang, but that's the first step. In fact, we could eventually create named `Pipe`, an object containing a name as `String` and a `Function(Flow)` stored somewhere. When a `Flow` is returned, it could contain the name of the function to call after.

# What's the Point?

One reading this article would think it's just another way to deal with state, no real advantage. In fact, if you remember the first paragraphs of this post, this method is really helpful to deal with unstable interfaces, or undocumented interfaces. Every steps are documented, in case of failure, only a small part of the pipeline can be fixed or a new pipe can be added between actual pipes.

# Conclusion

I hope this article is the first one of a long series. It's also my first Dart package. I'm not really sure if this is a good idea to implement this kind of high level procedure from a functional language like Erlang in Dart. For example, asynchronous calls, or reusable named pipeline can probably have lot of side effects. At this time, this is just a test, another way to learn more of Dart and to try to make my developer experience better.

The [`kanell`](https://github.com/niamtokik/kanell) package is currently in active development (version 0.1.0 released) but can be seen on my Github profile. It will evolve, perhaps with your help, but also with few publications to explain why and how I did those choices.

As last note, the Erlang snippet presented here is a smaller version of the one provided by the [`automata`](https://github.com/erlang-punch/automata) project created for Erlang-Punch. An article will be published on this topic, so, stay tuned. Wants to know a bit more about my research?

- [`pipeliner` module](https://pub.dev/packages/pipeliner) can be an alternative to my package in Dart;

- [`pipeline_plus` module](https://pub.dev/packages/pipeline_plus) is yet another alternative in Dart;

- [Erlang `gen_statem` behavior](https://www.erlang.org/doc/apps/stdlib/gen_statem.html), the main source of inspiration;

- [Erlang `gen_fsm` behavior](https://www.erlang.org/doc/apps/stdlib/gen_fsm.html), an old finite state machine implementation in Erlang;

- [Elixir `Plug` module](https://plug.hexdocs.pm/readme.html), the best example for a middleware/pipeline feature.

Enjoy and Happy Hack!

----

Cover Image by <a href="https://unsplash.com/@theblowup?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">the blowup</a> on <a href="https://unsplash.com/photos/gray-plastic-cups-on-wooden-table-lqx_D7xIZ2o?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>