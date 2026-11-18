---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/iso8601-format-in-latex-gh0"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2F3uroijrrqz6d6cmrsfn1.jpg"
created_at: "None"
crossposted_at: "None"
description: "A quick note on Latex with datetime2, I wanted to add a Revision on my CV recently, and got a bit..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/iso8601-format-in-latex-gh0"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "iso8601-format-in-latex-gh0"
social_image: "None"
title: "ISO8601 Format in Latex"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# ISO8601 Format in Latex

A quick note on Latex with `datetime2`, I wanted to add a Revision on my CV recently, and got a bit stuck with this package. I tried (again) chatgpt to fix this issue, and again, it failed. So, I just read the documentation, find the right options, and it was fixed.

```latex
%% header
\usepackage[calc,style=iso,showseconds,showzone]{datetime2}

%% document
\begin{document}
\today
\end{document}
```

It will display the date/time with the ISO8601 format.

```plaintext
2026-07-25T10:03:00Z
```

The idea here is to set few options while importing `datetime2` module:

- `calc`: Load the `datetime2-calc` package. This will allow the day of week to be computed and allow you to use the `pgfcalendar` offset style date formats in commands like `\DTMdate` as well as defining the commands described in Section 9. This option doesn’t take a value. It can’t be switched off. This option can’t be used in `\DTMsetkeys`. The default is to not load datetime2-calc; 

- `style=iso`: Sets the current style using `\DTMsetstyle` when the `datetime2` package has finished loading. This also sets `useregional=false` but that setting can be overridden later in the option list;

- `showseconds`: Boolean key to determine whether or not to show the seconds when the time is displayed;

- `showzone`: Boolean key to determine whether or not to show the date with commands that use `\DTMdisplay` or `\DTMDisplay`.

Here some references if you want to know more about this topic:

- [`datetime2` Official documentation](https://ctan.ceremade.dauphine.fr/macros/latex/contrib/datetime2/datetime2.pdf)

- [`datetime2` package](https://ctan.org/pkg/datetime2) on CPAN.

----

Cover Image by <a href="https://unsplash.com/@jontyson?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Jon Tyson</a> on <a href="https://unsplash.com/photos/brown-and-white-clocks-FlHdnPO6dlw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>