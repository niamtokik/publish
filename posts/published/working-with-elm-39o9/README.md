---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/working-with-elm-39o9"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Ftpvfidmtof2x0zds3slo.jpg"
created_at: "None"
crossposted_at: "None"
description: "Foreword: this article is from my attic. It was planned to be published in 2024, it's probably a bit..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/working-with-elm-39o9"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "working-with-elm-39o9"
social_image: "None"
title: "Working with Elm"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Working with Elm

Foreword: this article is from my attic. It was planned to be published in 2024, it's probably a bit old... But I don't think Elm and Phoenix framework changed a lot in 2 years.

----

I usually use OpenBSD when programming in Erlang, C or Elixir. Unfortunately, doing front-end development with node for example or even doing some back-end stuff in Rust can lead to a disaster. Indeed, OpenBSD is a great piece of software but not everything is working by default, and you will keep hacking around. Hacking is always a good way to learn, but, you don't always have time for doing that. When developing front-end application, but also application for iOS or Android, you should use something highly compatible and with not a lot of bad surprises.

# Introduction

Front-end programming is something a bit weird. In fact, front-end development is present in my long list of IT nightmare, alongside with Object Oriented Programming (in particular Java), systemd, blobs and other highly complex framework you can find in system administration.

Anyway, when it comes to design a web-site, it costs me time, to create the Javascript part and the CSS. Because the web is evolving fast -- perhaps too fast -- and because I'm not a front-end developer, my toolbox stayed in the past. How to find stability in this environment? Well, it seems [Elm](https://elm-lang.org/) is quite stable. I followed this project since 2016 or 2017 without seeing critical changes in the syntax, that's a very good point. The [standard library](https://elm-lang.org/docs) and [external modules](https://package.elm-lang.org/) are looking stable as well. The only alternative I know that could help to build front-end is [clojure-script](https://clojurescript.org).

My own projects led me to build web applications and I don't have time to maintain them. Dealing with stability and strict programming rules is a game changer. I don't know if a framework using the same principles than Erlang exists in Front-end world though. Anyway, let integrates Elm in an [Elixir stack](https://elixir-lang.org/) with [Phoenix framework](https://www.phoenixframework.org/).

# Phoenix Project from Scratch

If you already have used Phoenix Framework in the past, no secret there. I assume you already have [mix](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html) available on your system. You can use any solution for that, like [asdf](https://asdf-vm.com/) or [debian packages](https://packages.debian.org/bookworm/elixir).

``` sh
# install hex locally
mix local.hex --if-missing
```

``` sh
# install phx_new templating module
mix archive.install  hex phx_new
```

``` sh
# create a new project without assets,
# we will add them manually later
mix phx.new project --no-assets
cd project
```

# Elm Project from Scratch

[Elm](https://guide.elm-lang.org/) can be installed using [npm](https://www.npmjs.com/package/elm) or directly by downloading on the [official website](https://github.com/elm/compiler/releases/). We will first download it to create the project and then move to npm solution during the integration step.

``` sh
mkdir -p assets/elm
cd assets/elm
```

To init a project, [`elm init`](https://guide.elm-lang.org/install/elm.html#elm-init) command needs to be executed. It will generate a `elm.json` file and a `src` folder.

``` sh
elm init
```

Based on the different projects I watched before doing that, it seems the convention is to create a `src/Main.elm` file containing the entry-point.

``` sh
touch src/Main.elm
```

This file will contain our dummy application for the moment.

``` elm
module Main exposing (..)

import Browser
import Css exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)

-- This is our main function, our entry-point.
main =
  Browser.element
    { init = initialModel
    , view = view
    , subscriptions = \_ Sub.none
    , update = update
    }

-- Our model type (our state) will be empty
type alias Model = ()

-- this is our state function
initialModel : () -> ( Model, Cmd Msg )
initialModel _ =
  ( ()
  , Cmd.none
  )

-- this is our update (loop?) function, where all events
-- are received
update msg model =
  model

-- this is our view function, where all the html/css black
-- magic is created and rendered
view model =
  div [] []
```

Note: Don't forget to install [`elm-mode`]() in emacs!

## Esbuild and NPM Bootstrapping

`npm install` command can be executing in `assets/elm`, it will produce a generic `package.json` file. This one can be modified to fit our needs. [`elm`](), [`esbuild`]() and [`esbuild-plugin-elm`]() modules are required. Two scripts are also created, one to build the project in one time fashion (`build`), and the other one watching for modification (`watch`).

``` javascript
{
    "name": "project",
    "version": "0.1.0",
    "main": "src/index.js",
    "license": "MIT",
    "dependencies": {
        "elm": "^0.19.1-6",
        "esbuild": "0.17.11",
        "esbuild-plugin-elm": "^0.0.12"
    },
    "devDependencies": {
        "elm": "^0.19.1-6",
        "esbuild": "0.19.11",
        "esbuild-plugin-elm": "^0.0.12"
    },
    "scripts": {
        "build": "node ./build.js",
        "watch": "node ./build.js --watch"
    }
}
```

Phoenix supported [`esbuild`]() for a long time now, but integrating it with other language like Elm is a bit hard. That's why we will use esbuild API in a small script, instead of hacking Elixir esbuild module. This snippet is not from me, but from [esbuild-plugin-elm](https://github.com/phenax/esbuild-plugin-elm) and [Ben Koshy's blog](https://benkoshy.github.io/2022/02/08/elm-via-esbuild-on-rails.html).

``` javascript
const path = require('path')
const esbuild = require('esbuild');
const ElmPlugin = require('esbuild-plugin-elm');

esbuild.build({
    entryPoints: [
        "./src/index.js"
    ],
    bundle: true,
    // outfile: "app.js",
    target: "es2017",
    outdir: "../../priv/static/assets",
    minify: false,
    plugins: [
        ElmPlugin({
            debug: true,
            verbose: true,
        }),
    ],
}).catch(_e => process.exit(1))
```

The last bootstrap is to create a script to link Elm modules in the bundle produced by esbuild. This scrip

``` javascript
import { Elm } from './Main.elm';

// look for an element with the id application set
// and use it as mount point for our Elm application.
var $root = document.getElementById('application');
Elm.Main.init({
  node: $root
});
```

# Bootstrapping Phoenix Framework

``` elixir
defmodule Project.MixProject do
  use Mix.Project

    # ...
    
    defp aliases do
    [
      # ...
      "assets.setup": [
        "esbuild.install --if-missing",
        "cmd --cd assets/elm npm install"],
      "assets.build": [
        "cmd --cd assets/elm node build.js"
      ],
      "assets.deploy": [
        "cmd --cd assets/elm node build.js --deploy",
        "phx.digest"
      ]
    ]
  end
end
```

``` sh
# install esbuild and install node dependencies
mix assets.setup

# build assets
mix assets.build

# build assets and create digest
mix assets.deploy
```

We should have now a file `index.js` in `priv/assets` directory, ready to be injected in our HTML, just add the following code at the end of your page.

``` html
<script src={~p"/assets/index.js"}></script>
```

# Development Process

1.  Create your Elm application

2.  Run `mix assets.build`, your browser should reboot automatically if changes have been made

3.  Modify your Phoenix controllers or views.

4.  Don't forget to create or update `.gitignore` file, you don't want to deal with all assets produced in your repository.

# Configuring Backend Hostname

Elm accept [flags](https://guide.elm-lang.org/interop/flags.html) feature, that means when your application will start it initialization phase, some external arguments will be passed to the entry-point. When starting Phoenix server, this one will usually start to listen on TCP/4000 port. This value can be set as string in flag (or create a JSON object containing all value you want to put there). Based on the previous configuration and bootstrap we did, flags must be set in `assets/elm/src/index.js`.

``` javascript
import { Elm } from './Main.elm';

var $root = document.getElementById('application');
Elm.Main.init({
    node: $root,
    flags: "http://localhost:4000/"
});
```

Then, the arguments passed to the entry-point function in the application must also be modified. Here an example when sending a string.

``` elm
init : String -> ( Model, Cmd Msg)
init target_ = 
  ( { target = target_ }, Cmd.none )
```

If an URL is passed, it could probably better to use a JSON object, decoded with [Json.Decode](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode), decomposed it, to finally create a new clean and safe [Url](https://package.elm-lang.org/packages/elm/url/latest/Url).

# Managing Url with `Browser.element`

[Bernardoow](https://github.com/elm/browser/blob/1.0.2/notes/navigation-in-elements.md) already created an interesting gist on this topic.

# Conclusion

It's not so "hard" to use Elm with Phoenix Framework. In fact, except some issue with Esbuild configuration and some odd behaviors with npm, it was just working fine. Many other developers did also the same process - or a similar one.

# References and Resources

[Elm Guide](https://guide.elm-lang.org/)

[Elm Syntax](https://elm-lang.org/docs/syntax)

[Elm Best Practices](https://gist.github.com/rofrol/fd46e9570728193fddcc234094a0bd99)

[Elm Style Guide](https://github.com/ohanhi/elm-style-guide)

[Awesome Elm](https://github.com/sporto/awesome-elm): A curated list of useful Elm tutorials, libraries and software. Inspired by awesome list. Feel free to contribute.

[The Structure of an Elm Application](https://css-tricks.com/structure-elm-application/)

[How to Use Elm at Work](https://elm-lang.org/news/how-to-use-elm-at-work)

[JavaScript Interop](https://guide.elm-lang.org/interop/)

[Elm, Elixir, and Phoenix: Reflecting on a Functional Full-Stack Project](https://launchscout.com/blog/elm-elixir-and-phoenix-reflecting-on-a-functional-full-stack-project)

[phoenix-elm-starter](https://github.com/dwyl/phoenix-elm-starter)

[Elm Destructuring (or Pattern Matching) cheatsheet](https://gist.github.com/yang-wei/4f563fbf81ff843e8b1e)

----

Cover Image by <a href="https://unsplash.com/@lyrax_photograph?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Lyrax</a> on <a href="https://unsplash.com/photos/a-close-up-of-a-flower-on-a-tree-branch-_ExP5iI0a8M?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
      