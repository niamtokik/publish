---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/arguments-parsing-in-dart-jc1"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fhl12s81vnqi698y743eb.jpg"
created_at: "None"
crossposted_at: "None"
description: "This is a quick and dirty note about parsing command line arguments in Dart. If you are familiar with..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/arguments-parsing-in-dart-jc1"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "arguments-parsing-in-dart-jc1"
social_image: "None"
title: "Arguments Parsing in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Arguments Parsing in Dart

This is a quick and dirty note about parsing command line arguments in Dart. If you are familiar with C programming, you should already know the [`getopt`](https://manpages.debian.org/trixie/manpages-dev/getopt.3.en.html) function, or if you are doing a bit of shell scripting, the [`getopt`](https://manpages.debian.org/trixie/util-linux/getopt.1.en.html) command. In Dart, the main package to do that is called [`args`](https://pub.dev/packages/args) and it is maintained by the Dart team. The [API documentation](https://pub.dev/documentation/args/latest/) is containing examples and the descriptions of the difference classes to use. The source code is available on [dart-lang/core](https://github.com/dart-lang/core/tree/main/pkgs/args) repository at Github. Another package called [`capp`](https://pub.dev/packages/capp) is regrouping a lot of feature in one single module, including interactive console. We will not talk about this one today.

```console
$ dart create arg_parse
Creating arg_parse using template console...

  .gitignore
  analysis_options.yaml
  CHANGELOG.md
  pubspec.yaml
  README.md
  bin/arg_parse.dart
  lib/arg_parse.dart
  test/arg_parse_test.dart

Running pub get...                     0.3s
  Resolving dependencies...
  Downloading packages...
  Changed 48 dependencies!
  1 package has newer versions incompatible with dependency constraints.
  Try `dart pub outdated` for more information.

Created project arg_parse in arg_parse! In order to get started, run the following commands:

  cd arg_parse
  dart run

$ cd arg_parse

$ dart pub add args
Resolving dependencies... 
Downloading packages... 
  args 2.7.0 (from transitive dependency to direct dependency)
  package_config 2.2.0 (3.0.0 available)
Changed 1 dependency!
1 package has newer versions incompatible with dependency constraints.
Try `dart pub outdated` for more information.
```

Let modify the entry-point in `bin/arg_parse.dart` and imports `args.dart` module.

```dart
import 'package:args/args.dart';
```

# Parsing

Parsing a command line with the `args` package is simple. The first step is to instantiate a new [`ArgParser`](https://pub.dev/documentation/args/latest/args/ArgParser-class.html) object where all the parsing logic will be stored. The [constructor](https://pub.dev/documentation/args/latest/args/ArgParser/ArgParser.html) can deal with trailing options via the `allowTrailingOptions` parameter.

```dart
var parser = ArgParser(
  allowTrailingOptions: true
);
```

This newly created object defines 4 type of arguments when it comes to parse data:

- Commands are special keywords which can become subcommands with their own arguments and options. Those are created with the [`addCommand`](https://pub.dev/documentation/args/latest/args/ArgParser/addCommand.html) method;

- Flags are boolean key, if a flag is present, it will exist in the parsed result. Flags can be created with the [`addFlag`](https://pub.dev/documentation/args/latest/args/ArgParser/addFlag.html) method;

- Options are key/value arguments, they can be created with the [`addOption`](https://pub.dev/documentation/args/latest/args/ArgParser/addOption.html) method;

- Multi Options are multi key/value arguments, it means this kind of argument can be seen many time. a Multi Option can be created with [`addMultiOption`](https://pub.dev/documentation/args/latest/args/ArgParser/addMultiOption.html) method;

The best way to learn is to try. Let  reproduce a small subset of the arguments defined by [`curl`](https://manpages.debian.org/trixie/curl/curl.1.en.html) using the `args` package:

- [`--compressed`](https://manpages.debian.org/trixie/curl/curl.1.en.html#compressed): flag with long argument only;

```dart
parser.addFlag(
  'compressed',
  help: '(HTTP) Request a compressed response using one of the algorithms curl supports, and automatically decompress the content.',
  defaultsTo: false
);
```

- [`--connect-timeout <seconds>`](https://manpages.debian.org/trixie/curl/curl.1.en.html#connect): option with long argument only and accepting positive decimal values;

```dart
parser.addOption(
  'connect-timeout',
  help: 'Maximum time in seconds that you allow curl\'s connection to take. This only limits the connection phase, so if curl connects within the given period it continues - if not it exits.',
  defaultsTo: 0,
  valueHelp: 'timeout'
);
```

- [`-c, --cookie-jar <filename>`](https://manpages.debian.org/trixie/curl/curl.1.en.html#c,): option with short and long arguments, only accepting filename;

```dart
parser.addOption(
  'cookie-jar',
  help: '(HTTP) Specify to which file you want curl to write all cookies after a completed operation.',
  abbr: 'c',
  valueHelp: 'filename'
);
```

- [`-v, --verbose`](https://manpages.debian.org/trixie/curl/curl.1.en.html#v,): short and long flag with short floag repetition feature (`-vvvv`);

```dart
parser.addMultiOption(
  'verbose',
  help: 'Make curl output verbose information during the operation. Useful for debugging and seeing what\'s going on under the hood.',
  abbr: 'v',
  splitCommas: false,
  allowed: null,
  defaultsTo: null
);
```

- [`-V, --version`](https://manpages.debian.org/trixie/curl/curl.1.en.html#V,): short and long flag only argument.

```dart
parser.addFlag(
  'version',
  help: 'Display information about curl and the libcurl version it uses.',
  abbr: 'V',
  defaultsTo: false
);
```

At this time, it is possible to display the usage via the [`usage`](https://pub.dev/documentation/args/latest/args/ArgParser/usage.html) property. Let put everything in a function and simply print the usage to see what will happen.

```dart
ArgParser createParser() {
  final parser = ArgParser();

  parser.addFlag(
    'help',
    help: 'print usage',
    abbr: 'h',
    defaultsTo: false
  );

  parser.addFlag(
    'compressed',
    help: '(HTTP) Request a compressed response using one of the algorithms curl supports,'
      'and automatically decompress the content.',
    defaultsTo: false
  );

  parser.addOption(
    'connect-timeout',
    help: 'Maximum time in seconds that you allow curl\'s connection to take. '
      'This only limits the connection phase, so if curl connects within the '
      'given period it continues - if not it exits.',
    valueHelp: 'timeout'
  );

  parser.addOption(
    'cookie-jar',
    help: '(HTTP) Specify to which file you want curl to write all cookies after '
      'a completed operation.',
    abbr: 'c',
    valueHelp: 'filename'
  );

  parser.addMultiOption(
    'verbose',
    help: 'Make curl output verbose information during the operation. '
      'Useful for debugging and seeing what\'s going on under the hood.',
    abbr: 'v',
    splitCommas: false,
    allowed: null,
    defaultsTo: []
  );

  parser.addFlag(
    'version',
    help: 'Display information about curl and the libcurl version it uses.',
    abbr: 'V',
    defaultsTo: false
  );

  return parser;
}
```

```dart
void main(List<String> arguments) {                 
  final parser = createParser();                                                                         
  print(parser.usage);                              
}
```

```console
$ dart run bin/arg_parse.dart 
-h, --[no-]help                    print usage
    --[no-]compressed              (HTTP) Request a compressed response using one of the algorithms curl supports,and automatically decompress the content.
    --connect-timeout=<timeout>    Maximum time in seconds that you allow curl's connection to take. This only limits the connection phase, so if curl connects within the given period it continues - if not it exits.
-c, --cookie-jar=<filename>        (HTTP) Specify to which file you want curl to write all cookies after a completed operation.
-v, --verbose                      Make curl output verbose information during the operation. Useful for debugging and seeing what's going on under the hood.
-V, --[no-]version                 Display information about curl and the libcurl version it uses.
```

Interesting, but not really useful. Let parse the arguments directly using the [`parse()`](https://pub.dev/documentation/args/latest/args/ArgParser/parse.html) method. It will return a [`ArgResults`](https://pub.dev/documentation/args/latest/args/ArgResults-class.html) object in case of success. For debugging purpose, let creates a new function called `showParser()` to show the data stored in the `ArgResults` object.

```dart
void showResults(ArgResults result) {
  print("arguments: ${result.arguments}");
  print("help: ${result.flag('help')}");
  print("compressed: ${result.flag('compressed')}"); 
  print("connect-timeout: ${result.option('connect-timeout')}");
  print("cookie-jar: ${result.option('cookie-jar')}");
  print("verbose: ${result.multiOption('verbose')}");
  print("version: ${result.flag('version')}");
}
```

We can now modify our `main()` entry-point function.

```dart
void main(List<String> arguments) {
  final parser = createParser();
  ArgResults results = parser.parse(arguments);                                                          
  showResults(results);
}
```

Great, it's time to play with our application.

```console
$ dart run bin/arg_parse.dart 
arguments: []
help: false
compressed: false
connect-timeout: null
cookie-jar: null
verbose: []
version: false

$ dart run bin/arg_parse.dart -h
arguments: [-h]
help: true
compressed: false
connect-timeout: null
cookie-jar: null
verbose: []
version: false

$ dart run bin/arg_parse.dart --help
arguments: [--help]
help: true
compressed: false
connect-timeout: null
cookie-jar: null
verbose: []
version: false

$ dart run bin/arg_parse.dart --compressed
arguments: [--compressed]
help: false
compressed: true
connect-timeout: null
cookie-jar: null
verbose: []
version: false

$ dart run bin/arg_parse.dart --connect-timeout 10
arguments: [--connect-timeout, 10]
help: false
compressed: false
connect-timeout: 10
cookie-jar: null
verbose: []
version: false

$ dart run bin/arg_parse.dart --cookie-jar ./test.txt
arguments: [--cookie-jar, ./test.txt]
help: false
compressed: false
connect-timeout: null
cookie-jar: ./test.txt
verbose: []
version: false

$ dart run bin/arg_parse.dart -c ./test.txt
arguments: [-c, ./test.txt]
help: false
compressed: false
connect-timeout: null
cookie-jar: ./test.txt
verbose: []
version: false

$ dart run bin/arg_parse.dart -v
Unhandled exception:
FormatException: Missing argument for "-v".
#0      Parser._validate (package:args/src/parser.dart:324:7)
#1      Parser._readNextArgAsValue (package:args/src/parser.dart:128:5)
#2      Parser._handleSoloOption (package:args/src/parser.dart:163:7)
#3      Parser._parseSoloOption (package:args/src/parser.dart:146:12)
#4      Parser.parse (package:args/src/parser.dart:89:11)
#5      ArgParser.parse (package:args/src/arg_parser.dart:362:42)
#6      main (file:///home/user/tmp/dart/arg_parse/bin/arg_parse.dart:5:31)
#7      _delayEntrypointInvocation.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:312:33)
#8      _RawReceivePort._handleMessage (dart:isolate-patch/isolate_patch.dart:193:12)

$ dart run bin/arg_parse.dart -V
arguments: [-V]
help: false
compressed: false
connect-timeout: null
cookie-jar: null
verbose: []
version: true
```

As you can see, the `--verbose` multi option is crashing. The main is reason is because a MultiOption should always have a value, the same command will pass if we add more `v`.

```console
$ dart run bin/arg_parse.dart -vvvv
arguments: [-vvvv]
help: false
compressed: false
connect-timeout: null
cookie-jar: null
verbose: [vvv]
version: false
```

Well, it seems the Multi Option is not the good one to use for it and I'm currently not sure if it could be correctly supported with the `args` package, perhaps adding `addMultiFlag` methods could help. Too much work for this post, maybe for another one. Right now, let convert this argument to a simple Flag.

```dart
  parser.addFlag(
    'verbose',
    help: 'Make curl output verbose information during the operation. '
      'Useful for debugging and seeing what\'s going on under the hood.',
    abbr: 'v'
  );
```

# Validation

It is possible to validate every arguments using a `callback` function, but the document recommend to avoid doing that.

> The callback argument is invoked with the option's value when the option is parsed. Note that this makes argument parsing order-dependent in ways that are often surprising, and its use is discouraged in favor of reading values from the `ArgResults`.

The validation of each parsed values should be done outside of the parser and probably result in a new specific objects containing the valid values.

Data validation and sanitization in Dart will be the main subject of another article, so, we will see that later!

# Conclusion

The [`args`](https://pub.dev/packages/args) package is doing the job for most of the common use case, but in some situation where you will need a custom way to parse arguments, another solution will probably be required. Anyway, Dart was not created to deal with command line tools, and this package will probably fit in all your small projects, even like a small web server. Here a list of interesting resources:

- [Commands Dispatch](https://pub.dev/packages/args#dispatching-commands) can be used to create subcommands;

- [`args package](https://pub.dev/packages/args) show a complete use case with good examples, a must read;

- [`args` API documentation](https://pub.dev/documentation/args/latest/) is complete, as usual;

- [`pkgs/args/example/arg_parser/example.dart`](https://github.com/dart-lang/core/blob/main/pkgs/args/example/arg_parser/example.dart) example from the `dart-lang/core` repository show mostly all parser use case, you'll like it.


Hack well and have fun!

----

Cover Image by <a href="https://unsplash.com/@zoeey97?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Zoha Gohar</a> on <a href="https://unsplash.com/photos/two-crows-silhouetted-against-a-blue-spotlight-rf2Z1dsQCT4?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>