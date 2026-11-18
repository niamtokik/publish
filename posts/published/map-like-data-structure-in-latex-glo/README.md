---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/map-like-data-structure-in-latex-glo"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2F86na6z450mwbpyekobew.jpg"
created_at: "None"
crossposted_at: "None"
description: "My CV is a mess, but I think almost everybody got the same result over time. Lot of experiences,..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/map-like-data-structure-in-latex-glo"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "map-like-data-structure-in-latex-glo"
social_image: "None"
title: "Map like Data-Structure in LaTex"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Map like Data-Structure in LaTex

My CV is a mess, but I think almost everybody got the same result over time. Lot of experiences, certifications, projects and so on. Furthermore, having his CV in LaTex is great but it can be hard to update/upgrade it when needed... Why not using something like a database to store all those elements? Well, we can use another layer or tool to deal with that, but it seems LaTex can do that as well with the `pfgkeys` package.

The idea here is to create a really small local package offering an interface to store different kind of elements per categories. Let start with our requirement. How to put experiences?

```latex
\experiencePut{devto}{date}{2026}
\experiencePut{devto}{title}{author}
\experiencePut{devto}{summary}{Writing article for fun and no profit}
\experiencePut{devto}{location}{somewhere on the web}
\experiencePut{devto}{company}{dev.to}
\experiencePut{devto}{skills}{tex, latex, erlang, elixir, dart, flutter}
```

`\experiencePut` is taking 3 arguments, the first one will be a reference to a position (e.g. `devto`), the second argument will be an unique keyword (e.g. `date`) and finally, the last argument will be the data to store (e.g. `2026`). How to get this information back?

```latex
\experienceGet{devto}{date}
\experienceGet{devto}{title}
\experienceGet{devto}{summary}
```

By creating `experienceGet`, where the first argument is the reference to a position (e.g. `devto`) and the second one to the unique keyword previously set (e.g. `date`). Then, it will return `2026`. Neat. Right? Let create our local package called `map.sty`.

```console
$ touch map.sty
```

It will contain the definition of our interfaces and few mandatory elements for LaTex. Thanks to overleaf, we have now great [LaTex documentation](https://www.overleaf.com/learn/latex/Writing_your_own_package) about that.

```latex
\NeedsTeXFormat{LaTeX2e}
\ProvidesPackage{mystore}[2026/07/24 map package]
\RequirePackage{pgfkeys}
```

`pfgkeys` requires a [list of keys](https://tikz.dev/pgfkeys#sec-87.3) to work correctly, then the `/cv/` key is created. More information can be seen on the [documentation](https://tikz.dev/pgfkeys#section-is%20family-handler) regarding the `family` term.

```latex
\pgfkeys{
  /cv/.is family,
}
```

Here the definition of the `\experiencePut` and `\experienceGet` commands. Both of them are some kind of interfaces to `\mapPut` and `\mapGet` commands, where the main category (defined in the first argument) is set to `experiences`.

```latex
\newcommand{\experiencePut}[3]{\mapPut{experiences}{#1}{#2}{#3}}%
\newcommand{\experienceGet}[2]{\mapGet{experiences}{#1}{#2}}%
```

`\mapPut` command is using [`\pgfkeysetvalue`](https://tikz.dev/pgfkeys#pgf.back/pgfkeyssetvalue) to add a new key below `/cv/`, it requires 4 arguments, each one being a branch, and the last one being the final value to store.

`\mapGet` command is using [`\pgfkeysvalueof`](https://tikz.dev/pgfkeys#pgf.back/pgfkeysvalueof) to retrieve the data stored on the leaves, based on the same principle than `\mapPut`.

```latex
\newcommand{\mapPut}[4]{\pgfkeyssetvalue{/cv/#1/#2/#3}{#4}}%
\newcommand{\mapGet}[3]{\pgfkeysvalueof{/cv/#1/#2/#3}}%
```

That's great, be it could be even better if a command could be create to generate a short experience entry. In my case, the LaTex template was already using a definition for `\entrylist` and `\entry`. To avoid rewriting everything, let create a new command to generate an entry with the information stored.

```latex
\newcommand{\experienceShort}[1]{
    \entry
        {\experienceGet{#1}{date}}%
        {\experienceGet{#1}{title}}%
        {\textbf{\experienceGet{#1}{company}}, \experienceGet{#1}{location}}%
        {
            \experienceGet{#1}{summary}
        }
        {\experienceGet{#1}{skills}}
    % \\
}
```

Now, let create a `store.tex` file, it will be used to store all our information in one place.

```console
$ touch store.tex

$ cat > store.tex <<EOF
\experiencePut{devto}{date}{2026}
\experiencePut{devto}{title}{author}
\experiencePut{devto}{summary}{Writing article for fun and no profit}
\experiencePut{devto}{location}{somewhere on the web}
\experiencePut{devto}{company}{dev.to}
\experiencePut{devto}{skills}{tex, latex, erlang, elixir, dart, flutter}
EOF
```

Finally, have some "fun" with our resume.

```latex
% header definition
\documentclass[]{cv-style}
\usepackage{map}
% ... other requirement
\begin{document}

  % import our stored information
  \input{store}

  % create a new section dedicated for the experience
  \section{Experience}
   
    % create a new entry list
    \begin{entrylist}

      % add the devto experience
      \experienceShort{devto}
    \end{entrylist}
\end{document}
```

The best part of this approach is to be able to reuse the same information in many different kind of templates, without rewriting everything, every time. This is a really short part of my CV, but sharing this can probably help other LaTex developers to manage their resume. Even more, one can add multi-language support. Anyway, it's a nice way to deal with complexity in LaTex, if your CV is bigger than mine, the next step is to create a database and store everything in it. It's already in my pipes. As usual, some references.

- [`pgfkeys` package](https://ctan.org/pkg/pgfkeys) on CTAN;

- [`pgfkeys` Official Documentation](https://tikz.dev/pgfkeys) from tikz;

- [LATEX for package and class authors
current version](https://www.latex-project.org/help/documentation/clsguide.pdf) from Latex Project;

- [Understanding packages and class files](https://www.overleaf.com/learn/latex/Understanding_packages_and_class_files) from Overleaf;

- [Writing your own package](https://www.overleaf.com/learn/latex/Writing_your_own_package) from Overleaf.

Have fun and happy hack!

----

Cover Image by <a href="https://unsplash.com/@vrrosario?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Victor Rosario</a> on <a href="https://unsplash.com/photos/a-large-sandy-area-with-some-very-thin-lines-8YkqfzG5h0I?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>