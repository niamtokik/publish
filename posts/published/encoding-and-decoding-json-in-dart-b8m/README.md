---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/encoding-and-decoding-json-in-dart-b8m"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2F44fuzvev1teqyjndqq1s.jpg"
created_at: "None"
crossposted_at: "None"
description: "Is it really necessary to introduce JSON in 2026? Any developers had to deal with JSON at least one..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/encoding-and-decoding-json-in-dart-b8m"
public_reactions_count: "1"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "encoding-and-decoding-json-in-dart-b8m"
social_image: "None"
title: "Encoding and Decoding JSON in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Encoding and Decoding JSON in Dart

Is it really necessary to introduce [JSON](https://json.org/) in 2026? Any developers had to deal with JSON at least one time in his career. Anyway, JSON (JavaScript Object Notation) is an open standard format designed for web development usage. In fine, it became one of the most used data format.

Before working on more challengin but interesting serializer like [CBOR](https://cbor.io/) or [Protocol Buffer](https://protobuf.dev/), let take a moment to learn how use JSON in Dart.

```dart
import 'dart:convert';
```

When one needs to encode or decode JSON, two ways existing, using the [`JsonCodec()`](https://api.dart.dev/dart-convert/JsonCodec-class.html) class or use the specific class for encoding ([`JsonEncoder()`](https://api.dart.dev/dart-convert/JsonEncoder-class.html)) or for decoding ([`JsonDecoder()`](https://api.dart.dev/dart-convert/JsonDecoder-class.html)). In both case, the result will be the same.

# Encoding

JSON encoder is directly integrated in the Dart SDK, and can be included in your code by simply importing [`dart:convert`](https://api.dart.dev/dart-convert/) package.

```dart
import 'dart:convert';
```

Let create a first function called `encode()` to encode any kind of object using the [`json.encode()`](https://api.dart.dev/dart-convert/JsonCodec/encode.html) interface.

```dart
void encode(Object data, {String label = ""}) {
  print("-- ${label}:");
  var encoded = json.encode(data);
  print(encoded);
  print("");
}
```

Now, let create another function called `encode2()`. This one will instantiate an object from the [`JsonEncoder()`](https://api.dart.dev/dart-convert/JsonEncoder-class.html) class.

```dart
void encode2(Object data, {String label = ""}) {
  var encoder = JsonEncoder();
  print("-- ${label}:");
  var encoded = encoder.convert(data);
  print(encoded);
  print("");
}
```

Great, we have two ways to encode our objects, the main entry-point is still missing though. Let fix that.

```dart
void main() {
  print("== encode with JsonCodec");
  encode(1, label: "integer(1)");
  encode("test", label: "string(test)");
  encode([], label: "list()");
  encode([1,2,3], label: "list(1,2,3)");
  encode({}, label: "map()");
  encode({"a": 1}, label: "map(a, 1)");
  encode(0.001, label: "float(0.001)");
  encode(true, label: "bool(true)");
  encode(false, label: "bool(false)");
  
  print("encode with JsonEncoder");
  encode2(1, label: "integer(1)");
  encode2("test", label: "string(test)");
  encode2([], label: "list()");
  encode2([1,2,3], label: "list(1,2,3)");
  encode2({}, label: "map()");
  encode2({"a": 1}, label: "map(a, 1)");
  encode2(0.001, label: "float(0.001)");
  encode2(true, label: "bool(true)");
  encode2(false, label: "bool(false)");
}
```

The time has come to execute this program and see the result.

```console
$ dart run bin/encode.dart
== encode with JsonCodec
-- integer(1):
1

-- string(test):
"test"

-- list():
[]

-- list(1,2,3):
[1,2,3]

-- map():
{}

-- map(a, 1):
{"a":1}

-- float(0.001):
0.001

-- bool(true):
true

-- bool(false):
false

encode with JsonEncoder
-- integer(1):
1

-- string(test):
"test"

-- list():
[]

-- list(1,2,3):
[1,2,3]

-- map():
{}

-- map(a, 1):
{"a":1}

-- float(0.001):
0.001

-- bool(true):
true

-- bool(false):
false
```

It looks okay, the main Dart types are supported, but what will happen if we give an unsupported type to the encoder?

```dart
void main() {
  json.encode(Object());
}
```

The code is simple, we pass a raw `Object()`  to [`json.encode()`](https://api.dart.dev/dart-convert/JsonCodec/encode.html).

```console
$ dart bin/encode_exception.dart
Uncaught Error, error: Error: Converting object to an encodable object failed: Instance of 'Object'
```

Doh, it produces an error! In fact, this is normal, the JSON encoder does not know how to deal with such objects. JSON only support a subset of all Dart type, so, in this case, we need to find a way to convert (serialize) similar objects to something compatible with JSON. In most of the case, it will be converted as `String()`, perhaps using Base64 or something similar.

To illustrate that, let create a new class called `Tuple`, it will contain two public attributes, a `left` and a `right` one. Both are [`String()`](https://api.dart.dev/dart-core/String-class.html). To represent this kind of object in JSON we can easily use a Map containing at least two fields, one for the left and one of the right. Adding a method called `toJson()` here will help us.

```dart
class Tuple {
  String left = "";
  String right = "";
  Tuple(this.left, this.right);
  Map<String, String> toJson() => {
    "_object": "Tuple",
    "left": left,
    "right": right
  };
}
```

The JSON encoder needs a way to know how to convert this new object, it can be done by creating a simple function like the following one. The idea is to check the type of the object passed as argument and to return another object compatible with the JSON format.

```dart
Function(dynamic) toEncodable() {
  return (o) {
    switch (o) {
      case Tuple(): return o.toJson();
      case Object(): return o.toString();
    }
  };
}
```

The `toEncodable()` function can be passed to the [`JsonCodec`](https://api.dart.dev/dart-convert/JsonCodec/JsonCodec.html) constructor via the [`toEncodable`](https://api.dart.dev/dart-convert/JsonEncoder/JsonEncoder.html) attribute. The rest is pure testing.

```dart
void main() {
  var encoder = JsonCodec(toEncodable: toEncodable());
  var encoded = encoder.encode([
    1,
    "test",
    Object(),
    Tuple("Left1", "Right1")
  ]);
  print(encoded);
}
```

Let execute the code and check the result.

```console
$ dart bin/encode_encable.dart
[1,"test","Instance of 'Object'",{"_object":"Tuple","left":"Left1","right":"Right1"}]
```

Our object is correctly converted to a JSON map containing a left and right field. Regarding the raw object, we have now a string containing `"Instance of 'Object'"`, that's the direct result of the `toString()` method.

Last trick, it is also possible to encode a JSON using indentation via the [`JsonEncoder.withIndent()`](https://api.dart.dev/dart-convert/JsonEncoder/JsonEncoder.withIndent.html) constructor.

```dart
import 'dart:convert';

void main() {
  print(JsonEncoder
    .withIndent(" ")
    .convert(
      {"test": [1,2,3]}
    )
  );
}
```

Let execute our code, the output should be a JSON with indentation.

```console
$ dart bin/encode_indent.dart
{
 "test": [
  1,
  2,
  3
 ]
}
```

That's right! It works! Next step, decoding JSON.

# Decoding

Decoding a JSON String is similar than encoding Dart objects, one can use [`JsonCodec`](https://api.dart.dev/dart-convert/JsonCodec-class.html) or create a [`JsonDecoder`](https://api.dart.dev/dart-convert/JsonDecoder-class.html) object, the result will be the same.

```dart
void main() {
  print(
    json.decode(
      '{"test": 1}'
    )
  );
  
  print(
    JsonDecoder()
    .convert(
      '{"test": 1}'
    )
  );
}
```

Let execute this code.

```console
$ dart run bin/decode.dart
{test: 1}
{test: 1}
```

Without surprise, it returns a [`Map()`](https://api.dart.dev/dart-core/Map-class.html), but, what if we want to return a specific Object instead? Let take our `Tuple` class back from the Encoding section.

```dart
class Tuple {
  String left = "";
  String right = "";
  Tuple(this.left, this.right);
  Map<String, String> toJson() => {
    "_object": "Tuple",
    "left": left,
    "right": right
  };
}
```

The [`JsonDecoder`](https://api.dart.dev/dart-convert/JsonDecoder-class.html) class can accept a [`reviver()`](https://api.dart.dev/dart-convert/JsonDecoder/JsonDecoder.html) function passed as parameter and can be used for this kind of situation. When some data looks like it's a specific object, the `reviver()` function will be able to return the correct instantiated object. Here an example:

```dart
Object? Function (Object? key, Object? value)? reviver() {
  return (key, value) {
    print("--> key: $key");
    print("--> value: $value");
    switch (value) {
      case {"_object": "tuple"}: 
        var v = value as Map<String,dynamic>;
        return Tuple(v["left"] ?? "", v["right"] ?? "");
      default: return value;
    }
  };
}
```

The snippet above will check each value returned by the decoder, and if one of these values are matching a specific kind of pattern (in our case if the value is a Map containing a field `object` containing the string `tuple`), then it will create the object. Let check that with a new main entry-point.

```dart
void main() {
  var toEncode = {
    "1": [{ 
      "test": {
        "data": 2
      }
    }]
  };
  var decoder = JsonDecoder(reviver());
  var x = decoder.convert(
    json.encode(
      toEncode
    )
  );
  print("==> final: $x");
}
```

Now, we can execute the code and check the output.

```console
$ dart bin/decode_reviver.dart
--> key: data
--> value: 2
--> key: _object
--> value: tuple
--> key: left
--> value: left
--> key: right
--> value: right
--> key: tuple
--> value: {_object: tuple, left: left, right: right}
--> key: test
--> value: {data: 2, tuple: Instance of 'Tuple'}
--> key: 0
--> value: {test: {data: 2, tuple: Instance of 'Tuple'}}
--> key: 1
--> value: [{test: {data: 2, tuple: Instance of 'Tuple'}}]
--> key: null
--> value: {1: [{test: {data: 2, tuple: Instance of 'Tuple'}}]}
==> final: {1: [{test: {data: 2, tuple: Instance of 'Tuple'}}]}
```

As you can see, the returned value by the decoder includes an instance of a `Tuple` class. The code is still a bit messy, not enough check, but the idea is there.

# Conclusion

This post was a small one, JSON is a simple format, and the interfaces used to encode/decode it are relatively easy to use, at least, for simple use cases. JSON can also be specified using schema or used as serializer, but it will be seen in another publication. As usual, for the ones would like to dive deeper in the subject, here few interesting links for you.

- [Official JSON Dart Tutorial](https://dart.dev/learn/tutorial/data-and-json), where you can see more complex examples;

- [JsonCodec class](https://api.dart.dev/dart-convert/JsonCodec-class.html), where you will find the complete documentation API for the JsonCodec class;

- [JsonDecoder class](https://api.dart.dev/dart-convert/JsonDecoder-class.html), where you will learn how to use the JsonDecoder class;

- [JsonEncoder class](https://api.dart.dev/dart-convert/JsonEncoder-class.html), where the full description of the JsonEncoder class can be found;

- [`dart:convert` JSON source code](https://github.com/dart-lang/sdk/blob/fc3da898ea1664b8a8633f6ec03d2c2290bb3d01/sdk/lib/convert/json.dart), where you will find the full documentation of the `convert` package, containing also the classes for Base64 or UTF8/Unicode;

- [Passing Data from Dart to JSON for Backend Integration](https://dev.to/avwerosuoghene/passing-data-from-dart-to-json-for-backend-integration-5bn2a) by @avwerosuoghene

- [Mastering JSON Models in Dart & Flutter: From Basics to Complex Models](https://medium.com/@codewithif/mastering-json-serialization-in-dart-flutter-from-basics-to-complex-models-4c764400c2d6) by [Iftekhar Ahmed](https://medium.com/@codewithif) on Medium

- [How to Parse JSON in Dart/Flutter](https://medium.com/@vikranthsalian/how-to-parse-json-in-dart-flutter-60c17143198e) by [Vikranh Salian](https://medium.com/@vikranthsalian) on Medium

- [Mastering JSON Encoding and Decoding in Flutter/Dart: A Comprehensive Guide for API Integration](https://medium.com/@bhavesh.sachala/mastering-json-encoding-and-decoding-in-flutter-dart-a-comprehensive-guide-for-api-integration-b5153aa6f1bc) by [Bhaveshh Sachala](https://medium.com/@bhavesh.sachala) on Medium 

Have fun!

----

Cover Image by <a href="https://unsplash.com/@dieter_muenchen?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Dieter K</a> on <a href="https://unsplash.com/photos/a-black-and-white-photo-of-a-row-of-sinks-M4G5BSUo1p4?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>