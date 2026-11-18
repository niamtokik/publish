---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/sha-2-hash-functions-in-dart-2eg"
comments_count: "3"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2F6624kpay8zkuh4kzhz9x.jpg"
created_at: "None"
crossposted_at: "None"
description: "Hash functions are one way functions, they are taking an input and will return always the same output..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/sha-2-hash-functions-in-dart-2eg"
public_reactions_count: "3"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "sha-2-hash-functions-in-dart-2eg"
social_image: "None"
title: "SHA-2 Hash Functions in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# SHA-2 Hash Functions in Dart

Hash functions are one way functions, they are taking an input and will return always the same output based on the input. One of the one used hash function is SHA-256, which is part of the [SHA-2 FIPS 180-4 specification](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.180-4.pdf). You already know it if you are using Bitcoin and many other crypto-currencies/blockchains. Unfortunately, there are no cryptographic library implementation directly available in the Dart SDK, and we must use external packages.

Instead of re-implementing our own, we will use external packages. At this time, two packages look promising, [`cryptography` ](https://pub.dev/packages/cryptography), [`crypto`](https://pub.dev/packages/crypto), [`hashlib`](https://pub.dev/packages/hashlib) and [`hash`](https://pub.dev/packages/hash), [`sodium`](https://pub.dev/packages/sodium).

Let start with a new sandbox project and compare each ones.

```console
$ dart create hashing
Creating hashing using template console...

  .gitignore
  analysis_options.yaml
  CHANGELOG.md
  pubspec.yaml
  README.md
  bin/hashing.dart
  lib/hashing.dart
  test/hashing_test.dart

Running pub get...                     |-0.8s
  Resolving dependencies...
  Downloading packages...
  Changed 48 dependencies!
  1 package has newer versions incompatible with dependency constraints.
  Try `dart pub outdated` for more information.

Created project hashing in hashing! In order to get started, run the following commands:

  cd hashing
  dart run

$ cd hashing
```

This program should be simple, the idea is to return a hash from stdin as hexacimal string. This kind of program already exists and are installed by default on probably all Linux distribution via the [`shasum`](https://manpages.debian.org/trixie/perl/shasum.1.en.html).

```console
$ echo test | sha224
52f1bf093f4b7588726035c176c0cdb4376cfea53819f1395ac9e6ec  -

$ echo test | sha256sum
f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2  -

$ echo test | sha384sum 
109bb6b5b6d5547c1ce03c7a8bd7d8f80c1cb0957f50c4f7fda04692079917e4f9cad52b878f3d8234e1a170b154b72d  -

$ echo test | sha512sum 
0e3e75234abc68f4378a86b3f4b32a198ba301845b0cd6e50106e874345700cc6663a86c1ea125dc5e92be17c98f9a0f85ca9d5f595db2012f7cc3571945c123  -
```

Or it can also be done using [OpenSSL](https://manpages.debian.org/trixie/openssl/openssl.1ssl.en.html) or [LibreSSL](https://man.openbsd.org/openssl).

```console
$ echo test | openssl dgst -hex -sha224
SHA2-224(stdin)= 52f1bf093f4b7588726035c176c0cdb4376cfea53819f1395ac9e6ec

$ echo test | openssl dgst -hex -sha256
SHA2-256(stdin)= f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2

$ echo test | openssl dgst -hex -sha384
SHA2-384(stdin)= 109bb6b5b6d5547c1ce03c7a8bd7d8f80c1cb0957f50c4f7fda04692079917e4f9cad52b878f3d8234e1a170b154b72d

$ echo test | openssl dgst -hex -sha512
SHA2-512(stdin)= 0e3e75234abc68f4378a86b3f4b32a198ba301845b0cd6e50106e874345700cc6663a86c1ea125dc5e92be17c98f9a0f85ca9d5f595db2012f7cc3571945c123
```

The behavior should be the same, except it will use stdin by default and simply print the hash in hexadecimal without other information.

# `lib/crypto.dart` Interface

The [`crypto`](https://pub.dev/packages/crypto) package supports only Hash function, including SHA-2 ([`SHA-224`](https://pub.dev/documentation/crypto/latest/crypto/sha224-constant.html), [`SHA-256`](https://pub.dev/documentation/crypto/latest/crypto/sha256-constant.html), [`SHA-384`](https://pub.dev/documentation/crypto/latest/crypto/sha384-constant.html), [`SHA-512`](https://pub.dev/documentation/crypto/latest/crypto/sha512-constant.html)). Few [examples](https://github.com/dart-lang/core/blob/main/pkgs/crypto/example/example.dart) are available from its [repository](https://github.com/dart-lang/core/blob/main/pkgs/crypto). This package is maintained by the Dart Team and is including as core module. Let add it in our project to see what kind of dependencies it requires.

```console
$ dart pub add crypto
"crypto" is already in "dependencies". Will try to update the constraint.
Resolving dependencies... 
Downloading packages... 
  package_config 2.2.0 (3.0.0 available)
Got dependencies!
1 package has newer versions incompatible with dependency constraints.
Try `dart pub outdated` for more information.
```

```dart
import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
```

```dart
Future<List<int>> sha224(List<int> input) async {
  return _hash(input, crypto.sha224);
}

Future<List<int>> sha256(List<int> input) async {
  return _hash(input, crypto.sha256);
}

Future<List<int>> sha384(List<int> input) async {
  return _hash(input, crypto.sha384);
}

Future<List<int>> sha512(List<int> input) async {
  return _hash(input, crypto.sha512);
}
```

```dart
Future<List<int>> _hash(List<int> input, dynamic callback) async {
  return callback.convert(input).bytes;
}
```

# `lib/cryptography.dart` Interface

The [`cryptography`](https://pub.dev/packages/cryptography) package is supporting all version of `SHA-2` ([`SHA-224`](https://pub.dev/documentation/cryptography/latest/cryptography/Sha224-class.html), [`SHA-256`](https://pub.dev/documentation/cryptography/latest/cryptography/Sha256-class.html), [`SHA-384`](https://pub.dev/documentation/cryptography/latest/cryptography/Sha384-class.html) and [`SHA-512`](https://pub.dev/documentation/cryptography/latest/cryptography/Sha512-class.html)). It does not require a lot of dependencies and seem to be used by a lot of projects. Few [examples](https://pub.dev/packages/cryptography#examples) can be found. Let add it as dependency in our project.

```console
$ dart pub add cryptography
Resolving dependencies... 
Downloading packages... 
+ cryptography 2.9.0
+ ffi 2.2.0
  package_config 2.2.0 (3.0.0 available)
Changed 2 dependencies!
1 package has newer versions incompatible with dependency constraints.
Try `dart pub outdated` for more information.
```

```dart
import 'dart:convert';
import 'dart:async';
import 'package:cryptography/cryptography.dart';
```

To make things easier, the module `lib/cryptography.dart` will export 4 functions called `sha224()`, `sha256()`, `sha384()` and `sha512()`. All of them will take a `List<int>` as input and will return a `Future<List<int>>` as output. The next modules will follow the same pattern.

```dart
Future<List<int>> sha224(List<int> input) async {
  return _hash(input, Sha224());
}

Future<List<int>> sha256(List<int> input) async {
  return _hash(input, Sha256());
}

Future<List<int>> sha384(List<int> input) async {
  return _hash(input, Sha384());
}

Future<List<int>> sha512(List<int> input) async {
  return _hash(input, Sha512());
}
```

An object for each kind of hash function must be instantiated first. To avoid duplicated and annoying code, the private function `_hash()` was created. The first argument is the input as `List<int>` and the second argument is the instantiated object (all hash objects are using the same methods).

```dart
Future<List<int>> _hash(List<int> input, dynamic algorithm) async {
  final sink = algorithm.newHashSink();
  sink.add(input);
  sink.close();
  final hash = await sink.hash();
  return hash.bytes;
}
```

The implementation can use a synchronous or an asynchronous method to hash the data. In our case, we are using the asynchronous with the help of a [`Stream`](https://api.dart.dev/stable/3.11.5/dart-async/Stream-class.html) and a [`sink`](https://api.dart.dev/stable/3.11.5/dart-core/Sink-class.html). The `sink` is created with the help of [`newHashSink()`](https://pub.dev/documentation/cryptography/latest/cryptography/HashAlgorithm/newHashSink.html) method

# `lib/hashlib.dart` Interface

```console
$ dart pub add hashlib
Resolving dependencies... 
Downloading packages... 
+ hashlib 2.3.4
+ hashlib_codecs 3.1.2
  package_config 2.2.0 (3.0.0 available)
Changed 2 dependencies!
1 package has newer versions incompatible with dependency constraints.
Try `dart pub outdated` for more information.
```

Let edit `lib/hashlib.dart`. Firstly, we need to import the `hashlib` module.

```dart
import 'dart:convert';
import 'package:hashlib/hashlib.dart' as hashlib;
```

Then, we will reuse the same kind of interface as functions we created before.

```dart
Future<String> sha224(List<int> input) async {
  return _hash(input, hashlib.sha224);
}

Future<String> sha256(List<int> input) async {
  return _hash(input, hashlib.sha256);
}

Future<String> sha384(List<int> input) async {
  return _hash(input, hashlib.sha384);
}

Future<String> sha512(List<int> input) async {
  return _hash(input, hashlib.sha512);
}
```

Finally, we will create our `_hash()` function. This time, the second argument is waiting for an object callback from `hashlib`.

```dart
Future<String> _hash(List<int> input, dynamic callback) async {
  final s = Stream.fromIterable(input);
  final digest = await callback.byteStream(s);
  return digest.toString();
}
```

The callback reads the list of integer with the help of the [`byteStream()`](https://pub.dev/documentation/hashlib/latest/hashlib/HashBase/byteStream.html) method and returns a `Future<String>` instead of a `List<int>`. I don't think it was necessary to convert it, it would have been slower for no real benefit.

# `lib/sodium.dart` Interface

The [`libsodium`](https://libsodium.gitbook.io/) library [supports SHA-2](https://libsodium.gitbook.io/doc/advanced/sha-2_hash_function#sha-256) but the [`sodium`](https://pub.dev/packages/sodium) package in Dart [does not support it](https://github.com/Skycoder42/libsodium_dart_bindings#considered-for-the-future) algorithms for now. Let just add it anyway just to see the list of dependency required.

```console
$ dart pub add sodium
Resolving dependencies... 
Downloading packages... 
+ archive 4.0.9
+ code_assets 1.0.0 (1.2.1 available)
+ csslib 1.0.2
+ freezed_annotation 3.1.0
+ hooks 1.0.3 (2.0.2 available)
+ html 0.15.6
+ json_annotation 4.12.0
  package_config 2.2.0 (3.0.0 available)
+ posix 6.5.0
+ record_use 0.6.0
+ sodium 4.0.2+1
Changed 10 dependencies!
3 packages have newer versions incompatible with dependency constraints.
Try `dart pub outdated` for more information.
```

So, instead of SHA-2, it offers an implementation of [`Blake2b`](https://www.rfc-editor.org/rfc/rfc7693.txt) via the [`GenericHash`](https://pub.dev/documentation/sodium/latest/sodium/GenericHash-class.html) class. Sadly, I was expecting a lot from this module because I've already used [`NaCl`](https://nacl.cr.yp.to/) and [`libsodium`](https://libsodium.net/) in the past.

# Entry-point `bin/hashing.dart`

The main entry-point is defined in `bin/hashing.dart`. Let import few modules first.

```dart
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:hashing/cryptography.dart' as cryptography;
import 'package:hashing/crypto.dart' as crypto;
import 'package:hashing/hashlib.dart' as hashlib;
```

It will be a command line tool, an `usage()` function can be nice to have.

```dart
int usage() {
  print("usage: hashing HASH MODULE");
  return 1;
}
```

More than half of the functions created will return a `List<int>` and did not find a way to convert that in hexadecimal string in the SDK. To fix that, the `toHex()` function will convert each integers present in the list as 8 bits hexadecimal string and join them. I don't know also if a Dart offers a way to identify the default endianness of the system, a parameter called `little` has been created to deal with that. It assumes the data are in `little-endian` and will convert them to `big-endian`.

```dart
String toHex(List<int> bytes, {bool little = true}) {
  return bytes
    .map((i) {
      final int left = i & 0x0f;
      final int right = i >> 4;
      if (little = true)
        return hex(right) + hex(left);
      else
        return hex(left) + hex(right);
    })
    .join();
}
```

The `hex()` function is converting an integer to its hexadecimal representation as `String`. This is a simple switch/case and throwing an error if the integer is not present in the statement.

```dart
String hex(int i) {
 switch (i) {
  case 0: return "0";
  case 1: return "1";
  case 2: return "2";
  case 3: return "3";
  case 4: return "4";
  case 5: return "5";
  case 6: return "6";
  case 7: return "7";
  case 8: return "8";
  case 9: return "9";
  case 10: return "a";
  case 11: return "b";
  case 12: return "c";
  case 13: return "d";
  case 14: return "e";
  case 15: return "f";
  default: throw("error");
 }
}
```

The arguments passed to the program must be "parsed". Again, a simple switch/case will do the job. At least, everybody can easily understand what I want to do there.

```dart
Future<String> switcher(List<int> bytes, List<String> args) async {
  switch (args) {
    case ["sha224", "cryptography"]: 
      return toHex(await cryptography.sha224(bytes));
    case ["sha256", "cryptography"]: 
      return toHex(await cryptography.sha256(bytes));
    case ["sha384", "cryptography"]: 
      return toHex(await cryptography.sha384(bytes));
    case ["sha512", "cryptography"]: 
      return toHex(await cryptography.sha512(bytes));
                                                    
    case ["sha224", "crypto"]: 
      return toHex(await crypto.sha224(bytes));
    case ["sha256", "crypto"]: 
      return toHex(await crypto.sha256(bytes));
    case ["sha384", "crypto"]: 
      return toHex(await crypto.sha384(bytes));
    case ["sha512", "crypto"]: 
      return toHex(await crypto.sha512(bytes));
                                                    
    case ["sha224", "hashlib"]: 
      return await hashlib.sha224(bytes);
    case ["sha256", "hashlib"]: 
      return await hashlib.sha256(bytes);
    case ["sha384", "hashlib"]:     
      return await hashlib.sha384(bytes);
    case ["sha512", "hashlib"]: 
      return await hashlib.sha512(bytes);

    default:
      return "";
  }
}
```

Finally, the `main()` function, reading the input from `stdin` and forwarding it to the `switcher()` function.

```dart
Future<int> main(List<String> args) async {
  final bytes = (await stdin.toList())[0];
  String digest = await switcher(bytes, args);
  if (digest != "")            
    print(digest);      
    return 0;                         
  return usage();
} 
```

# Test

Let build this project and test it.

```console
$ dart build cli
The `dart build cli` command is in preview at the moment.
See documentation on https://dart.dev/interop/c-interop#native-assets.

Deleting output directory: /tmp/dart/hashing/build/cli/linux_x64/.
Running build hooks... 
Running link hooks... 
Copying 1 build assets:
package:sodium/libsodium
Generated: /tmp/dart/hashing/build/cli/linux_x64/bundle/bin/hashing
```

Are you lazy? That's my case today. We will use [`xargs`](https://manpages.debian.org/trixie/findutils/xargs.1.en.html) to do most of the jobs for us.

```console
$ printf "cryptography\ncrypto\nhashlib\n" \
  | xargs -I%i sh -c 'echo %i: $(echo test | ./build/cli/linux_x64/bundle/bin/hashing sha224 %i)'
cryptography: 52f1bf093f4b7588726035c176c0cdb4376cfea53819f1395ac9e6ec
crypto: 52f1bf093f4b7588726035c176c0cdb4376cfea53819f1395ac9e6ec
hashlib: 52f1bf093f4b7588726035c176c0cdb4376cfea53819f1395ac9e6ec

$ printf "cryptography\ncrypto\nhashlib\n" 8
  | xargs -I%i sh -c 'echo %i: $(echo test | ./build/cli/linux_x64/bundle/bin/hashing sha256 %i)'
cryptography: f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2
crypto: f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2
hashlib: f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2

$ printf "cryptography\ncrypto\nhashlib\n" \
  | xargs -I%i sh -c 'echo %i: $(echo test | ./build/cli/linux_x64/bundle/bin/hashing sha384 %i)'
cryptography: 109bb6b5b6d5547c1ce03c7a8bd7d8f80c1cb0957f50c4f7fda04692079917e4f9cad52b878f3d8234e1a170b154b72d
crypto: 109bb6b5b6d5547c1ce03c7a8bd7d8f80c1cb0957f50c4f7fda04692079917e4f9cad52b878f3d8234e1a170b154b72d
hashlib: 109bb6b5b6d5547c1ce03c7a8bd7d8f80c1cb0957f50c4f7fda04692079917e4f9cad52b878f3d8234e1a170b154b72d

$ printf "cryptography\ncrypto\nhashlib\n" \
  | xargs -I%i sh -c 'echo %i: $(echo test | ./build/cli/linux_x64/bundle/bin/hashing sha512 %i)'
cryptography: 0e3e75234abc68f4378a86b3f4b32a198ba301845b0cd6e50106e874345700cc6663a86c1ea125dc5e92be17c98f9a0f85ca9d5f595db2012f7cc3571945c123
crypto: 0e3e75234abc68f4378a86b3f4b32a198ba301845b0cd6e50106e874345700cc6663a86c1ea125dc5e92be17c98f9a0f85ca9d5f595db2012f7cc3571945c123
hashlib: 0e3e75234abc68f4378a86b3f4b32a198ba301845b0cd6e50106e874345700cc6663a86c1ea125dc5e92be17c98f9a0f85ca9d5f595db2012f7cc3571945c123
```

The output is identical for all commands. So, it looks good to me.

# Performance

The performance difference when a program is executed with the Dart VM and as native application is real. Here a few examples.

```console
$ time echo test | openssl dgst -sha224 -binary | base64
UvG/CT9LdYhyYDXBdsDNtDds/qU4GfE5Wsnm7A==

real    0m0,007s
user    0m0,002s
sys     0m0,007s

$ time echo test | dart run bin/hashing.dart sha224 cryptography
Running build hooks... 
52f1bf093f4b7588726035c176c0cdb4376cfea53819f1395ac9e6ec

real    0m0,944s
user    0m1,343s
sys     0m0,194s

$ time echo test | ./build/cli/linux_x64/bundle/bin/hashing sha224 cryptography
52f1bf093f4b7588726035c176c0cdb4376cfea53819f1395ac9e6ec

real    0m0,007s
user    0m0,000s
sys     0m0,009s
```

When using the Dart Virtual Machine, the code is taking more than 1 second to hash the string "test". I think its due to the VM initialization or the Dart application trying to see what kind of changes have been made. Anyway, the code generated by Dart in a native format is still a bit slow compared to OpenSSL though.

# Conclusion

Choosing a cryptographic library nowadays is hard. 10 years ago, only few projects were available, and most of the time, we were using [OpenSSL](https://www.openssl.org/) or one of its fork like [LibreSSL](https://www.libressl.org/). [GnuTLS](https://gnutls.org/), [BearSSL](https://www.bearssl.org/), [PolarSSL](https://github.com/cuberite/polarssl) or [WolfSSL](https://www.wolfssl.com/) were also other alternatives to consider. Instead of reusing the already deeply tested and checked libraries, all "modern languages" decided to reimplement their own.

The Dart team only support the `crypto` package offering hashing algorithms, but any other cryptographic functions. If you only need hashing, use this one. If you need more, you should probably test `cryptography` and `hashlib` packages. Finally, if you don't care about SHA-2 and you just want something portable, you can check `libsodium` package.

----

Cover Image by <a href="https://unsplash.com/@noahdavis?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Noah Näf</a> on <a href="https://unsplash.com/photos/assorted-umbrellas-hanging-on-ceiling-qhfxY3X6JV0?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>