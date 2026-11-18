---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/signalapp-ui-chat-screen-but-with-flutter-39of"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Ff08z9anwmo46ir31u3zb.jpg"
created_at: "None"
crossposted_at: "None"
description: "If your competitors start copying you then you are doing something right! -- Jay Baer   The previous..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/signalapp-ui-chat-screen-but-with-flutter-39of"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "signalapp-ui-chat-screen-but-with-flutter-39of"
social_image: "None"
title: "SignalApp UI Chat Screen but with Flutter"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# SignalApp UI Chat Screen but with Flutter

> If your competitors start copying you then you are doing something right!
> -- Jay Baer

The previous article was focused on the SignalApp Home screen, on this one, we will try to reproduce the Chat screen, where all messages from an user are displayed. Like the last time, we will first analyze the design, and then re-implement it using only Flutter available features.

![SignalApp Screenshot from appgefahren.de](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/164ka5pkn9pbhnbkssgs.png)

# Chats Screen

> If you copy my dreams, you automatically will copy my challenges too. My success will give you a crown. My challenges will make you frown.
> -- Israelmore Ayivor

This article will focus on the second screenshot on the right. When an User is tapping on one active chat available from the home screen, the action is to open a new screen containing the list of messages related to this conversation.

## Chat Bar

![Top bar of the Chat Screen](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/qzocgtm86xssy5zq5n5t.png)

The top navigation bar using the [`AppBar`](https://api.flutter.dev/flutter/material/AppBar-class.html) widget is made of 3 parts, the [`leading`](https://api.flutter.dev/flutter/material/AppBar/leading.html) is displaying a [left arrow](https://api.flutter.dev/flutter/material/Icons/arrow_back-constant.html) also called `arrow_back`. When clicking on it, the application should go to the home screen. The [`title`](https://api.flutter.dev/flutter/material/AppBar/title.html) parameter is now displaying the icon/avatar of the contact and its name. The Avatar part can be created via the [CircleAvatar](https://api.flutter.dev/flutter/material/CircleAvatar-class.html) widget. The [`actions`](https://api.flutter.dev/flutter/material/AppBar/actions.html) parameter contains 3 buttons, one to start a video call using a [`videocam_rounded`](https://api.flutter.dev/flutter/material/Icons/videocam_rounded-constant.html) icon, one to start a phone call using a [`phone_rounder`](https://api.flutter.dev/flutter/material/Icons/phone_rounded-constant.html) icon and the last one to open a menu used to configure the parameter of the chat using a [`more_vert`](https://api.flutter.dev/flutter/material/Icons/more_vert-constant.html) icon. The background color of this element is blue (`#2b6cee`), but the [`Colors.blue`](https://api.flutter.dev/flutter/material/Colors/blue-constant.html) constant will be used instead.

```dart

class ChatBar extends StatelessWidget {
  const ChatBar({super.key, PreferredSizeWidget? bottom});

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue[700],
      leading: Center(child: Icon(Icons.arrow_back, color: Colors.white)),
      title: Row(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.directional(end: 10),
            child: CircleAvatar(),
          ),
          Text(
            "Maya Dorai",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.videocam_rounded),
          onPressed: () {},
          color: Colors.white,
        ),
        IconButton(
          icon: Icon(Icons.phone_rounded),
          onPressed: () {},
          color: Colors.white,
        ),
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () {},
          color: Colors.white,
        ),
      ],
    );
  }
}
```

This is not the most complex part, at least for the design. All buttons must be configured to react to user actions. For example, one user tapping on the video button should open a new screen to start a call with video support. The screenshot below shows this `AppBar` on Android:

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/u2il0ts34tilv0d8h6fm.png)

## Chat Messages

![Middle part of the Chat Screen](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/hmxnrjg32pckyfcl7x8x.png)

The next chunk of the screen is containing the list of messages. I suppose those are [`Card`](https://api.flutter.dev/flutter/material/Card-class.html) widgets, probably added in a [`ListView`](https://api.flutter.dev/flutter/widgets/ListView-class.html). A message can have different design depending on many parameters. The most visible one is the position of each messages, when a message is sent by the user, it is on right side of the screen and if it's received from a contact, it is put on the left side of the screen. A message with attachments will not have the same shape than a message containing only text. Messages containing only emojis will not be displayed the same as well. In short, it will be painful to design that, so, I will only try to implement only a small subset of all features.

In short, a message can contain text as `String`, attachments (e.g. images, video, audio) as `List<Image>`, emoji(s) as `String` or can be a sticker (signal-like emoji feature) as `Image`. It must have an origin (`Sender` or `Receiver`) and can have labels using emojis.

## Attachments

![User's Message with Images/Medias](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/kjy8848js1nkh1i13no3.png)

Let start implementing the messages representation when attachments are shared. You can see on the screenshot 3 pictures of a cat, but the number of attachments can change the whole shape and design if this message. For example, with 1 attachment, the image will use all the space. with 2 attachments, both images will share the space in half, with 5+ attachments, only 5 attachments are displayed, with the one on the top taking half the space. To be honest, this part was kinda hard, and I was curious to see how it was implemented in SignalApp. 

The SignalApp source code can be seen in [`app/src/main/java/org/thoughtcrime/securesms/components/AlbumThumbnailView.java`](https://github.com/signalapp/Signal-Android/blob/837598657dab7a01874ea515e319e72d669dc77e/app/src/main/java/org/thoughtcrime/securesms/components/AlbumThumbnailView.java#L25) (goddamn it, Java paths are crazy). The implemention is not so complex but look like a big hack, their idea is to create a list of attachment, and use a representation for each case (1, 2, 3... 5 attachments). It works well, I think we can reuse it.

The first step is to create a new class called `AttachmentView` extending a `StatelessWidget`. This new class will only store the list of images and how to display them.

```dart
class AttachmentView extends StatelessWidget {
  final List<Image> images;

  const AttachmentView({super.key, images}) : this.images = images;
```

Each images are "encapsulated" in their own [`AnimatedContainer`](https://api.flutter.dev/flutter/widgets/AnimatedContainer-class.html) (currently not active, but it was to add an animation when someone is tapping on the image). I did - too - many test to find the "best" way to display an image, but it seems the easy path was to use a [`BoxDecoration`](https://api.flutter.dev/flutter/painting/BoxDecoration-class.html) and [`BoxFit.cover`](https://api.flutter.dev/flutter/painting/BoxFit.html#cover). With these parameters, the image will always use the space available.

```dart
  Widget _container(Image image) {
    return AnimatedContainer(
      duration: Duration(seconds: 2),
      decoration: BoxDecoration(
        image: DecorationImage(image: image.image, fit: BoxFit.cover),
      ),
    );
  }
```

Many [`Row`](https://api.flutter.dev/flutter/widgets/Row-class.html) will be required, then using a custom method called `_row` can be helpful to avoid duplicated code. Nothing fancy there, a row is created after having modified via a [`map`](https://api.flutter.dev/flutter/dart-core/Iterable/map.html) the list of images passed as arguments.

```dart
  Widget _row(List<Image> images) {
    final rows = images.map((x) {
      return Expanded(child: _container(x));
    }).toList();
    return Row(spacing: 2, children: rows);
  }
```

The same is done for [`Column`](https://api.flutter.dev/flutter/widgets/Column-class.html), a `_column` method is created, taking a list of images are arguments and doing the applying the same procedure than the one used for the rows.

```dart
  Widget _column(List<Image> images) {
    final columns = images.map((x) {
      return Expanded(child: _container(x));
    }).toList();
    return Column(spacing: 2, children: columns);
  }
```

The images must be displayed in different way based on the amount of images passed as arguments. The method `_displayImages()` is doing that for us, based on the [`length`](https://api.flutter.dev/flutter/dart-core/Iterable/length.html) of the list of image. The previous defined methods are reused to deal with the view.

```dart
  Widget _displayImages() {
    if (images.length == 1) {
      return _container(images[0]);
    }

    if (images.length == 2) {
      return _row(images);
    }

    if (images.length == 3) {
      return Row(
        spacing: 2,
        children: [
          Expanded(child: _container(images[0])),
          Expanded(child: _column([images[1], images[2]])),
        ],
      );
    }

    if (images.length == 4) {
      return Row(
        spacing: 2,
        children: [
          Expanded(child: _column([images[0], images[1]])),
          Expanded(child: _column([images[2], images[3]])),
        ],
      );
    }

    if (images.length == 5) {
      return Row(
        spacing: 2,
        children: [
          Expanded(child: _column([images[0], images[1]])),
          Expanded(child: _column([images[2], images[3], images[4]])),
        ],
      );
    }

    if (images.length > 5) {
      return Row(
        spacing: 2,
        children: [
          Expanded(child: _column([images[0], images[1]])),
          Expanded(child: _column([images[2], images[3], images[4]])),
        ],
      );
    }

    return Container(child: Text("nothing to see there..."));
  }
```

Finally, the [`build()`](https://api.flutter.dev/flutter/widgets/StatelessWidget/build.html) method returns a [`SizedBox`](https://api.flutter.dev/flutter/widgets/SizedBox-class.html) widget with the return of `_displayImages()` method as child. The `height` if here is quite important and will be used to define the final size of the images displayed. Without it, nothing will be printed and an error will be generated. I did not find a good way right now to avoid that.

```dart
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: _displayImages()
    );
  }
}
```

A quick note on Flutter's assets, I downloaded some random cat images from unsplash and put them in `assets/images`. After that, the `pubspec.yaml` file must be updated, like mentioned in [Flutter documentation](https://docs.flutter.dev/ui/assets/assets-and-images).

```yaml
# ...
flutter:
  # ...
  assets:
    - assets/images/loan-7AIDE8PrvA0-unsplash.jpg
    - assets/images/manja-vitolic-gKXKBY-C-Dk-unsplash.jpg
    - assets/images/mikhail-vasilyev-IFxjDdqK_0U-unsplash.jpg
    - assets/images/kate-stone-matheson-uy5t-CJuIK4-unsplash.jpg
    - assets/images/amber-kipp-75715CVEJhI-unsplash.jpg
```

Then, those assets can be used inside the code, let check that with our `AttachmentView` class.

```dart
AttachmentView(
  images: [
    Image.asset(
      "assets/images/loan-7AIDE8PrvA0-unsplash.jpg",
    ),
    Image.asset(
      "assets/images/manja-vitolic-gKXKBY-C-Dk-unsplash.jpg",
    ),
    Image.asset(
      "assets/images/mikhail-vasilyev-IFxjDdqK_0U-unsplash.jpg",
    ),
    Image.asset(
      "assets/images/kate-stone-matheson-uy5t-CJuIK4-unsplash.jpg",
    ),
    Image.asset("assets/images/amber-kipp-75715CVEJhI-unsplash.jpg"),
  ],
)
```

Below the result of this snippet.

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/vcmm53rnhbog261jv1or.png)

The behavior is a bit different than SignalApp, when configured 5 images, they are using a `Column` and not a `Row` as main widget, resulting in the 2 top images being the biggest ones.

## Messages

**Warning: dirty code**. It was not expected to take so much time due to the complexity of the different layer. I offer only a partial solution there, a better implementation will be created in another post.

![Contact's Text Message](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/254foi2d84sv0tff1suo.png)

The remote contact can send a message containing only text, emoji or sticker. It can be created using a `Card` Widget. The following code is quite complex because I tried to include all the features in one class. The design is dirty, but it "works". The main issue I got is the different parts of a message that can be modified due to the differences between a message received or sent.

```dart
  Message({
    super.key,
    final Alignment alignment = Alignment.centerLeft,
    final Color color = Colors.blue,
    final Color textColor = Colors.white,
    final String? text,
    final String? date,
    final String? label,
    final bool received = false,
    final List<Image> attachments = const [],
  }) : this.alignment = alignment,
       this.color = color,
       this.textColor = textColor,
       this.text = text,
       this.date = date,
       this.label = label,
       this.received = received,
       this.attachments = attachments;

  Widget _text() {
    return text == null
        ? Container()
        : Text(
            text ?? "null",
            style: TextStyle(
              color: alignment == Alignment.centerLeft
                  ? textColor
                  : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          );
  }

  Widget _date() {
    return date == null
        ? Container()
        : Text(
            date ?? "??",
            style: TextStyle(
              color: alignment == Alignment.centerLeft
                  ? textColor
                  : Colors.black,
              fontWeight: FontWeight.w100,
              fontSize: 10,
            ),
          );
  }

  Widget _attachment() {
    return attachments.isEmpty
        ? Container()
        : Row(
            children: [Expanded(child: AttachmentView(images: attachments))],
          );
  }

  Widget _label() {
    return Container(
      padding: EdgeInsets.all(1),
      margin: EdgeInsets.all(1),
      child: label == null
          ? Container()
          : Text(label!, style: TextStyle(fontSize: 14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(
        right: alignment == Alignment.centerLeft ? 40 : 10,
        left: alignment == Alignment.centerLeft ? 10 : 40,
      ),
      child: Badge(
        backgroundColor: Colors.grey[400],
        offset: alignment == Alignment.centerLeft
            ? Offset(-40, -20)
            : Offset(20, -20),
        alignment: alignment == Alignment.centerLeft
            ? AlignmentGeometry.bottomEnd
            : AlignmentGeometry.bottomStart,
        isLabelVisible: label == null ? false : true,
        label: _label(),
        child: Container(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _attachment(),
              text == null
                  ? Container()
                  : Container(
                      // margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      alignment: alignment,
                      decoration: BoxDecoration(
                        color: alignment == Alignment.centerLeft
                            ? color
                            : Colors.grey[300],
                        borderRadius: BorderRadius.only(
                          topLeft: attachments.isEmpty
                              ? Radius.circular(12)
                              : Radius.zero,
                          topRight: attachments.isEmpty
                              ? Radius.circular(12)
                              : Radius.zero,
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        spacing: 5,
                        children: [
                          Align(alignment: Alignment.topLeft, child: _text()),
                          Align(
                            alignment: alignment == Alignment.centerLeft
                                ? Alignment.bottomLeft
                                : Alignment.bottomRight,
                            child: _date(),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
```

I waste a lot of time also on the shape of the different objects, until I discovered the [`Clip.hardEdge`](https://api.flutter.dev/flutter/dart-ui/Clip.html#hardEdge) and [`Clip.antiAlias`](https://api.flutter.dev/flutter/dart-ui/Clip.html#antiAlias). Indeed, when I was adding attachments, I was losing the rounded borders, it was quickly fixed by enabling those parameters in the parent containers.

![User's Messages](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/uy4wz62wo5dehe4bj2wx.png)

The same can be done for an User's message. Unfortunately, as you can see, the same message can contain different kind of data (1) an emoji (2) text only (3) a small image called [sticker](https://sticker201.github.io/signalstickers/pack/9acc9e8aba563d26a4994e69263e3b25) (see [Bandit the Cat](https://sticker201.github.io/signalstickers/pack/9acc9e8aba563d26a4994e69263e3b25)) if I remember correctly. This will not be implemented though.

## User Chat Input

![Bottom part of the Chat Screen](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/3tb20dh3bxkle1rsps13.png)

Finally, the last part of this screen is the place where the user can write messages. It is split in 2 parts, the left side is to let the user write a message via a text input, this one is also made of 3 buttons, one on the left to add emojis, and 2 on the right, to insert a picture or record a vocal messages. The last button on the left is used to send the message to the contact. The background color is grey (`#fefefe`).

![User Message Text Input](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/paama1nz1e642k13s6zk.png)

The user's input can be divided in 3 parts, the leading part containing an IconButton with an emoji. The body part containing a TextField. The actions part containing more IconButton.

![User Message Send Button](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/4kp8ky30zn523fe0dp81.png)

The final button of this part of the application is the one used to send the message.

```dart
class ChatBox extends StatelessWidget {
  const ChatBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 10,
        children: [
          Expanded(child: ChatInput()),
          SendButton(),
        ],
      ),
    );
  }
}
```

```dart
class SendButton extends StatelessWidget {
  const SendButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: 14),
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(100),
        ),
        child: IconButton(
          onPressed: () {},
          icon: Icon(Icons.add),
          color: Colors.white,
        ),
      ),
    );
  }
}
```

```dart
class ChatInput extends StatelessWidget {
  const ChatInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      margin: EdgeInsetsGeometry.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsetsGeometry.only(left: 10, right: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 10,
            children: [
              EmojiButton(),
              Expanded(child: ChatInputText()),
              ActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
```

```dart
class ChatInputText extends StatelessWidget {
  const ChatInputText({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        onTap: () {
          print("tapped");
        },
        onChanged: (str) {
          print("$str");
        },
        minLines: 1,
        maxLines: 6,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Signal message",
          contentPadding: EdgeInsets.all(10),
        ),
      ),
    );
  }
}
```

```dart
class EmojiButton extends StatelessWidget {
  const EmojiButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
      ),
      alignment: Alignment.bottomCenter,
      child: IconButton(
        onPressed: () {},
        icon: Icon(Icons.emoji_emotions_outlined),
      ),
    );
  }
}
```

```dart
class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      alignment: Alignment.topCenter,
      child: Row(
        spacing: 2,
        children: [
          Container(
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.camera_outlined),
            ),
          ),
          Container(
            // decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
            child: IconButton(onPressed: () {}, icon: Icon(Icons.mic_outlined)),
          ),
        ],
      ),
    );
  }
}
```

Here a screenshot of a `ChatBox` object on Android:

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/m9n7wqyl1gkf22bq49iq.png)

# Final Result

> Design can be art. Design can be aesthetics. Design is so simple, that's why it is so complicated.
> -- Paul Rand

Learning design is a long journey but the pieces are starting to fit together. The final result is not perfect, but it will reflect my current level. All widgets previously created can be mixed together.

The `ChatBody` class will create a `ListView` to deal with all the messages. Actually, those messages are created manually, including all the assets, the label and the raw text. In a real world application, those messages are fetched from a server, a local database or a cache.

```dart
class ChatBody extends StatelessWidget {
  const ChatBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Message(
          label: "❤️",
          alignment: Alignment.centerRight,
          attachments: [
            Image.asset(
              "assets/images/loan-7AIDE8PrvA0-unsplash.jpg",
              // fit: BoxFit.cover,
            ),
            Image.asset(
              "assets/images/manja-vitolic-gKXKBY-C-Dk-unsplash.jpg",
              // fit: BoxFit.fill,
            ),
            Image.asset(
              "assets/images/mikhail-vasilyev-IFxjDdqK_0U-unsplash.jpg",
              // fit: BoxFit.fill,
            ),
          ],
        ),
        Message(
          text:
              "The rain is pouring down and I'm sitting here just listening to it",
          label: "👍",
          date: "30m",
        ),
        // Message(alignment: Alignment.centerRight, text: "☺️"),
        Message(
          alignment: Alignment.centerRight,
          text: "That's what I did this morning too.",
        ),
        Message(
          text:
              "The rain is pouring down and I'm sitting here just listening to it",
          date: "30m",
          attachments: [
            Image.asset(
              "assets/images/loan-7AIDE8PrvA0-unsplash.jpg",
              // fit: BoxFit.cover,
            ),
            Image.asset(
              "assets/images/manja-vitolic-gKXKBY-C-Dk-unsplash.jpg",
              // fit: BoxFit.fill,
            ),
            Image.asset(
              "assets/images/mikhail-vasilyev-IFxjDdqK_0U-unsplash.jpg",
              // fit: BoxFit.fill,
            ),
            Image.asset(
              "assets/images/kate-stone-matheson-uy5t-CJuIK4-unsplash.jpg",
            ),
            Image.asset("assets/images/amber-kipp-75715CVEJhI-unsplash.jpg"),
          ],
        ),
      ],
    );
  }
}
```

Then, the `ChatScreen` will contain the `ChatBody` widget (containing all messages) and the `ChatBox` (containing the input). A `Scaffold` and a `Column` widgets are being used there.

```dart
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatBar().build(context),
      body: Column(
        children: [
          Expanded(child: ChatBody()),
          ChatBox(),
        ],
      ),
    );
  }
}
```

The main widget called `MyApp` can be created, it will just be used to manage the `ChatScreen` object.

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignalCopyCat',
      home: ChatScreen(),
      theme: ThemeData(fontFamily: "Roboto"),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

Finally, the application can be started from the main entry-point.

```dart
void main() {
  runApp(const MyApp());
}
```

The final result can be seen in the following screenshot.

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/8xif5yxd8vp8aj0zltca.png)

Lot of features are missing, but it could be a good challenge to try to reproduce that in 6 months or 1 year, to see if I can produce better code.

# Conclusion

> Only God creates. The rest of us just copy.
> -- Michelangelo

When I started this post, I thought it will be done in few hours, perhaps few days. It was not the case. The level of complexity to design a "simple" is crazy. I know, I'm no expert in Flutter yet, but based on the amount of opened tabs in my web browser, I can be sure it was not an easy task.

In fact, it's not a surprise. SignalApp is quite old now, and the design evolved alongside new features. Reproducing everything in one long coding session is then complex, even if the Java/Kotlin source code of the application is available on Github. Just to be clear, this article does not include state management, animations and interactivity.

One question we can ask thought... Many projects are using the same patterns to represent messages, Flutter is a kind of "low level" design framework, then why not creating a project reproducing the same design from Signal, WhatsApp and so on? It could be great to mix great ideas together.

As usual, if you want to know a bit more about this publication, here few resources:

- [Flutter Learning resources](https://docs.flutter.dev/reference/learning-resources) from the Official Flutter website;

- [Create a grid list](https://docs.flutter.dev/cookbook/lists/grid-lists) from the Official Flutter documentation;

- [WhatsUp Flutter Appplication](https://github.com/Tauseef-Hilal/WhatsUp) on Github;

- [Chat Screen from the WhatsUp Application](https://github.com/ishandeveloper/Chatter-App/blob/master/lib/pages/chatterScreen.dart) on Github;

- [Chat from the WhatsUp Application](https://github.com/Tauseef-Hilal/WhatsUp/blob/main/lib/features/chat/views/chat.dart) on Github;

- [Chat Field from the WhatsUp Application](https://github.com/Tauseef-Hilal/WhatsUp/blob/b3ab4ffdf7296e4df7b00dc2e982e65616fff295/lib/features/chat/views/widgets/chat_field.dart#L42) on Github;

- [Attachment Renderers from the WhatsUp Application](https://github.com/Tauseef-Hilal/WhatsUp/blob/b3ab4ffdf7296e4df7b00dc2e982e65616fff295/lib/features/chat/views/widgets/attachment_renderers.dart) on Github;

- [WhatsApp Flutter Application](https://github.com/muhammad-fiaz/WhatsApp-Flutter) on Github;

- [Flutter Row and Column: MainAxis, CrossAxis, and Spacing Explained](https://sagnikbhattacharya.com/blog/flutter-row-column-widget) by [Sagnik Bhattacharya](https://www.linkedin.com/in/sagnik-bhattacharya-916b9463/);

- [SignalApp UI source code](https://github.com/signalapp/Signal-Android/tree/main/core/ui/src/main/java/org/signal/core/ui) on Github;

- [SignalApp MMS (Multimedia Messages?) source code](https://github.com/signalapp/Signal-Android/tree/837598657dab7a01874ea515e319e72d669dc77e/app/src/main/java/org/thoughtcrime/securesms/mms) on Github;

- [SignalApp Album Thumbnail View](https://github.com/signalapp/Signal-Android/blob/837598657dab7a01874ea515e319e72d669dc77e/app/src/main/java/org/thoughtcrime/securesms/components/AlbumThumbnailView.java#L25) on Github;

- [The equivalent of wrap_content and match_parent in flutter?
](https://stackoverflow.com/questions/42257668/the-equivalent-of-wrap-content-and-match-parent-in-flutter) on StackOverflow;

- [How to make one side circular border of widget with flutter?](https://stackoverflow.com/questions/57304512/how-to-make-one-side-circular-border-of-widget-with-flutter) on StackOverflow;

- [How to change height of a card in flutter](https://stackoverflow.com/questions/58115148/how-to-change-height-of-a-card-in-flutter) on StackOverflow;

- [How do I stretch an image to fit the whole background (100% height x 100% width) in Flutter?](https://stackoverflow.com/questions/45745448/how-do-i-stretch-an-image-to-fit-the-whole-background-100-height-x-100-width) on StackOverflow;

- [Why isn't my image filling the space with BoxFit.fill in Flutter?](https://stackoverflow.com/questions/79416429/why-isnt-my-image-filling-the-space-with-boxfit-fill-in-flutter) on StackOverflow;

- [Flutter BoxFit.cover - Show top of image, not center](https://stackoverflow.com/questions/75557639/flutter-boxfit-cover-show-top-of-image-not-center) on StackOverflow;

- [Flutter images in a row](https://stackoverflow.com/questions/79547276/flutter-images-in-a-row) on StackOverflow;

- [How do I crop an image in Flutter?](https://stackoverflow.com/questions/44665720/how-do-i-crop-an-image-in-flutter) on StackOverflow;

- [border radius not apply inside container widget](https://stackoverflow.com/questions/52148292/border-radius-not-apply-inside-container-widget) on StackOverflow.

That's a lot of links, right? Well, my web browser was full of tabs... I just extracted few of them, the ones I found the most interesting.

Have fun and Hack the planet!

----

Cover Image by <a href="https://unsplash.com/@kellysikkema?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Kelly Sikkema</a> on <a href="https://unsplash.com/photos/two-white-speech-bubbles-sitting-on-top-of-a-brown-surface-sWRPYgjpygQ?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>