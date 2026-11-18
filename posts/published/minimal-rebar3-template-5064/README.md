---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/minimal-rebar3-template-5064"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fviw92nd40zcytkc70nom.jpg"
created_at: "None"
crossposted_at: "None"
description: "rebar3 is not the best project manager ever created, but it does the job. When it comes to Erlang,..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/minimal-rebar3-template-5064"
public_reactions_count: "1"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "minimal-rebar3-template-5064"
social_image: "None"
title: "Minimal Rebar3 Template"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Minimal Rebar3 Template

[`rebar3`](https://rebar3.org/) is not the best project manager ever created, but it does the job. When it comes to Erlang, one does not have a lot of choice anyway, we can switch to [`erlang.mk`](https://erlang.mk/) or use any other random projects from some unknown guys. One can also try to use [`Mix`](https://hexdocs.pm/elixir/introduction-to-mix.html) from Elixir to deal with Erlang project, it can be fun.

Did you know rebar3 can create new application using templates like most of the modern project manager? Let me show you that. This publication will be a minimal [template](https://www.rebar3.org/docs/tutorials/templates/). The first thing to do is to be sure the `templates` directory exist in your home directory.

```sh
mkdir -p ${HOME}/.config/rebar3/templates/
```

Global variables can be created and modified in the file `globals` file.

```sh
cat > ${HOME}/.config/rebar3/templates/globals << EOF
{variables, [
]}.
EOF
```

A file called `my_template_name.template` can now be created, in our case, it will be called `minimal.template`. This file contains the rules to create the project tree using a [mustache](https://github.com/mojombo/mustache.erl)-like system.

```sh
mkdir -p ${HOME}/.config/rebar3/templates/minimal
cat >  ${HOME}/.config/rebar3/templates/minimal.template << EOF
{description, "minimalist template"}.
{variables, []}.

{dir, "{{name}}"}.
{file, "minimal/_gitignore", "{{name}}/.gitignore"}.
{file, "minimal/_tool-versions", "{{name}}/.tool-versions"}.
{file, "minimal/AGENTS.md", "{{name}}/AGENTS.md"}.
{file, "minimal/README.md", "{{name}}/README.md"}.
{file, "minimal/CONTRIBUTING.md", "{{name}}/CONTRIBUTING.md"}.
{file, "minimal/SECURITY.md", "{{name}}/SECURITY.md"}.
{template, "minimal/LICENSE", "{{name}}/LICENSE"}.
{template, "minimal/rebar.config", "{{name}}/rebar.config"}.
{template, "minimal/Makefile", "{{name}}/Makefile"}.

{dir, "{{name}}/src"}.
{template, "minimal/src/minimal.app.src", "{{name}}/src/{{name}}.app.src"}.
{template, "minimal/src/minimal.erl", "{{name}}/src/{{name}}.erl"}.
{template, "minimal/src/minimal_app.erl", "{{name}}/src/{{name}}_app.erl"}.
{template, "minimal/src/minimal_sup.erl", "{{name}}/src/{{name}}_sup.erl"}.

{dir, "{{name}}/test"}.
{template, "minimal/test/minimal_SUITE.erl", "{{name}}/test/{{name}}_SUITE.erl"}.
EOF
```

The `{{name}}` term is a mustache pattern, it will print the content of the variable `name`, passed during the project creation.

# Rebar3 Configuration Template

The `rebar3.config` file can be generated. Here a minimal template for this one:

```erlang
{erl_opts, [debug_info]}.
{deps, []}.
{shell, [{apps, {{name}}}]}.
```

All other parameters can be seen on the [official rebar3 base config documentation](https://rebar3.org/docs/configuration/configuration/).

# Erlang Template Source Files

Now, we can create Erlang code. The first one to create will be `src/{{name}}.app.src` file, the [`app`](https://www.erlang.org/doc/apps/kernel/app.html) file describing the required resources used by the application.

```erlang
{application, {{name}}, [
  {description, "a minimal application"},
  {vsn, "0.1.0"},
  {registered, [
    {{name}}_sup
  ]},
  {mod, {{{name}}_app, []}},
  {applications, [
    kernel,
    stdlib
  ]},
  {env, []},
  {modules, []},
  {licenses, ["MIT"]},
  {links, []}
]}.
```

I like to have one module called with the name of the application. Most of the time, it will be used for the main interface for the rest of the application, other modules could then be totally hidden from the developers. This module can also be used to be the main entry-point when creating an `escript`. This file is called `src/{{name}}.erl`.

```erlang
%%%===================================================================
%%% @copyright {{copyright_year}} (c) {{author_name}}
%%% @author {{author_name}}
%%% @doc
%%% @end
%%%===================================================================
-module({{name}}).
-export([start/0, stop/0]).

%%--------------------------------------------------------------------
%% @doc start {{name}} application and its dependencies.
%% @end
%%--------------------------------------------------------------------
start() ->
  application:ensure_all_started({{name}}).

%%--------------------------------------------------------------------
%% @doc stop {{name}} application.
%% @end
%%--------------------------------------------------------------------
stop() ->
  application:stop({{name}}).
```

Then, the application module present in the file `src/{{name}}_app.erl` containing the functions to start and stop the application via the [`application`](https://www.erlang.org/doc/system/applications.html) behavior.

```erlang
%%%===================================================================
%%% @copyright {{copyright_year}} (c) {{author_name}}
%%% @author {{author_name}}
%%% @doc
%%% @end
%%%===================================================================
-module({{name}}_app).
-behavior(application).
-export([start/2, stop/1]).

%%--------------------------------------------------------------------
%% @doc
%% @end
%%--------------------------------------------------------------------
start(_StartType, _StartArgs) ->
  {{name}}_sup:start_link().

%%--------------------------------------------------------------------
%% @doc
%% @end
%%--------------------------------------------------------------------
stop(_State) ->
  ok.
```

Finally, we can create the main supervisor, the one in charge of the supervision tree of the application presents in `src/{{name}}_sup.erl`.

```erlang
%%%===================================================================
%%% @copyright {{copyright_year}} (c) {{author_name}}
%%% @author {{author_name}}
%%% @doc {{name}} application main supersivor.
%%% @end
%%%===================================================================
-module({{name}}_sup).
-behavior(supervisor).
-export([start_link/0, init/1]).

%%--------------------------------------------------------------------
%% @doc
%% @end
%%--------------------------------------------------------------------
start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%%--------------------------------------------------------------------
%% @doc
%% @end
%%--------------------------------------------------------------------
init(_) ->
  {ok, {supervisor_flags(), child_specs()}}.

%%--------------------------------------------------------------------
%% @hidden
%% @doc
%% @end
%%--------------------------------------------------------------------
supervisor_flags() ->
  #{
    strategy => one_for_all,
    intensity => 0,
    period => 1
  }.

%%--------------------------------------------------------------------
%% @hidden
%% @doc
%% @end
%%--------------------------------------------------------------------
child_specs() ->
  [].
```

Nothing really fancy, simple minimal template which will do the job. For the one interested, my convention for the documentation and comments are to use practically the same one than the Erlang convention.

# Erlang Common Test Template

I like [`common_test`](https://www.erlang.org/doc/apps/common_test/basics_chapter.html), an integration testing suite delivered by default with Erlang/OTP. Here a really small template for your application:

```erlang
%%%===================================================================
%%% @copyright {{copyright_year}} (c) {{author_name}}
%%% @author {{author_name}}
%%% @doc
%%% @end
%%%===================================================================
-module({{name}}_SUITE).
-compile(export_all).
-include_lib("common_test/include/ct.hrl").

%%--------------------------------------------------------------------
%% @doc
%% @end
%%--------------------------------------------------------------------
suite() ->
    [{timetrap,{minutes,10}}].

%%--------------------------------------------------------------------
%% @doc
%% @end
%%--------------------------------------------------------------------
init_per_suite(Config) ->
    Config.

%%--------------------------------------------------------------------
%% @doc
%% @end
%%--------------------------------------------------------------------
end_per_suite(_Config) ->
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @end
%%--------------------------------------------------------------------
init_per_group(_GroupName, Config) ->
    Config.

%%--------------------------------------------------------------------
%% @doc
%% @end
%%--------------------------------------------------------------------
end_per_group(_GroupName, _Config) ->
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @end
%%--------------------------------------------------------------------
init_per_testcase(_TestCase, Config) ->
    Config.

%%--------------------------------------------------------------------
%% @doc
%% @end
%%--------------------------------------------------------------------
end_per_testcase(_TestCase, _Config) ->
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @end
%%--------------------------------------------------------------------
groups() ->
    [].

%%--------------------------------------------------------------------
%% @doc
%% @end
%%--------------------------------------------------------------------
all() ->
    [default].

%%--------------------------------------------------------------------
%% @doc
%% @end
%%--------------------------------------------------------------------
default() ->
  [].

%%--------------------------------------------------------------------
%% @doc
%% @end
%%--------------------------------------------------------------------
default(_Config) ->
  {{name}}:start(),
  {{name}}:stop().
```

# Usage

The templates can be copied in `${HOME}/.rebar3/templates`.

```sh
cp -rp minimal ${HOME}/.rebar3/templates
cp minimal.template ${HOME}/.rebar3/templates
```

Then, the template can be used like any other rebar3 template.

```console
$ cd cd /tmp
$ rebar3 new minimal name=t
===> Writing t/.gitignore
===> Writing t/.tool-versions
===> Writing t/AGENTS.md
===> Writing t/README.md
===> Writing t/CONTRIBUTING.md
===> Writing t/SECURITY.md
===> Writing t/LICENSE
===> Writing t/rebar.config
===> Writing t/Makefile
===> Writing t/src/t.app.src
===> Writing t/src/t.erl
===> Writing t/src/t_app.erl
===> Writing t/src/t_sup.erl
===> Writing t/test/t_SUITE.erl
$ cd t
$ rebar3 compile
...
$ rebar3 ct
...
$ rebar3 shell
===> Verifying dependencies...
===> Analyzing applications...
===> Compiling t
===> "/tmp/t/_build/default/lib/t/ebin/t.app" is missing description entry
Erlang/OTP 28 [erts-16.0.1] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [jit:ns]

Eshell V16.0.1 (press Ctrl+G to abort, type help(). for help)
1>
```

# Conclusion

The repository can be found at [niamtokik/rebar3_minimal_template](https://github.com/niamtokik/rebar3_minimal_template) on Github. I got a similar templates for years without sharing it (with few extra-features like C code support).

Other markdown files can easily be modified, I use by default the MIT-license (or the ISC-OpenBSD one). `.gitignore` and `.tool-versions` files are also created based on templates.

Have fun with Erlang!

----

Cover Image by <a href="https://unsplash.com/@glencarrie?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Glen Carrie</a> on <a href="https://unsplash.com/photos/three-gray-kingfisher-birds-_oNISBwMTwo?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>