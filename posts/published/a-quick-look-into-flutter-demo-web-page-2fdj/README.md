---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/a-quick-look-into-flutter-demo-web-page-2fdj"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2F6d3bpksen7bpic2fvrmj.jpg"
created_at: "None"
crossposted_at: "None"
description: "On the previous post, I was simply creating a new Flutter web application project using their default..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/a-quick-look-into-flutter-demo-web-page-2fdj"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "a-quick-look-into-flutter-demo-web-page-2fdj"
social_image: "None"
title: "A Quick Look into Flutter Demo Web Page"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# A Quick Look into Flutter Demo Web Page

On the previous post, I was simply creating a new Flutter web application project using their default template. It's a simple way to learn the basic commands and already have an idea where all the artifacts are stored. Not really interesting though, no code, no modification, just few shell commands executed.

Dart/Flutter main entry point can be found in `lib/main.dart`, at this time, it only contains code from the template (comments were removed). Let explain each blocks.

```dart
import 'package:flutter/material.dart';
```

Flutter is using Dart, and Dart has a modular approach like many modern languages. Public [packages](https://dart.dev/tools/pub/packages) can be found on [pub.dev](https://pub.dev/). Here, the application is looking for the flutter/[`material`](https://api.flutter.dev/flutter/material/) library. [Material](https://m3.material.io/) is a design system/library and will be used for all the front-end UI/UX thingies.

```dart
void main() {
  runApp(const MyApp());
}
```

In Dart, the function entry-point is called `main()` and - currently - can't be changed but using another file as entry-point can be done using `flutter run -t lib/other_file.dart`. Anyway, this snippet call the [`runApp()`](https://api.flutter.dev/flutter/widgets/runApp.html) function coming directly from Flutter. Its argument is a [`Widget` object](https://api.flutter.dev/flutter/widgets/Widget-class.html) containing elements of the page. In our case `MyApp()` is an object created using `MyApp` class defined below.

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(
        title: 'Flutter Demo Home Page'
      ),
    );
  }
}
```

`MyApp` class extends the Flutter [`StatelessWidget`](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html) class. First, let try to understand what `extends` mean in this context. From the [dart documentation](https://dart.dev/language/extend), `extends` creates a subclass, it will then inherit methods and attributes from the main class and give the ability to add new methods and/or attributes to it. Here, `MyApp` will extend the `StatelessWidget` class.

> A stateless widget is a widget that describes part of the user interface by building a constellation of other widgets that describe the user interface more concretely [...] For compositions that can change dynamically, e.g. due to having an internal clock-driven state, or depending on some system state, consider using `StatefulWidget`.
> -- [Flutter StatelessWidget class](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html)

The next part of the class definition overrides the [`build()`](https://api.flutter.dev/flutter/widgets/StatelessWidget/build.html) method, used to describe the user interface represented by the widget. The [`@override`](https://dart.dev/language/extend#overriding-members) annotation is used to override the instance method. This method must return a Widget object, in this case, the template is using the [`MaterialApp`](https://api.flutter.dev/flutter/material/MaterialApp-class.html) class as object constructor, mostly used to configure and wrap many required values from Material Design applications.

> A convenience widget that wraps a number of widgets that are commonly required for Material Design applications [...] The MaterialApp configures the top-level Navigator to search for routes.
> -- [Flutter MaterialApp class](https://api.flutter.dev/flutter/material/MaterialApp-class.html)

Three attributes/arguments are passed to the constructor:

- [`title`](https://api.flutter.dev/flutter/material/MaterialApp/title.html) attribute set the title of the page;

- [`theme`](https://api.flutter.dev/flutter/material/MaterialApp/theme.html) attribute set the theme of the page (color, fonts and shapes);

- [`home`](https://api.flutter.dev/flutter/material/MaterialApp/home.html) attribute configure the default route of the application. This parameter is configured in the next paragraph.

```dart
class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title
  });
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
```

`MyHomePage` class is extending [`StatefulWidget`](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html) class. Like for the StatelessWidget class, this is a container, but this time, with mutable properties. Here the syntax can be a bit confusing, the `const MyHomePage()` part is a [constant constructor](https://dart.dev/language/constructors#constant-constructors) where `super.key` is the [`key`](https://api.flutter.dev/flutter/widgets/Widget/key.html) property from the `Widget` class and `this.title` is the [`title`]() property defined in `MyApp` class.

Finally, this snippet override [`createState()`](https://api.flutter.dev/flutter/widgets/StatefulWidget/createState.html) method, and returns a custom object from `_MyHomePageState()` defined below. Few notes from the documentation:

> Creates the mutable state for this widget at a given location in the tree. Subclasses should override this method to return a newly created instance of their associated State subclass.
> -- [Flutter StatefulWidget createState](https://api.flutter.dev/flutter/widgets/StatefulWidget/createState.html) method

```dart
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _incrementCounter() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

The last class implemented there is `_MyHomePageState` extending the class [`State`](https://api.flutter.dev/flutter/widgets/State-class.html). Managing states in Dart/Flutter seems to be quite... complex. Firstly, it could be great to explain the syntax of `State<MyHomePage>` in the class definition. This part means the subtype must be using `MyHomePage` type, this is called [parameterized type](https://dart.dev/language/generics#restricting-the-parameterized-type).

Two local definitions are then created, the `_counter` attribute, used to store the number of time someone clicked on a button and `_incrementCounter()` method, incrementing `_counter` attribute. `_` (underscore) here is not only a convention, but makes those private (based on [stack overflow answer](https://stackoverflow.com/questions/53142171/what-does-underscore-before-variable-name-mean-for-flutter)) and from the documentation:

> Unlike Java, Dart doesn't have the keywords `public`, `protected`, and `private`. If an identifier starts with an underscore (`_`), it's **private to its library**. For details, see [Libraries and imports](https://dart.dev/language/libraries). Identifiers can start with a letter or underscore (`_`), followed by any combination of those characters plus digits.
> -- [Dart Important Concepts](https://dart.dev/language#important-concepts)

Finally, the last part of code to explain is the redefinition of `build()` method from the [`StatefulWidget`](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html) class. This time, this method return a [`Scaffold`](https://api.flutter.dev/flutter/material/Scaffold-class.html) object, from the documentation:

> Implements the basic Material Design visual layout structure. This class provides APIs for showing drawers and bottom sheets.
> -- [Flutter Documentation Scaffold class](https://api.flutter.dev/flutter/material/Scaffold-class.html)

It seems pretty clear this is the place where all the magic happens. The `Scaffold` object generated will be in charge to create an [`AppBar`](https://api.flutter.dev/flutter/material/AppBar-class.html), deal with the page [`body`](https://api.flutter.dev/flutter/material/Scaffold/body.html) using a [`Center`](https://api.flutter.dev/flutter/widgets/Center-class.html) object and add a button using a [`FloatingActionButton`](https://api.flutter.dev/flutter/material/FloatingActionButton-class.html) object. The final result when this code is executed can be seen in the screenshot below.

![Flutter Demo Page](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/jxlhu6zp42hryz2u4k7c.png)

Now, few remarks regarding Dart and Flutter syntax. Variables, attributes, methods and/or functions can be used in string using `$` (dollar) symbol, like mentioned in the core documentation:

> You can use ${} to interpolate the value of Dart expressions within strings. The curly braces can be omitted when evaluating identifiers:
> -- [String class](https://api.dart.dev/dart-core/String-class.html)

It looks like a constant can be used simply by using its name without its class origin like in `.center`. It should be equivalent to [`MainAxisAlignment.center`](https://api.flutter.dev/flutter/rendering/MainAxisAlignment.html). I always found this kind of syntax highly confusing, with the same level of confusion than `this` and `super`.

The end of the file has been reached. Dart and Flutter are interesting, but the object paradigm is still a big mess with lot of implicit reference, mostly due to the syntax. Anyway, when one is coming from functional programming and in particular Erlang/Elixir/Prolog, it's hard to deal with this kind of philosophy.

----

Cover Image by <a href="https://unsplash.com/@visualsbyroyalz?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Anastase Maragos</a> on <a href="https://unsplash.com/photos/black-and-brown-dart-board-X4zx5Vc_LZU?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>