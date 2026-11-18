---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/stateless-widgets-in-flutters-eaf"
comments_count: "8"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fyakj8f53g5yy6bxr3e3m.jpg"
created_at: "None"
crossposted_at: "None"
description: "Most of the blog posts and articles I've read about Stateless Widgets during the last weeks were..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/stateless-widgets-in-flutters-eaf"
public_reactions_count: "1"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "stateless-widgets-in-flutters-eaf"
social_image: "None"
title: "Stateless Widgets in Flutters"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Stateless Widgets in Flutters

Most of the blog posts and articles I've read about [Stateless Widgets](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html) during the last weeks were mostly listing the differences with the [Stateful Widgets](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html). Sadly, I was hoping to have a deep description of stateless widgets and their usage. I mean, managing state is hard, everybody knows that, and if they can avoid having dealing with any kind of state, they will do it. What kind of application can be created without any state? Could a prototype or a demo app can work with any specific state? Let find out.

# Definition

> A widget that **does not require mutable state** [...] `Stateless` widget are useful when the part of the user interface you are describing **does not depend on anything other than the configuration information in the object itself** and the `BuildContext` in which the widget is inflated.
>
> -- [StatelessWidget class](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html)

What does it mean? When an application is running, it needs to keep some state; for example, if your application is requiring credentials, it must be stored somewhere, this is a state. A [`StatelessWidget`](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html) does not care about that and can be used to modify the Flutter application tree.

- https://api.flutter.dev/flutter/widgets/Widget-class.html

- https://api.flutter.dev/flutter/widgets/Element-class.html

- https://github.com/flutter/flutter/blob/main/packages/flutter/lib/src/widgets/framework.dart#L523

- https://api.flutter.dev/flutter/foundation/Key-class.html

- https://api.flutter.dev/flutter/widgets/GlobalKey-class.html

- https://docs.flutter.dev/cookbook/navigation/navigation-basics

# Use Case

I was looking for an use case, without any state... But it seems complicated to do that. At my level of knowledge, I would said [`StatelessWidget`](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html) only application could be used to design the style of an application and the flow between the different screens. Then the data can be hardcoded in the code.

But one problem arises: how to switch between `Screen`s? We will need a `Navigator` object, and this one is based on... [`StatefulWidget`](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html)! A complete stateless application looks really hard to create right now. Let start to write the code.

```dart
import 'package:flutter/material.dart';
```

The `main()` entry-point will start the application using an `Init()` object, based on the `Init` class created just after. Why not direcly using the class `MyApp` instead? We will see that on another post, but having a first Widget before the application can be quite helpful to deal with the application state.

```dart
void main() {
  runApp(const Init());
}
```

The `Init` class extends a `StatelessWidget` and returns `MyApp()` object. Again, nothing complex there. This `Init` class could have been replaced by the `main()` entry-point.

```dart
class Init extends StatelessWidget {
  const Init({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MyApp();
  }
}
```

`MyApp` class creates a `MaterialApp` object when it is instantiated. This one will have a default route set to the `home` parameter and a list of extra-routes defined in `routes` attribute. The `Navigator` part will have its own article very soon, but the idea is to easily switch from/to different screens.

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyApp',
      home: Home(),
      routes: {
        "/blog": (BuildContext context) => BlogPage(),
        "/projects": (BuildContext context) => ProjectsPage(),
        "/about": (BuildContext context) => AboutPage()
      }
    );
  }
}
```

Because all our pages/screens will have the same `AppBar`, creating a `topBar` helper function can be helpful. The trick here is to alter the `AppBar` object returned based on the page displayed. If the current page is a reference to the active page, nothing happens, else, a new screen is opened. This is a really dirty way to deal with routes by the way, but it "works" for a cheap draft application.

```dart
AppBar topBar(BuildContext context, String active) {
  return AppBar(
      title: Text("MyApp"),
      leading: IconButton(
          onPressed: () {
            Navigator.of(context).popUntil(ModalRoute.withName('/'));
          },
          icon: Icon(
            Icons.home
          )
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (active != "blog") {
              Navigator.of(context).pushNamed("/blog");
            }
          },
          child: Text("blog")
        ),
        TextButton(
          onPressed: () {
            if (active != "projects") {
              Navigator.of(context).pushNamed("/projects");
            }
          },
          child: Text("projects")
        ),
        TextButton(
          onPressed: () {
            if (active != "about") {
              Navigator.of(context).pushNamed("/about");
            }
          },
          child: Text("about")
        ),
      ]
    );
}
```

The `Home` class displaying the home page. A list of [`ListTile`](https://api.flutter.dev/flutter/material/ListTile-class.html) is created via the `listTiles` function defined below.

```dart
class Home extends StatelessWidget {
  const Home({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topBar(context, "home"),
      body: listTiles([
        ListTile(
          leading: Icon(
            Icons.favorite
          ),
          title: Text("Title 0"),
          subtitle: Text("Subtitle 0"),
          trailing: Text("Trailing 0")
        ),
        ListTile(
          leading: Icon(
            Icons.access_time_outlined
          ),
          title: Text("Lorem ipsum dolor sit amet"),
          subtitle: Text("Tempus leo eu aenean sed diam urna tempor. Pulvinar vivamus fringilla lacus nec"),
          trailing: Text("himenaeos")
        ),
      ])
    );
  }
}
```

The `listTiles()` function is creating a [`ColoredBox()`](https://api.flutter.dev/flutter/widgets/ColoredBox-class.html) object, nothing more.

```dart
ColoredBox listTiles(List<ListTile> tiles, {Color color = Colors.white}) {
  return ColoredBox(
    color: color,
    child: Material(
      child: Column(
        children: tiles
      )
    ),
  );
}
```

The `BlogPage` class definition. Again, nothing really exciting there.

```dart
class BlogPage extends StatelessWidget {
  const BlogPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topBar(context, "blog"),
      body: Container(
        child: Padding(
          padding: .all(16.0),
          child: listTiles([
        ListTile(
          leading: Icon(
            Icons.favorite
          ),
          title: Text("Title 0"),
          subtitle: Text("Subtitle 0"),
          trailing: Text("Trailing 0")
        )])
        )
      )
    );
  }
}
```

The `ProjectsPage` class definition, quite similar to the previous one.

```dart
class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topBar(context, "projects"),
      body: Container(
        child: Text("projects")
      )
    );
  }
}
```

Finally, the `AboutPage` class definition, the last one. No surprise, tt looks like the previous.

```dart
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topBar(context, "about"),
      body: Container(
        child: Container()
      )
    );
  }
}
```

No theme, no color, nothing fancy, here. The code is working correctly on [dartpad](https://dartpad.dev/), so, if you want to modify it, you can.

![Screenshot of the final draft](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/qlbt9e6o2i5l1w1oey3k.png)

# Conclusion

Talking only about [`StatelessWidget`](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html) is perhaps not the best thing to do. In fact, using them can be quite limited without state. Maybe I still don't have enough experiences and can see more use cases though... I have even more questions than answers, for example, how to create a new [`Screen`](https://api.flutter.dev/flutter/dart-html/Screen-class.html) without a `Navigator`? After a quick research, it seems a `Screen` is a native interface, specified by the [w3c](https://www.w3.org/TR/cssom-view/#screen).

Anyway, If you want to know more about [`StatelessWidget`](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html), you can still check those links:

- [`StatelessWidget` class](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html) from Flutter API documentation;

- [How to Create Stateless Widgets](https://blog.flutter.dev/how-to-create-stateless-widgets-6f33931d859) from Flutter blog;

- [Understanding Stateless and Stateful Widgets in Flutter.](https://dev.to/shahid6289/understanding-stateless-and-stateful-widgets-in-flutter-14cp) by @shahid6289 

- [To never forget again: Stateless vs. Stateful in Flutter](https://dev.to/feministech/to-never-forget-again-stateless-vs-stateful-in-flutter-ho0) by @feministech 

- [Flutter Stateful and Stateless widgets](https://dev.to/dailydevtips1/flutter-stateful-and-stateless-widgets-3bnh) by @dailydevtips1 

- [Flutter: Difference Between Stateful and Stateless Widget](https://dev.to/iqrafatimame/flutter-difference-between-stateful-and-stateless-widget-54le) by @iqrafatimame 

- [Best practices for using StatelessWidget in Flutter](https://colinchflutter.github.io/2023-09-24/15-34-28-643008-best-practices-for-using-statelesswidget-in-flutter/) by colinchflutter on Github;

- [Stateless Widgets in Flutter](https://gist.github.com/theailanguage/1e631bf0d4d3b2966a53bbbf094ad334) on Gist;

- [Stateless Flutter](https://medium.com/@eggzotic/stateless-flutter-2e14b6ae30b5) by [eggzotic](https://medium.com/@eggzotic) on Medium;

- [`flutter_create_stateless`](https://github.com/eggzotic/flutter_create_stateless) repository on Github;

- [Flutter Stateless Widget – Adding interactivity To Your Application](https://bosctechlabs.com/flutter-stateless-widget-adding-interactivity-to-your-application/) by BOSC Lab;

- [Guide to Flutter Stateless Widget
](https://medium.com/@letmeflutter123/guide-to-flutter-stateless-widget-ee11d9d23375) by [Zeeshan Ali](https://medium.com/@letmeflutter123) on Medium;

- [Is it Stateful? Is it Stateless? A guide for choosing widget in flutter](https://medium.com/flutter-tips/is-it-stateful-is-it-stateless-a-guide-for-choosing-widget-in-flutter-b92c2283c813) by [Mario Gunawan](https://medium.com/@mario-gunawan) on Medium;

- [Stateful and Stateless Widget Flutter Example](https://github.com/myvsparth/stateless_stateful) on Github;

- [Using widgets wisely (Stateless vs Stateful) in Flutter App Development](https://medium.com/@shresthabwes/using-widgets-wisely-stateless-vs-stateful-in-flutter-app-development-3191ab08e20d) by [Shresthabwes](https://medium.com/@shresthabwes) on Medium

- [Stateless Widget in flutter](https://medium.com/@appdevinsights/stateless-widget-in-flutter-c3fa3c845859) by [App Dev Insights](https://medium.com/@appdevinsights) on Medium

- [Designing Screens & Widgets In Flutter
](https://dev.to/kcl/designing-screens-in-flutter-4nn1) by @kcl 

- [Stateless widget example](https://gist.github.com/jamiecollinson/27a78ca05e168ffc483a587a98de3d0d) on Gist

- [Flutter demo card using proper stateless widget extraction](https://gist.github.com/chaadow/ffdd0af107fa2442d9da9a5e62beb5b7) on Gist.


Nothing to add there, just... Hack well and Have fun!

----

Cover Image by <a href="https://unsplash.com/@enginakyurt?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">engin akyurt</a> on <a href="https://unsplash.com/photos/a-tall-glass-sitting-on-top-of-a-table-fiN073Jt5L8?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>