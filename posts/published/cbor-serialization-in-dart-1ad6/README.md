---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/cbor-serialization-in-dart-1ad6"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2F6ega6hcgl3h7iy1c87hu.jpg"
created_at: "None"
crossposted_at: "None"
description: "Every developer knows JSON, they also probably knows XML and sometime protobuf or BSON. For the ones..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/cbor-serialization-in-dart-1ad6"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "cbor-serialization-in-dart-1ad6"
social_image: "None"
title: "CBOR Serialization in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# CBOR Serialization in Dart

Every developer knows `JSON`, they also probably knows `XML` and sometime `protobuf` or `BSON`. For the ones coming from Erlang/Elixir, they will probably know `ETF` and for the ones using LISP/Scheme, they will also probably have heard of S-expressions. Many other serialization format can be found on the web, a Wikipedia page collect them all. CBOR is another one, this time, not specified by a language, but by an organization. It makes it more portable than any other binary serialization formation.

Anyway, CBOR was in my list for a while, and I wanted to use it with Dart to see how it could be used there. It will also be a good time to deal with I/O, like creating, reading, writing and deleting files.

# Bootstrapping

As usual, a sandbox project will be created. This time, it will be called `cboring`.

```console
$ dart create cboring
Creating cboring using template console...

  .gitignore
  analysis_options.yaml
  CHANGELOG.md
  pubspec.yaml
  README.md
  bin/cboring.dart
  lib/cboring.dart
  test/cboring_test.dart

Running pub get...                     0.8s
  Resolving dependencies...
  Downloading packages...
  Changed 48 dependencies!

Created project cboring in cboring! In order to get started, run the following commands:

  cd cboring
  dart run

$ cd cboring
```

The [`cbor`](https://pub.dev/packages/cbor) package will be required.

```console
$ dart pub add cbor
Resolving dependencies... 
Downloading packages... 
+ cbor 6.5.1
+ characters 1.4.1
+ hex 0.2.0
Changed 3 dependencies!
```

# Quick Introduction to CBOR

As mentioned above, CBOR is a binary serial format specified in many RFCs. If you are using Erlang you should probably be aware of ETF or Erlang Term Format. Both are similar in the design. The idea is to encode different kind of data in a binary format, for example, if you want to encode an integer, instead of writing directly it like in JSON, the final produced result in a binary format will result in - at least - 2 values: (1) a tag as an integer defined in the specification used to inform on the data type (2) the data itself, encoded in a specific format or not, depending on the specification. Let compare that with JSON directly.

```json
1023
```

The same textual value in binary looks like that:

```hex
0x31 0x30 0x32 0x33
```
 
The previous value is a simple integer (`1023`) supported by the JSON format. If you read this value with a JSON parser, it will return `1023` as value. 

```cbor
0x19 0x03 0xff
```

In other hands, CBOR is using binary term, and the same value (`1023`) will be encoded as `0x03ff` in hexadecimal. This value only is not enough, because nobody really know. Indeed, this value can represent any other kind of values. To avoid confusion, CBOR will prefix this integer by `0x19` (`000_11001`). Then, when the decoder will read the binary file, it will know the next value stored after this tag is an integer. Let check that for a more complex data like a list made of an integer and a string.

```json
[1023,"test",65536]
```

```hex
0x5b 0x31 0x30 0x32 0x33 0x2c 0x22 0x74
0x65 0x73 0x74 0x22 0x2c 0x36 0x35 0x35
0x33 0x36 0x5d 
```

The JSON representation of those data is still quite simple, but in CBOR, it can become a bit more challenging:

```cbor
0x82 0x19 0x03 0xff 0x64 0x74 0x65 0x73 
0x74 0x1a 0x00 0x01 0x00 0x00
```

The type defined in the first byte can be divided in two parts, the first 3 bits define the [major type](https://www.rfc-editor.org/rfc/rfc8949.html#section-3.1), the 5 remaining bits are used for extra-arguments.

- `0x82` (`100_00010`) is an array of data items (major type 4) containing 3 elements (`00010`);

- `0x19` (`000_11001`) is an unsigned integer (major type 0)  with 25 ([16 bits encoded value](https://www.rfc-editor.org/rfc/rfc8949.html#fpnoconttbl)) as additional parameter and followed by the value 1023 (`0x03 0xff);

- `0x64` (`011_00100`) is a text string (major type 3) containing the 4 (`00100`) characters `t` `e` `s` t` (`0x74 0x65 0x73 0x74`);

- `0x1a` (`000_11010`) is an unsigned integer (major type 0) with 26 as additional parameter ([32 bits encoded value](https://www.rfc-editor.org/rfc/rfc8949.html#fpnoconttbl)), followed by the value 65536 (`0x00 0x01 0x00 0x00`).

The amount of data encoded in CBOR is more concise, and can be a huge win when an application should deal with limited payload size. If you want to know more about the specification itself, the [RFC8949](https://www.rfc-editor.org/rfc/rfc8949.html) contains everything.

# Exporting CBOR Data To a File

It was a long prelude... but it's now the time to come back to the CBOR package and have some fun. Exporting CBOR data to a file is straightforward, even more knows after having reviewed how to use the Dart file API.

```dart
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cbor/simple.dart';

void main(List<String> arguments) {
  final data = {
    'map': {
      'key': "value",
    },
    'list': [1,2,3,4],
  };
  Uint8List buffer = Uint8List.fromList(cbor.encode(data));
  File cborExport = File("./export.cbor");
  RandomAccessFile fh = cborExport.openSync(mode: FileMode.append);
  fh.writeFromSync(buffer);
  fh.closeSync();
}
```

```console
$ dart run

$ stat export.cbor 
  File: export.cbor
  Size: 26              Blocks: 8          IO Block: 4096   regular file
Device: 254,1   Inode: 279569      Links: 1
Access: (0664/-rw-rw-r--)  Uid: ( 1000/    user)   Gid: ( 1000/    user)
Access: 2026-09-04 07:12:05.262214381 +0000
Modify: 2026-09-04 07:11:22.398703675 +0000
Change: 2026-09-04 07:11:22.398703675 +0000
 Birth: 2026-09-04 07:11:22.398703675 +0000

$ hexdump -C export.cbor
00000000  a2 63 6d 61 70 a1 63 6b  65 79 65 76 61 6c 75 65  |.cmap.ckeyevalue|
00000010  64 6c 69 73 74 84 01 02  03 04                    |dlist.....|
0000001a
```

As you can see, the file has been created and contains CBOR encoded data.

# Import CBOR Data From Files

If a CBOR data structure can be exported to a file, it can also be imported from a file. Let check that.

```dart
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cbor/simple.dart';

void main(List<String> arguments) {
  File cborExport = File("./export.cbor");
  RandomAccessFile fh = cborExport.openSync(mode: FileMode.read);
  Uint8List buffer = Uint8List(fh.lengthSync());
  fh.readIntoSync(buffer);
  fh.closeSync();
  print(buffer);
  print(cbor.decode(buffer));
}
```

```console
$ dart run
[162, 99, 109, 97, 112, 161, 99, 107, 101, 121, 101, 118, 97, 108, 117, 101, 100, 108, 105, 115, 116, 132, 1, 2, 3, 4]
{map: {key: value}, list: [1, 2, 3, 4]}
```

While decoding the file, the data present in it are correctly converted to Dart terms using the CBOR encoding format.

# Conclusion

CBOR is amazing, not only because it was specified, but also because it's small and elegant. This is a great alternative to [Protocol Buffer](https://protobuf.dev/) and [BERT](https://archive.is/PiKh) (Binary ERlang Term, a "fork" of [ETF](https://www.erlang.org/doc/apps/erts/erl_ext_dist.html)). In the case of protobuf, CBOR is easier to use, and will act as a binary-like JSON, with extra-type and a smaller payload. For [BERT](https://archive.is/PiKh)/[ETF](https://www.erlang.org/doc/apps/erts/erl_ext_dist.html), it will be safer, because the serializer will not use some low-level functions (e.g. [`binary_to_term/1`](https://www.erlang.org/doc/apps/erts/erlang.html#binary_to_term/1)) to automatically convert the data, including atoms. Indeed, ETF has been created to be used in a safe and controlled environment, using it in production is a huge risk and should be avoided.

Anyway, CBOR remains one of my favorite binary format, and its implementation in Dart is doing the job. Not everything has been implemented though, for example, it is possible to specify more accurately the CBOR payload by using [CDDL](https://tools.ietf.org/html/rfc8610) (Concise Data Definition Language) and offering mostly the same feature than Protobuf. CBOR can also be used as an alternative to JWT, with [CWT](https://tools.ietf.org/html/rfc8392). CBOR can also be used to sign and encrypt data via [COSE](https://datatracker.ietf.org/doc/html/rfc8152), an alternative to [JOSE](https://datatracker.ietf.org/wg/jose/about/).

CBOR can easily replace JSON in practically all situations and was designed to offer performance and flexibility. It's a perfect format for messaging, game industry, low-level programming and eventually system application. This article was only the tip of the iceberg, the [number of drafts](https://datatracker.ietf.org/doc/search/?name=CBOR&rfcs=on&activedrafts=on&olddrafts=on) related to CBOR available on the IETF website is astonishing.

As usual, if the reader wants to know more about CBOR and how to use it with Dart, here a list of nice references:

- the [Official CBOR website](https://cbor.io/);

- [`cbor` package](https://pub.dev/packages/cbor) on pub.dev;

- [`cbor` package API documentation](https://pub.dev/documentation/cbor/latest/) at pub.dev;

- [`cbor` package source code](https://github.com/shamblett/cbor) at Github;

- [`libcbor`](https://github.com/PJK/libcbor) at Github;

- [RFC-8949 - Concise Binary Object Representation (CBOR)](https://www.rfc-editor.org/rfc/rfc8949.html) Official specification;

- [Understanding CBOR Encoded Data](https://dev.to/mnelsonwhite/deserialising-cbor-encoded-data-in-net-5cgo) by @mnelsonwhite;

- [JSON VS CBOR (Javascript)](https://dev.to/vipert/json-vs-cbor-javascript-2plh) by @vipert;

- [JSON vs CBOR](https://blog.vitalvas.com/post/2026/03/09/json-vs-cbor/);

- [Understanding the CBOR data serialisation format](https://surrealdb.com/blog/understanding-cbor) by Aravind Putrevu;

- [CBOR vs MessagePack: Binary JSON Formats Explained](https://devtoys.pro/blog/cbor-messagepack-guide) by DevToys.

Happy hacking and have fun!

----

Cover Image by <a href="https://unsplash.com/@artlasovsky?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Art Lasovsky</a> on <a href="https://unsplash.com/photos/brass-quilt-pen-8XddFc6NkBY?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>