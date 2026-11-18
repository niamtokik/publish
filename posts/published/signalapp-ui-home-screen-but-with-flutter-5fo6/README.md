---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/signalapp-ui-home-screen-but-with-flutter-5fo6"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2F75u2wckknvjv28p0sjrx.jpg"
created_at: "None"
crossposted_at: "None"
description: "He who can copy can do. -- Leonardo Da Vinci   My UI skill is very low, I'm not really good with..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/signalapp-ui-home-screen-but-with-flutter-5fo6"
public_reactions_count: "1"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "signalapp-ui-home-screen-but-with-flutter-5fo6"
social_image: "None"
title: "SignalApp UI Home Screen but with Flutter"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# SignalApp UI Home Screen but with Flutter

> He who can copy can do.
> -- Leonardo Da Vinci

My UI skill is very low, I'm not really good with colors or themes and it's always a pain to design a full interface by myself... In short: I'm not an artist and it needs to be fixed. [SignalApp](https://signal.org/download/) is one of my main messenger, the interface is simple and functional. The application source code is also available on [Github](https://github.com/signalapp), and the Android application is using Material3. I think it can be a good target.

![SignalApp Screenshot from appgefahren.de](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/164ka5pkn9pbhnbkssgs.png)

Trying to reproduce it completely will take a while, only a small subset of the interface will be re-implemented, the home and the user chat screens, both can be seen from the screenshot above.

# Home Screen

> Good artists copy, great artists steal.
> -- Pablo Picasso

The Home screen will be the entry-point of the application, where the active conversations can be seen by the user. It is also the place where [SignalApp](https://signal.org/) can be configured, when tapping on the User avatar on the top left of the application, a [Drawer](https://api.flutter.dev/flutter/material/Drawer-class.html) menu should open. This menu is not displayed on the screenshot, then, only an empty one will be created.

![Top part of the Home Screen](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/qwexdjbot5qn2x8ntrjj.png)

The first easily identifiable element of the application is the top bar. I will assume this one can be created with the help of the [`AppBar`](https://api.flutter.dev/flutter/material/AppBar-class.html) class, where the `leading` parameter will contain the user picture (rounded). This element can be created with a [`CircleAvatar`](https://api.flutter.dev/flutter/material/CircleAvatar-class.html) class. The `title` parameter will display the text "Signal" in bold, a [`TextStyle`](https://api.flutter.dev/flutter/painting/TextStyle-class.html) class can be set properly inside the [`Text`](https://api.flutter.dev/flutter/widgets/Text-class.html) class [`style`](https://api.flutter.dev/flutter/widgets/Text/style.html) attribute. The parameters `actions` will be set with 2 icons, one icon will represent a camera with [`Icons.camera`](https://api.flutter.dev/flutter/cupertino/CupertinoIcons/camera-constant.html) and the last one will represent a pencil using the [`pencil`](https://api.flutter.dev/flutter/cupertino/CupertinoIcons/pencil-constant.html) constant. Finally, the background color of this element is grey (`#fafafa`).

```dart
AppBar homeBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.grey[50],
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold
    ),
    leading: Padding(
      padding: EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor: Colors.amber,
        child: Text('AH')
      ),
    ),
    title: Center(child: Text('SignalCopyCat')),
    actions: [
      IconButton(
        onPressed: () {}, 
        icon: Icon(Icons.camera_alt_outlined)
      ),
      IconButton(
        onPressed: () {},
        icon: Icon(Icons.edit_outlined)
      ),
    ],
  );
}
```

The top Bar using by Signal is not the most challenging part of the design, at least, when we don't have state to manage. The `homeBar()` function created above is returning an [`AppBar()`](https://api.flutter.dev/flutter/material/AppBar-class.html) object with some custom parameters.

The [`backgroundColor`](https://api.flutter.dev/flutter/material/AppBar/backgroundColor.html) parameter is set to [`grey`](https://api.flutter.dev/flutter/material/Colors/grey-constant.html). The [`titleTextStyle`](https://api.flutter.dev/flutter/material/AppBar/titleTextStyle.html) parameter has been set with a custom [`Color`](https://api.flutter.dev/flutter/dart-ui/Color-class.html) and [`FontWeight`](https://api.flutter.dev/flutter/dart-ui/FontWeight-class.html), this should be applied on the rest of the widgets instantiated below this bar.

The [`leading`](https://api.flutter.dev/flutter/material/AppBar/leading.html) parameter (the right part of the bar) is using a [`Padding`](https://api.flutter.dev/flutter/widgets/Padding-class.html) widget to reduce the side of its child element with the help of an [`EdgeInsets`](https://api.flutter.dev/flutter/painting/EdgeInsets-class.html) object. The offset configured (`8.0`) is applied on all sides, thanks to the [`EdgeInsets.all()`](https://api.flutter.dev/flutter/painting/EdgeInsets/EdgeInsets.all.html) constructor. Its only child is [`CircleAvatar`](https://api.flutter.dev/flutter/material/CircleAvatar-class.html) widget containing only the initials of the users as a [`Text()`](https://api.flutter.dev/flutter/widgets/Text-class.html) widget.

The [`title`](https://api.flutter.dev/flutter/material/AppBar/title.html) parameter is only containing the title of the application as in a [`Text()`](https://api.flutter.dev/flutter/widgets/Text-class.html) object, centered via a [`Center()`](https://api.flutter.dev/flutter/widgets/Center-class.html) widget.

The [`actions`](https://api.flutter.dev/flutter/material/AppBar/actions.html) parameter is using a list of [`IconButton`](https://api.flutter.dev/flutter/material/IconButton-class.html) widget, which one set with an [`Icon()`](https://api.flutter.dev/flutter/widgets/Icon-class.html). The number of icons available with Material is astonishing... I took me a moment to find what I was looking for, [`Icons.camera_alt_outlined`](https://api.flutter.dev/flutter/material/Icons/camera_alt_outlined-constant.html) for the camera and [`Icons.edit_outlined`](https://api.flutter.dev/flutter/material/Icons/edit_outlined-constant.html) for the pencil. Other icons can also be used via the [`CubertinoIcons`](https://api.flutter.dev/flutter/cupertino/CupertinoIcons-class.html) class (usually designed for iOS though).

No callback functions have been set in the `onPressed` parameters, this is not the goal of this article.

![Middle and bottom part of the Home screen](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/vodmhogim052xt2m5fwa.png)

The next big part of the Home screen is taking the remaining place. This section can be scrolled. It is made of many similar elements probably derived from a [`ListTile`](https://api.flutter.dev/flutter/material/ListTile-class.html) class. Those are split in 3 part, from the left to the right, the first part is an icon containing a picture of a remote user where we can reuse the [`CircleAvatar`](https://api.flutter.dev/flutter/material/CircleAvatar-class.html) class. The second part contains the name of the user (in bold) above the last messages (if any). The last part contains the date of the last message received (with an attachment or an acknowledgement if any). When the user is tapping on one of these elements, it is redirected to a Chat Screen. The background color of this part of the application is white (`#ffffff`).

```dart
String initials(String str) {
  return str
    .split(" ")
    .map((x) => x.isEmpty ? "?" : x[0])
    .take(2)
    .join("");
}
```

Firstly, I think creating a function to convert a first name and last name (or any kind of string) to their initials can be helpful for the next part. This is a quick and dirty implementation, the string must be sanitized first and only characters (including UTF8 characters) should be used. It will do the job for know though, it could be nice to see what kind of algorithm SignalApp is using, I think the [`getAbbreviation()`](https://github.com/signalapp/Signal-Android/blob/c8d2a06676fa3aaee16aa1ca250ffed352f0e5ba/app/src/main/java/org/thoughtcrime/securesms/util/NameUtil.kt#L18) method  from [`org.thoughtcrime.securesms.util.NameUtil`](https://github.com/signalapp/Signal-Android/blob/c8d2a06676fa3aaee16aa1ca250ffed352f0e5ba/app/src/main/java/org/thoughtcrime/securesms/util/NameUtil.kt) is the one we are looking for.

```dart
ListTile tile({
  String? title,
  String? subtitle,
  String? trailing,
  MaterialColor? avatarColor,
  String? notifications,
  bool? received,
}) {
  return ListTile(
    leading: Badge(
      label: Text(notifications ?? "0"),
      isLabelVisible: notifications == null ? false : true,
      textColor: Colors.white,
      backgroundColor: Colors.blue,
      child: CircleAvatar(
        backgroundColor: avatarColor ?? Colors.amber,
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: Text(title == null ? "??" : initials(title)),
        ),
      ),
    ),
    title: Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            title ?? "John Smith",
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Roboto")
            )
          ),
        Align(
          alignment: Alignment.topRight,
          child: Text(
            trailing ?? "11:11 AM",
            style: notifications != null 
              ? TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: "Roboto")
              : TextStyle(fontWeight: FontWeight.normal, fontSize: 12, fontFamily: "Roboto"),
          ),
        ),
      ],
    ),
    subtitle: Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            subtitle ?? "Last message...",
            overflow: TextOverflow.ellipsis,
            style: notifications != null 
              ? TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: "Roboto")
              : TextStyle(fontWeight: FontWeight.normal, fontSize:14, fontFamily: "Roboto")
          ),
        ),
        received == true
            ? Icon(Icons.library_add_check_rounded, size: 16)
            : Container(),
      ],
    ),
    onTap: () {},
  );
}
```

Another function helper called `tile()` will help us to generate each [`ListTile()`](https://api.flutter.dev/flutter/material/ListTile-class.html) objects. This function can take 6 optional arguments, if those are not set, some default values are used instead.

The [`leading`](https://api.flutter.dev/flutter/material/ListTile/leading.html) parameter is containing the user avatar, material gives us the [`Badge()`](https://api.flutter.dev/flutter/material/Badge-class.html) object to deal with that. This one contains a [`label`](https://api.flutter.dev/flutter/material/Badge/label.html) (the blue circle containing the number of notifications). I tried to add a white border on this label, without success, perhaps my future me will fix that. If there is no notification, the [`isLabelVisible`](https://api.flutter.dev/flutter/material/Badge/isLabelVisible.html) parameter can be set to `false`, in this case, the label will be removed. The only child is a [`CircleAvatar`](https://api.flutter.dev/flutter/material/CircleAvatar-class.html) using a specific [`BoxDecoration`](https://api.flutter.dev/flutter/painting/BoxDecoration-class.html) to produce a circle via [`BoxShape.circle`](https://api.flutter.dev/flutter/painting/BoxShape.html#circle). By default, the initials of the `title` variable will be used.

Regarding badges, 2 modules can probably fix most of my issues here:

- [`info_label`](https://pub.dev/packages/info_label): A high-performance Flutter label widget built on CustomPainter. Background, border, text, and overlay indicators are painted directly on canvas for minimal widget overhead;

- [`badges`](https://pub.dev/packages/badges): A package for creating badges. Badges can be used for an additional marker for any widget, e.g. show a number of items in a shopping cart.

The [`title`](https://api.flutter.dev/flutter/material/ListTile/title.html) parameter was configured to set the user name on the left and the date on the right. I thought at first I could use the [`trailing`](https://api.flutter.dev/flutter/material/ListTile/trailing.html) parameter to do that, but it was kinda messy, and way more complex. Anyway, a [`Flex`](https://api.flutter.dev/flutter/widgets/Flex-class.html) widget is used to let us have a flexible positioning across the elements. Indeed, we want the widgets on an horizontal Axis (see [`Axis.horizontal`](https://api.flutter.dev/flutter/painting/Axis.html#horizontal)) with a space between them (see [`MainAxisAlignment.spaceBetween`](https://api.flutter.dev/flutter/rendering/MainAxisAlignment.html#spaceBetween)). Then the 2 widgets children can be aligned using the [`Alignment.topLeft`](https://api.flutter.dev/flutter/painting/Alignment/topLeft-constant.html) and [`Alignment.topRight`](https://api.flutter.dev/flutter/painting/Alignment/topRight-constant.html) constants. Nothing smart here, both of them are [`Text()`](https://api.flutter.dev/flutter/widgets/Text-class.html) widgets. 

The [`subtitle`](https://api.flutter.dev/flutter/material/ListTile/subtitle.html) is using the same hack than the `title` parameter previously described. An element to left (last message from the remote user) and another one to the right (message ack).

`onTap` is not configured yet, but the idea when someone is tapping on one tile, he will be redirected to the chat screen.

```dart
class Conversations extends StatelessWidget {
  const Conversations({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        tile(
          avatarColor: Colors.blueGrey,
          title: "Tina Ukuku",
          subtitle: "You set disappearing message time to 1...",
          avatarText: "TU",
        ),
        tile(
          avatarColor: Colors.indigo,
          title: "Chairman Meow",
          subtitle: "Missed call",
          avatarText: "CM",
          notifications: "2",
        ),
        tile(
          avatarColor: Colors.lightGreen,
          title: "Myles Larson",
          subtitle: "🎤 Voice Message",
          trailing: "11:07 AM",
          notifications: "7",
        ),
        tile(
          avatarColor: Colors.lime,
          title: "Cat Chat 🐈 🐱",
          subtitle: "This is the instruction manual. 📎 Attachment",
          trailing: "11:02 AM",
        ),
        tile(
          avatarColor: Colors.blueGrey,
          title: "Ali Smith",
          subtitle: "📷 Attachment",
          trailing: "10:38 AM",
          received: true,
        ),
        tile(
          avatarColor: Colors.indigo,
          title: "Kirk Family",
          subtitle: "Happy birthday to you. Happy birthday to you!",
          trailing: "9:13 AM",
          notifications: "1",
        ),
        tile(
          avatarColor: Colors.lightGreen,
          title: "Jordan B.",
          subtitle: "Sticker Message",
          received: true,
        ),
        tile(
          avatarColor: Colors.lime,
          title: "Sunsets 🌅",
          subtitle: "View-once media",
          trailing: "TUE",
          received: true,
        ),
        tile(
          avatarColor: Colors.blueGrey,
          title: "🧗‍♂️ Rock Climbers",
          subtitle: "Which route should we take?",
          trailing: "TUE",
        ),
        tile(
          avatarColor: Colors.indigo,
          title: "Nikki R.",
          subtitle: "Thanks! What a wonderful message to read in the morning!",
          trailing: "TUE",
        ),
        tile(
          avatarColor: Colors.lightGreen,
          title: "Weather Forecasts",
          subtitle: "Raining all day 📷 Attachment",
          trailing: "MON",
        ),
        tile(avatarColor: Colors.lime),
        tile(avatarColor: Colors.blueGrey),
        tile(avatarColor: Colors.indigo),
        tile(avatarColor: Colors.lightGreen),
        tile(avatarColor: Colors.lime),
      ],
    );
  }
}
```

Now our `tile()` function is ready, we can create our `Conversations()` object containing the list of user chats. This part creates a [`ListView`](https://api.flutter.dev/flutter/widgets/ListView-class.html) object, containing a list of [`ListTile`](https://api.flutter.dev/flutter/material/ListTile-class.html) created by our helper function. This part seems complex, but only one function is used many time to generated content and mimic the screenshot.

```dart
class Home extends StatelessWidget {
  const Home({super.key});
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeBar(context),
      body: Conversations()
    );
  }
}
```

Everything looks good, we then mix everything together inside an `Home` class returning a [`Scaffold()`](https://api.flutter.dev/flutter/material/Scaffold-class.html) object.

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignalCopyCat',
      home: Home(),
      theme: ThemeData(
        fontFamily: "Roboto"
      ),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(const MyApp());
}
```

Finally, the last step, we can create also our application using a [`MaterialApp()`](https://api.flutter.dev/flutter/material/MaterialApp-class.html) object.

![SignalApp UI Home Screen but with Flutter](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/l42q3i0vj03ilh1amn3s.png)

Above, a screenshot of this application from the Android emulator. The images/pictures are missing on purpose, I was not able to found the "correct" images. As you can see, the emojis are not correctly rendered as well. Still few bugs to fix, but I did that in few hours.

I forgot something though, a big part of my code is using custom fonts (`Roboto`). Fonts are kind of assets and must be downloaded then configured in the project. The [Use a custom font](- https://docs.flutter.dev/cookbook/design/fonts) article on the official Flutter documentation is doing a great job to explain that.

# Conclusion

> I’ve been imitated so well, I’ve heard people copy my mistakes.
> -- Jimi Hendrix

This is not the perfect 1:1 reproduction of the SignalApp Home screen... I still need more experience with Flutter. The terms used are also new to me, finding one icon similar to the one from the screenshot is taking time for example. The infinite amount of solution to display something is also time consuming. Here a list of few resources I checked during this experience.

- [Flutter - Wrapping text](https://stackoverflow.com/a/58470417) on StackOverflow;

- [Lay out multiple widgets vertically and horizontally](https://docs.flutter.dev/ui/layout#lay-out-multiple-widgets-vertically-and-horizontally) from Flutter Documentation;

- [How to show a notification badge on the app icon using flutter?](https://stackoverflow.com/questions/61979970/how-to-show-a-notification-badge-on-the-app-icon-using-flutter) on StackOverflow;

- [Flutter CIrcle Avatar With Border](https://stackoverflow.com/questions/62227581/flutter-circle-avatar-with-border) on StackOverflow

- [Flutter give container rounded border](https://stackoverflow.com/questions/57777737/flutter-give-container-rounded-border) on StackOverflow

- [How to make a widget maximum size be equal to the flex value in a row](https://stackoverflow.com/questions/71035632/how-to-make-a-widget-maximum-size-be-equal-to-the-flex-value-in-a-row) on StackOverflow

- [`Roboto` fonts](https://fonts.google.com/selection?query=roboto) from Google fonts, an alternative font to the one used by [Signal](https://madegooddesigns.com/signal-font/)



Anyway, copying and reproducing is a great way to learn. It also train the mind to decompose every applications in small pieces. The same could have been done for [Briar](https://briarproject.org/), [SimpleX](https://simplex.chat/) or [Telegram](https://telegram.org/) applications, all of them are open-source and available on Github, Gitlab or somewhere else. Some of them are supporting mobile, desktop and web platform, in short, they are great targets. To summarize, if you want to learn how to design UI, try to recreate the design and the style of your favorite application.

The next step? Why not create an open-source library in Dart/Flutter exposing these styles? Perhaps one day...

Happy Hack and Have fun!

----

Cover Image by <a href="https://unsplash.com/@sigmund?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Compagnons</a> on <a href="https://unsplash.com/photos/red-and-purple-light-digital-wallpaper-t-da_md1qMc?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a> 