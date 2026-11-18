---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/json-schema-in-dart-3ik7"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2F1aqghxkxy84bef8hygwc.jpg"
created_at: "None"
crossposted_at: "None"
description: "Everything which distinguishes man from the animals depends upon this ability to volatilize..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/json-schema-in-dart-3ik7"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "json-schema-in-dart-3ik7"
social_image: "None"
title: "JSON Schema in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# JSON Schema in Dart

> Everything which distinguishes man from the animals depends upon this ability to volatilize perceptual metaphors in a schema, and thus to dissolve an image into a concept.
> -- Friedrich Niezsche

When you know how to encode and decode JSON data, it can become annoying to deal with the structure every time. Worse, it can become a nightmare when some kind of data structure are being upgraded. That why some people created [JSON Schema](https://json-schema.org/). The idea is to define what kind of fields and values should be contained in JSON objects. A package called [`json_schema`](https://pub.dev/packages/json_schema) was created to implement this standard. 

# Bootstrapping

```dart
$ dart create validate
Creating validate using template console...

  .gitignore
  analysis_options.yaml
  CHANGELOG.md
  pubspec.yaml
  README.md
  bin/validate.dart
  lib/validate.dart
  test/validate_test.dart

Running pub get...                     0.3s
  Resolving dependencies...
  Downloading packages...
  Changed 48 dependencies!
  3 packages have newer versions incompatible with dependency constraints.
  Try `dart pub outdated` for more information.

Created project validate in validate! In order to get started, run the following commands:

  cd validate
  dart run

$ cd validate

$ dart pub add json_schema
Resolving dependencies... 
Downloading packages... 
  _fe_analyzer_shared 103.0.0 (104.0.0 available)
  analyzer 13.3.0 (14.0.0 available)
+ http 1.6.0
+ json_schema 5.2.2
  package_config 2.2.0 (3.0.0 available)
+ quiver 3.2.2
+ rfc_6901 0.2.1
+ uri 1.0.0
Changed 5 dependencies!
3 packages have newer versions incompatible with dependency constraints.
Try `dart pub outdated` for more information.
```

We can edit `bin/validate.dart` and import the `json_schema` package.

```dart
import 'package:json_schema/json_schema.dart';
```

# Schema Conception

> Don't trust, just verify.
> -- Steven Levitt

For this example, we will use the examples present in the [JSON Schema Getting Started tutorial](https://json-schema.org/learn/getting-started-step-by-step). Their first JSON object looks like that:

```json
{
  "productId": 1,
  "productName": "A green door",
  "price": 12.50,
  "tags": [
    "home",
    "green"
  ]
}
```

To help us with the tests, we can create a function helper instantiating a schema and validating data. Let call it `validate()`. To instantiate a new [`JsonSchema`](https://pub.dev/documentation/json_schema/latest/json_schema/JsonSchema-class.html) object, the [`JsonSchema.create()`](https://pub.dev/documentation/json_schema/latest/json_schema/JsonSchema/create.html) static function can be invoked. Then, the [`JsonSchema.validate()`](https://pub.dev/documentation/json_schema/latest/json_schema/JsonSchema/validate.html) method will be called to check if the `data` passed is correct.

```dart
void validate(Map<String, dynamic> schema, Map<String, dynamic> data, {String? msg}) {
  if (msg!=null) print("${msg}:");
  final _schema = JsonSchema.create(schema);
  final validate = _schema.validate(data);
  print("  ${validate}: ${data}");
  print("");
}
```

Before doing the whole specification for this object, we can start to specify only one of those fields, like the `productId`. `json_schema` module can use both a `Map<String, dynamic>` or a `JSON<String>` to load this. To make our life easier, we will create functions wrapper returning the schema we want as a Map.

```dart
Map<String, dynamic> _productId() {
  return {                                          
    "description": "The unique identifier for a product",
    "type": "integer",                              
  };                                                
}
```

A JSON schema describe an object and its properties. A `productId` is an `integer`. The [`description`](https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.9.1) field is not used by the validator, it's only a way to help developers and designer to understand the structure. An object can be defined by [many types](https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.6.1.1):

- `null` (e.g. `null`);

- `boolean` (e.g. `true` or `false`);

- `number` (e.g. `1` or `-1.23`);

- `integer` (e.g `1` or `1024`);

- `string` (e.g. `"test"`);

- `object` (e.g. `{}`);

- `array` (e.g. `[]`).

All of them are coming from the JSON specification itself.


```dart
Map<String, dynamic> _productName() {               
  return {                                          
    "description": "Name of the product",           
    "type": "string"                                
  };                                                
}
```

The `productName` is a `string`. Nothing complex here, the schema is similar to the `productId` object.

```dart
Map<String, dynamic> _price() {
  return {                                          
    "description": "The price of the product",
    "type": "number",                               
    "exclusiveMinimum": 0                           
  };                                                
}
```

A `price` is a `number`. To avoid negative numbers, we are also enforcing the specification with the [`exclusiveMinimum`](https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.6.2.5) parameter. If a price is negative, the schema becomes invalid.

```dart
Map<String, dynamic> _tags() {
  return {                                          
    "description": "Tags for the product",
    "type": "array",                                
    "items": {                                      
      "type": "string"                              
    },                                              
    "minitems": 1,                                  
    "uniqueItems": true                             
  };                                                
}
```

Compound terms can also be created. The `tags` object is defined as an `array` or `string`. It must have at least 1 items (see [`minitems`](https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.6.4.2) parameter) and must contain only unique items (see [`uniqueItems`](https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.6.4.3) parameter).

```dart
Map<String, dynamic> _dimensions() {
  return {                                          
    "type": "object",                               
    "properties": {                                 
      "length": {                                   
        "type": "number"                            
      },                                            
      "width": {                                    
        "type": "number"                            
      },                                            
      "height": {                                   
        "type": "number"                            
      }                                             
    },                                              
    "required": [ "length", "width", "height" ]
  };                                                
}
```

Another `object` can be defined. It is also a compound term. In our case, the `dimensions` of an item must have a `length` as `number`, a `width` as `number` and a `height` as number too. All those fields are required (see [`required`](https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.6.5.3)).

```java
Map<String, dynamic> fullSchema() {
  return {
    "\$schema": "https://json-schema.org/draft/2020-12/schema",
    "\$id": "https://example.com/product.schema.json",
    "title": "Product",             
    "description": "A product in the catalog",
    "type": "object",
    "required": [  
      "productId",
      "productName",    
      "price",
    ],          
    "properties": {     
      "productId": _productId(),
      "productName": _productName(),
      "price": _price(),
      "tags": _tags(),
      "dimensions": _dimensions()
    }                                          
  };
}
```

Finally, the function `fullSchema()` is containing the whole JSON schema. Lot of fields here a kinda mandatory and are directly related to the JSON Schema specification. Let test that in our main entry-point.

```dart
void main(List<String> arguments) {
  validate(fullSchema(), {}, msg: "empty data");

  validate(fullSchema(), {
    "productId": 1
  }, msg: "productId only");

  validate(fullSchema(), {
    "productId": 1,
    "productName": "A green door",
    "price": 12.50
  }, msg: "minimal valid data");

  validate(fullSchema(), {
    "productId": 1,
    "productName": "A green door",
    "price": 12.50,
    "tags": [
      "home",
      "green"
    ]
  }, msg: "valid data with tags");

  validate(fullSchema(), {
    "productId": 1,
    "productName": "A green door",
    "price": 12.50,
    "tags": [
      "home",
      "green"
    ],
    "dimensions": {
      "length": 1,
      "width": 2,
      "height": 3,
    }
  }, msg: "valid data with tags and dimensions");
}
```

We can now run this application to see the result.

```console
$ dart run
Resolving dependencies in `/tmp/dart/validate`... 
Downloading packages... 
Got dependencies in `/tmp/dart/validate`.
Building package executable... 
Built validate:validate.

empty data:
  INVALID, Errors: [# (root): required prop missing: productId from {}, /productId: required prop missing: productId from {}, # (root): required prop missing: productName from {}, /productName: required prop missing: productName from {}, # (root): required prop missing: price from {}, /price: required prop missing: price from {}]: {}

productId only:
  INVALID, Errors: [# (root): required prop missing: productName from {productId: 1}, /productName: required prop missing: productName from {productId: 1}, # (root): required prop missing: price from {productId: 1}, /price: required prop missing: price from {productId: 1}]: {productId: 1}

minimal valid data:
  VALID: {productId: 1, productName: A green door, price: 12.5}

valid data with tags:
  VALID: {productId: 1, productName: A green door, price: 12.5, tags: [home, green]}

valid data with tags and dimensions:
  VALID: {productId: 1, productName: A green door, price: 12.5, tags: [home, green], dimensions: {length: 1, width: 2, height: 3}}
```

As you can see, if the data received is missing some fields, the data is considered invalid. In other hands, if the requirements are there, the data is considered valid. Great, right? We now have a way to control the data received (or to control what we are sending).

# Conclusion

> Without approval and without scorn, but carefully studying the sentences word by word, one should trace them in the Discourses and verify them by the Discipline. If they are neither traceable in the Discourses nor verifiable by the Discipline, one must conclude thus: 'Certainly, this is not the Blessed One's utterance; this has been misunderstood by that bhikkhu - or by that community, or by those elders, or by that elder.' In that way, bhikkhus, you should reject it.
> -- Siddharta Gautama

JSON Schema is a good way to make your application resilient and stable. It can be used as documentation tool, it will help to create tests, and it will also ensure the data received are legit. If you are working with public APIs, it can also help you to create the OpenAPI specifications. Finally, it will help you to design your application by thinking on what it needs, it will lead to a lean application containing only the necessary values.

JSON Schema can also be used to help us to reverse engineer private API interfaces by documenting what kind of data is working and which ones are not working. Creating specifications is great, Enjoy.

Wants to know more about JSON Schema? Here few interesting resources for you.

- [Official JSON Schema website](https://json-schema.org/);

- [`json_schema` package](https://pub.dev/packages/json_schema) on pub.dev;

- [`json_schema` API documentation](https://pub.dev/documentation/json_schema/latest/) on pub.dev;

- [`json_schema` source code](https://github.com/workiva/json_schema) on Github;

- [`json_schema` examples](https://github.com/Workiva/json_schema/tree/master/example) on Github;

- [JSON Schema Explained with Examples: The Complete Guide](https://dev.to/_d7eb1c1703182e3ce1782/json-schema-explained-with-examples-the-complete-guide-2679) by [楊東霖](https://dev.to/_d7eb1c1703182e3ce1782) on dev.to;

- [How to Validate JSON Schema: A Complete Developer Guide](https://dev.to/_d7eb1c1703182e3ce1782/how-to-validate-json-schema-a-complete-developer-guide-219e) by [楊東霖](https://dev.to/_d7eb1c1703182e3ce1782) on dev.to;

- [JSON Schema in 10 Minutes — Validation, Types & Real Examples](https://dev.to/anh_qunnguyn_57549060f/json-schema-in-10-minutes-validation-types-real-examples-4pjg) by [Anh Quân Nguyễn](https://dev.to/anh_qunnguyn_57549060f) on dev.to;

- [JSON Schema Examples - Real-World Schema Patterns](https://jsonwebtools.com/json-schema-examples) by [Saurabh Goyal](https://jsonwebtools.com/about).

Happy Hack and Have fun!

----

Cover Image by <a href="https://unsplash.com/@killerfvith?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Alex wong</a> on <a href="https://unsplash.com/photos/worms-eye-view-of-buildings-l5Tzv1alcps?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>