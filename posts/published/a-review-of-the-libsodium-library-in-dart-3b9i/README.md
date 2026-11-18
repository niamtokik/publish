---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/a-review-of-the-libsodium-library-in-dart-3b9i"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Fwzjdkjsb8usmyuo6vb6d.jpg"
created_at: "None"
crossposted_at: "None"
description: "This article is a big sandbox based on the notes I took during my test of the sodium Dart package, an..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/a-review-of-the-libsodium-library-in-dart-3b9i"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "a-review-of-the-libsodium-library-in-dart-3b9i"
social_image: "None"
title: "A review of the libsodium library in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# A review of the libsodium library in Dart

This article is a big sandbox based on the notes I took during my test of the [`sodium`](https://pub.dev/packages/sodium) Dart package, an implementation of the [`libsodium`](https://libsodium.gitbook.io/) (a well known C cryptographic library), itself coming from a fork of [`NaCl`](https://nacl.cr.yp.to/). `libsodium` was ported on many languages like [javascript](https://github.com/jedisct1/libsodium.js/), [rust](https://docs.rs/libsodium-rs/latest/libsodium_rs/), [go](https://github.com/GoKillers/libsodium-go), [ocaml](https://github.com/ahrefs/ocaml-sodium), [haskell](https://hackage.haskell.org/package/libsodium), [erlang](https://github.com/potatosalad/erlang-libsodium), [elixir](https://github.com/ArteMisc/libsalty) and many others.

`sodium` implementation tries to be a 1:1 interface to `libsodium` but with the object oriented paradigm in mind and the specificity of the Dart language. In fact, the few examples present in the source code and the documentation looks limited to me, and did not answer my questions. The test suite is huge, and a big part of the following code will be inherited from it, to avoid you, dear readers, to do the same annoying task. `sodium` can simply be installed using the `dart pub add sodium` command in your current project.

```console
$ dart pub add sodium
Resolving dependencies... 
Downloading packages... 
+ archive 4.5.2
+ code_assets 2.1.0
+ csslib 1.0.2
+ freezed_annotation 3.1.0
+ hooks 2.2.0
+ html 0.15.7
+ json_annotation 4.12.0
+ posix 6.5.2
+ record_use 1.1.1
+ sodium 4.1.2
Changed 10 dependencies!
```

The following code can easily be copy/pasted, but you should probably not do it. Keep in mind those are simply examples for some use case. Cryptography is an hard topic requiring years of experiences to do something secure. So, be really careful with my code.

# Bootstrapping

The `sodium` package offers 2 APIs, the "normal" one called `Sodium` and the "sumo" one, called `SodiumSumo`. In fact, it seems to matter ONLY if you plan to create a JavaScript/WEB application. In this case, you will need to chose the correct API depending of your needs and based on the [API status table](https://github.com/Skycoder42/libsodium_dart_bindings/tree/main/packages/sodium#api-status). In most of the case, if you plan to create a 100% native application, the `SodiumSumo` API should be enough. One can read more on the [APIs differences from the README](https://github.com/Skycoder42/libsodium_dart_bindings/tree/main/packages/sodium#sodium-vs-sodiumsumo). To import the `SodiumSumo` API:

```dart
import 'package:sodium/sodium_sumo.dart';
```

If the normal API is required for some reason, simply use this header, and remove the `Sumo` part of the next command.

```dart
import 'package:sodium/sodium.dart';
```

Now, the `sodium` library needs to be [initialized/loaded](https://github.com/Skycoder42/libsodium_dart_bindings/tree/main/packages/sodium#loading-libsodium). Indeed, a global instance of this object is required, and can be created using the [`SodiumSumoInit`](https://pub.dev/documentation/sodium/latest/sodium_sumo/SodiumSumoInit-class.html) class, with the help of the [`init()`](https://pub.dev/documentation/sodium/latest/sodium_sumo/SodiumSumoInit-class.html) constructor. It should return an instance of `SodiumSumoFFI` object (an instance of [`SodiumSumo`](https://pub.dev/documentation/sodium/latest/sodium_sumo/SodiumSumo-class.html) class).

```dart
var sodium = await SodiumSumoInit.init();
print("sodium: $sodium");
print("version: ${sodium.version}");
print("randombytes: ${sodium.randombytes}");
print("runtimeType: ${sodium.runtimeType}");
```

Let check that.

```console
$ dart run
...
sodium: Instance of 'SodiumSumoFFI'
version: 1.0.22
randombytes: Instance of 'RandombytesFFI'
runtimeType: SodiumSumoFFI
```

Neat. It seems our main object is ready to do a bit of encryption/decryption.

# PRNG

[`libsodium`](https://libsodium.gitbook.io/) has been created with portability and security in mind. It embeds its own [PRNG](https://en.wikipedia.org/wiki/Pseudorandom_number_generator), but will the one exposed by the operating system if any. For example, on most of the Linux/Unix operating system, it will read the [`/dev/urandom`](https://manpages.debian.org/trixie/manpages/urandom.4.en.html) file. If you are using [OpenBSD](https://www.openbsd.org/) (like me), it will probably use [`arc4random`](https://man.openbsd.org/arc4random.3) instead. The `sodium` Dart implementation requires an instance of the [`Randombytes`](https://pub.dev/documentation/sodium/latest/sodium/Randombytes-class.html) object.

The first method to test will be the [`random()`](https://pub.dev/documentation/sodium/latest/sodium/Randombytes/random.html) one, and it will return a random integer. In the code below, 8 random integers are generated.

```dart
final List<int> random = List
  .generate(8, (_) => sodium.randombytes.random());
print("random: $random");
```

```console
random: [1516676843, 4096214122, 3177965578, 2291181405, 4245144458, 3289700635, 106475476, 1321601073]
```

The next method that can be used is to return an uniform random integer (inside a range) and is called [`uniform()`](https://pub.dev/documentation/sodium/latest/sodium/Randombytes/uniform.html). In the following code, 8 uniform random numbers are generated. The output should contain integer between `0` and `1023`.

```dart
final List<int> randomUniform = List<int>
  .generate(8, (_) => sodium.randombytes.uniform(1024));
print("randomUniform: $randomUniform");
```

```console
randomUniform: [322, 681, 185, 1000, 297, 457, 376, 872]
```

It is also possible to generate list of random integers using the [`buf()`](https://pub.dev/documentation/sodium/latest/sodium/Randombytes/buf.html) method. The code snippet below will generate 8 random numbers.

```dart
final List<int> randomBuf = sodium.randombytes.buf(8);
print("randomBuf: $randomBuf");
```

```console
randomBuf: [241, 28, 11, 77, 198, 128, 177, 157]
```

[`libsodium`](https://libsodium.gitbook.io/) is also offering a way to generate random numbers from a custom seed. It can be useful for many scenario, including testing. To do that the [`bufDeterministic`](https://pub.dev/documentation/sodium/latest/sodium/Randombytes/bufDeterministic.html) method can be used, where the first argument is the length of the list returned, and the second is the seed.

```dart
final Uint8List seed1 = Uint8List.fromList(
  List<int>.generate(32, (_) => 0)
);
final Uint8List deterministicBuf1 =
  sodium.randombytes.bufDeterministic(8, seed1);
print("seed1: $seed1");
print("deterministicBuf: $deterministicBuf1");

final Uint8List seed2 = Uint8List.fromList(
  List<int>.generate(32, (_) => 1)
);
final Uint8List deterministicBuf2 =
  sodium.randombytes.bufDeterministic(8, seed2);
print("seed2: $seed2");
print("deterministicBuf: $deterministicBuf2");
```

```console
deterministicBuf1: [161, 31, 143, 18, 208, 135, 111, 115]
deterministicBuf2: [61, 161, 61, 31, 87, 207, 88, 221]
```

The same seed should always output the same random number. This MUST BE set to 32 bytes (a list of 32 integers), if it's not the case, it will throw a `RangError`.

```plaintext
RangeError (seed): Only allowed value is 32, but was: 4
```

If you want to create test with reproducible output from `sodium`, the [`seedBytes`](https://pub.dev/documentation/sodium/latest/sodium/Randombytes/seedBytes.html) attribute can be used.

Finally the [`stir()`](https://pub.dev/documentation/sodium/latest/sodium/Randombytes/stir.html) method is more or less related to any kind of custom PRNG that could have been created by the developer. It will reseed the generator, like defined in the [`libsodium`](https://libsodium.gitbook.io/doc/generating_random_data) documentation.

# Generic Hash Function (BLAKE2b)

Hashes are another important tools to have when dealing with encryption, and authentication. The official [`crypto`](https://pub.dev/packages/crypto) package created by the Dart team already offers a great support for the most used algorithms, including MD5, SHA1, SHA2 and HMAC (only for a subset of the algorithms previously listed). On the other hand, [`libsodium`](https://libsodium.gitbook.io/doc/hashing/generic_hashing) selected the [`BLAKE2b`](https://www.rfc-editor.org/rfc/rfc7693.txt) hash function to be its generic one.

[BLAKE2](https://www.blake2.net/) is a modern hash function specified in [RFC7693](https://tools.ietf.org/html/rfc7693). BLAKE2b is an optimized version of BLAKE2 for 64 bits platform and can create output from 1 to 64 bytes. The reference implementation in pure-C is available on the official BLAKE2 [Github repository](https://github.com/BLAKE2/BLAKE2).

An hash can be created in two ways with `sodium`. The first one is by using the instance present in the [`sodium.crypto.genericHash`](https://pub.dev/documentation/sodium/latest/sodium/Crypto/genericHash.html) as a function (see the [`call()`](https://pub.dev/documentation/sodium/latest/sodium/GenericHash/call.html) method). The code snippet bellow will return the BLAKE2b hash of the string "test", with a 32 bytes (256 bits) output encoded in [`Base64`](https://api.flutter.dev/flutter/dart-convert/base64-constant.html).

```dart
Uint8List message1 = utf8.encode("test");
final hash1 = sodium.crypto.genericHash(
  message: message1,
  outLen: 32
);
print("hash1: ${base64.encode(hash1)}");
```

```console
hash1: kosgNmlD4q/RHrwOri5TqTvxd6T881vMZNUDcE5l4gI=
```

The same can also be done using a `Stream` object via the [`stream()`](https://pub.dev/documentation/sodium/latest/sodium/GenericHash/stream.html) method.

```dart
final message2 = () async => utf8.encode("test");
final hash2 = await sodium.crypto.genericHash.stream(
  messages: Stream.fromFuture(message2()),
  outLen: 32
);
print("hash2: ${base64.encode(hash2)}");
```

```console
hash2: kosgNmlD4q/RHrwOri5TqTvxd6T881vMZNUDcE5l4gI=
```

Both results are identical, like expected from a hash function using the same input. `libsodium` is also giving access to [SHA-2](https://libsodium.gitbook.io/doc/advanced/sha-2_hash_function) and [SHA-3](https://libsodium.gitbook.io/doc/advanced/sha-3_hash_function) hash functions. Unfortunately, it seems the Dart implementation is not offering an interface to them. If you need them, the [`crypto`](https://pub.dev/packages/crypto) package will be required.

# Short Input Hash Function (SipHash-2-4)

[`libsodium`](https://libsodium.gitbook.io/) can use more specific hash functions. For example, when it comes to small input, a classic hash function can be a problem. It is useful for internal data-structure and algorithm. [SipHash-2-4](https://github.com/veorq/SipHash) is the default algorithm used here.

To create a digest, one can use the [`ShortHash`](https://pub.dev/documentation/sodium/latest/sodium/Crypto/shortHash.html) object instance from the main sodium object, called [`shortHash`](https://pub.dev/documentation/sodium/latest/sodium/Crypto/shortHash.html). This object is implementing the [`call()`](https://pub.dev/documentation/sodium/latest/sodium/ShortHash/call.html) and then, can be used as a function.

```dart
final key = SecureKey.random(sodium, 16);
final smallInput = Uint8List.fromList([0,0,0,0]);
final smallHash = sodium.crypto.shortHash(
  key: key,
  message: smallInput,
);

print("key: ${base64.encode(key.extractBytes())}");
print("smallInput: ${base64.encode(smallInput)}");
print("smallHash: ${base64.encode(smallHash)}");
```

```console
key: tbaaEL+9ztfX000L54FlDw==
smallInput: AAAAAA==
smallHash: baRxJQlLnXg=
```

More information about this hash (and its usage) can be found on the official [`libsodium` documentation](https://libsodium.gitbook.io/doc/hashing/short-input_hashing).

# Extendable Output Functions (Shake and TurboShake)

[`libsodium`](https://libsodium.gitbook.io/) also offers [Extendatable Output Functions (XOF)](https://libsodium.gitbook.io/doc/hashing/xof), these functions can be configured to return a flexible output size. A [`Xof`](https://pub.dev/documentation/sodium/latest/sodium/Xof-class.html) object instance of each of these algorithms can be found on the main [`sodium`](https://pub.dev/documentation/sodium/latest/sodium_sumo/SodiumSumo-class.html) object instance created during the initialization part:

- [`xofShake128`](https://pub.dev/documentation/sodium/latest/sodium/Crypto/xofShake128.html) for [Shake128](https://eprint.iacr.org/2026/2080) algorithm;

- [`xofShake256`](https://pub.dev/documentation/sodium/latest/sodium/Crypto/xofShake256.html) for the Shake256 algorithm

- [`xofTurboshake128`](https://pub.dev/documentation/sodium/latest/sodium/Crypto/xofTurboshake128.html) for the [TurboShake128](https://eprint.iacr.org/2023/342) algorithm;

- [`xofTurboshake256`](https://pub.dev/documentation/sodium/latest/sodium/Crypto/xofTurboshake256.html) for the [TurboShake256](https://eprint.iacr.org/2023/342) algorithm.

Let have a look at the Shake128 function first. An instance of a  can be found in the initialized `sodium` object created at the beginning of this post.

```dart
final Uint8List xofShake128Input = Uint8List.fromList([0,0,0,0]);
final Uint8List xofShake128Output8 = sodium.crypto.xofShake128(
  message: xofShake128Input,
  outLen: 8,
);  
final Uint8List xofShake128Output32 = sodium.crypto.xofShake128(
  message: xofShake128Input,
  outLen: 32, 
);  
final Uint8List xofShake128Output64 = sodium.crypto.xofShake128(
  message: xofShake128Input,
  outLen: 64, 
);  
print("xofShake128Input: ${base64.encode(xofShake128Input)}");
print("xofShake128Output8: ${base64.encode(xofShake128Output8)}");
print("xofShake128Output32: ${base64.encode(xofShake128Output32)}");
print("xofShake128Output64: ${base64.encode(xofShake128Output64)}");
```

```console
xofShake128Input: AAAAAA==
xofShake128Output8: j5cMpCyEnKA=
xofShake128Output32: j5cMpCyEnKAMSPiNiDgMV0j0Lc9SkIgAHcUmt12xu74=
xofShake128Output64: j5cMpCyEnKAMSPiNiDgMV0j0Lc9SkIgAHcUmt12xu74TNSTXBo+lx6AI6GKH1Mc7+qGNds7/V7XPqcJ1ArqOvA==
```

As you can see, the output is flexible, and the first part will always be the same (a propriety of XOF). Let check that with the TurboShake256 algorithm.

```dart
  final Uint8List xofTurboshake256Input = Uint8List.fromList([0,0,0,0]);
  final Uint8List xofTurboshake256Output8 = sodium.crypto.xofTurboshake256(
    message: xofTurboshake256Input,
    outLen: 8,
  );  
  final Uint8List xofTurboshake256Output32 = sodium.crypto.xofTurboshake256(
    message: xofTurboshake256Input,
    outLen: 32, 
  );  
  final Uint8List xofTurboshake256Output64 = sodium.crypto.xofTurboshake256(
    message: xofTurboshake256Input,
    outLen: 64, 
  );  
  print("xofTurboshake256Input: ${base64.encode(xofTurboshake256Input)}");
  print("xofTurboshake256Output8: ${base64.encode(xofTurboshake256Output8)}");
  print("xofTurboshake256Output32: ${base64.encode(xofTurboshake256Output32)}");
  print("xofTurboshake256Output64: ${base64.encode(xofTurboshake256Output64)}");
```

```console
xofTurboshake256Input: AAAAAA==
xofTurboshake256Output8: /kSBXrzATNM=
xofTurboshake256Output32: /kSBXrzATNNdtXhOHkidRkpZ9IOK3jeHTWo+Zr1/pfg=
xofTurboshake256Output64: /kSBXrzATNNdtXhOHkidRkpZ9IOK3jeHTWo+Zr1/pfj20vK3er1FEbuD12Chmf11GTTi8VVe+OPfW3Tom3cI4w==
```

More information regarding these algorithms can be seen on the [`libsodium` xof documentation](https://libsodium.gitbook.io/doc/hashing/xof).

# Password Hashing (Argon2)

[`libsodium`](https://libsodium.gitbook.io/) offers an implementation of the [Argon2](https://en.wikipedia.org/wiki/Argon2) algorithm, it can be an alternative to the [argon2](https://pub.dev/packages/argon2) package. [Argon2](https://en.wikipedia.org/wiki/Argon2) is a key derivativation function designed to be protected against brute-force; At this time, this is the recommended algorithm to store hashed password. [`libsodium`](https://libsodium.gitbook.io/) gives us 2 versions of the algorithm, Argon2i and Argon2id, this last one is recommended by the [OWASP team](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html), but the default one used by `sodium` is Argon2i. Anyway, let do some test here.

To create a new hash, the already created instance of the [`Pwhash`](https://pub.dev/documentation/sodium/latest/sodium_sumo/Pwhash-class.html) object in `sodium.crypto.pwhash` can be used and the [`str()`](https://pub.dev/documentation/sodium/latest/sodium_sumo/Pwhash/str.html) can be invoked. It will return a formatted string containing the functions parameters and the random salt generated automatically. The `opsLimit` represents the amount of computations to use (more CPU usage) and the `memLimit` represents the amount of memory in bytes to allocate. 

```dart
final String password = "secret_password";
final hashedPassword = sodium.crypto.pwhash.str(
  password: password,
  opsLimit: 1024,
  memLimit: 8192,
);  
final resultValid = sodium.crypto.pwhash.strVerify(
  passwordHash: hashedPassword,
  password: password,
);  
final resultInvalid = sodium.crypto.pwhash.strVerify(
  passwordHash: hashedPassword,
  password: "test",
);  
print("hashedPassword: $hashedPassword");
print("resultValid: $resultValid");
print("resultInvalid: $resultInvalid");
```

```console
hashedPassword: $argon2id$v=19$m=8,t=1024,p=1$PfWonIyaTiDh0mhyUT55UA$Y63dvkUjVtKYnvBSdzstDN0QIhyi6xcba83efmMaa7I
resultValid: true
resultInvalid: false
```

A [`Pwhash`](https://pub.dev/documentation/sodium/latest/sodium_sumo/Pwhash-class.html) object exposes properties to know the limitations of these values, here a list of some of them.

- [`memLimitInteractive`](https://pub.dev/documentation/sodium/latest/sodium_sumo/Pwhash/memLimitInteractive.html)
- [`memLimitMax`](https://pub.dev/documentation/sodium/latest/sodium_sumo/Pwhash/memLimitMax.html)
- [`memLimitMin`](https://pub.dev/documentation/sodium/latest/sodium_sumo/Pwhash/memLimitMin.html)

- [`opsLimitInteractive`](https://pub.dev/documentation/sodium/latest/sodium_sumo/Pwhash/opsLimitInteractive.html)
- [`opsLimitMax`](https://pub.dev/documentation/sodium/latest/sodium_sumo/Pwhash/opsLimitMax.html)
- [`opsLimitMin`](https://pub.dev/documentation/sodium/latest/sodium_sumo/Pwhash/opsLimitMin.html)

If you want other flavor like Argon2id13, the [`callStr()`](https://pub.dev/documentation/sodium/latest/sodium_sumo/Pwhash/callStr.html) can be used instead but it will require new parameters, like the length of the output, a random salt and the name of the algorithm to use.

```dart
final Uint8List salt = Uint8List.fromList(sodium.randombytes.buf(16));
final hashPasswordBis = sodium.crypto.pwhash.callStr(
  outLen: 1024,
  password: password,
  salt: salt,
  opsLimit: 1024,
  memLimit: 8192,
  alg: CryptoPwhashAlgorithm.argon2id13,
);  
print("salt: ${base64.encode(salt)}");
print("hashPasswordBis: ${base64.encode(hashPasswordBis.extractBytes())}");
```

```console
salt: NAf4uZwlge7mm1kwT5pTZw==
hashPasswordBis: e47DIsAic0Tx9S1g/gIItsrCcf0WpLEaiIj8Jbzn1cneVfPz8w7PH50WmEbj2+kPUZFxgtZdyfRVsjP/N8l521BMxwxAA/hPWFz9a5qM4+BhaKFStMVl5JHQnq+P48ucYTTH7dNwoXe6KuyvR4/gI2kYYdzYQOnymeOzdZxl9Ipz85CfFSJD4S40zuGGLqzL/He2Edabnny1W2PFfBHQoBP1k7egv/b2ZoHVayAWyxOaRHbQ5wrsVIRzliKmG9x8bgDyq/sqP/M+MV2cdD8h5spPq6PFq88+KKAuXD4XORbnSocmCw84oqaOcscubsEcPOnMVhJYEAJIRgytDTlpHjgWNykNahQAkiLBp+UkLQx+pmVAwDG47zyTsEQmyjeAgVL+yVqRFPfT6m5hKJLVXC7wrttR/flDqh+TUgVrZ3FS6rQBOaJA6E4yc9IC/JSVO95UrsBRGABYd5K9tYJccOrEpbb3Rx69dPKw66RWUn8WIxeRB0yf+BiqD1xx6Mqp4axRmvSFTZmLV3Pz9fkXZqYDjGpucytLevUDmumtoHbP3dobuRk0lxhIIFDLfqx2cvymumnByePpwmnTC+1AXw83EX+NBMOzKcXPGVepGONNt0HnT3riW99+kBmRDDPmeHINT7I3k4VsAcWexRxdRHuGCbg9CjxQ4kzLD5DWdibS+FtivhR8D2UWgaH3QZGmNxYpslyhhzCNVcNGO+vgNVH3omyUh7gAbC/oMCL0j1u9u3he4sXBKfCERs5YACIHB7YHVEFTvgZHFfk78SNq4zyNQWfPeMlTGVLrshsOM5BjcTuUg8EJ6AnwiUVkygdSYih1wIX48jwprPW+K53SEig2exm4S6jbl4L65W/+9Ciaue9gobGQVN7zlL2+H9FopLdU+ieMXQJhIGemVZqL3+Geq1KoOm2H4ufJ9olyNbzry8cxZQpgFSdIAfqicgIYeJpBmH8Rdn4C0J9L/I6khDE+Ew63oVuw/Uk6xahYUnQDtveQG86A13F+p459DiSxQR7sJjNvUuSlKHkFWLF9qTU4wGmgzoiBIHCro9KZGegKA2H92kdQP1j+EhPxBeeeiQu/X59Miq+hDiMm0sqt4bIOra+lKBJJ8/T/Ly6VHU6NYvt0JozqazXkmFSh6rj0tfOWuZqmlRpn+OQPoWnLvPurm3iIVo+q3OS9QnZcpCKgrxQr3aJ3NBI5PnoYxslnWJUjwC9FCRTesYqmrMXjk09XCFmF+p96VqhYTXJ1hB3yu70fgFcARvY4jJocnqTfN9UBzGvWRWjK+lZDc/4imQRrbMlCzKxSVgnQKHZRjbG/xpMramlZxqn9WJ8SC3vgI2nZN7RpmCOrm9B7AAboNw==
```

As you can see, the output is an `Uint8List` and not a formatted `String`. Unfortunately, in this mode, it is not possible to generate the Unix-like format. The [`libsodium` official documentation](https://pub.dev/documentation/sodium/latest/sodium_sumo/CryptoSumo/pwhash.html) contains more information on this feature.

# Symmetric Encryption (chacha20-Poly1305)

`sodium` is offering 3 algorithms, all of them based on the [`Aead`](https://pub.dev/documentation/sodium/latest/sodium/Aead-class.html) class

- [Aegis256](https://pub.dev/documentation/sodium/latest/sodium/Crypto/aeadAegis256.html)

- [Chacha2020-Poly1305](https://pub.dev/documentation/sodium/latest/sodium/Crypto/aeadChaCha20Poly1305.html)

- [XChaCha20Poly1305](https://pub.dev/documentation/sodium/latest/sodium/Crypto/aeadXChaCha20Poly1305IETF.html)

A message can be encrypted using the [`encrypt()`](https://pub.dev/documentation/sodium/latest/sodium/Aead/encrypt.html) method.

```dart
final Uint8List message = utf8.encode("my message");
final Uint8List nonce = Uint8List.fromList(sodium.randombytes.buf(8));
final SecureKey keyAead = SecureKey.random(sodium, 32);
final encrypted = sodium.crypto.aeadChaCha20Poly1305.encrypt(
  message: message,
  nonce: nonce,
  key: keyAead,
);
print("message: $message");
print("key: ${base64.encode(key.extractBytes())}");
print("encrypted: ${base64.encode(encrypted)}");
```

```console
message: [109, 121, 32, 109, 101, 115, 115, 97, 103, 101]
key: GkjKYnsKNITUsROWYOiujw==
encrypted: SsldZX2XkQqcRTgiqyP0KH97Yz/YkQ1BIE8=
```

The ciphertext produced by the previous method can be decrypted using the [`decrypt()`](https://pub.dev/documentation/sodium/latest/sodium/Aead/decrypt.html) method.

```dart
Uint8List decrypted = sodium.crypto.aeadChaCha20Poly1305.decrypt(
  cipherText: encrypted,
  nonce: nonce,
  key: keyAead,
);
print("decrypted: ${utf8.decode(decrypted)}");
```

```console
decrypted: my message
```

Nothing really fancy here, the interface is quite easy to use. Be careful regarding the nonce and the key to use though, both of them are important and must be configured accordingly.

# Public Key Generation

This post was - at first - created to understand how public key generation was done with `sodium`. Indeed, the Dart community does not really offer a lot of choice when it comes to encryption, and instead of using yet another library created from scratch (this is usually not a good idea in cryptography), the port to `libsodium` looked way more safer and interesting.

Anyway, [`libsodium`](https://libsodium.gitbook.io/) is only supporting [Ed25519](https://ed25519.cr.yp.to/) and [X25519](https://datatracker.ietf.org/doc/html/rfc7748#section-5) algorithms. The first one is for authentication (signatured), the second is for key exchange. In both case, the method is the same to generate a pair of keys and then, return a [`KeyPair`](https://pub.dev/documentation/sodium/latest/sodium/KeyPair-class.html) object.

```dart
var seedBytesPK = sodium.crypto.box.seedBytes;
var secureRandomSeedPK = sodium.secureRandom(seedBytesPK);
var keyPair = sodium.crypto.box.seedKeyPair(secureRandomSeedPK);
print("seedBytesPK: $seedBytesPK");
print("secureRandomSeedPK: $secureRandomSeedPK");
print("keyPair: $keyPair");
print("publicKey: ${base64.encode(keyPair.publicKey)}");
print("secretKey: ${base64.encode(keyPair.secretKey.extractBytes())}");
```

```console
seedBytesPK: 32
secureRandomSeedPK: Instance of 'SecureKeyFFI'
keyPair: KeyPair(publicKey: [29, 132, 192, 107, 208, 25, 162, 211, 228, 70, 109, 169, 238, 124, 161, 248, 143, 24, 82, 64, 86, 39, 93, 254, 93, 54, 113, 62, 30, 145, 73, 50], secretKey: Instance of 'SecureKeyFFI')
publicKey: HYTAa9AZotPkRm2p7nyh+I8YUkBWJ13+XTZxPh6RSTI=
secretKey: /8SV7xv0ReOpTgau97cmmGZM5PdKSA13hbfxYYs0F1Q=
```

A keypair can also created using a seed via the [`seedKeyPair`](https://pub.dev/documentation/sodium/latest/sodium/Box/seedKeyPair.html) method. More information can be found in the [`Box`](https://pub.dev/documentation/sodium/latest/sodium/Box-class.html) class documentation.

# Public Key Signature (Ed25519)

`libsodium` is using Ed25519 to sign messages with a private key. 3 modes of signatures have been defined by this library, [detached mode](https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#detached-mode), [combined mode](https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#combined-mode) and [multi-part messages mode](https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#multi-part-messages). All of them have been ported to `sodium` via the [`Sign`](https://pub.dev/documentation/sodium/latest/sodium/Sign-class.html) class.

Before using these modes, it is also necessary to understand the key generation process. One can sign a message by generating a new random key when calling the [`keyPair()`](https://pub.dev/documentation/sodium/latest/sodium/Sign/keyPair.html) method, or derive a new key from an existing one using the [`seedKeyPair()`](https://pub.dev/documentation/sodium/latest/sodium/Sign/seedKeyPair.html) method. For example, to derive a key from the keypair generated in the previous section:

```dart
var newSeedBytes = sodium.crypto.box.seedBytes;
var newSecureRandomSeed = sodium.secureRandom(newSeedBytes);
var newKeyPair = sodium.crypto.box.seedKeyPair(newSecureRandomSeed);
var derivedKeyPair = sodium.crypto.sign.seedKeyPair(newKeyPair.secretKey);
print("newSeedBytes: $newSeedBytes");
print("newSecureRandomSeed: $newSecureRandomSeed");
print("newKeyPair: $newKeyPair");
print("derivedKeyPair: $derivedKeyPair");
print("derivedKeyPair.publicKey: ${base64.encode(derivedKeyPair.publicKey)}");
print("derivedKeyPair.secretKey: ${base64.encode(derivedKeyPair.secretKey.extractBytes())}");
```

```console
newSeedBytes: 32
newSecureRandomSeed: Instance of 'SecureKeyFFI'
newKeyPair: KeyPair(publicKey: [17, 113, 139, 202, 227, 188, 47, 55, 65, 155, 129, 183, 29, 22, 170, 28, 186, 137, 114, 114, 10, 130, 235, 100, 124, 126, 64, 156, 63, 99, 192, 108], secretKey: Instance of 'SecureKeyFFI')
derivedKeyPair: KeyPair(publicKey: [12, 10, 30, 205, 0, 239, 115, 167, 34, 206, 106, 197, 126, 152, 34, 58, 162, 79, 75, 239, 76, 73, 249, 136, 211, 66, 86, 31, 187, 16, 201, 200], secretKey: Instance of 'SecureKeyFFI')
derivedKeyPair.publicKey: DAoezQDvc6cizmrFfpgiOqJPS+9MSfmI00JWH7sQycg=
derivedKeyPair.secretKey: S1dqHYqlbEO39PGZM1rY6smO/34FgEGKw7cq2G/HNy4MCh7NAO9zpyLOasV+mCI6ok9L70xJ+YjTQlYfuxDJyA==
```

The combined mode is prepending the signature to the message. To sign a message with this mode, the [`call()`](https://pub.dev/documentation/sodium/latest/sodium/Sign/call.html) method is used, and to validate the message, the [`open()`](https://pub.dev/documentation/sodium/latest/sodium/Sign/open.html) method is required.

```dart
var messageCombined = utf8.encode("test");
var signatureCombined = sodium.crypto.sign(
  message: messageCombined,
  secretKey: randomKeyPair.secretKey,
);
print("signatureCombined: $signatureCombined");
print("signatureCombined: ${base64.encode(signatureCombined)}");

var verifyCombined = sodium.crypto.sign.open(
  signedMessage: signatureCombined,
  publicKey: randomKeyPair.publicKey,
);
print("verifyCombined: $verifyCombined");
print("verifyCombined: ${utf8.decode(verifyCombined)}");
```

```console
signatureCombined: [175, 80, 179, 20, 23, 55, 168, 83, 169, 53, 225, 232, 239, 10, 9, 101, 53, 236, 192, 245, 177, 194, 17, 42, 195, 100, 161, 72, 62, 172, 251, 39, 160, 26, 90, 165, 49, 158, 220, 169, 183, 149, 174, 209, 44, 85, 214, 189, 62, 246, 93, 249, 215, 40, 54, 32, 240, 150, 56, 78, 93, 23, 101, 7, 116, 101, 115, 116]
signatureCombined: r1CzFBc3qFOpNeHo7woJZTXswPWxwhEqw2ShSD6s+yegGlqlMZ7cqbeVrtEsVda9PvZd+dcoNiDwljhOXRdlB3Rlc3Q=
verifyCombined: [116, 101, 115, 116]
verifyCombined: test
```

The detached mode produces a signature without altering the message. To sign the message, the [`detached()`](https://pub.dev/documentation/sodium/latest/sodium/Sign/detached.html) method is invoked, and to verify it, the [`verifyDetached()`](https://pub.dev/documentation/sodium/latest/sodium/Sign/verifyDetached.html) is called.

```dart
var messageDetached = utf8.encode("test");
print("message: ${base64.encode(messageDetached)}");
var signatureDetached = sodium.crypto.sign.detached(
  message: messageDetached,
  secretKey: randomKeyPair.secretKey,
);
print("signatureDetached: ${base64.encode(signatureDetached)}");

var verifyDetached = sodium.crypto.sign.verifyDetached(
  message: messageDetached,
  publicKey: randomKeyPair.publicKey,
  signature: signatureDetached,
);
print("verifyDetached: $verifyDetached");
```

```console
message: dGVzdA==
signatureDetached: r1CzFBc3qFOpNeHo7woJZTXswPWxwhEqw2ShSD6s+yegGlqlMZ7cqbeVrtEsVda9PvZd+dcoNiDwljhOXRdlBw==
verifyDetached: true
```

Finally, the multi-part messages mode is used to sign/verify huge messages and is using a `Stream` in the Dart implement. To sign a message in multi-part messages mode, the 

```dart
var messageMulti = () async {
  return utf8.encode("test");
};
var signatureMulti = await sodium.crypto.sign.stream(
  messages: Stream.fromFuture(messageMulti()),
  secretKey: randomKeyPair.secretKey,
);
print("signatureMulti: ${base64.encode(signatureMulti)}");

var verifyMulti = await sodium.crypto.sign.verifyStream(
  messages: Stream.fromFuture(messageMulti()),
  signature: signatureMulti,
  publicKey: randomKeyPair.publicKey,
);
print("verifyMulti: $verifyMulti");
```

```console
signatureMulti: KqgvmypphuUC0aLzZCQ56rQQ2CwidxdQFoBBlVDqLhvqiyQKZSbBvq76UsChFy9GLm+rM6ncBocevJHTthMNBg==
verifyMulti: true
```

Don't hesitate to check the API documentation, especially the [`SignSumo`](https://pub.dev/documentation/sodium/latest/sodium_sumo/SignSumo-class.html) class and the [`call()`](https://pub.dev/documentation/sodium/latest/sodium/Sign/call.html) method.

# Public Key Encryption

[`libsodium`](https://libsodium.gitbook.io/) offers an easy interface to encrypt data with via a public key. In fact, it will use the public/private key to authenticate the message while a secret a shared between both part of the communication. The messages are then encrypted using the [XSalsa20](https://libsodium.gitbook.io/doc/advanced/stream_ciphers/xsalsa20) stream cipher. Key pairs can be generated using the [`keyPair()`](https://pub.dev/documentation/sodium/latest/sodium/Box/keyPair.html) method from a[`Box`](https://pub.dev/documentation/sodium/latest/sodium/Box-class.html) object instance.

```dart
var kpAlice = sodium.crypto.box.keyPair();
var kpBob = sodium.crypto.box.keyPair();
print("kpAlice: ${base64.encode(kpAlice.publicKey)}");
print("kpBob: ${base64.encode(kpBob.publicKey)}");
```

```console
kpAlice: UfVCLUDk7+W/8hdnGvGWXUAazrzhDmGJvx1b14ZTtRc=
kpBob: U9zxXl5KfUO3XcKNoLeYg/hZawnzjMIaLQ8kf01pNF8=
```

Then, the [`easy()`](https://pub.dev/documentation/sodium/latest/sodium/Box/easy.html) method can be invoked to create an encrypted payload containing all required information for the exchange.

```dart
var msg1 = utf8.encode("hello Bob!");
var nonce1 = sodium.randombytes.buf(24);
var cipher1 = sodium.crypto.box.easy(
  message: msg1,
  nonce: nonce1,
  publicKey: kpBob.publicKey,
  secretKey: kpAlice.secretKey,
);
print("msg1: ${base64.encode(msg1)}");
print("nonce1: ${base64.encode(nonce1)}");
print("cipher1: ${base64.encode(cipher1)}");
```

```console
msg1: aGVsbG8gQm9iIQ==
nonce1: ACpqcCbUEGfeUtqF4qhjJhKLZ/56mJHh
cipher1: t0dIKRIlLxTX3Cp656DN/XgRy8rka9GApsw=
```

After the reception of the message by the receiver, the clear text can be extracted using the [`openEasy()`](https://pub.dev/documentation/sodium/latest/sodium/Box/openEasy.html) method.

```dart
var recv1 = sodium.crypto.box.openEasy(
  cipherText: cipher1,
  nonce: nonce1,
  publicKey: kpAlice.publicKey,
  secretKey: kpBob.secretKey,
);
print("recv1: ${utf8.decode(recv1)}");
```

```console
recv1: hello Bob!
```

Another exchange can be initiated using the same principle (for example to send a response to the previous message).

```dart
var msg2 = utf8.encode("Hey alice");
var nonce2 = sodium.randombytes.buf(24);
var cipher2 = sodium.crypto.box.easy(
  message: msg2,
  nonce: nonce2,
  publicKey: kpAlice.publicKey,
  secretKey: kpBob.secretKey,
);
```

```console
msg2: SGV5IGFsaWNl
nonce2: XqvB6EwaF9GxPvSSM/TMuSkaXLmUfnDF
cipher2: q0fyatMRoWChE17eKUouJinJTqahCa8P3g==
```

```dart
var recv2 = sodium.crypto.box.openEasy(
  cipherText: cipher2,
  nonce: nonce2,
  publicKey: kpBob.publicKey,
  secretKey: kpAlice.secretKey,
);
print("recv2: ${utf8.decode(recv2)}");
```

```console
recv2: Hey alice
```

`libsodium` is also offering a detached mode, it will give more flexibility when sending the information, instead of using a complete payload, the required information can be put in some other formats. To use this mode, the [`detached()`](https://pub.dev/documentation/sodium/latest/sodium/Box/detached.html) and [`openDetached()`](https://pub.dev/documentation/sodium/latest/sodium/Box/openDetached.html) methods can be used.

It is also possible to use a [Sealed Box](https://libsodium.gitbook.io/doc/public-key_cryptography/sealed_boxes#usage) with the help of the [`seal()`](https://pub.dev/documentation/sodium/latest/sodium/Box/seal.html) and [`sealOpen()`](https://pub.dev/documentation/sodium/latest/sodium/Box/sealOpen.html) methods. The idea is to make the exchange even more secure by always creating an ephemeral key.

More information can be found on the [official `libsodium` documentation](https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption).

# Key Exchange

`libsodium` also offers some facilities to do [key exchanges](https://libsodium.gitbook.io/doc/key_exchange) and [key derivation](https://libsodium.gitbook.io/doc/key_derivation). A keypair can be generate using the [`keyPair()`](https://pub.dev/documentation/sodium/latest/sodium/Kx/keyPair.html) method from an instance of a [`Kx`](https://pub.dev/documentation/sodium/latest/sodium/Kx-class.html) object or by deriving an existing key using the [`seedKeyPair()`](https://pub.dev/documentation/sodium/latest/sodium/Kx/seedKeyPair.html) method from the same instance.

```dart
var kpClient = sodium.crypto.kx.keyPair();
var kpServer= sodium.crypto.kx.keyPair();
print("kpClient: ${base64.encode(kpClient.publicKey)}");
print("kpServer: ${base64.encode(kpServer.publicKey)}");
```

```console
kpClient: dPmBU3994tkERAjQUyD+ibo7rBFujq+ZV197l8FvwVU=
kpServer: 52FiQPJtOJkkBDoRoZYzC3ASjJDFsHu6SbeEP3jrswg=
```

A session can be started by sharing one's public key, signed with its private key, and by sharing a secret encrypted with the target public key. To do that, the [`clientSessionKeys()`](https://pub.dev/documentation/sodium/latest/sodium/Kx/clientSessionKeys.html) method can be used. It will return a [`SessionKeys`](https://pub.dev/documentation/sodium/latest/sodium/SessionKeys-class.html) object, containing the session keys to decrypt received data ([`tx`](https://pub.dev/documentation/sodium/latest/sodium/SessionKeys/rx.html) property) or encrypt ([`tx`](https://pub.dev/documentation/sodium/latest/sodium/SessionKeys/tx.html)) data to send.

```dart
var session1 = sodium.crypto.kx.clientSessionKeys(
  clientPublicKey: kpClient.publicKey,
  clientSecretKey: kpClient.secretKey,
  serverPublicKey: kpServer.publicKey,
);  
print("session1: $session1");
print("session1.tx: ${base64.encode(session1.tx.extractBytes())}");
print("session1.rx: ${base64.encode(session1.rx.extractBytes())}");
```

```console
session1: SessionKeys(rx: Instance of 'SecureKeyFFI', tx: Instance of 'SecureKeyFFI')
session1.tx: vzJw72Dib/qHhze9LOsUGwYxjFYNzWV3D6541pLMxZc=
session1.rx: r7QtsYaSFrydDg6ijk1mbNrvR3cVSJmFqMXVH3m2YV4=
```

The previous example was using the client API, but a server can also take the lead by creating its session via the [`serverSessionKeys()`](https://pub.dev/documentation/sodium/latest/sodium/Kx/serverSessionKeys.html) method. The same kind of object is returned.

```dart
var session2 = sodium.crypto.kx.serverSessionKeys(
  serverPublicKey: kpServer.publicKey,
  serverSecretKey: kpServer.secretKey,
  clientPublicKey: kpClient.publicKey,
);  
print("session2: $session2");
print("session2.tx: ${base64.encode(session2.tx.extractBytes())}");
print("session2.rx: ${base64.encode(session2.rx.extractBytes())}");
```

```console
session2: SessionKeys(rx: Instance of 'SecureKeyFFI', tx: Instance of 'SecureKeyFFI')
session2.tx: r7QtsYaSFrydDg6ijk1mbNrvR3cVSJmFqMXVH3m2YV4=
session2.rx: vzJw72Dib/qHhze9LOsUGwYxjFYNzWV3D6541pLMxZc=
```

Creating encrypted/authenticated sessions can be challenging, more information about this part can also be found on the [official `libsodium` documentation](- https://libsodium.gitbook.io/doc/key_exchange
).

# Public Key Encapsulation

Secrets can also be shared using [key encapsulation mechanism](https://libsodium.gitbook.io/doc/public-key_cryptography/key_encapsulation). The idea is to share a secret with someone using public key cryptography. Firstly, let generate a key pair with the [`keyPair()`](https://pub.dev/documentation/sodium/latest/sodium/Kem/keyPair.html) method from a [`Kem`](https://pub.dev/documentation/sodium/latest/sodium/Kem-class.html) object instance.

```dart
KeyPair kpCarl = sodium.crypto.kem.keyPair();
print("kpCarl: ${base64.encode(kpCarl.publicKey)}");
```

```console
kpCarl: X0w77TyQOXGrhBQV/ypBYTYt6zx7kniSE4ttD1d+qKa8Wyt7nKZJXjFeAiI2tKh2KBHLR9J5QHSPOvIVy5q5ZXEVpnJL4rivkEcE+MKeqbGvsvaYv2iK3sN96ejMnWSMHBABucw+oJMMHUcnD5sHgLKtD6tDjwJkjnoIVlmNShzPiUHPinhdRIdPpEizBQsAYBo40Qwo0nAph8l6T7VoyOOCaLHJotGj/2Z3P7cqU6UUOIq6kUBkjPlKJ3e4Ojgd4whmNfg6HEQuxQvCMxfAyOWSKaZE9cETVDIy4WWIX1VDjmWNGISlEtaMwmdSbnVJB4pWNbAhbCZeJ3pWZoFP71Gy5yeH0tme+tg9S3C0CauNM5ZuevhVHfVeERZob1Ig7pEIRgB04qAW8kYlD9ZiMhWH/+PK8mQu3XxOiWUoCii3xdbLAsVvJfEUiAHDzzhzs4oerHe4WOEVGPAqjaGAvfNOEJYbC4NXL/NhRvenYcutteqMuKFDVuYo2gUZN9nEX/wzM2qNoLO2ByEi8kUkOmQgMXo8F3Y+P0woNZS6jYaBTip4ocuIP8N4YYRSEciJi+FcAK1PPGQ7kWNsNPFv2LVw8xl2DTFx8glsMsACz7wiSQgdWbkHzRkizKcLwSdYYdefz1FmaFaDL4wsXsAzjhaXvedG3Oou7OJtqHK9OwTL/DCWUZEavMCqqaqWYsxJZbol0qdhEWWL5hexm1GGzmYnCPNdsusKOOCItFUwQfB5v9qbBKCWOVBEN/dJ1scaT3cXhZaqrphT45R1EKgVKXCIwVxifDd7P9FwGlV7b1Acpfao00xtpha7DabC8NZkSoiHX2V8PnwveHUjBDqZUTIhlSZO71R2sBbB8kTC0YiU2PKgBspsf0ywenRHR8N0cFygn3a4LOCKMTd9kKUlbWbAi2o1QmtaaUwd7KfAXfShSwdt+murTOSgVjWi87sfhONml7tC4qDFo6SF5WI1nRFik5YexptOgteuRgVWkCpmVPJF1UJRMtaobzjDpGm+pfl2jDIHYml+XHMcHCkKy6KCnbxSj1MaAAyZLZI1nFbKHYpvYOLAsjQE1adf+TsfaOC7ydZ9ILp4QcxfzAFxlpiqVSyRmMiXhTdc4xQBoUEZnFM8IVcuy/Jec+pe1heu/UnA1zw0MtoB6SQ616RkAeq6zmuoRbKt/GgoQvyQq+tLfakFPcNAsdUU3/p/GeVkjXQa2Qx7M/osyrKmiUJvN7pNZ5lIe/VC9zpadLZnHoIODICIgqaIG4QFxLOdiTHP9hKB7dA4SmZxgJOn0Rl1nDBRAlIgvmiVW9lrPkO3cRGdDkE/3dGQppinn5OFxgjOtHFRJVi037hmuDaRZmW/OIiV8VCuTbkeCNUg3sUix8mxtxG0GrVsJypvMHY1DNWSV2soK4Mk/IjLUdUWImhhUeCudMBNaPINYiEJkQpd67g+YkuRXOlBy9djpRQjTQtaITVvwbbG3as9Q5RlunktEOQvqJg6zMK7i1Be/HFI4SLKqtxQg5ePYQhHIbUzppd1sweNpuDs+9XxRsxZKtUb2KjYeoKiltPFRojgHOr5Ik6yXD67oxPVMorCn3gZv8mMrPu5cg7vXiWnxXDuncdHEg==
```

The public key can be then encrypted using the desired public key (the following example is wrong, the public key to use should have been another one, but the idea is the same). To encrypt the secret, the [`enc()`](https://pub.dev/documentation/sodium/latest/sodium/Kem/enc.html) method can be used, it will return a ciphertext that can be send to to the recipient.

```dart
KemEncResult enc1 = sodium.crypto.kem.enc(
  publicKey: kpCarl.publicKey,
);  
print("enc1.ciphertext: ${base64.encode(enc1.ciphertext)}");
print("enc1.sharedSecret: ${base64.encode(enc1.sharedSecret.extractBytes())}");
```

```console
enc1.ciphertext: GgIpamj4uT72RQi1PYs8wyr5DJWGW2wAsU1tBxQIBPF4d4xke/Q3fL16FE0v5dLlF7Esvoq9DBVxSMLuGLM0xM95FU9Hz/nup6AZ2hpJEJLnzWWyw8lTMUmVmgttiKPiFCRGlaPeoZZCnofy7ccbPnST+0w3Pb0pknaxmAF6y4x6Q+Kp/u+1jbhRtx49Lb4gIWDqH3UAxWke5srjzyGnQkLBHtwsh1KIHtpFuk4KWcc5wHgZRfGHGTrim6bUZXoD6hz4KebEE4bNNEZtYDJyyME4p3sPKTLuvIBbUfJKfn3bl8rjbWBeTgDubFBoPs37PPIvg9xsJtdBRoynVoSEG6njTyNU3ZQNxbYTPgi5tVbwPpTkBwDaDc9roypNyu6QiBFVxrtSi1brsfQAeWXy2qO3PNySHhO0mcvpz27VmKE+UbaB+i93IkosxpD3TndnSkEODb0Dwzq544oTv588Qk1n02sTbEgIqofTFNjeJfyHJ3VVM/zEwKxA7lX9ud214XVZpzfLKj7AkoXlpX/0unZYUuyfyr/ooUZkvOu5cA9MBYiowZMTPNWddMkcRxCz2mRGFyZyiAGu6Xqwz8Mpv3b7Ci5r8OEZaOewke2d9XqXRSjkTEYi7hy/dVYSrX2e1STvfKxPdqtoNXCyfhg9IE+v8C0qcYgh4b34EDC1qg8BITUJl7KFFw111Qm+5B+BipVCjyttHQJUO6OoqMsDztc0NlO2kY37bI3mlU7SgHVTFEReqMHMpoIOoNWcPF6V7FwksllBkjdG5XR7bF6c0ShhQtrJViJv+wV0u7I4LtYCuHKoKnFM2+QEWMjJyrk5jpSErI3g2izscF/ku94wC3JeYUyou9gcz0u4xqMdoPBPdahZRjinmF6MzK5pY0mRhnbf6rLVkoxe5NCexmO4+ZddTEEivMx+ZCb+IYLfYfhIiWLMYYUni6MEs0hXTAv4ylS5u2JH0Ke/2YYsZ/Dj3g/zrMNPemp3IDLRSxvjWdZcF6oxP+X+tlOY/UBAiWpKFXPCTUthlH9u2KRNQX8inl4wQjqurXG4oAKqHl5SWEvTIaw6otfawZMffQIe4LjNLS/OCVZIchoFXU1KBxZX1w1Z8OW9zDIj17zYCYy5Gt+Rf0oYmqtjzq58/jQ+oggkPgj1Ey05b5XTlN2RFaID2IRJFNUMU/C0nRbpHcQJ36pS0by8UgWSHRY8Umb8u4dh6+k5zXM2X+1wEtf5SV/yN6dr7L11N7X1rHhrUuLf68Tvpuqnb0ecb3b0V5RziRC7J+NpvndDXEyqKXvZJJzOReq+mXLuc0J6qGdGpzKu7IqQwX0iKrlcTWrMNzXR667PrMnSxgMQJx7CeWHigXJGwWhWck5vhiNpy7YAZL3Awk153Zqgs0sJ+nSPVpSqkuLe1f1whfLxbiyMMQvE3KfXzYR4JY7hy5AkhKWXpehGaO+mtbxxN7+HK7n5ggKl74RO/Pl/+pPWtpEs8KfB8CY+Ng==
enc1.sharedSecret: LV6LjDbXe1v33jkOLx1YPAktFzgj2wAvQ+ns3RT6CPs=
```

The recipient receive the message and can decipher it using the [`dec()`](https://pub.dev/documentation/sodium/latest/sodium/Kem/dec.html) method. It will return the shared secret, previously generated.

```dart
SecureKey dec1 = sodium.crypto.kem.dec(
  ciphertext: enc1.ciphertext,
  secretKey: kpCarl.secretKey,
);  
print("dec1: ${base64.encode(dec1.extractBytes())}");
```

```console
dec1: LV6LjDbXe1v33jkOLx1YPAktFzgj2wAvQ+ns3RT6CPs=
```

Most of the time, the secret will be derived using a [KDF](https://libsodium.gitbook.io/doc/key_derivation), to do that, one can use [HKDF](https://libsodium.gitbook.io/doc/key_derivation/hkdf) or the [`deriveFromKey()`](https://pub.dev/documentation/sodium/latest/sodium/Kdf/deriveFromKey.html) method from a [`KDF`](https://pub.dev/documentation/sodium/latest/sodium/Kdf-class.html) object instance.

```dart
SecureKey derivedKey1 = sodium.crypto.kdf.deriveFromKey(
  masterKey: dec1,
  context: "test",
  subkeyId: BigInt.from(1),
  subkeyLen: sodium.crypto.kdf.bytesMax,
);  
print("derivedKey1: $derivedKey1");
print("derivedKey1: ${base64.encode(derivedKey1.extractBytes())}");
```

```console
derivedKey1: Instance of 'SecureKeyFFI'
derivedKey1: n1a5LPoQ80DNK0Sd3wwf4WrcjtELvPhGF6O58sM6YDk7izyipRBLpsXls42vqZNzEOrB27xuPgplF4YRIgJIDQ==
```

Don't forget to check the official [`libsodium`](https://libsodium.gitbook.io/) documentation to have more information and study their examples.

# Conclusion

`libsodium`, like most of the cryptographic libraries, is not easy to use. Why using `sodium` when other packets can offer a simpler interface? Well, because of its portability, working almost everywhere. To be honest, this library was also in my toolbox for many years (the javascript implementation), and was used on many of my personal projects, but the Dart interface feels... different.

A big part of the functions available on `libsodium` have been ported via FFI, and it's really a good thing to use modern cryptographic algorithms on a modern language. Some parts are missing though, for example, the function to encode correctly a password hash in the Unix-like format. The [source code is available from `libsodium`](https://github.com/jedisct1/libsodium/blob/master/src/libsodium/crypto_pwhash/argon2/argon2-encoding.c), but it would have been nice to have it in the Dart implementation.

I hope I will have more time to write a better post, with real use case.As usual, if you want to know a bit more about all of this:

- [`sodium` package in Dart](https://pub.dev/packages/sodium/) using FFI on pub.dev, where you will find the global information about the Dart implementation;

- [`sodium` examples in Dart](https://pub.dev/packages/sodium/example) on pub.dev, where you will find few examples;

- [`sodium` source code](https://github.com/Skycoder42/libsodium_dart_bindings) on Github, where you will find the source code of the Dart package;

- [`sodium` test suite](https://github.com/Skycoder42/libsodium_dart_bindings/blob/main/packages/sodium/test/) on Github, where you will find the test suite, quite useful to see more examples;

- [Official `libsodium` documentation](https://libsodium.gitbook.io/doc), where you will find the original documentation for the `libsodium`;

- [`libsodium` source code](https://github.com/jedisct1/libsodium) on Github, where you will find the pure-C `libsodium` source code, especially useful if you want to check the vectors and other test suite;

- [Official NaCl website](https://nacl.cr.yp.to/), the original project from cr.yp.to, you should probably check, very instructive.

Always be careful when using cryptography in your code, try to reuse existing patterns and avoid creating your own stuff, it's most of the time a bad idea. 

But as always... Happy hacking and have fun!

----

Cover image by <a href="https://unsplash.com/@mariaspics?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Maria Petersson</a> on <a href="https://unsplash.com/photos/brown-wooden-spoon-on-white-snow-OuvmgR815MQ?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>