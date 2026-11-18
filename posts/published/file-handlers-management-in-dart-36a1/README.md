---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/file-handlers-management-in-dart-36a1"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2F09xlym61h9kos85fv1mg.jpg"
created_at: "None"
crossposted_at: "None"
description: "In a previous article, the File object has been dissected. It's a perfect interface to use if one..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/file-handlers-management-in-dart-36a1"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "file-handlers-management-in-dart-36a1"
social_image: "None"
title: "File Handlers Management in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# File Handlers Management in Dart

In a previous article, the `File` object has been dissected. It's a perfect interface to use if one needs to write or read small files. When it comes to more complex or bigger files, using a file handler is necessary. The following code snippets will [`dart:io`](https://api.dart.dev/dart-io/), [`dart:convert`](https://api.dart.dev/dart-convert/) and [`dart:typed_data`](https://api.dart.dev/dart-typed_data/) packages where:

- [`dart:io`](https://api.dart.dev/dart-io/) will be used for the [`File`](https://api.dart.dev/dart-io/File-class.html) and [`RandomAccessFile`](https://api.dart.dev/dart-io/RandomAccessFile-class.html) classes;

- [`dart:typed_data`](https://api.dart.dev/dart-typed_data/) will be used for the [`Uint8List`](https://api.dart.dev/dart-typed_data/Uint8List-class.html) class, object returned when reading a file byte by byte;

- [`dart:convert`](https://api.dart.dev/dart-convert/) will be required for the [`ascii`](https://api.dart.dev/dart-convert/ascii-constant.html) and [`utf8`](https://api.dart.dev/dart-convert/utf8-constant.html) converters, to convert the bytes read from a file or to convert a String to bytes before writing them.

```dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
```

When opening a file via the [`File.open()`](https://api.dart.dev/dart-io/File/open.html) method, it returns a [`RandomAccessFile`](https://api.dart.dev/dart-io/RandomAccessFile-class.html). This object is an interface to manage a file in a more accurate way than the methods offered by `File`. Indeed, the `File.read*()` or `File.write*()` methods are dealing with the whole file and not a subset of it. Before digging in those details, one bigger problem must be fixed.

When a file is opened, a file descriptor is allocated for the process. The amount of file descriptors is not unlimited, and in case of exhaustion, the process can crash. A good practice is to always close an unused file to avoid this kind of issues. To do that, a [`try`/`finally`](https://dart.dev/language/error-handling) clause can be used like in the example below.

```dart
File myFile = File("./file.test");
myFile.create();

final handler = await myFile.open(mode: FileMode.read);

try {
  // code to execute here while the  file is opened
}
finally {
  // in case issue, we always close the handler
  await handler.close();
}
```

Repeating this code is boring, this is Dart, not Go. To avoid code duplication and eventually errors, let creates a new function to always close a file.

```dart
void handlerManager(String path, 
                    FileMode mode,
                    Function closure) async {

  // create a new File object
  File file = File(path);

  // open the file using the mode specified
  // in the arguments
  RandomAccessFile fh = await file.open(mode: mode);
  print("> open $file");

  // execute the closure passed in the last
  // argument of the function...
  try {
    await closure(fh);
  }

  // if the closure throw an exception, we
  // print it and rethrow it
  catch (e, s) {
    print("$e, $s");
    rethrow;
  }

  // in all cases, the file handler must be
  // closed to avoid file descriptor exhaustion
  finally {
    fh.closeSync();
    print("> close $file");
  }
}
```

This small function can then be used to automatically close a file handler like the following piece of code:

```dart
final action = () {};
handlerManager("./read.txt", FileMode.read, action);
```

Now this part is fixed, let have a quick look on the [`open`](https://api.dart.dev/dart-io/File/open.html) and [`openSync()`](https://api.dart.dev/dart-io/File/openSync.html) methods and how to use it. Five file modes defined as constants in the [`FileMode`](https://api.dart.dev/dart-io/FileMode-class.html) class can be used to open a file.

The [`read` mode](https://api.dart.dev/dart-io/FileMode/read-constant.html) set the file handler in read-only, in this mode, the application can only read bytes from the file or set the position of the cursor.

The [`write` mode](https://api.dart.dev/dart-io/FileMode/write-constant.html) set the file handler in read-write mode, in this case, the application can read or write bytes to the file. If the file is opened and then nothing is done on it, the file is then truncated (emptied).

The [`append` mode](https://api.dart.dev/dart-io/FileMode/append-constant.html) set the file handler in read-write mode but will not truncate the file if this one is closed before doing anything on it.

The [`writeOnly` mode](https://api.dart.dev/dart-io/FileMode/writeOnly-constant.html) can only write bytes to a file without reading it. If a file is already present, it will be overwritten.

The [`writeOnlyAppend` mode](https://api.dart.dev/dart-io/FileMode/writeOnlyAppend-constant.html) can only write data on the end of the file.

# File Handler Cursor

A file can be seen as a contiguous array of bytes, where an empty file can be seen as an empty array with a zero length. When dealing with an array, an index is used to store an object. The same concept exists with an opened file, but it is called a cursor. A cursor can be positioned on a specific offset on the file to read or write content on it. Let test that with Dart. First, two files will be created, one called `empty.txt` and another one called `hello.txt`, respectively an empty file, and a file containing the string "hello world".

```console
$ touch empty.txt

$ echo hello world > hello.txt
```

A `RandomAccessFile` object is offering 3 methods to configure the cursor. The first one is the [`length()`](https://api.dart.dev/dart-io/RandomAccessFile/length.html) method, useful to know the size of the file and to avoid configuring the cursor at the wrong place. Then, the [`position()`](https://api.dart.dev/dart-io/RandomAccessFile/position.html) method and the [`setPosition()`](https://api.dart.dev/dart-io/RandomAccessFile/setPosition.html) method are used to interact with the cursor. Easy, right?

```dart
// create a new file object
File emptyFile = File("./empty.txt");

// open the file, in read-only mode by default
RandomAccessFile emptyFileHandler = await emptyFile.open();

// create a clojure to print the length of a file handler
final length = (RandomAccessFile fh) async {
  final length = await emptyFileHandler.length();
  print("length: $length");
};
await length(emptyFileHandler);

// create another clojure to print the position of
// a cursor
final position = (RandomAccessFile fh) async {
  final position = await emptyFileHandler.position();
  print("position: $position");
};
await position(emptyFileHandler);

// configure the position of the cursor
await emptyFileHandler.setPosition(10);

// print the length of the file and
// the position of the cursor
await length(emptyFileHandler);
await position(emptyFileHandler);

// close the file handler
await emptyFileHandler.close();
```

Let execute this code snippet.

```console
$ dart run
length: 0
position: 0
length: 0
position: 10
```

What's happening there? Firstly, the `empty.txt` file is opened, the default [`FileMode`](https://api.dart.dev/dart-io/FileMode-class.html) is `read`. This file is empty, then it's length is set to `0` and the cursor is also set to `0` (start of the file). The cursor position is set to `10`, you would think it fails, but it works. If a byte is written at this place, the previous bytes (from the beginning to the current cursor position) will be set to `0`. Finally, the file handler is closed to free the file descriptor.


# Read Mode

When opening a file in [`read` mode](https://api.dart.dev/dart-io/FileMode/read-constant.html), the application can only read the content of the file without altering it.

```dart
File file = File("./hello.txt");
RandomAccessFile fh = file.open(mode: FileMode.read);
// ... do something here
fh.close()
```

To read the data from the handler, one can use the [`read()`](https://api.dart.dev/dart-io/RandomAccessFile/read.html), [`readByte()`](https://api.dart.dev/dart-io/RandomAccessFile/readByte.html) or [`readInto()`](https://api.dart.dev/dart-io/RandomAccessFile/readInto.html) methods. Let check them one by one. Just to avoid too much duplicated code, a closure to print the position of the cursor will be created.

```dart
// another clojure to print the position of
// a cursor.
final printPosition = (RandomAccessFile fh) {
  int position = fh.positionSync();
  print('> position: $position');
};
```

The [`read()`](https://api.dart.dev/dart-io/RandomAccessFile/read.html) and [`readSync()`](https://api.dart.dev/dart-io/RandomAccessFile/readSync.html) methods return an [`Uint8List`](https://api.dart.dev/dart-typed_data/Uint8List-class.html) containing the amount of bytes requested from the opened file, starting at the beginning of it. For our first test, let try to read 10 bytes from the files previously created.

```dart
handlerManager("./hello.txt", FileMode.read, (RandomAccessFile fh) {
  // print the position of the cursor
  printPosition(fh);

  // store the 10 first bytes of the file in
  // a buffer
  Uint8List readBuffer = fh.readSync(10);

  // print the buffer
  print(readBuffer);

  // convert the buffer in ascii and print it
  print(ascii.decode(readBuffer));
});
```

```console
$ dart run
> open File: './hello.txt'
> position: 0
[104, 101, 108, 108, 111, 32, 119, 111, 114, 108]
hello worl
> close File: './hello.txt'
```

Great, the file is correctly opened, and 10 bytes are returned. Those bytes can be converted with [`ascii.decode()`](https://api.dart.dev/dart-convert/ascii-constant.html) and printed as readable String. Sometimes, we don't want to read a part of the file, but only read it byte by byte. In this case, [`readByte()`](https://api.dart.dev/dart-io/RandomAccessFile/readByte.html) and [`readByteSync()`](https://api.dart.dev/dart-io/RandomAccessFile/readByteSync.html) methods can be used. They are returning an `int` representing the character from the cursor position.

```dart
handlerManager("./hello.txt", FileMode.read, (RandomAccessFile fh) {
  printPosition(fh);

  // create an integer buffer (one char)
  int byteBuffer;

  // read the file until we reach an eof
  while ((byteBuffer=fh.readByteSync())>=0) {
    // print the cursor's position at every step
    printPosition(fh);

    // print the buffer and its ascii representation
    print("$byteBuffer | ${ascii.decode([byteBuffer])}");
  }
});
```

```console
$ dart run
> open File: './hello.txt'
> position: 0
> position: 1
104 | h
> position: 2
101 | e
> position: 3
108 | l
> position: 4
108 | l
> position: 5
111 | o
> position: 6
32 |  
> position: 7
119 | w
> position: 8
111 | o
> position: 9
114 | r
> position: 10
108 | l
> position: 11
100 | d
> position: 12
10 | 

> close File: './hello.txt'
```

As you can see, the `while` loop store the returned value into a variable. Every time the [`readByteSync()`](https://api.dart.dev/dart-io/RandomAccessFile/readByteSync.html) method is called, the position of the cursor is increased until it reaches the end of file (`eof`) represented by `-1`. Perhaps your file is really huge, or you have your own parser, in this case, one can use the [`readInto()`](https://api.dart.dev/dart-io/RandomAccessFile/readInto.html) or [`readIntoSync()`](https://api.dart.dev/dart-io/RandomAccessFile/readIntoSync.html) methods. The idea here is to create a buffer and store the content of the file in it. The buffer can have its own limited size, in this case, the [`readInto()`](https://api.dart.dev/dart-io/RandomAccessFile/readInto.html) method needs to now how many characters it can read from the file to store them in the buffer.

```dart
handlerManager("./hello.txt", FileMode.read, (RandomAccessFile fh) {
  printPosition(fh);

  // buffer initialization using the length of
  // the file.
  Uint8List buffer = Uint8List(fh.lengthSync());

  // let read it a first time
  fh.readIntoSync(buffer);
  print(buffer);
  print(ascii.decode(buffer));
  printPosition(fh);

  // let reset the position and read it a
  // second time.
  fh.setPositionSync(0);
  print(fh.readSync(10));
  print(fh.readSync(10));

  // reset another time the position of
  // the cursor at the beginning of the file
  fh.setPositionSync(0);
  print(fh.readSync(10));
});
```

```console
$ dart run
> open File: './hello.txt'
> position: 0
[104, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100, 10]
hello world

> position: 12
[104, 101, 108, 108, 111, 32, 119, 111, 114, 108]
[100, 10]
[104, 101, 108, 108, 111, 32, 119, 111, 114, 108]
> close File: './hello.txt'
```

As you can see, a buffer can be used to store part of the file temporarily. Another interesting thing is a position cursor can be configured while reading the file, it means a file can be opened for a long time, and the cursor can move during all this time.

# Write Mode

Reading a file is great, but writing data can also be useful. The [`writeByte()`](https://api.dart.dev/dart-io/RandomAccessFile/writeByte.html), [`writeByteSync()`](https://api.dart.dev/dart-io/RandomAccessFile/writeByteSync.html), [`writeFrom()`](https://api.dart.dev/dart-io/RandomAccessFile/writeFrom.html), [`writeFromSync`](https://api.dart.dev/dart-io/RandomAccessFile/writeFromSync.html), [`writeString()`](https://api.dart.dev/dart-io/RandomAccessFile/writeString.html) and [`writeStringSync()`](https://api.dart.dev/dart-io/RandomAccessFile/writeFromSync.html) methods can be used to accomplish this tasks.

```dart
File file = File("./hello.txt");
RandomAccessFile fh = file.open(mode: FileMode.write);
// ... do something here
fh.close()
```dart

Just to be sure, let create another closure to display the length of the file this time. If you prefer create it as a function, you can do it as well.

```dart
final printLength = (RandomAccessFile fh) {
  int length = fh.lengthSync();
  print('> length: $length');
};
```

The first test is to open the `empty.txt` file and writing data byte by byte. To do that, the [`writeByteSync()`](https://api.dart.dev/dart-io/RandomAccessFile/writeByteSync.html) or [`writeByte()`](https://api.dart.dev/dart-io/RandomAccessFile/writeByte.html) functions can be used, where the first argument is the character to write in the file as an integer.

```dart
handlerManager("./empty.txt", FileMode.write, (RandomAccessFile fh) {
  // write the character H
  printPosition(fh);
  printLength(fh);
  fh.writeByteSync(0x48);

  // write the character E
  printPosition(fh);
  printLength(fh);
  fh.writeByteSync(0x45);

  // write the character L
  printPosition(fh);
  printLength(fh);
  fh.writeByteSync(0x4C);

  // write the character L
  printPosition(fh);
  printLength(fh);
  fh.writeByteSync(0x4C);

  // write the character O
  printPosition(fh);
  printLength(fh);
  fh.writeByteSync(0x4F);

  // write the character \n
  printPosition(fh);
  printLength(fh);
  fh.writeByteSync(0xa);
});
```

```console
$ dart run
> open File: './empty.txt'
> position: 0
> length: 0
> position: 1
> length: 1
> position: 2
> length: 2
> position: 3
> length: 3
> position: 4
> length: 4
> position: 5
> length: 5
> close File: './empty.txt'
```

As you can see, every time one byte is written in the file, the cursor is increased and the length of the file as well. Writing data byte by byte can be slow, sometimes, a buffer containing a specific amount of data should be written in one step. In this case, the [`writeFrom()`](https://api.dart.dev/dart-io/RandomAccessFile/writeFrom.html) and [`writeFromSync()`](https://api.dart.dev/dart-io/RandomAccessFile/writeFromSync.html) methods can be called.

```dart
handlerManager("./empty.txt", FileMode.write, (RandomAccessFile fh) {
  printPosition(fh);
  printLength(fh);

  // create a new Uint8List buffer from
  // an encoded ASCII string
  Uint8List buffer = Uint8List.fromList(
    ascii.encode("hello world\n")
  );

  // write the content of the buffer
  // to the file
  fh.writeFromSync(buffer);

  printPosition(fh);
  printLength(fh);
});
```

```console
$ dart run
> open File: './empty.txt'
> position: 0
> length: 6
> position: 12
> length: 12
> close File: './empty.txt'
```

When the file is opened, the cursor is set to the position `0` and the buffer is written at the beginning of it, overwriting the previous data if any. The last methods to test are [`writeString()`](https://api.dart.dev/dart-io/RandomAccessFile/writeString.html) and [`writeStringSync()`](https://api.dart.dev/dart-io/RandomAccessFile/writeStringSync.html), both of them are simply writings a `String` directly into the file.

```dart
handlerManager("./empty.txt", FileMode.write, (RandomAccessFile fh) {
  printPosition(fh);
  printLength(fh);

  // write the string "data...\n"
  // in the file
  fh.writeStringSync("data...\n");

  printPosition(fh);
  printLength(fh);
});
```

```console
$ dart run
> open File: './empty.txt'
> position: 0
> length: 12
> position: 8
> length: 12
> close File: './empty.txt'
```

Like the previous example, the data added are overwriting the data from the position `0`. Obviously, the position of the cursor can be set on all previous methods by setting it with [`setPosition()`](https://api.dart.dev/dart-io/RandomAccessFile/setPosition.html). Last questions we can ask here, what is happening if the cursor is set to a value greater than the length of the file?

```dart
handlerManager("./empty.txt", FileMode.write, (RandomAccessFile fh) {
  printPosition(fh);
  printLength(fh);

  // we know the file size is 12 bytes,
  // but we set the position to 1024.
  fh.setPositionSync(1024);
  fh.writeStringSync("!\n");

  printPosition(fh);
  printLength(fh);
});
```

```console
$ dart run
> open File: './empty.txt'
> position: 0
> length: 12
> position: 1026
> length: 1026
> close File: './empty.txt'

$ hexdump -C empty.txt
00000000  64 61 74 61 2e 2e 2e 0a  72 6c 64 0a 00 00 00 00  |data....rld.....|
00000010  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
00000400  21 0a                                             |!.|
00000402
```

Everything works perfectly, and the missing bytes are simply set to `0`, like the output of [`hexdump`](https://manpages.debian.org/trixie/bsdextrautils/hexdump.1.en.html) is showing us.

# Append Mode

Using [`FileMode.write`](https://api.dart.dev/dart-io/FileMode/write-constant.html) can be dangerous, if someone forgot to set the cursor at the right place, the data stored in the file can be overwritten. In many situation, using the [`FileMode.append`](https://api.dart.dev/dart-io/FileMode/append-constant.html) is a better choice, because the [`RandomAccessFile`](https://api.dart.dev/dart-io/RandomAccessFile-class.html) object returned will set the position of the cursor directly at the end of the file.

```dart
File file = File("./hello.txt");
RandomAccessFile fh = file.open(mode: FileMode.append);
// ... do something here
fh.close()
```

```dart
handlerManager("./hello.txt", FileMode.append, (RandomAccessFile fh) {
  printLength(fh);
  printPosition(fh);

  fh.writeStringSync("append data");

  printLength(fh);
  printPosition(fh);

  fh.setPositionSync(0);
  printLength(fh);
  printPosition(fh);

  print(ascii.decode(fh.readSync(fh.lengthSync())));
  printLength(fh);
  printPosition(fh);
});
```

```console
$ dart run
> open File: './hello.txt'
> length: 12
> position: 12
> length: 23
> position: 23
> length: 23
> position: 0
hello world
append data
> length: 23
> position: 23
> close File: './hello.txt'
```

One can still set the position of the cursor manually if needed.

# WriteOnly Mode

The [`FileMode.writeOnly`](https://api.dart.dev/dart-io/FileMode/writeOnly-constant.html) mode can only write to a file, without reading its content.

```dart
File file = File("./hello.txt");
RandomAccessFile fh = file.open(mode: FileMode.writeOnly);
// ... do something here
fh.close()
```

This is a dangerous mode, because if the file is already containing data, they will be overwritten. From the documentation:

> Mode for opening a file for writing only. The file is overwritten if it already exists. The file is created if it does not already exist.
>
> -- [`writeOnly constant `](https://api.dart.dev/dart-io/FileMode/writeOnly-constant.html)

Let check that. In the following example, the `hello.txt` file will simply be opened in this mode and then closed, without doing any actions (except checking the length of the file and the position of the cursor).

```dart
handlerManager("./hello.txt", FileMode.writeOnly, (RandomAccessFile fh) {
  printLength(fh);
  printPosition(fh);
});
```

```console
$ echo hello world > hello.txt 

$ ls -l hello.txt 
-rw-rw-r-- 1 user user 12 Sep  3 12:14 hello.txt

$ dart run
> open File: './hello.txt'
> length: 0
> position: 0
> close File: './hello.txt'

$ ls -l hello.txt 
-rw-rw-r-- 1 user user 0 Sep  3 12:14 hello.txt
```

At the beginning of the test, the file is containing 12 characters, but when the application is opening it with the [`FileMode.writeOnly`](https://api.dart.dev/dart-io/FileMode/writeOnly-constant.html), the size is set to 0. Well, in fact, this is why this mode is dangerous, it will simply overwrite the content of the file by default.

# WriteOnlyAppend Mode

The [`FileMode.writeOnlyAppend`](https://api.dart.dev/dart-io/FileMode/writeOnlyAppend-constant.html) mode is the last one to check. It has the same behavior than the [`FileMode.writeOnly`](https://api.dart.dev/dart-io/FileMode/writeOnly-constant.html) mode, except the cursor is set at the end of the file, and when data are written, the content is not overwritten.

> Mode for opening a file for writing only to the end of it. The file is created if it does not already exist.
> 
> -- [`writeOnlyAppend` constant ](https://api.dart.dev/dart-io/FileMode/writeOnlyAppend-constant.html)

```dart
File file = File("./hello.txt");
RandomAccessFile fh = file.open(mode: FileMode.writeOnlyAppend);
// ... do something here
fh.close()
```

```dart
handlerManager("./hello.txt", FileMode.writeOnlyAppend, (RandomAccessFile fh) {
  printLength(fh);
  printPosition(fh);
}); 

handlerManager("./hello.txt", FileMode.writeOnlyAppend, (RandomAccessFile fh) {
  printLength(fh);
  printPosition(fh);

  fh.writeStringSync("new line added");
  printLength(fh);
  printPosition(fh);
});
```

```console
$ echo hello world > hello.txt

$ stat hello.txt
  File: hello.txt
  Size: 12              Blocks: 8          IO Block: 4096   regular file
Device: 254,1   Inode: 279568      Links: 1
Access: (0664/-rw-rw-r--)  Uid: ( 1000/    user)   Gid: ( 1000/    user)
Access: 2026-09-03 12:24:41.882489242 +0000
Modify: 2026-09-03 12:27:18.162466032 +0000
Change: 2026-09-03 12:27:18.162466032 +0000
 Birth: 2026-09-02 07:37:41.595715171 +0000

$ dart run
> open File: './hello.txt'
> length: 12
> position: 12
> close File: './hello.txt'
> open File: './hello.txt'
> length: 12
> position: 12
> length: 26
> position: 26
> close File: './hello.txt'

$ stat hello.txt
  File: hello.txt
  Size: 26              Blocks: 8          IO Block: 4096   regular file
Device: 254,1   Inode: 279568      Links: 1
Access: (0664/-rw-rw-r--)  Uid: ( 1000/    user)   Gid: ( 1000/    user)
Access: 2026-09-03 12:24:41.882489242 +0000
Modify: 2026-09-03 12:27:45.530452395 +0000
Change: 2026-09-03 12:27:45.530452395 +0000
 Birth: 2026-09-02 07:37:41.595715171 +0000

$ cat hello.txt
hello world
new line added
```

As you can see, even if the file is open with a write-only mode, the data are added at the end of the file, without overwriting the previous ones.

# Truncating

The [`truncate()`](https://api.dart.dev/dart-io/RandomAccessFile/truncate.html) and [`truncateSync()`](https://api.dart.dev/dart-io/RandomAccessFile/truncateSync.html) methods can be used to extend the size of a file. The new space is filled with `0x00`.

```dart
handlerManager("./hello.txt", FileMode.append, (RandomAccessFile fh) {
  printLength(fh);
  printPosition(fh);

  fh.truncateSync(1024);
  printLength(fh);
  printPosition(fh);
});
```

```console
$ stat hello.txt
  File: hello.txt
  Size: 26              Blocks: 8          IO Block: 4096   regular file
Device: 254,1   Inode: 279568      Links: 1
Access: (0664/-rw-rw-r--)  Uid: ( 1000/    user)   Gid: ( 1000/    user)
Access: 2026-09-03 12:28:05.510440866 +0000
Modify: 2026-09-03 12:27:45.530452395 +0000
Change: 2026-09-03 12:27:45.530452395 +0000
 Birth: 2026-09-02 07:37:41.595715171 +0000

$ dart run
> open File: './hello.txt'
> length: 26
> position: 26
> length: 1024
> position: 26
> close File: './hello.txt'

$ stat hello.txt
  File: hello.txt
  Size: 1024            Blocks: 8          IO Block: 4096   regular file
Device: 254,1   Inode: 279568      Links: 1
Access: (0664/-rw-rw-r--)  Uid: ( 1000/    user)   Gid: ( 1000/    user)
Access: 2026-09-03 12:28:05.510440866 +0000
Modify: 2026-09-03 12:32:04.602216874 +0000
Change: 2026-09-03 12:32:04.602216874 +0000
 Birth: 2026-09-02 07:37:41.595715171 +0000

$ hexdump -C hello.txt
00000000  68 65 6c 6c 6f 20 77 6f  72 6c 64 0a 6e 65 77 20  |hello world.new |
00000010  6c 69 6e 65 20 61 64 64  65 64 00 00 00 00 00 00  |line added......|
00000020  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
00000400
```

As you can see, the size of the file was 26 bytes, after the truncate, the file size is 1024 bytes. The `hexdump` command display also the new space added filled with `0` only.

# Locking and Unlocking File

**WARNING**: this part of the article is not working as expected, for some reasons I don't currently understand. The following code is presented as is, and should be used with care.

To avoid editing a file at the same time than another process, the file used can be locked (and unlocked). To lock it, the [`lock()`](https://api.dart.dev/dart-io/RandomAccessFile/lock.html) and [`lockSync()`](https://api.dart.dev/dart-io/RandomAccessFile/lockSync.html) methods can be used. To unlock it, the [`unlock()`](https://api.dart.dev/dart-io/RandomAccessFile/unlock.html) and [`unlockSync()`](https://api.dart.dev/dart-io/RandomAccessFile/unlockSync.html) methods can be used.

> Locks the byte range from `start` to `end` of the file, with the byte at position end not included. If no arguments are specified, the full file is locked, If only `start` is specified the file is locked from byte position `start` to the end of the file, no matter how large it grows. It is possible to specify an explicit value of end which is past the current length of the file.
>
> -- [`lock` abstract method ](https://api.dart.dev/dart-io/RandomAccessFile/lock.html)

Four blocking modes exist:

- [`FileLock.blockingExclusive`](https://api.dart.dev/dart-io/FileLock/blockingExclusive-constant.html)

- [`FileLock.blockingShared`](https://api.dart.dev/dart-io/FileLock/blockingShared-constant.html)

- [`FileLock.exclusive`](https://api.dart.dev/dart-io/FileLock/exclusive-constant.html)

- [`FileLock.shared`](https://api.dart.dev/dart-io/FileLock/shared-constant.html)

```dart
handlerManager("./hello.txt", FileMode.write, (RandomAccessFile fh) async {
  printLength(fh);
  printPosition(fh);
  fh.lockSync(FileLock.blockingExclusive);

  await Future.delayed(Duration(seconds: 4), () => "ok");

  printLength(fh);
  printPosition(fh);
  fh.unlockSync();
});

Future.delayed(Duration(seconds: 2), () {
    handlerManager("./hello.txt", FileMode.append, (RandomAccessFile fh) async {
    printLength(fh);
    printPosition(fh);

    fh.writeStringSync("test");

    printLength(fh);
    printPosition(fh);
  });
});
```

```console
$ echo hello world > hello.txt

$ dart run
> open File: './hello.txt'
> length: 0
> position: 0
> open File: './hello.txt'
> length: 0
> position: 0
> length: 4
> position: 4
> close File: './hello.txt'
> length: 4
> position: 0
> close File: './hello.txt'
```

Reading the documentation and testing this feature could be a good idea if you want to use it for your project, because the behaviors differs between the supported platform by Dart. The behavior on Linux/MacOS is not the same than the one on Windows for example.

Note: while testing the locking feature, I was unable to see the difference between a file locked or not. I tried to open the file with another process and write some data, no errors were reported on both side. I checked the test suite to understand how it was working, here the sources:

- [`tests/standalone/io/file_lock_script.dart`](https://github.com/dart-lang/sdk/blob/cbdda8b4e08d686a811672e8e7de67bacb4afb43/tests/standalone/io/file_lock_script.dart)

- [`tests/standalone/io/file_blocking_lock_script.dart`](https://github.com/dart-lang/sdk/blob/cbdda8b4e08d686a811672e8e7de67bacb4afb43/tests/standalone/io/file_blocking_lock_script.dart)

- [`tests/standalone/io/file_lock_test.dart`](https://github.com/dart-lang/sdk/blob/cbdda8b4e08d686a811672e8e7de67bacb4afb43/tests/standalone/io/file_lock_test.dart)

I assume - but I'm probably wrong - the Dart implementation is using [`lockf`](https://manpages.debian.org/trixie/manpages-dev/lockf.3.en.html) POSIX function to lock a file on Linux, but this function was not found in the SDK source code. Then, [`fcntl`](https://manpages.debian.org/trixie/manpages-dev/fcntl.2.en.html) was perhaps the one used, `lockf` is just an interface to it. Unfortunately, the code using this function does not seem to be involved in file locking. The last one to check was [`flock`](https://manpages.debian.org/trixie/manpages-dev/flock.2.en.html), and I think it was the right one. The locking feature is implemented in [`runtime/bin/file_linux.cc`](https://github.com/dart-lang/sdk/blob/cbdda8b4e08d686a811672e8e7de67bacb4afb43/runtime/bin/file_linux.cc#L221) and uses `flock`.

Anyway, it was not expected, and some tests with the POSIX interface in C will be required to correctly understand how the file locking is working there. The future tasks:

- try to create shared and exclusive lock on a file, it should fail;

- try to create an exclusive lock on a file, and with another program, try to edit it, it should fail;

- do both implementation in C/Dart and compare the results.

Fun right?

# File Descriptor Exhaustion

Learning from mistakes is a hard way to know what's happening when something's bad happens. Instead of waiting for this kind of bug, let create an application using all file descriptors available and crashing. The [`ulimit`](https://manpages.debian.org/trixie/bash/bash.1.en.html#ulimit~2) builtin command can usually be used to check those limits. On BSD, one will also need to check the [`login.conf`](https://man.openbsd.org/login.conf.5). 

```console
$ ulimit -a
real-time non-blocking time  (microseconds, -R) unlimited
core file size              (blocks, -c) 0
data seg size               (kbytes, -d) unlimited
scheduling priority                 (-e) 0
file size                   (blocks, -f) unlimited
pending signals                     (-i) 3798
max locked memory           (kbytes, -l) 8192
max memory size             (kbytes, -m) unlimited
open files                          (-n) 1024
pipe size                (512 bytes, -p) 8
POSIX message queues         (bytes, -q) 819200
real-time priority                  (-r) 0
stack size                  (kbytes, -s) 8192
cpu time                   (seconds, -t) unlimited
max user processes                  (-u) 3798
virtual memory              (kbytes, -v) unlimited
file locks                          (-x) unlimited

$ ulimit -n
1024

$ ulimit -n 10
```

```dart
import 'dart:io';

void main() async {
  List<RandomAccessFile> store = [];
  File file = File("./t");

  while (true) {
    print(store.length);
    RandomAccessFile fh = await file.open(mode: FileMode.read);
    store.add(fh);
  }
}
```

```console
$ dart run
1
2
3
...
1015
Unhandled exception:
FileSystemException: Cannot open file, path = './t' (OS Error: Too many open files, errno = 24)
#0      _checkForErrorResponse (dart:io/common.dart:58:9)
#1      _File.open.<anonymous closure> (dart:io/file_impl.dart:438:7)
<asynchronous suspension>
#2      exhaustion (file:///home/user/tmp/cboring/bin/cboring.dart:33:27)
<asynchronous suspension>
```

This is not the only value to check. Other limits can have an impact on the stability of the application, like the number of file locks (`ulimit -x`) or the file size (`ulimit -f`). The file [quota](https://manpages.debian.org/trixie/quota/quota.1.en.html) can also be a source of crashes. So, it's always a good idea to check the limits imposed by the system in case of issues.

Note: it seems the limits can't be accessed via Dart. I was unable to find a reference to [`getrlimit`](https://manpages.debian.org/trixie/manpages-dev/getrlimit.2.en.html) or [`setrlimit`](https://manpages.debian.org/trixie/manpages-dev/setrlimit.2.en.html) functions. In fact, not really, but the only references to them are from [`tools/utils.py`](https://github.com/dart-lang/sdk/blob/cbdda8b4e08d686a811672e8e7de67bacb4afb43/tools/utils.py#L571), in Python, so, outside of the Dart scope. I assume then Dart is unable to `get` or `set` limits.

# Conclusion

Reading and writing files are not an easy job even if the interfaces provided are quite simple. This article wanted to show the different methods available to deal with the files and the potential issues one can found. In fact, the interfaces provided by Dart is similar to the one provided by the `libc`, with oriented object flavor. As usual if you want to know more about that, here few links to extend your knowledge of this API. Unfortunately, it seems not a lot of people are talking about this API...

- [`File` class API documentation](https://api.dart.dev/dart-io/File-class.html)

- [`FileMode` class API documentation](https://api.dart.dev/dart-io/FileMode-class.html)

- [`RandomAccessFile` class API documentation](https://api.dart.dev/dart-io/RandomAccessFile-class.html);

- [`file_linux.cc` source](https://github.com/dart-lang/sdk/blob/fb4752caaf04866d68afbece85c4df9759ff1f42/runtime/bin/file_linux.cc)

- [`file.cc` source](https://github.com/dart-lang/sdk/blob/fb4752caaf04866d68afbece85c4df9759ff1f42/runtime/bin/file.cc)

- [`Dart RandomAccessFile`](https://zetcode.com/dart/randomaccessfile/) by ZetCode.

Happy hacking and have fun!

----

Cover Image by <a href="https://unsplash.com/@khoiruabdan?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Khoiru Abdan</a> on <a href="https://unsplash.com/photos/a-person-writing-on-a-piece-of-paper-with-a-pen-TKk29MxSjAA?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>