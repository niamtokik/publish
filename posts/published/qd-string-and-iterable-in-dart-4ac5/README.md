---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/qd-string-and-iterable-in-dart-4ac5"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2F11oimcbycfm31m27f53m.jpg"
created_at: "None"
crossposted_at: "None"
description: "By default, Strings in Dart can't be used as Iterable, they must be converted to a List&lt;int&gt; or..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/qd-string-and-iterable-in-dart-4ac5"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "qd-string-and-iterable-in-dart-4ac5"
social_image: "None"
title: "Q&D: String and Iterable in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Q&D: String and Iterable in Dart

By default, [`String`](https://api.dart.dev/dart-core/String-class.html)s in Dart can't be used as [`Iterable`](https://api.dart.dev/dart-core/Iterable-class.html), they must be converted to a [`List<int>`](https://api.dart.dev/dart-core/List-class.html) or another kind of [`Iterable`](https://api.dart.dev/dart-core/Iterable-class.html) class. To do that, one must import the [`dart:convert`](https://api.dart.dev/dart-convert/) module and start playing with the converters.

A pure ASCII string can be converted using [`ascii.encode(str)`](https://api.dart.dev/dart-convert/ascii-constant.html), where `str` is the [`String`](https://api.dart.dev/dart-core/String-class.html) to convert to `List<int>`.

```dart
import 'dart:convert';

void main() {
  final str = "hello world";
  for (var c in ascii.encode(str)) {
    print("${c} (${String.fromCharCode(c)})");
  }
}
```

```console
$ dart run
104 (h)
101 (e)
108 (l)
108 (l)
111 (o)
32 ( )
119 (w)
111 (o)
114 (r)
108 (l)
100 (d)
```

The same can be done with utf8 Strings as well.

```dart
import 'dart:convert';

void main() {
  final str = "波動拳: ↓↙←Ⓑ";
  for (var c in utf8.encode(str)) {
    print("${c} (${String.fromCharCode(c)})");
  }
}
```

```console
$ dart run
230 (æ)
179 (³)
162 (¢)
229 (å)
139 ()
149 ()
230 (æ)
139 ()
179 (³)
58 (:)
32 ( )
226 (â)
134 ()
147 ()
226 (â)
134 ()
153 ()
226 (â)
134 ()
144 (
226 (â)
146 ()
183 (·)
```

This output is "normal", because an utf8 character is encoded on 8, 16 or 32 bits, but the encoder will encode it only on 8 bits. This means an utf8 character will be split in more than one byte. A quick and dirty solution to avoid this issue is to use the [`String.split()`](https://api.dart.dev/dart-core/String/split.html) method and iterate over the [`List`](https://api.dart.dev/dart-core/List-class.html) generated.

```dart
void main() {
  final str = "波動拳: ↓↙←Ⓑ";
  for (var c in str.split("")) {
    print("${c} : ${utf8.encode(c)}");
  }
}
```

```console
$ dart run
波 : [230, 179, 162]
動 : [229, 139, 149]
拳 : [230, 139, 179]
: : [58]
  : [32]
↓ : [226, 134, 147]
↙ : [226, 134, 153]
← : [226, 134, 144]
Ⓑ : [226, 146, 183]
```

The 波 character is made of 3 integers `[230, 179, 162]`, like the rest of the unicode characters displayed. Here a list of resources talking about that:

- [How to Handle Character Encoding with UTF-8 in Dart](https://compile7.org/character-encoding-decoding/how-to-handle-character-encoding-with-utf-8-in-dart/)

- [How to Handle Character Encoding with ASCII in Dart](https://compile7.org/character-encoding-decoding/how-to-handle-character-encoding-with-ascii-in-dart/)

----

Cover Image by <a href="https://unsplash.com/@cochinoraw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Julian Schultz</a> on <a href="https://unsplash.com/photos/yellow-and-brown-signage-hP_rcZ8WOFs?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>