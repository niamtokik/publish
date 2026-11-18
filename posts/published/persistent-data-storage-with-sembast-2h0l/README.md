---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/persistent-data-storage-with-sembast-2h0l"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Feoctxw2a9o1x9ifqfgi6.jpg"
created_at: "None"
crossposted_at: "None"
description: "As a general rule, the most successful man in life is the man who has the best information. --..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/persistent-data-storage-with-sembast-2h0l"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "persistent-data-storage-with-sembast-2h0l"
social_image: "None"
title: "Persistent Data Storage with sembast"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Persistent Data Storage with sembast

> As a general rule, the most successful man in life is the man who has the best information.
> -- Benjamin Disraeli

It's pretty rare to find an application without state, in fact, I don't even think it's possible to find that except for prototype or demos. My future application(s) will require a way to store temporarily data locally (e.g. cache), and it could be nice to have something flexible to do that. In Erlang/Elixir, in-memory cache can be created with [ETS](https://www.erlang.org/doc/apps/stdlib/ets.html), for persistent state, [DETS](https://www.erlang.org/doc/apps/stdlib/dets.html) can also be used. More recently, a [rocksdb backend for Mnesia](https://github.com/aeternity/mnesia_rocksdb) has been created and seems stable enough to be used by blockchains like [aeternity](https://github.com/aeternity).

Anyway, we are not writing Erlang code there, it's about Dart, and we have a lot of choice from [pub.dev](https://pub.dev), here a quick list of the popular ones:

- [`sembast`](https://pub.dev/packages/sembast): NoSQL persistent embedded file system document-based database for Dart VM and Flutter with encryption support;

- [`objectbox`](https://pub.dev/packages/objectbox): Flutter database for super-fast NoSQL ACID compliant object persistence;

- [`tostore`](https://pub.dev/packages/tostore): Fast distributed AI vector database and persistent local storage engine. High-performance key-value store supporting SQL, NoSQL, offline cache and encrypted data;

- [`localstore`](https://pub.dev/packages/localstore): A JSON file-based storage package provides a persistent repository for simple NoSQL database;

- [`isar`](https://pub.dev/packages/isar): Extremely fast, easy to use, and fully async NoSQL database for Flutter;

- [`mimir`](https://pub.dev/packages/mimir): Extremely powerful, reactive NoSQL database with typo-tolerant full-text search and declarative queries;

- [`stash`](https://pub.dev/packages/stash): a key-value store abstraction with plain and cache driven semantics and support for a pluggable backend architecture;

- [`orange`](https://pub.dev/packages/orange): super fast and esay modern key-value store. working everywhere.and no need build_runner;

- [`hive`](https://pub.dev/packages/hive): Lightweight and blazing fast key-value database written in pure Dart. Strongly encrypted using AES-256.

All of them look great, but for this first article, we will test [`sembast`](https://pub.dev/packages/sembast). The [source code](https://github.com/tekartik/sembast.dart/tree/master/sembast) is available on Github, and the [API Documentation](https://pub.dev/documentation/sembast/latest/) can be found on pub.dev. [More examples and documentation](https://github.com/tekartik/sembast.dart/tree/master/sembast/doc) can also be found in the doc directory from the repository.

# Bootstrapping

As usual, we will create a small sandbox project, called `sb` this time.

```dart
$ dart create sb
Creating sb using template console...
                                               
  .gitignore                         
  analysis_options.yaml
  CHANGELOG.md                             
  pubspec.yaml
  README.md    
  bin/sb.dart                                                                                  
  lib/sb.dart                                                                                  
  test/sb_test.dart                          
                                               
Running pub get...                     4.1s                                                                                                                                                   
  Resolving dependencies...                                                                    
  Downloading packages...
  Changed 48 dependencies!

Created project sb in sb! In order to get started, run the following commands:
                                                                                               
  cd sb                                                                                        
  dart run                                                                                     

$ cd sb

$ dart pub add sembast
Resolving dependencies... 
Downloading packages... 
+ sembast 3.8.9+1
+ synchronized 3.4.1
Changed 2 dependencies!
```

# Persistent Local Store

> The NICS database has holes big enough to drive a Mack truck through.
> -- John Kennedy

A [sembast](https://pub.dev/documentation/sembast/latest) database needs to be initialized like any other database. [`sembast.dart`](https://pub.dev/documentation/sembast/latest/sembast/) and [`sembast_io.dart`](https://pub.dev/documentation/sembast/latest/sembast_io/) are required. The first one will offer the methods to deal with the database, the second one will give access to 

```dart
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart' as sio;
```

To help us for the initialization part, we can create a dedicated function called `initDb()`. `sembast` can support different kind of method to store the database, in this example, we will use an IO database stored on the filesystem with the help of [`databaseFactoryIo`](https://pub.dev/documentation/sembast/latest/sembast_io/databaseFactoryIo.html) method. It returns a new [`DatabaseFactory()`](https://pub.dev/documentation/sembast/latest/sembast/DatabaseFactory-class.html) object we can directly use to open the database via the [`openDatabase()`](https://pub.dev/documentation/sembast/latest/sembast/DatabaseFactory/openDatabase.html) method.

```dart
Future<Database> initDb({dbPath = "./sample.db"}) async {
  String dbPath = './sample.db';
  DatabaseFactory dbFactory = sio.databaseFactoryIo;
  return await dbFactory.openDatabase(dbPath);
}
```

This function can be called from the `main()` entry-point. At the end of the execution, the database can be closed by calling the [`close()`](https://pub.dev/documentation/sembast/latest/sembast/Database/close.html) method.

```dart
void main(List<String> arguments) {
  Database db = await initDb();
  await db.close();
}
```

Finally, the application can be invoked with `dart run`.

```console
$ dart run
Building package executable... 
Built sb:sb.
```

After the execution, you should find a `sample.db` file in your project directory. This is the `sembast` database. As you can see, it contains JSON objects.

```console
$ file sample.db 
sample.db: JSON text data

$ cat sample.db 
{"version":1,"sembast":1}
```

Before opening a database, some checks must be applied, especially if the local database is persistent. Indeed, if a database is already existing, opening it with `sembast` will drop its content. To avoid this issue, a [`DatabaseMode`](https://pub.dev/documentation/sembast/latest/sembast/DatabaseMode-class.html) can be configured when calling [`DatabaseFactory.openDatabase()`](https://pub.dev/documentation/sembast/latest/sembast/DatabaseFactory/openDatabase.html) method by setting the [`mode`](https://pub.dev/documentation/sembast/latest/sembast/DatabaseFactory/openDatabase.html) parameter with the database mode of your choice. As reminder, 6 modes are currently available:

- [`create`](https://pub.dev/documentation/sembast/latest/sembast/DatabaseMode/create-constant.html);

- [`defaultMode`](https://pub.dev/documentation/sembast/latest/sembast/DatabaseMode/defaultMode-constant.html);

- [`empty`](https://pub.dev/documentation/sembast/latest/sembast/DatabaseMode/empty-constant.html);

- [`existing`](https://pub.dev/documentation/sembast/latest/sembast/DatabaseMode/existing-constant.html);

- [`neverFails`](https://pub.dev/documentation/sembast/latest/sembast/DatabaseMode/neverFails-constant.html);

- [`readOnly`](https://pub.dev/documentation/sembast/latest/sembast/DatabaseMode/readOnly-constant.html).

Furthermore, before initializing or opening a database, one should check its existence. It can be achieved via the [`DatabaseFactory.databaseExists()`](https://pub.dev/documentation/sembast/latest/sembast/DatabaseFactory/databaseExists.html) method. If the database is already present on the filesystem, opening it without removing the data already stored there can be a good choice for a persistent data-store.

# In-Memory Store

> Database: the information you lose when your memory crashes.
> -- Dave Barry


`sembast` is flexible, and many different backend can used. For example, if you have to deal with temporary data,

```dart
import 'package:sembast/sembast_memory.dart' as smem;
```

```dart
Future<Database> initMemDb({dbId = "main"}) async {
  DatabaseFactory dbFactory = smem.databaseFactoryMemory;
  return await dbFactory.openDatabase(dbId);
}
```

- https://pub.dev/documentation/sembast/latest/sembast_memory/

# Data Store Usage

> If you want a database, you don't go out and say you're going to write it. I see platforms as going in that direction.
> -- Parker Harris

Now we know how to create a database with `sembast`, we can use it. Any data added, updated or removed from the database needs a [`StoreRef()`](https://pub.dev/documentation/sembast/latest/sembast/StoreRef-class.html) object, one object from this class can be instantiated using with the [`StoreRef.main()`](https://pub.dev/documentation/sembast/latest/sembast/StoreRef/StoreRef.main.html) constructor.

```dart
var store = StoreRef.main();
```

A new value can be added via the [`add()`](https://pub.dev/documentation/sembast/latest/sembast/SembastStoreRefExtension/add.html) method. If no record has been defined, then the key will be an auto-incremented integer. Assuming the database is a fresh new one, the returned key will be set to `1`.

```dart
var k = await store.add(db, "1234");
  print("k: ${k}");
var key = store.add(db, "test");
```

```console
k: 5
```

In case one would like to set a different key, for example using a `String` or a different kind of data, a new record can be created via the [`record()`](https://pub.dev/documentation/sembast/latest/sembast/StoreRef/record.html) method. In the following example, the value `mykey` will be printed.

```plaintext
var k2 = await store.record("mykey").add(db, "test");
print("k2: ${k2}");
```

```console
k2: mykey
```

At this point in the database, two key/value have been added, one with the key `1` and the second with the key `mykey`. To list all the keys available, one can use the [`findKeys()`](https://pub.dev/documentation/sembast/latest/sembast/SembastStoreRefExtension/findKeys.html) method. It is possible to filter the keys by configuring the `finder` parameter with a [`Finder()`](https://pub.dev/documentation/sembast/latest/sembast/Finder-class.html) object, if not configured, all keys will be returned.

```dart
var keys = await store.findKeys(db);
print("keys: ${keys}");
```

```console
keys: [1, mykey] 
```

If one wants to check if a key is present, the [`findKey()`](https://pub.dev/documentation/sembast/latest/sembast/SembastStoreRefExtension/findKey.html) method can be used instead. Like the previous method, `finder` parameter can be set to filter the keys stored in the store. Let defines one here for the example.

```dart
var keyA = await store.findKey(db,
  finder: Finder(
    filter: Filter.byKey("mykey")
  )
);
print("keyA: ${keyA}");
```

```console
keyA: mykey
```

A [`Finder()`](https://pub.dev/documentation/sembast/latest/sembast/Finder/Finder.html) object is used to filter the key/value from the store, a [`Filter()`](https://pub.dev/documentation/sembast/latest/sembast/Filter-class.html) object can then be instantiated to find the desired key or value; for example, to check if a `key` equals another key via the [`Filter.byKey()`](https://pub.dev/documentation/sembast/latest/sembast/Filter/Filter.byKey.html) constructor.

A more global method called [`find()`](https://pub.dev/documentation/sembast/latest/sembast/SembastStoreRefExtension/find.html) can also be used to find a key, a value or both, using the same interface.

The data stored can obviously be returned via the `get()` method.

```dart
var value1 = await store.record(1).get(db);
print("value1: ${value1}");
var value2 = await store.record('mykey').get(db);
print("value2: ${value2}");
```

```console
value1: 1234
value2: test
```

`sembast` can also react to changes on records when using the [`onSnapshot()`](https://pub.dev/documentation/sembast/latest/sembast/SembastQueryRefExtension/onSnapshot.html) method. It will return a [`Stream`](https://api.dart.dev/stable/3.12.2/dart-async/Stream-class.html) where one can [`listen`](https://api.dart.dev/stable/3.12.2/dart-async/Stream/listen.html) to the events. Based on the documentation, the [`dart:async`](https://api.dart.dev/dart-async/) module is needed to invoke the  [`unawaited()`](https://api.dart.dev/dart-async/unawaited.html) function to avoid memory leaks.

```dart
var subscription = store.record('mykey').onSnapshot(db).listen((snapshot) {
    print("listen snapshot: ${snapshot}");
    print("listen key: ${snapshot?.key}");
    print("listen value: ${snapshot?.value}");
  });
await store.record('mykey').put(db, 'update');
unawaited(subscription?.cancel());
```

```console
listen snapshot: Record(_main, mykey) test
listen key: mykey
listen value: test
listen snapshot: {key: mykey, value: update, revision: 3}
listen key: mykey
listen value: update
```

As you can see above, the key `mykey` has been updated, it is also possible to remove records using the [`delete()`](https://pub.dev/documentation/sembast/latest/sembast/SembastRecordRefExtension/delete.html) method.

```dart
var kdelete = await store.record('mykey').delete(db);
print("kdelete: ${kdelete}");
var f = await store.record('mykey').get(db);
print("f: ${f}");
```

```console
kdelete: mykey
f: null
```

`sembast` also supports transactions via the [`Database.transaction()`](https://pub.dev/documentation/sembast/latest/sembast/Database/transaction.html) method. A transaction reference to the database will be passed to an asynchronous lambda function, containing the list of actions to execute and alter the database accordingly.

```dart
await db.transaction((txn) async {
  await store.add(txn, 'transaction_data');
  await store.record('transaction').put(txn, "test");
});
var vtx1 = await store.record('transaction').get(db);
print("vtx1: ${vtx1}");
```

```console
vtx1: test
```

All data can be wiped-out when using `dropAll()` method.

```dart
await db.dropAll();
```

The full application source code looks like that:

```dart
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart' as sio;
import 'package:sembast/sembast_memory.dart' as smem;
import 'dart:async';

void main(List<String> arguments) async {
  Database db = await initDb();
  var store = StoreRef.main();

  var k = await store.add(db, "1234");
  print("k: ${k}");

  var k2 = await store.record("mykey").add(db, "test");
  print("k2: ${k2}");

  var keys = await store.findKeys(db);
  print("keys: ${keys}");

  var keyA = await store.findKey(db,
    finder: Finder(
      filter: Filter.byKey("mykey")
    )
  );
  print("keyA: ${keyA}");

  var value1 = await store.record(1).get(db);
  print("value1: ${value1}");

  var value2 = await store.record('mykey').get(db);
  print("value2: ${value2}");

  var subscription = store.record('mykey').onSnapshot(db).listen((snapshot) {
    print("listen snapshot: ${snapshot}");
    print("listen key: ${snapshot?.key}");
    print("listen value: ${snapshot?.value}");
  });
  await store.record('mykey').put(db, 'update');
  unawaited(subscription?.cancel());

  var kdelete = await store.record('mykey').delete(db);
  print("kdelete: ${kdelete}");
  var f = await store.record('mykey').get(db);
  print("f: ${f}");

  await db.transaction((txn) async {
    await store.add(txn, 'transaction_data');
    await store.record('transaction').put(txn, "test");
  });
  var vtx1 = await store.record('transaction').get(db);
  print("vtx1: ${vtx1}");

  await db.dropAll();

  var close = await db.close();
  print("close: ${close}");
}

Future<int> addUser(Database db, String name) async {
  var store = StoreRef<int, String>.main();
  int key = await store.add(db, name);
  return key;
}

Future<Database> initDb({dbPath = "./sample.db"}) async {
  String dbPath = './sample.db';
  DatabaseFactory dbFactory = sio.databaseFactoryIo;
  return await dbFactory.openDatabase(dbPath);
}

Future<Database> initMemDb({dbId = "main"}) async {
  DatabaseFactory dbFactory = smem.databaseFactoryMemory;
  return await dbFactory.openDatabase(dbId);
}
```

# Corrupted Database

JSON format is not really safe, no checksum by default, no real recovery procedure in case of corruption, and no way to know if the data received is the correct one. What could happen if the JSON objects stored in the database are corrupted? Let check that.

The first step is simple, how `sembast` will react when a database file is fully corrupted with random data. One can use `/dev/random` or [`openssl rand`](https://man.openbsd.org/openssl#rand) function.

```console
$ cat /dev/random | dd of=sample.db count=1 bs=8k
1+0 records in
1+0 records out
8192 bytes (8.2 kB, 8.0 KiB) copied, 0.00407324 s, 2.0 MB/s

$ file sample.db 
sample.db: data

$ dart run
Building package executable... 
Built sb:sb.
k: 1
k2: mykey
keys: [1, mykey]
keyA: mykey
value1: 1234
value2: test
listen snapshot: Record(_main, mykey) test
listen key: mykey
listen value: test
listen snapshot: {key: mykey, value: update, revision: 3}
listen key: mykey
listen value: update
kdelete: mykey
f: null
vtx1: test
close: null

$ hexdump -C sample.db  | head -n 10
00000000  9c 50 9e 52 be 47 ca 73  5c 5f 62 44 8a 6f ab a5  |.P.R.G.s\_bD.o..|
00000010  be 77 b8 f3 a0 2b 55 ed  2f 7e d9 36 0c 04 15 96  |.w...+U./~.6....|
00000020  f5 d0 42 0a c5 32 40 ef  5c 21 cb 96 26 1a a0 ee  |..B..2@.\!..&...|
00000030  c8 d8 66 1e 17 f5 00 3e  e7 ae fd 94 e6 94 c2 f7  |..f....>........|
00000040  fb 90 2f 20 cc 1e f7 92  e9 bf 6d 38 09 32 a3 00  |../ ......m8.2..|
00000050  06 c2 5d bb f1 15 30 40  bf 45 56 ae 00 01 3c 87  |..]...0@.EV...<.|
00000060  ba cb ff 40 19 e9 76 69  3a 0d 65 38 bb 67 f6 30  |...@..vi:.e8.g.0|
00000070  c0 6a 98 9a e1 46 43 9d  7b d7 6e 3c e9 8c 15 8d  |.j...FC.{.n<....|
00000080  00 d7 22 8c 87 ac ea 20  0b b9 8a c0 1b 24 83 98  |..".... .....$..|
00000090  1b 5b 99 80 ac 41 f9 82  97 09 7e fd e3 9b 0c 66  |.[...A....~....f|
``` 

Interesting. The first part of the file is still random, but the end is containing the database. After another run, the random data at the beginning of the file is removed. The application used is the one created in the previous section, nothing really complex.

With the current database saved, we can append some random data at the end of the file, just to have an idea of what will happen.

```console
$ cat /dev/random | dd count=1 bs=8k | tee -a sample.db > /dev/null
1+0 records in
1+0 records out
8192 bytes (8.2 kB, 8.0 KiB) copied, 0.0102849 s, 797 kB/s

$ dart run
Building package executable... 
Built sb:sb.
Unhandled exception:
FormatException: Unexpected character (at character 1)
&
^

#0      _ChunkedJsonParser.fail (dart:convert-patch/convert_patch.dart:1467:5)
#1      _ChunkedJsonParser.parseNumber (dart:convert-patch/convert_patch.dart:1333:9)
#2      _ChunkedJsonParser.parse (dart:convert-patch/convert_patch.dart:935:22)
#3      _parseJson (dart:convert-patch/convert_patch.dart:35:10)
#4      JsonDecoder.convert (dart:convert/json.dart:640:36)
#5      JsonCodec.decode (dart:convert/json.dart:219:41)
#6      SembastDatabase._fsFullMetaAndImport (package:sembast/src/database_impl.dart:861:23)
<asynchronous suspension>
#7      SembastDatabase.open.<anonymous closure>.import (package:sembast/src/database_impl.dart:1101:28)
<asynchronous suspension>
#8      SembastDatabase.open.<anonymous closure> (package:sembast/src/database_impl.dart:1115:15)
<asynchronous suspension>
#9      BasicLock.synchronized (package:synchronized/src/basic_lock.dart:38:16)
<asynchronous suspension>
#10     SembastDatabase.open (package:sembast/src/database_impl.dart:971:5)
<asynchronous suspension>
#11     DatabaseOpenHelper.openDatabase.<anonymous closure> (package:sembast/src/database_open_helper.dart:63:7)
<asynchronous suspension>
#12     BasicLock.synchronized (package:synchronized/src/basic_lock.dart:38:16)
<asynchronous suspension>
#13     SembastDatabaseFactoryMixin.openDatabaseWithOptions (package:sembast/src/database_factory_mixin.dart:55:12)
<asynchronous suspension>
#14     initDb (file:///home/user/tmp/dart/sb/bin/sb.dart:67:10)
<asynchronous suspension>
#15     main (file:///home/user/tmp/dart/sb/bin/sb.dart:7:17)
<asynchronous suspension>
```

Dart JSON parser can't parse the database anymore. Can we recover it? In this case, yes, because all the random data can be found at the end of the file, the JSON format can still be delimited. Unfortunately, what could happen if only a subset of the JSON object is modified? I think you already have the answer. The format used by `sembast` does not support data integrity, the metadata stored on the first line of the database does not contain for example a checksum. Every JSON objects stored are stored as it, without checksum as well.

# Export/Import Database

`sembast` can import or export database with the help of `import_export.dart` module. For example, this can be used to import a database from the filesystem into memory. This feature can also be seen from the test suite in [`test/sembast_import_export_io_test.dart`](https://github.com/tekartik/sembast.dart/blob/master/sembast/test/sembast_import_export_io_test.dart). Let start this section by adding the [`sembast_import_export`](https://pub.dev/documentation/sembast/latest/utils_sembast_import_export/) module. The database file is the one generated from the first part of this article.

```dart
import 'package:sembast/utils/sembast_import_export.dart';
```

All the next snippets can be added in a custom `main()` function, just for doing some test. The first part of procedure to import/export a database is similar to our previous examples.

```dart
String dbPath = './sample.db';
DatabaseFactory dbFactory = sio.databaseFactoryIo;
var store = StoreRef.main();
```

The local database is opened with the [`openDatabase()`](https://pub.dev/documentation/sembast/latest/sembast/DatabaseFactory/openDatabase.html) method from a `DatabaseFactory` instance.

```dart
var db = await dbFactory.openDatabase(dbPath);
print(db);
```

Then we call the [`exportDatabase()`](https://pub.dev/documentation/sembast/latest/utils_sembast_import_export/exportDatabase.html) function. It will return the data in a specific format, ready to be imported somewhere else. To be sure the feature is working, we can `close()` the database.

```dart
var exp = await exportDatabase(db);
print(exp);
await db.close();
```

In this example, the exported database is imported in an in-memory store via the `importDatabase()` function. The first argument is the exported database object, the second is the kind of database we want (e.g. `databaseFactoryMemory`) and finally, we can give a `path`, but I think this is not mandatory for this factory.

```dart
db = await importDatabase(
  exp,
  smem.databaseFactoryMemory,
  dbPath
);  
print(db);
```

The previously added data - here with the `transaction` key - can be retrieved directly from the memory.

```dart
print(await store.record("transaction").get(db));
```

This feature is great if one wants to import/export database from one factory to another. It can also be used to dump in-memory database (e.g. cache) locally for a fast-boot after an application shutdown.

# Encryption and Integrity

> War is 90% information.
> -- Napoleon Bonaparte 

We have seen in the corrupted database section `sembast` does not support data integrity. In case of corrupted data, nothing can be done to find what happened, then, we can't really trusted the content of the database. So, yes, transaction is supported, but we trust blindly the data saved on the HDD or in memory. Is it possible to fix that partially by creating our own codec, it can include a checksum and encrypt the data as well.

The document mention this feature, but forgot to give us something working. In fact, the implementation example can be found in the test suite, in [`sembast_test/lib/encrypt_codec.dart`](https://github.com/tekartik/sembast.dart/blob/216e7326f5f4b447404251012746e4aef47f19fb/sembast_test/lib/encrypt_codec.dart) and in [`sembast_test/test/database_encrypt_codec_io_test.dart`](https://github.com/tekartik/sembast.dart/blob/216e7326f5f4b447404251012746e4aef47f19fb/sembast_test/test/database_encrypt_codec_io_test.dart). If you want to use it, you should be aware the code there is not production-ready:

> ```dart
> /// FOR DEMONSTRATION PURPOSES ONLY -- do not use in production as-is!
> ```

Anyway, it gives us a good idea of how things are working. Before encrypting data, validating it could be way better. It will also the first time I will create a [Codec](https://api.dart.dev/stable/3.12.2/dart-convert/Codec-class.html) from scratch. To do  that, `dart:convert` and `dart:typed_data` modules will be required.

```dart
import 'dart:convert';
import 'dart:typed_data';
```

We also need a way to create a checksum, for this test, I think using SHA256 from the `crypto` module will be enough.

```dart
import 'package:crypto/crypto.dart';
```

This is an external module, `dart pub add` is then required.

```console
$ dart pub add crypto
...
```

Now we have our checksum function, we can create an interface to use it. The code above will take any kind of data as `String` and will return the checksum as hexadecimal `String`.

```dart
String _checksum(String s) {
  final json_encoded = json.encode(s);
  final utf8_encoded = utf8.encode(json_encoded);
  return sha256.convert(utf8_encoded).toString();
}
```

A [`Codec`](https://api.dart.dev/stable/3.12.2/dart-convert/Codec-class.html) requires a [`decoder`](https://api.dart.dev/stable/3.12.2/dart-convert/Codec/decoder.html) and a [`encoder`](https://api.dart.dev/stable/3.12.2/dart-convert/Codec/encoder.html) attributes. Those attributes are created when the object is instantiated via the `_IntegrityCoded()` constructor. As you can see, two custom objects called `_IntegrityEncoder()` and `_IntegrityDecoder()` as then set to the corresponding attributes.

```dart
class _IntegrityCodec extends Codec<Object?, String> {
  late _IntegrityEncoder _encoder;
  late _IntegrityDecoder _decoder;

  _IntegrityCodec() {
    _encoder = _IntegrityEncoder();
    _decoder = _IntegrityDecoder();
  }

  @override
  Converter<String, Object?> get decoder => _decoder;

  @override
  Converter<Object?, String> get encoder => _encoder;
}
```

The `_IntegrityEncoder` class extends the [`Converter`](https://api.dart.dev/stable/3.12.2/dart-convert/Converter-class.html) class. This class is used to return another representation of some kind of data. The only method to recreate is the [`convert()`](https://api.dart.dev/stable/3.12.2/dart-convert/Converter/convert.html) one.  Below the raw working code snippet created to deal with the encoding part. When `sembast` is opening the database, it will pass the `signature` key in the encoder, then, the same signature must be returned by the coded. Then, if some keys/values are being added into the database, the key/value is passed to the encoder. The final returned value will be the line stored into the database. It seems a `try`/`catch` is present somewhere in `sembast`, hiding the errors and the exceptions if something bad is happening in the encoder, so, if you are creating your own encoder, one should be careful with that.

```dart
class _IntegrityEncoder extends Converter<Object?, String> {
  @override
  String convert(dynamic input) {
    print("encoder: $input");
    try {
      switch (input) {
        case {"signature": String signature}: return signature;
        case {"key": dynamic key, "value": dynamic value}:
          return json.encode({
            "key": key,
            "value": value,
            "checksum": _checksum(value)
          });
        default:
          return "error";
      }
    }
    catch (e,s) {
      print("$e, $s");
      throw(e);
    }
  }
}
```

A decoder is now required, let create the `_IntegrityDecoder` class. Like the previous one, it extends the [`Converter`](https://api.dart.dev/stable/3.12.2/dart-convert/Converter-class.html) class and override the [`convert()`](https://api.dart.dev/stable/3.12.2/dart-convert/Converter/convert.html) method. The data to decode will be JSON strings, except for the signature. My code is a bit dirty, but I'm trying to be explicit. When a `String` is given, then it is decoded, the `value` and `checksum` values are extracted. A new checksum is generated to check if the `value` is correct, if it's the case, then the line is returned, else, an error is thrown.

```dart
class _IntegrityDecoder extends Converter<String, Object?> {
  @override
  dynamic convert(String input) {
    print("decoder: $input");
    try {
      switch (input) {
        case "integrity": return {"signature": "integrity"};
        case String s:
          final j = json.decode(s);
          final checksum = j["checksum"];
          final value = j["value"];
          final checksum_value = _checksum(value);
          if (checksum == checksum_value) return j;
          else throw("checksum error");
        default: return input;
      }
    }
    catch (e,s) {
      print("$e, $s");
      throw(e);
    }
  }
}
```

The codec is ready, but a [`SembastCodec`](https://pub.dev/documentation/sembast/latest/sembast/SembastCodec-class.html) object is required by `sembast`. The code present in the test suite creates a function to instantiate this kind of object, and I will follow this path. [`SembastCodec`](https://pub.dev/documentation/sembast/latest/sembast/SembastCodec-class.html) needs at least two parameters, [`signature`](https://pub.dev/documentation/sembast/latest/sembast/SembastCodec/signature.html) representing the name of the codec is used, and [`codec`](https://pub.dev/documentation/sembast/latest/sembast/SembastCodec/codec.html) where the custom `Codec` will be stored.

```dart
SembastCodec getIntegritySembastCodec() {
  return SembastCodec(
    signature: 'integrity',
    codec: _IntegrityCodec()
  );
}
```

A quick modification to the `initDb()` function is also required. The [custom codec](https://pub.dev/documentation/sembast/latest/sembast/DatabaseFactory/openDatabase.html) is also required when we are opening a database.

```dart
Future<Database> initDb({dbPath = "./sample.db", SembastCodec? codec}) async {
  String dbPath = './sample.db';
  DatabaseFactory dbFactory = sio.databaseFactoryIo;
  return await dbFactory.openDatabase(
    dbPath,
    codec: codec
  );
}
```

Finally, let modify the `main()` entry-point. Nothing fancy there, few data are inserted and then retrieved.

```dart
void main(List<String> arguments) async {
  Database db = await initDb(codec: getIntegritySembastCodec());
  var store = StoreRef.main();

  await store.record("test").put(db, "test");
  await store.record("test1").put(db, "test");
  await store.record("test2").put(db, "test");
  await store.record("test3").put(db, "test");

  print(await store.record("test").get(db));
  print(await store.record("test1").get(db));
  print(await store.record("test2").get(db));
  print(await store.record("test3").get(db));

  await db.close();
}
```

Okay, it looks good. What will happen when this application is executed?

```console
$ > sample.db

$ dart run
Building package executable... 
Built sb:sb.
encoder: {signature: integrity}
encoder: {signature: integrity}
encoder: {signature: integrity}
encoder: {key: test, value: test}
encoder: {key: test1, value: test}
encoder: {key: test2, value: test}
encoder: {key: test3, value: test}
test
test
test
test

$ cat sample.db
{"version":1,"sembast":1,"codec":"integrity"}
{"key":"test","value":"test","checksum":"4d967a30111bf29f0eba01c448b375c1629b2fed01cdfcc3aed91f1b57d5dd5e"}
{"key":"test1","value":"test","checksum":"4d967a30111bf29f0eba01c448b375c1629b2fed01cdfcc3aed91f1b57d5dd5e"}
{"key":"test2","value":"test","checksum":"4d967a30111bf29f0eba01c448b375c1629b2fed01cdfcc3aed91f1b57d5dd5e"}
{"key":"test3","value":"test","checksum":"4d967a30111bf29f0eba01c448b375c1629b2fed01cdfcc3aed91f1b57d5dd5e"}
```

It works! If we modify a checksum or a value, the program should then crash. Let check that, I will modify the value stored with the key `test3`, and comment the insertion from the `main()` function.

```console
$ sed -iE '/test3/s/"value":"test"/"value":"corrupted"/' sample.db 

$ cat sample.db
{"version":1,"sembast":1,"codec":"integrity"}
{"key":"test","value":"test","checksum":"4d967a30111bf29f0eba01c448b375c1629b2fed01cdfcc3aed91f1b57d5dd5e"}
{"key":"test1","value":"test","checksum":"4d967a30111bf29f0eba01c448b375c1629b2fed01cdfcc3aed91f1b57d5dd5e"}
{"key":"test2","value":"test","checksum":"4d967a30111bf29f0eba01c448b375c1629b2fed01cdfcc3aed91f1b57d5dd5e"}
{"key":"test3","value":"corrupted","checksum":"4d967a30111bf29f0eba01c448b375c1629b2fed01cdfcc3aed91f1b57d5dd5e"}
```

Let rerun the application with this modification.

```console
$ dart run
...
decoder: {"key":"test3","value":"corrupted","checksum":"4d967a30111bf29f0eba01c448b375c1629b2fed01cdfcc3aed91f1b57d5dd5e"}
checksum error, #0      _IntegrityDecoder.convert (file:///home/user/tmp/dart/sb/bin/sb.dart:93:16)
#1      Codec.decode (dart:convert/codec.dart:30:34)
#2      SembastContentCodecAsyncSupport.decodeContentSync (package:sembast/src/async_content_codec.dart:128:30)
#3      SembastDatabase.decodeRecordLineStringSync (package:sembast/src/database_impl.dart:262:50)
#4      SembastDatabase._fsFullMetaAndImport (package:sembast/src/database_impl.dart:856:17)
<asynchronous suspension>
#5      SembastDatabase.open.<anonymous closure>.import (package:sembast/src/database_impl.dart:1101:28)
<asynchronous suspension>
#6      SembastDatabase.open.<anonymous closure> (package:sembast/src/database_impl.dart:1115:15)
<asynchronous suspension>
#7      BasicLock.synchronized (package:synchronized/src/basic_lock.dart:38:16)
<asynchronous suspension>
#8      SembastDatabase.open (package:sembast/src/database_impl.dart:971:5)
<asynchronous suspension>
#9      DatabaseOpenHelper.openDatabase.<anonymous closure> (package:sembast/src/database_open_helper.dart:63:7)
<asynchronous suspension>
#10     BasicLock.synchronized (package:synchronized/src/basic_lock.dart:38:16)
<asynchronous suspension>
#11     SembastDatabaseFactoryMixin.openDatabaseWithOptions (package:sembast/src/database_factory_mixin.dart:55:12)
<asynchronous suspension>
#12     initDb (file:///home/user/tmp/dart/sb/bin/sb.dart:166:10)
<asynchronous suspension>
#13     main (file:///home/user/tmp/dart/sb/bin/sb.dart:11:17)
<asynchronous suspension>
```

It crashed because the checksums are not the same. This code is just a draft, a recovery method should probably be used, a faster checksum like `blake2` or `blake3` would be better for this task. Anyway, the codec to encrypt can be seen in the test suite, it can be improved, but now, you have an idea of the flow to reproduce this feature.

# Database Migration

> In the 21st century, the database is the marketplace.
> -- Stan Rapp 

`sembast` supports versioned store, the first line of the file containing the data contains a `version` field. When opening a database, `sembast` expects to find a specific `version` number, if it's not the case, a migration procedure can be applied. No headers are required there, only the `sembast.dart` one. Let re-open again our `sample.db` database.

```dart
String dbPath = './sample.db';
DatabaseFactory dbFactory = sio.databaseFactoryIo;
```

A [`VersionChange()`](https://pub.dev/documentation/sembast/latest/sembast/OnVersionChangedFunction.html) function will be required, here I will create a lambda function stored in a variable, but this function can be named somewhere else. The idea is too dynamically change/update the data from the database based on a version number. If you already did some SQL migration in the past, this is mostly the same thing, every time a new version of the schema is found, changes are applied.

```dart
final versionChange = (Database db, int oldVersion, int newVersion) {
  print("db: $db");
  print("oldVersion: $oldVersion");
  print("newVersion: $newVersion");
  print("--");
  while (oldVersion <= newVersion) {
    switch (oldVersion) {
      case 1:
        print("version 1 update");
        // do some check here
      case 2:  
        print("version 2 update");
        // do some update here
      case 3:
        print("version 3 update");
        // do some update here
      case 4:
        print("version 4 update");
        // do some update here
      case 5:  
        print("version 5 update");
        // do some update here
      case 6:  
        print("version 6 update");
        // do some update here
      default:
        throw("unsupported version $oldVersion");
    }   
    oldVersion += 1;
  }   
};
``` 

Finally, we can open the database and defines the version we are expecting from it (version `6`). The versionChange() function is passed to the `onVersionChanged` parameter.

```dart
var db = await dbFactory.openDatabase(
  dbPath,
  version: 6,
  onVersionChanged: versionChange
);  

await db.close();
```

Now, we can execute the application, and you will see the different update procedure being executed.

```console
$ dart run
Building package executable... 
Built sb:sb.
db: {path: /home/user/tmp/dart/sb/sample.db, version: 1, stores: [{name: _main, count: 5}], exportStat: {lineCount: 12, obsoleteLineCount: 4, compactCount: 0}}
oldVersion: 1
newVersion: 6
--
version 1 update
version 2 update
version 3 update
version 4 update
version 5 update
version 6 update
```

A migration procedure is always a nice feature, especially when it comes to databases. Indeed, in a world where applications are changing fast, a model should follow these changes without breaking. Adding an explicit format and a version to a database can help to do smooth upgrade without losing data (or service). More examples are available from the [examples](https://github.com/tekartik/sembast.dart/blob/master/sembast/doc/migration_example.md)

# Conclusion

> life is short and information endless: nobody has time for everything
> -- Aldous Huxley

`sembast` is a complete NoSQL database store, offering a wide range of features. It is easy to use, it supports transactions, multi-format and can be used with reactive programming pattern. Many different backend exists, allowing a developer to store data locally, in-memory or above more stable platform like sqlite.

Nothing is perfect though, and one should probably avoid using it if some custom specific formats are being used by its application. Using the filesystem as data-store can also have its own limitations (e.g. race condition, size limit...) and should be avoid when working with important volume of data. In fact, `sembast` should not be used for that, and one should expect good performance if the store is limited for a small amount of inserts.

One thing I fear the most with database is data-corruption, and `sembast` does not seem to support a way to recover data in case corrupted data. It's not really surprise, the database has been created using JSON, where each objects are stored line by line. `sembast` user must keep that in mind, and should probably use `sembast_sqflite` to avoid eventual corrupted data.

Anyway, to be honest, the `sembast` experience was great, and looks to be a good choice for cache management or for non-critical data. The effort to improve this library for other needs is perhaps to important though, and another choice - like SQLite - could be better. As usual, more resources can be found here:

- [Official `sembast` API documentation](https://pub.dev/documentation/sembast/latest/);

- [`sembast` source code](https://github.com/tekartik/sembast.dart/tree/master/sembast) at Github;

- [`sembast_sqflite`](https://pub.dev/packages/sembast_sqflite) package from pub.dev;

- [`sembast_web`](https://pub.dev/packages/sembast_web) package from pub.dev;

- [`stash_sembast`](https://pub.dev/packages/stash_sembast) from pub.dev;

- [Flutter/Dart ORM Benchmarking: Drift vs Floor vs Isar vs SQLite3](https://medium.com/@sidharthmudgil/flutter-dart-orm-benchmarking-drift-vs-floor-vs-isar-vs-sqlite3-d096465d87e1) by [Sidharth Mudgil](https://medium.com/@sidharthmudgil) on Medium;

- [Comparing Hive to other Flutter app database options](https://blog.logrocket.com/comparing-hive-other-flutter-app-database-options) by [Onuoha Ifeanyi ](https://blog.logrocket.com/author/onuohaifeanyi/) at LogRocker;

- [DB Benchmarks](https://github.com/o-ifeanyi/db_benchmarks) at Github;

- [Flutter — Persisting data locally using sembast](https://shivmaurya.medium.com/flutter-persisting-data-locally-using-sembast-2511d567df2 ) by [Shivmaurya](https://shivmaurya.medium.com/) on Medium.

Have fun and Happy Hack!

PS: it was a really huge article and it took me a lot of time to write it. I was expecting to find more documentation or examples on this module... But it was not the case. I started to read the source code and the test to understand more how `sembast` was working. Furthermore, writing articles during summer in France is kinda hard. ;)

----

Cover Image by <a href="https://unsplash.com/@qwitka?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Maksym Kaharlytskyi</a> on <a href="https://unsplash.com/photos/file-cabinet-Q9y3LRuuxmg?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
      

