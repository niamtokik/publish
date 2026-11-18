---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/sandbox1-flutter-application-design-first-steps-35ge"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fvw7tjshczer2v44d9yli.jpg"
created_at: "None"
crossposted_at: "None"
description: "Epic things start with small humble steps. Pay respect to your beginnings. And if you're just..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/sandbox1-flutter-application-design-first-steps-35ge"
public_reactions_count: "1"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "sandbox1-flutter-application-design-first-steps-35ge"
social_image: "None"
title: "Sandbox#1: Flutter Application Design First Steps"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Sandbox#1: Flutter Application Design First Steps

> Epic things start with small humble steps. Pay respect to your beginnings. And if you're just starting out, know that it's OK to be sucky. To be small. To be messy and chaotic. Just make sure to never ever stop dreaming.
>
> -- Vishen Lakhiani

Let start another chapter of this journey with Dart by creating a mobile application with [Flutter](https://flutter.dev/). For this post, a really simple application will be created called `sandbox`. Instead of adding some interactive part, like sending/receiving data from a backend, let simply design an application based on a wireframe.

# Bootstrapping

As usual, I'm using `asdf` to install Flutter on my laptop but it can also be installed manually by following the [Flutter Quick Install documentation](https://docs.flutter.dev/install/quick). This new project will be called `sandbox`, a good name for a draft.

```console
$ flutter create sandbox
Creating project sandbox...
Resolving dependencies in `sandbox`... 
Downloading packages... 
Got dependencies in `sandbox`.
Wrote 131 files.

All done!
You can find general documentation for Flutter at: https://docs.flutter.dev/
Detailed API documentation is available at: https://api.flutter.dev/
If you prefer video documentation, consider: https://www.youtube.com/c/flutterdev

In order to run your application, type:

  $ cd sandbox
  $ flutter run

Your application code is in sandbox/lib/main.dart.

$ cd sandbox
```

# Wireframe and Prototype

My career is from network and system administration, backend and distributed development, when it comes to design something, I'm thinking like a technician/engineer: I don't care about the look, it should work. In a previous publication, rock-paper-scissors data structure and primitive have been designed, why not starting with a kind of interface for this game?

![Prototype made with Figma](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/1f69igd0hrdsbrxifzzo.png)

Creating a prototype or a wireframe with Figma is painful. Really. I still don't believe such kind of "application" can be so successful. Anyway, after a long fight, and without any idea how to expert a layer correctly, I finally decided to do a screenshot of the page. Yeah. Ridiculous. If you are a developer at Figma, are you really using your software? I mean, exporting a selected area can be done quite easily with [draw.io](https://app.diagrams.net/).

Anyway, the goal here is to reproduce this with Flutter. No need for interactive feature, just a raw prototype.

# First Version

Someone said "start humble", this is the first version, with lot of duplicated code an crappy colors, but it should give the big picture of the application.

The top bar will be used for the menu, to switch to another mode or game for example. It contains the title of the current page. At this time, it will do nothing.

Then comes the opponent container. This part will be empty at first, but in the future, it could be an animated area, where the final shape of the opponent will be loaded.

The third container will contain the final result, when both players selected the shape, and the result should be displayed. If this application is used also by someone else (remotely), one player can see "loss", while the other one will see "win". If the shapes are the same, both players will see "draw".

The fourth container is where the player will select the action. Three shapes are available, rock, paper and scissors. When tapping on one of them, it will send it to a remote server (if playing against someone else), or simply update the state of the application (if playing against the machine).

Finally, the last container is the bottom bar. It will be removed in the second version because I think an user can click by mistake on one of the button instead of selecting one shape. Let begins the implementation. Nothing really fancy at first.

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}
```

The interesting part is present in `MyApp()` class where we are defining the different layer of the application.

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
          title: Text("Jan Ken Pon"),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: InkWell(
                  onTap: () {},
                  child: Ink(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.grey,
                    child: Center(child: Text("opponent choice")),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: InkWell(
                  onTap: () {},
                  child: Ink(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.amber,
                    child: Center(child: Text("result")),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Ink(
                          height: double.infinity,
                          width: double.infinity,
                          color: Colors.blue,
                          child: Center(child: Text("rock")),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Ink(
                          height: double.infinity,
                          width: double.infinity,
                          color: Colors.green,
                          child: Center(child: Text("paper")),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Ink(
                          height: double.infinity,
                          width: double.infinity,
                          color: Colors.red,
                          child: Center(child: Text("scissors")),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.star), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: "Jan Ken Pon",
            ),
          ],
        ),
      ),
    );
  }
}
```

I know, this is a disgusting piece of code. The level of indentation is insane and the duplicated code is crazy, but at least, it works. What kind of classes I used here?

- [`Scaffold`](https://api.flutter.dev/flutter/material/Scaffold-class.html) class is used to configure the visual layout. 

- [`AppBar()`](https://api.flutter.dev/flutter/material/AppBar-class.html) class is instantiated in the `Scaffold` object ([`appBar`](https://api.flutter.dev/flutter/material/Scaffold/appBar.html) attribute) and configure the top bar of the application. The menu button on the left currently don't work. The title is a simple `Text()` object;

```dart
AppBar(
  leading: IconButton(
    // ...
  ),
  title: Text(
    // ...
  ),
 )
```

- [`BottomNavigationBar`](https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html) is also instantiated in `Scaffold` in the [`bottomNavigationBar`](https://api.flutter.dev/flutter/material/Scaffold/bottomNavigationBar.html) attribute. This object is also made of a list of Widgets defined in the `items` attribute. At least 2 items must be created, in our case, two [`BottomNavigationBarItem`](https://api.flutter.dev/flutter/widgets/BottomNavigationBarItem-class.html) are created;

```dart
BottomNavigationBar(
  items: [
   BottomNavigationBarItem(
     // ...
   ),
   BottomNavigationBarItem(
     // ...
   ),
  ]
)
```

- [`Column`](https://api.flutter.dev/flutter/widgets/Column-class.html) class is used in the [`body`](https://api.flutter.dev/flutter/material/Scaffold/body.html) attribute of the `Scaffold` object. This is where the user will be able to see the actions and play with the application. A list of `Widget` can be provided using the `children` attributes, each one will divide the available space. So, in our case, we need 3 "lines", one for the opponent, one for the result and the last one for the user selection;

```dart
Column(
  children: <Widget>[
    // ...
  ]
)
```

- [`Expanded`](https://api.flutter.dev/flutter/widgets/Container-class.html) class is used on every "line" to use all the space available from each line;

```dart
Expanded(
  child: Center(
    // ...
  )
)
```

- [`Center`](https://api.flutter.dev/flutter/widgets/Center-class.html) is then used to vertically and horizontally center all elements;

```dart
Center(
  child: InkWell(
    // ...
  )
)
```

- [`InkWell`](https://api.flutter.dev/flutter/material/InkWell-class.html) classes are then used to define a place that can react to user touch, a bit like a button, but with more flexibility;

```dart
InkWell(
  onTap: () {},
  child: Ink(
    // ...
  ),
)
```

- [`Ink`](https://api.flutter.dev/flutter/material/Ink-class.html) classes are finally used to set the [`height`](https://api.flutter.dev/flutter/material/Ink/height.html), [`width`](https://api.flutter.dev/flutter/material/Ink/width.html) and [`color`](https://api.flutter.dev/flutter/material/MaterialApp/color.html) of each active elements;

```dart
Ink(
  height: double.infinity,
  width: double.infinity,
  color: Colors.amber,
  child: Center(
    // ...
  ),
)
```

- [`Row`](https://api.flutter.dev/flutter/widgets/Row-class.html) is also used for the shapes user layer, where the user can select `rock`, `paper` or `scissors`. The goal of this class is to split the available space in rows.

```dart
Row(
  children: <Widget>[
    // ...
  ]
)
```

# Conclusion

This application can be compiled and installed on the Android emulator. Here a screenshot of this first application draft from Android (API 36.0).

![Design First Version](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/b3p82ep5tl05fdfv2xhe.png)

The colors have been set simply to see where the important information will be displayed. The same colors will stay there until we have something functional.

With this first version, we also have an idea of the essential bricks we can reuse in the future. It means the next iteration will remove some part of this design, create reusable functions and likely add a bit of interactivity.

Have fun!

----

Cover Image by <a href="https://unsplash.com/@tetrakiss?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Arseny Togulev</a> on <a href="https://unsplash.com/photos/white-robot-MECKPoKJYjM?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>