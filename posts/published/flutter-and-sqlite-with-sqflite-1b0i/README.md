---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/flutter-and-sqlite-with-sqflite-1b0i"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2F4ncf68at6gwtcusgznrh.jpg"
created_at: "None"
crossposted_at: "None"
description: "SQLite is an incredible embedded database. Anyone is using it, when you are browsing internet with..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/flutter-and-sqlite-with-sqflite-1b0i"
public_reactions_count: "1"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "flutter-and-sqlite-with-sqflite-1b0i"
social_image: "None"
title: "Flutter and SQLite with sqflite"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Flutter and SQLite with sqflite

SQLite is an incredible embedded database. Anyone is using it, when you are browsing internet with your browser, or when you are using your smartphone. A library for Flutter called [`sqflite`](https://pub.dev/packages/sqflite) offers an interface to manage SQLite database on all supported platform.

# Bootstrapping

As usual, let create a new project from scratch to test this package.

```console
$ flutter create mydb
Creating project mydb...
Resolving dependencies in `mydb`... 
Downloading packages... 
Got dependencies in `mydb`.
Wrote 131 files.

All done!
You can find general documentation for Flutter at: https://docs.flutter.dev/
Detailed API documentation is available at: https://api.flutter.dev/
If you prefer video documentation, consider: https://www.youtube.com/c/flutterdev

In order to run your application, type:

  $ cd mydb
  $ flutter run

Your application code is in mydb/lib/main.dart.

$ cd mydb
```

`sqflite` can be installed with `flutter pub add` command. The amount of dependencies is correct.

```console
$ flutter pub add sqflite
Resolving dependencies... 
Downloading packages... 
  matcher 0.12.19 (0.12.20 available)
  meta 1.18.0 (1.19.0 available)
+ platform 3.1.6
+ plugin_platform_interface 2.1.8
+ sqflite 2.4.3
+ sqflite_android 2.4.3
+ sqflite_common 2.5.11
+ sqflite_darwin 2.4.3+1
+ sqflite_platform_interface 2.4.1
+ synchronized 3.4.1
  test_api 0.7.11 (0.7.13 available)
  vector_math 2.2.0 (2.4.0 available)
Changed 8 dependencies!
4 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
```

If you are working on Linux, MacOS or Windows, you will need [`sqlite_ffi`](https://pub.dev/documentation/sqflite_common_ffi/latest/sqflite_ffi/) package. It will be especially helpful for the testing part.

```console
$ flutter pub add sqflite_ffi
Resolving dependencies... 
Downloading packages... 
+ code_assets 1.2.1
+ crypto 3.0.7
+ ffi 2.2.0
+ file 7.0.1
+ glob 2.1.3
+ hooks 2.0.2
+ logging 1.3.0
  matcher 0.12.19 (0.12.20 available)
  meta 1.18.0 (1.19.0 available)
+ native_toolchain_c 0.19.2
+ pub_semver 2.2.0
+ record_use 0.6.0
+ sqflite_common_ffi 2.4.2
+ sqflite_ffi 0.1.0
+ sqlite3 3.4.0
  test_api 0.7.11 (0.7.13 available)
+ typed_data 1.4.0
  vector_math 2.2.0 (2.4.0 available)
+ web 1.1.1
+ yaml 3.1.3
Changed 16 dependencies!
4 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
```

It seems we are ready to code. Before starting, ensure you have the `sqlite3` installed locally, it can be helpful for designing or even debugging SQLite database.

```console
$ sudo apt-get install sqlite3
```

# Simple Cache Schema

Before doing anything with SQLite, a schema will be required. Indeed, SQLite is like any other SQL database, and data must be structured before being stored. For a first test, creating a kind of cache system with SQLite could be interesting. The following schema will be stored in a file called `cache.sql`.

```sql
CREATE TABLE cache (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  key BLOB UNIQUE NOT NULL,
  value BLOB NOT NULL,
  created_at INTEGER NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at INTEGER
);
```

Few notes regarding this table, `BLOB` type is being used for the `key` and the `value` column because they will receive raw data from Flutter. I would like to see how SQLite will manage them. The `created_at` and `updated_at` should use `TIMESTAMP`, but while reading `sqflite` documentation, this type was not implemented. The documentation also advise the developer to use `INTEGER` instead. Why not. `BOOL` is not supported as well and `INTEGER` must be used instead. On this last type, [SQLite `BOOL` type](https://sqlite.org/datatype3.html#boolean_datatype) is already represented by an `INTEGER`.

Before integrating this schema with Flutter, let have some fun with an in-memory SQLite database.

```console
$ sqlite3
SQLite version 3.46.1 2024-08-13 09:16:08
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
```

The [`.read` command](https://sqlite.org/cli.html#reading_sql_from_a_file) can be used to import a schema, if you are lazy, you can also just do a copy/paste of the previous schema, it's still okay for small schemas.

```console
sqlite> .help read
.read FILE               Read input from FILE or command output
    If FILE begins with "|", it is a command that generates the input.

sqlite> .read cache.sql
```

To check if the schema was correctly created, the [`.schema`](https://sqlite.org/cli.html#querying_the_database_schema) command can be used as well. It will return the current schema of the database.

```console
sqlite> .help schema
.schema ?PATTERN?        Show the CREATE statements matching PATTERN
   Options:
      --indent             Try to pretty-print the schema
      --nosys              Omit objects whose names start with "sqlite_"

sqlite> .schema
CREATE TABLE cache (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  key BLOB UNIQUE NOT NULL,
  value BLOB NOT NULL,
  created_at INTEGER NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at INTEGER
);
CREATE TABLE sqlite_sequence(name,seq);
```

When dealing with complex schema, it can be helpful to have headers displayed when checking the content of a table. For doing that, one can use the `.headers` command.

```console
sqlite> .help headers
.headers on|off          Turn display of headers on or off

sqlite> .headers on
```

The environment is now ready. Let insert some values in the `cache` table.

```console
sqlite> INSERT INTO cache (key, value) VALUES ('key', 'value');
```

It looks good, let check if the data has been correctly inserted.

```console
sqlite> SELECT * from cache;
id|key|value|created_at|updated_at
1|key|value|2026-07-13 12:31:41|
```

# Integration

The schema is ready, but it needs to be integrated in the Flutter application previously created. Let start with the headers, the device target will be a desktop Linux application, and `sqflite_ffi` will be required.

```dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_ffi/sqflite_ffi.dart';
```

## Entry-Point

When the application is starting, the `main()` entry-point is called. If something goes wrong during this part of the code, the application must crash quick. The SQLite database is opened with the help of the [`sqflite.openDatabase()`](https://pub.dev/documentation/sqflite/latest/sqflite/openDatabase.html) function and will be stored in memory by setting the path to the [`inMemoryDatabasePath`](https://pub.dev/documentation/sqflite/latest/sqflite/inMemoryDatabasePath-constant.html) constant (in fact, this is a `String` containing the value [`:memory`](https://sqlite.org/inmemorydb.html)).

The database is then passed to the `CacheInterface.init()` method. The `CacheInterface` class will be described later, but in short, it contains the attributes, parameters and methods to deal with the `cache` table present in the database.

The last step here is to start the application by calling the [`runApp()`](https://api.flutter.dev/flutter/widgets/runApp.html) Flutter function with our `Application()` object instantiated with the cache object previously created.

```dart
void main() async {
  final db = await sqflite.openDatabase(inMemoryDatabasePath);
  final CacheInterface cache = CacheInterface.init(db: db);
  runApp(Application(cache: cache));
}
```

The database can be opened with custom options via the [`OpenDatabaseOptions`](https://pub.dev/documentation/sqflite/latest/sqflite/OpenDatabaseOptions-class.html). A quick note regarding this part, if the database is coming from the filesystem, its presence should be checked first.

## Material Application

The `Application` class is extending a [`StatefulWidget`](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html). Why? Because it was choice I did in the first version of the tests, but a [`StatelessWidget`](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html) would have done the job perfectly.

```dart
class Application extends StatefulWidget {
  final CacheInterface cache;

  const Application({
    super.key,
    required CacheInterface this.cache,
  });

  static ApplicationState? of(BuildContext context) {
    return context.findAncestorStateOfType<ApplicationState>();
  }

  @override
  State<Application> createState() => ApplicationState(cache: cache);
}
```

One interesting function is the [`of()`](https://api.flutter.dev/flutter/material/Scaffold/of.html) one. Indeed, this is a static function used to wrap the [`findAncestorStateOfType()`](https://api.flutter.dev/flutter/widgets/BuildContext/findAncestorStateOfType.html) method and then help to find the `ApplicationState` across the whole application tree. It was mostly a test to see how this function was implemented and how it was working. If someone wants to share a state across the application, it would be easier to use an [`InheritedWidget`](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html).

The second part of this code is the state definition. In our case, it will store the reference of the `CacheInterface()` as well. The [`build()`](https://api.flutter.dev/flutter/widgets/State/build.html) function is returning a [`MaterialApp()`](https://api.flutter.dev/flutter/material/MaterialApp-class.html) object, where the home page is created using the `Home` class.

```dart
class ApplicationState extends State<Application> {
  final CacheInterface cache;

  ApplicationState({ required CacheInterface this.cache });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyDB',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Home()
    );
  }
}
```

A quick note on this part, the state is created there because it's one of the first widget created on the tree. This means the state can easily be shared across the rest of the application.

## Home Screen

The Home screen will also be a StatefulWidget (why? because I need to have the habit to create them, and that's a good exercise). So, the `Home` class is not really complex and does not contain any specific methods or attributes.

```dart
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}
```

The `_HomeState` class is a bit more complex though. The attributes `length` and `items` will respectively store the length of the items from the database and the items themselves. In fact the `length` can simply be a getter like `int get length => items.length;` or something similar.

```dart
class _HomeState extends State<Home> {
  int length = 0;
  List<Map<String, Object?>> items = [];
```

The `build` method will be split in small part, because lot needs to be say there.

```dart
  @override
  Widget build(BuildContext context) {
```

Firstly, let's talk a bit of the `cache` variable, this one is created by finding the `CacheInterface` state using the `Application.of()` method defined in the `Application` class. It will then return the `cache` object containing the database. A `Scaffold` object is returned. The `appBar` parameter is set with a title, and that's all.

```dart
    CacheInterface? cache = Application.of(context)?.cache;
    return Scaffold(
      appBar: AppBar(
        title: Text("MyDB"),
        actions: []
      ),
```

`Scaffold`'s body is a bit more complex though. The first object created there is a [`NotificationListener()`](https://api.flutter.dev/flutter/widgets/NotificationListener-class.html), this element is new on my side. The idea is to listen for [`Notification`](https://api.flutter.dev/flutter/widgets/Notification-class.html) sent by Widgets below in the tree. Those [`Notification`](https://api.flutter.dev/flutter/widgets/Notification-class.html)s are generated by the `Notification().dispatch()` method and will bubble to the root of the tree. The [`NotificationListener()`](https://api.flutter.dev/flutter/widgets/NotificationListener-class.html) Widget can stop this bubbling by returning `true` when the [`onNotification`](https://api.flutter.dev/flutter/widgets/NotificationListener/onNotification.html) callback function is called.

Regarding the callback, it will only set the `length` and the `items` attributes when the `DatabaseInputNotification` notification is received. `cache.getLength()` and `cache.list()` methods are defined later in the code, but they are both asynchronous function, they are then both returning a [`Future`](https://api.flutter.dev/flutter/dart-async/Future-class.html) object. To deal with that, I'm using [`Future.then()`](https://api.flutter.dev/flutter/dart-async/Future/then.html) method and then call the [`setState()`](https://api.flutter.dev/flutter/widgets/State/setState.html). This is probably not the best method, using a [`StreamBuilder`](https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html) object would be maybe a bit better, but I discovered it only recently.

```dart
      body: NotificationListener(
        onNotification: (DatabaseInputNotification din) {
          cache!.getLength()
            .then((x) {
              setState(() {
                this.length = x;
              });
            });
          cache!.list()
            .then((items) {
              setState(() {
                this.items = items!;
              });
            });
          return true;
        },
```

The direct child of the [`NotificationListener`](https://api.flutter.dev/flutter/widgets/NotificationListener-class.html) Widget is a `Container`, the most interesting part of this code is the [`ListView.builder()`](https://api.flutter.dev/flutter/widgets/ListView/ListView.builder.html) part, where the `itemCount` parameter as `int` is using the `length` attribute and the [`itemBuilder`](https://api.flutter.dev/flutter/rendering/ItemExtentBuilder.html) parameter using the `items` attribute from the state.

The `ListView` Widget can then dynamically build its list using the data from `items`. This is not an efficient method though, because every time a new item is created or deleted, the full content of the database is stored in the `items` attributes. It does the work though, many works around can be created there, for example, by storing only the `id` of the item in the `items` attribute for example, or, even better, create a fully interface to the database able to return both the length but also an item based on an index.

```dart
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            spacing: 10,
            children: [
              Flexible(
                child: DatabaseInput()
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: this.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Item(item: items[index]);
                  },
                )
              )
            ]
          )
        )
      )
    );
  }
}
```

## Inputs

Adding data into the database requires some kind of inputs. Those data can be added from a remote server, but in our case, they will be added by the user directly. A `StatefulWidget` will be used again.

```dart
class DatabaseInput extends StatefulWidget {
  DatabaseInput({super.key});

  @override
  State<DatabaseInput> createState() => _DatabaseInputState();
}
```

The state of the object will encapsulate `key` and `value` as `String`. Those will be contain user's data.

```dart
class _DatabaseInputState extends State<DatabaseInput> {
  String key = "";
  String value = "";
```

To make things "easier", the `TextField`s widget have their own methods. The `_buildKey()` method will create a `TextField` dedicated for the `key`. As you can see, the `onChanged()` anonymous function is able to configure the key, in short, when an user is updating the content of the `TextField` (by adding/removing some letters) the `key` attribute will reflect it.

```dart
  Widget _buildKey(context) {
    final onChanged = (String key) {
      setState(() {
        this.key = key;
      });
    };
    return Row(
      spacing: 10,
      children: [
        Text('key:'),
        Expanded(
          child: TextField(onChanged: onChanged)
        )
      ]
    );
  }
```

The same is done for the `value`, by using a method called `_buildValue()`.

```dart
  Widget _buildValue(BuildContext context) {
    final onChanged = (String key) {
      setState(() {
        this.value = value;
      });
    };
    return Row(
      spacing: 10,
      children: [
        Text('value:'),
        Expanded(
          child: TextField(onChanged: onChanged)
        )
      ]
    );
  }
```

When the user has done with the key/value, the data can be sent to the database when pressing a `TextButton`. It will add these two elements with the help of the `cache.add()` method, and then, will send a `Notification` via `DatabaseInputNotification().dispatch()` to notify other Widget to rebuild their screen if needed.

```dart
  Widget _buildButton(BuildContext context) {
    final CacheInterface? cache = Application.of(context)?.cache;
    return TextButton(
      onPressed: () {
        setState(() {
          cache!.add(this.key, this.value);
          DatabaseInputNotification().dispatch(context);
        });
      },
      child: Text('add')
    );
  }
```

Finally, the `build()` method is defined.

```dart
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        spacing: 10,
        children: [
          Expanded(child: _buildKey(context)),
          Expanded(child: _buildValue(context)),
          _buildButton(context),
        ]
      )
    );
  }
}
```

## Notifications

Remember the [`NotificationListener`](https://api.flutter.dev/flutter/widgets/NotificationListener-class.html) widget from the Home class? Well, a `Notification` object is required to notify it, but the [`Notification`](https://api.flutter.dev/flutter/widgets/Notification-class.html) class is abstract. A new class extending it is then needed. In our case, it is called `DatabaseInputNotification`. When I created it, I was thinking if it's a good practice to add some methods in it to directly embed the actions to do when some updates are made.

```dart
class DatabaseInputNotification extends Notification {}
```

## Items

Every items retrieved from the SQLite database are typed as `Map<String,Objects?>` and usuallyed returned as `List`. The SQL request used here is returning all the content of the objects without any kind of filtering. So, an item can be represented by the `Item` class extending a `StatelessWidget`.

This is a very poor design, the `Item` class should have all attribute defined inside the class itself, and should not use a `dynamic Item`. The constructor should then be used to initialize all required fields. When the `build()` method is called, those attributes can then be used safely.

```dart
class Item extends StatelessWidget {
  final dynamic item;
  Item({
    super.key,
    required dynamic this.item
  });
```

An instantiated item object embed all required informatio, but if an efficient implementation was required, only the `id` is really mandatory. Other fields can be easily retrieved from the database by using this unique identifier. The only interesting part here is the related to the `TextButton` widget used to delete an item. It follows the same principle seen previously, by dispatching a `Notification` after having removed the item from the database by calling the `cache.delete()` method.

```dart
  Widget build(BuildContext context) {
    final CacheInterface? cache = Application.of(context)?.cache;
    final id = item["id"];
    final key = item["key"];
    final value = item["value"];
    final locked = item["locked"];
    final created_at = item["created_at"];
    final updated_at = item["updated_at"];
    return ListTile(
      leading: Text("$id"),
      title: Text('${key} (${locked})'),
      subtitle: Text('${value}'),
      trailing: Column(
        children: [
          Text('created_at: ${created_at}'),
          Text(updated_at == null ? '' : 'updated_at ${updated_at}'),
          Expanded(child: TextButton(
            onPressed: () {
              cache!.delete(id);
              DatabaseInputNotification().dispatch(context);
            },
            child: Text('delete'),
          )),
        ],
      )
    );
  }
}
```

## Database Interface

The "most" import part of the this application is the interface to the SQLite database using `sqflite`.

```dart
class CacheInterface {
  Database db;
```

The SQL schema containing the `cache` table is directly embedded in the `CacheInterface` class. This schema is straightforward, it creates a new class `cache` containing a primary key `id`, a column `key` as BLOB, a column `value` as BLOB, a `locked` column as BOOL and two columns to add a timestamp the data (`created_at` and `updated_at`).

```dart
  final String schema = '''
    CREATE TABLE cache (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      key BLOB UNIQUE NOT NULL,
      value BLOB NOT NULL,
      locked BOOL NOT NULL DEFAULT FALSE,
      created_at INTEGER NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at INTEGER
    );
  ''';
```

The main constructor requires only a valid opened database, but another one called `CacheInterface.init()` can also deploy the previous schema to the opened database.

```dart
  CacheInterface({required Database this.db});

  CacheInterface.init({required Database this.db, bool createSchema = true}) {
    if (createSchema == true)
      db.execute(this.schema);
  }
```

`add()` is a wrapper around `Database.rawInsert()` method. This is more an `UPSERT` than an `INSERT`, a key/value couple is inserted inside the database, in case of conflict, the `value` field is overwritten, and the `update_at` field updated. All SQL requests crafted with sqflite can use the `?` parameter to insert value. Please avoid `String` concatenation here to avoid SQL injection.

```dart
  Future<int> add(String key, String value) async {
    final ret = await db.rawInsert('''
        INSERT INTO cache (key, value) VALUES (?, ?)
          ON CONFLICT (key) DO UPDATE SET
            value=?,
            updated_at=CURRENT_TIMESTAMP;
      ''',
      [key, value, value]
    );
    return ret;
  }
```

The `delete()` method is used to delete an item by using its unique `id` (primary key).

```dart
  Future<List<Map<String, Object?>>> delete(int id) async {
    final ret = await db.rawQuery('''
        DELETE FROM cache WHERE id=?;
      ''',
      [id]
    );
    return ret;
  }
```

The `lock()` method set the `locked` field to `True`. It was simply to test the BOOL/INTEGER types in SQLite.

```dart
  Future<List<Map<String, Object?>>> lock(int id) async {
    final ret = await db.rawQuery('''
        UPDATE FROM cache SET locked=true WHERE id=?;
      ''',
      [id]
    );
    return ret;
  }
```

The `unlock()` method set the `locked` field to `False`.

```dart
  Future<List<Map<String, Object?>>> unlock(int id) async {
    final ret = await db.rawQuery('''
        UPDATE FROM cache SET locked=false 
          WHERE id=?
          RETURNING id;
      ''',
      [id]
    );
    return ret;
  }
```

The `list()` method returns the complete list of items from the database. This is not a really efficient way of doing that, if the database contains to much items, it can have a huge impact on the memory. A better solution would probably to use `LIMIT` and `OFFSET` to only select a subset of the items when needed. This method can also have another impact, this time on the CPU and the I/O, but the amount of memory used should be negligible.

```dart
  Future<List<Map<String, Object?>>> list() async {
    final ret = await db.rawQuery('''
      SELECT * FROM cache ORDER BY id;
    ''');
    return ret;
  }
```

The `getLength()` method returns the total number of items present in the `cache` table.

```dart
  Future<int> getLength() async {
    final ret = await db.rawQuery('''
      SELECT count(id) as count FROM cache;
    ''');
    int l = 0;
    if (ret.length == 1) {
      l = ret[0]['count'] as int;
    }
    return l;
  }
```

# Interfaces Summary

`sqflite` reflects the complexity of SQLite by offering many different interfaces to interact with the database, because a simple example like the previous one can't cover everything, a small non-exhaustive list of the interesting functions and methods can be seen below.

- [**`sqflite.databaseExists()`**](https://pub.dev/documentation/sqflite/latest/sqflite/databaseExists.html): this function checks if a database exists (or not);

- [**`sqflite.inMemoryDatabasePath`**](https://pub.dev/documentation/sqflite/latest/sqflite/inMemoryDatabasePath-constant.html): this is a constant, used to open an in-memory SQLite database. The same behavior can be done by passing the `String` `:memory:` when opening a database;

- [**`sqflite.OpenDatabaseOptions()`**](https://pub.dev/documentation/sqflite/latest/sqflite/OpenDatabaseOptions/OpenDatabaseOptions.html): an object containing extra database options for `sqflite`. For example, if someone needs to migrate the database, the function callbacks will be defined there;

- [**`sqflite.openReadOnlyDatabase()`**](https://pub.dev/documentation/sqflite/latest/sqflite/openReadOnlyDatabase.html): it can be useful to open a database in read-only, for example after a crash or simply to protect the content of the database from the user;

- [**`sqflite.openDatabase()`**](https://pub.dev/documentation/sqflite/latest/sqflite/openDatabase.html): this is the default function used to open a database;

- [**`sqflite.deleteDatabase()`**](https://pub.dev/documentation/sqflite/latest/sqflite/deleteDatabase.html): if a database can be created, it can also be deleted. If for some reasons, the database is not required anymore (e.g. temporary data), it can be deleted using this function;

- [**`Database.close()`**](https://pub.dev/documentation/sqflite/latest/sqflite/Database/close.html): when the application is terminated, or if the database is not required anymore, it can be closed using this method;

- [**`Database.execute()`**](https://pub.dev/documentation/sqflite/latest/sqflite/DatabaseExecutor/execute.html): execute a query on the opened database. It can be used to create the schema of the database or configure some SQLite [pragmas](https://sqlite.org/pragma.html). Optional arguments can be passed as a `List`;

```dart
db.execute(
  '''
    PRAGMA foreign_keys = TRUE;
    CREATE TABLE t(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      value STRING UNIQUE
    );
  '''
);
```

- [**`Database.rawQuery()`**](https://pub.dev/documentation/sqflite/latest/sqflite/DatabaseExecutor/rawQuery.html): execute a raw query and returns the result of it. It works like all the raw queries methods;

```dart
db.rawQuery(
  '''
    SELECT * FROM cache WHERE id = ?;
  ''', 
  [id]
);
```

- [**`Database.rawInsert()`**](https://pub.dev/documentation/sqflite/latest/sqflite/DatabaseExecutor/rawInsert.html): execute an [`INSERT`](https://sqlite.org/lang_insert.html) and returns its result, works like other raw queries methods;

```dart
db.rawInsert(
  '''
    INSERT INTO cache (key, value)
      VALUES (?, ?);
  ''', 
  ['mykey', 'myvalue']
);
```

- [**`Database.rawUpdate()`**](https://pub.dev/documentation/sqflite/latest/sqflite/DatabaseExecutor/rawUpdate.html): execute an [`UPDATE`](https://sqlite.org/lang_update.html) and returns its result;

```dart
db.rawUpdate(
  '''
    UPDATE FROM cache
      SET value = ?
      WHERE key = ?
  ''', 
  ['my_new_value', 'mykey']
);
```

- [**`Database.rawDelete()`**](https://pub.dev/documentation/sqflite/latest/sqflite/DatabaseExecutor/rawDelete.html): a method used to use [`DELETE`](https://sqlite.org/lang_delete.html) against the database, returning the changes;

```dart
db.rawDelete(
  '''
    DELETE FROM cache
      WHERE key = ?
  ''', 
  ['mykey']
);
```

- [**`Database.query()`**](https://pub.dev/documentation/sqflite/latest/sqflite/DatabaseExecutor/query.html): this method is a function helper to select data from a table, by setting the different elements of a query as class parameters. It was not used in the previous application example, but it is a nice tool to deal with data;

```dart
final int id = 1;
db.query(
  'cache',
  columns: ['id'],
  where: 'id = ?',
  whereArgs: [id]
);
```

- [**`Database.insert()`**](https://pub.dev/documentation/sqflite/latest/sqflite/DatabaseExecutor/insert.html): this method is another helper, this time to insert data into a table. In case of conflict on the table, a [`ConflictAlgorithm`](https://pub.dev/documentation/sqflite/latest/sqflite/ConflictAlgorithm.html) can be selected (`rollback`, `abort`, `fail`, `ignore` and `replace`);

```dart
final item = {
  'key': 'mykey',
  'value': 'myvalue',
};
db.insert(
  'cache',
  item,
  conflictAlgorithm: ConflictAlgorithm.replace
);
```

- [**`Database.update()`**](https://pub.dev/documentation/sqflite/latest/sqflite/DatabaseExecutor/update.html): another function helper to update data from a table;

```dart
final item = {
  'key': 'mykey',
  'value': 'myvalue2',
};

db.update(
  'cache',
  item,
  where: 'key = ?',
  whereArgs: [item.key],
  conflictAlgorithm: ConflictAlgorithm.rollback
);
```

- [**`Database.delete()`**](https://pub.dev/documentation/sqflite/latest/sqflite/DatabaseExecutor/delete.html): another method to help deleting data from a table;

```dart
db.delete(
  'cache',
  where: 'id = ?',
  whereArgs: [item.id]
);
```

- [**`Database.transaction()`**](https://pub.dev/documentation/sqflite/latest/sqflite/Database/transaction.html): `sqflite` support SQL transactions, a really important feature when inserting complex data in a database. The transaction uses an anonymous function with one argument (the transaction id as [`Transaction()`](https://pub.dev/documentation/sqflite/latest/sqflite/Transaction-class.html) object), if something goes wrong during the execution of this function, the data are not commited;

```dart
db.transaction((txid) {
  final int id = txid.insert(
    'cache',
    {'key': 'test', 'value': 'data'}
  );

  txid.delete(
    'cache',
     where: 'id = ?',
     whereArgs: [id]
  );
});
```

- [**`Database.batch()`**](https://pub.dev/documentation/sqflite/latest/sqflite/DatabaseExecutor/batch.html): even if `sqflite` does not support the `WHERE IN` statement, it's still possible to insert many data at the time with a batch. Those data can be inserted atomically with the [`Batch.commit()`](https://pub.dev/documentation/sqflite/latest/sqflite/Batch/commit.html) method or one by one by calling the [`Batch.apply()`](https://pub.dev/documentation/sqflite/latest/sqflite/Batch/apply.html) method;

```dart
var batch = db.batch();
batch.insert('cache', {'key': '1', 'value': '1'});
batch.insert('cache', {'key': '2', 'value': '2'});
batch.insert('cache', {'key': '3', 'value': '3'});
var results = await batch.commit();
```

# Conclusion

**The code source of this application should not be used in production environment. It is a draft and was used as sandbox to test some of the interfaces available on the `sqflite` library.**

`sqflite` is the most used SQLite library on Flutter, and it does most of the given tasks. After few days of testing though, lot of important features are missing from my point of view.

The first one is the lack of `WHERE IN` statement support, and the different "solutions" offered by the community are sometimes totally unsafe (SQL injection[^so-sqflite-where-in-operator]) or complete hacks (requests crafting[^git-sqflite-where-in-operator]). If you can't use another library, you will probably need to use a loop inside a transaction.

```dart
db.transaction(txid) {
  for (var item in items) {
    txid.rawQuery('DELETE FROM items WHERE id=?'), [item.id]);
  }
}
```

Another idea is to mark all data to be removed by adding a column `to_delete` and then use a recursive query. When marked as deleted, another tasks can be used to cleanup the database asynchronously.

```sqlite
ALTER TABLE items ADD COLUMN to_delete BOOL NOT NULL DEFAULT FALSE;
```

```dart
db.rawQuery('''
  WITH d AS (SELECT id FROM items WHERE to_delete IS TRUE)
  DELETE FROM items WHERE items.id IN d;
''');
```

Those are still hacky solutions, but it should be better than crafting queries and risking SQL injections. More workarounds exist, like creating a temporary table to store those elements to delete for example.

The second missing feature is the lack of prepared statement [^git-prepared-statement]. In fact, this feature could have been a good alternative to deal with multi item deletion or batch queries, but well, no support. The solution? Using transactions (or batch) instead.

Another annoying behavior from this package is the overuse of asynchronous functions to query the database. I don't think a library should enforce asynchronous functions call everywhere, but should let the developer to do synchronous or asynchronous call. For example, opening a database should be a synchronous call, if the database can't be opened, the application retries or crashes. This step is usually done at the startup of the application, when no one cares are about asynchronous call because if you don't have your database is not there, the rest of the application can't work.

The best way to fix that, is to improve `sqflite`. Unfortunately, it's not in my todo list, if some of you wants to create a PR, you are welcome!

Finally, what do I really think of `sqflite` now... Well, it can be used to create proof of concepts, small prototypes or even small application with a limited amount of SQL requirements. In case of bigger app, I would probably recommend to switch to [`sqlite3`](https://pub.dev/packages/sqlite3) package.

This topic is not a small one, covering both SQL, SQLite, Dart and Flutter in the same article is not an easy task. In fact, it took me 2 or 3 days to write this dirty application while reading the documentation and the source code. It seems I'm not an expert with Flutter yet! Anyway many others developers wrote about that, here a list of resources I consulted:

- [Persist data with SQLite](https://docs.flutter.dev/cookbook/persistence/sqlite) from Flutter documentation;

- [`sqflite` package](https://pub.dev/packages/sqflite) on pub.dev;

- [Official `sqflite` API Documentation](https://pub.dev/documentation/sqflite/latest/) on pub.dev;

- [Official `sqflite_ffi` API Documentation](https://pub.dev/documentation/sqflite_ffi/latest/) on pub.dev;

- [Official `sqflite` git Repository](https://github.com/tekartik/sqflite/tree/master/sqflite) at Github;

- [`sqflite` Opening a database Example](https://github.com/tekartik/sqflite/blob/master/sqflite/doc/opening_db.md) at Github;

- [`sqflite` Migration Example](https://github.com/tekartik/sqflite/blob/master/sqflite/doc/migration_example.md) at Github;

- [SQLite in Flutter: Guide with CRUD Example](https://medium.com/@bouargalne.hamid/sqlite-in-flutter-guide-with-crud-example-8849e942aab1) by [Bouargalne Hamid](https://medium.com/@bouargalne.hamid) on Medium;

- [SQLite in Flutter: The Complete Guide](https://dev.to/arslanyousaf12/sqlite-in-flutter-the-complete-guide-11nj) by @arslanyousaf12.

Many open-source application using `sqflite` can be found on Github or elsewhere, here a short list of them:

- [Flutter Tutorial - Database Storage Using Sqlite & Sqflite](https://github.com/JohannesMilke/sqflite_database_example):  Persist data with Flutter's Sqflite Database locally on your Android or iOS device by using Raw SQL statements;

- [Flutter SQFLITE MVP LOGIN APP](https://github.com/iampawan/Flutter-Sqflite-MVP): An Login Page App in Flutter with MVP and SQFLITE ( SQLITE) Implementation;

- [Flutter Sqflite Manager](https://github.com/mcrovero/flutter_sqflite_manager):  Visually manage your Flutter Sqflite database;

- [flutter-notes-app](https://github.com/roshanrahman/flutter-notes-app):  A notes taking app written in Flutter;

- [contacts](https://github.com/harsh159357/contacts):  A flutter project with Implementation of a Contacts app in 4 ways (API, Custom, Preferences and Sqflite);

Have fun and Happy Hacking!

[^so-sqflite-where-in-operator]: please don't do what the author of the answer is saying. It's a huge risk of SQL injection, and can have huge consequences on your code. https://stackoverflow.com/questions/59215540/sqflite-in-operator-with-and-operator

[^git-sqflite-where-in-operator]: The first comments are from the authors of the library and should not be followed (sql injection). The last answers are probably the best because they are crafting the SQL requests by using `?` parameters, but it's still crafting, and crafting SQL requests can be dangerous. https://github.com/tekartik/sqflite/issues/15#issuecomment-350979779

[^git-prepared-statement]: the author of the module said prepared statement is not supported. https://github.com/tekartik/sqflite/issues/253#issuecomment-518954845

----

Cover Image by <a href="https://unsplash.com/@teddyblk_?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Theodore Black</a> on <a href="https://unsplash.com/photos/brown-wooden-table-on-gray-floor-Ltgg9uGi7tE?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>