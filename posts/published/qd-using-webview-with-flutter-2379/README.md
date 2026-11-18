---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/qd-using-webview-with-flutter-2379"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fp0udpb1bw4o8mbj8eip1.jpg"
created_at: "None"
crossposted_at: "None"
description: "Your website is already working well, compatible with mobile device? Why recreating the wheel, and..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/qd-using-webview-with-flutter-2379"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "qd-using-webview-with-flutter-2379"
social_image: "None"
title: "Q&D: Using WebView with Flutter"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Q&D: Using WebView with Flutter

Your website is already working well, compatible with mobile device? Why recreating the wheel, and simply recreate your application around the [`WebView`](https://developer.android.com/reference/android/webkit/WebView) feature? The idea is simple, use the native Android (or iOS) browser inside your application. It will not fix everything though, but you will be able to reuse your website without rewriting everything from scratch.

Another purpose of `WebView` objects is to create an interface to a platform without public API. Indeed, with `WebView` you will have access to a real web browser capabilities, including executing requests on a remote service, storing cookies or executing Javascript script. on Dart/Flutter, the `webview_flutter` package is required.

```console
$ flutter pub add webview_flutter
Resolving dependencies... 
Downloading packages... 
  cupertino_icons 1.0.9 (2.0.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  meta 1.18.3 (1.19.0 available)
+ plugin_platform_interface 2.1.8
  test_api 0.7.12 (0.7.15 available)
  vector_math 2.4.2 (2.4.3 available)
+ webview_flutter 4.14.1
+ webview_flutter_android 4.14.1
+ webview_flutter_platform_interface 2.15.1
+ webview_flutter_wkwebview 3.27.0
Changed 5 dependencies!
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
```

`WebView` objects are objects to display web content (usually website) inside an application. This kind of object can be found on [Android](https://developer.android.com/reference/android/webkit/WebView) and on [iOS](https://developer.apple.com/documentation/webkit/wkwebview), both implementation offering similar (but not perfectly identical) features. When one `WebView` object is instantiated, it can be used like a browser where a part of its interfaces are exposed to the application.

The best way to demonstrate this is to create a [`WebViewController`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewController-class.html) object. The one presented in the example should do the job for now (with few modification):

- The [`setJavaScriptMode`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewController/setJavaScriptMode.html) method is called, it can be set to [`disabled`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/JavaScriptMode.html#disabled) or [`unrestricted`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/JavaScriptMode.html#unrestricted);

- The [`setNavigationDelegate`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewController/setNavigationDelegate.html) method is called, and a [`NavigationDelegate`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/NavigationDelegate-class.html) object is created. This last one is used to accept or reject the navigation changes. The following callback functions can be configured:

  - [`onNavigationRequest`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/NavigationDelegate/onNavigationRequest.html): executed to accept/deny navigation;
  - [`onPageFinished`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/NavigationDelegate/onPageFinished.html): executed when the page is fully loaded;
  - [`onPageStarted`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/NavigationDelegate/onPageStarted.html): executed when the page loading started;
  - [`onProgress`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/NavigationDelegate/onProgress.html): executed during the page loading progression;
  - [`onWebResourceError`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/NavigationDelegate/onWebResourceError.html): executed when an error occurs.

- The [`cacheClear`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewController/clearCache.html) method is called: use the remove the cache from the `WebView`;

- The [`clearLocalStorage`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewController/clearLocalStorage.html) method is called: used to clear the local storage from the `WebView`;

- The [`loadRequest`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewController/loadRequest.html) method is called: used to load an URL.

```dart
WebViewController controller({
  String target = 'https://authenticationtest.com/simpleFormAuth/'
}) {
  // parse an URL from a string
  final url = Uri.parse(target);
 
  // Return a WebViewController Object with custom callbacks
  // and parameters
  return WebViewController()

    // set the javascript mode to unrestricted (javascript
    // can be executed)
    ..setJavaScriptMode(JavaScriptMode.unrestricted)

    // configure the authorized navigation pattern
    ..setNavigationDelegate(
      NavigationDelegate(

        // a progression gauge can be created if necessary
        onProgress: (int progress) {
          print("loading in progress ($progress)...");
        },

        // when the connection to the page start
        onPageStarted: (String url) {
          print("page start to be loaded ($url).");
        },

        // when the page is totally loaded
        onPageFinished: (String url) {
          print("page loaded successfully ($url).");
          showCookies();
        },

        // what to do in case of error
        onHttpError: (HttpResponseError error) {
        }, 

        // this callback is used to select what kind of request
        // is allowed (to which website).
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        }))

    // when a new object is created, clear up the cache
    ..clearCache()

    // clear also the local storage
    ..clearLocalStorage()

    // and finally, load the requested url
    ..loadRequest(url);
}
```

With this future object created, it is possible to include it in the flutter tree. To that, one can use a [`WebViewWidget`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewWidget-class.html) object, with the previous controller passed as argument.

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: 
        Theme.of(context).colorScheme.inversePrimary,
      title: Text(widget.title),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Container(
            child: Row(children: [])
          ),
          Expanded(child: WebViewWidget(controller: _controller == null ? controller() : _controller!))
          ],
        ),
      ),
    );
}
```

Some variable states can eventually store the reference of the current controller, initialized in the [`initState()`](https://api.flutter.dev/flutter/widgets/State/initState.html) method. This code was defined inside a [`StatefulWidget`](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html) Widget.

```dart
WebViewController? _controller;

@override
initState() {
  super.initState();
  _controller = controller();
}
```

Here the log output during the loading. Yeah, the `authenticationtest.com` was used to retrieve some session cookies.

```console
I/flutter (19018): page start to be loaded (https://authenticationtest.com/simpleFormAuth/).
I/flutter (19018): loading in progress (20)...
I/flutter (19018): loading in progress (20)...
I/flutter (19018): loading in progress (29)...
I/flutter (19018): loading in progress (70)...
I/flutter (19018): loading in progress (87)...
I/flutter (19018): loading in progress (100)...
I/flutter (19018): loading in progress (100)...
I/flutter (19018): loading in progress (100)...
I/flutter (19018): page loaded successfully (https://authenticationtest.com/simpleFormAuth/)
```

The cookies from the `WebView` can also be retrieved (and if needed stored in a local store). This can be achieved by created a new [`WebViewCookieManager`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewCookieManager-class.html) object. After having been successfully instantiated, the cookies can be exported using the [`getCookies()`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewCookieManager/getCookies.html) method.

```dart
WebViewController? _controller;

@override
initState() {
  super.initState();
  _controller = controller();
  _cookieManager = WebViewCookieManager();
}

Future<void> showCookies() async {
  final currentUrl = await _controller?.currentUrl() ?? ''; 
  final Uri? domain = Uri.tryParse(currentUrl);
  final cookies = await _cookieManager?.getCookies(
    domain: domain!
  );
  print(cookies);
}
```

Here the log output when some cookies have been received from the website. Those cookies are using the [`WebViewCookie`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewCookie-class.html) object, containing 4 fields, [`name`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewCookie/name.html), [`value`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewCookie/value.html), [`domain`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewCookie/domain.html) and [`path`](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewCookie/path.html). The other cookies attributes like `expires` are not available on Android (but it seems they can be found on iOS).

```console
I/flutter (19018): [WebViewCookie{name: PHPSESSID, value: 8035d936660419d25f1969de60945682, domain: https://authenticationtest.com/simpleFormAuth/, path: /}]
```

Here a screenshot of the `WebView` from the Android emulator. Few buttons have been added to do tests, like extract the cookies and save same in a permanent store, or switch to another URL.

![WebView Flutter Screenshot from Android Application](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/irkfatbddtllve9bx2mz.png)

`WebView` is a really interesting feature to bypass some website limitations, especially the one with public API only. Collecting those cookies can then be reused afterward. Some of you would probably ask why I was playing with this package. Well, I needed to fetch some cookies from another website (not the one used here for test), on one of my project. Having access to the cookies will help me to query my target when authenticated. Anyway, here some interesting links if you want to know more:

- [`webview_flutter` package](https://pub.dev/packages/webview_flutter) from pub.dev;

- The [official `webview_flutter` API documentation](https://pub.dev/documentation/webview_flutter/latest/) on pub.dev;

- The [`webview_flutter` source code](https://github.com/flutter/packages/tree/main/packages/webview_flutter/webview_flutter) from github;

- The [official `WebView` documentation](https://developer.android.com/reference/android/webkit/WebView) from the Android developer website;

- The [official `mkWebView` documentation](https://developer.apple.com/documentation/webkit/wkwebview) from the Apple developer website;

- [cURL HTTP cookies documentation](https://curl.se/docs/http-cookies.html) where the cURL cookies format is explained;

- The [RFC6265](https://www.rfc-editor.org/info/rfc6265/) where the `set-cookie` is explained, containing also the official cookies attributes with their specifications;

- [Starting with Flutter: How to embed a webview](https://dev.to/theotherdevs/starting-with-flutter-how-to-embed-a-webview-5g91) by @theotherdevs; 

- [Converting any website into an app: Flutter webview](https://dev.to/franciscodex/converting-any-website-into-an-app-flutter-webview-55i7) by @franciscodex; 

- [Not Just a WebView: Building a Native Engine on Flutter to Convert Sites to Apps with SDUI](https://dev.to/__2ea5fee000c/not-just-a-webview-building-a-native-engine-on-flutter-to-convert-sites-to-apps-with-sdui-4j0e) by @__2ea5fee000c; 

- [Flutter: Two-way communication between a WebView and a web page](https://dev.to/diamantidis/flutter-two-way-communication-between-a-webview-and-a-web-page-iji) by @diamantidis; 

- [Is there a way to show more cookies fields from webview_flutter's WebViewCookieManager](https://stackoverflow.com/questions/80009751/is-there-a-way-to-show-more-cookies-fields-from-webview-flutters-webviewcookiem) on StackOverflow, where I asked a question regarding the extra cookies attributes.

As usual, have fun and happy hacking!

----

The stackoverflow user who answered me on my question found a bug in the parser (I missed it), when a value is set to base64, it returns an empty string. In fact, while I was reading the code, I did not see any limits on the size of the key or the value. This should also be tested, a malicious server could eventually overflow an application with badly crafted cookies. This protected could be implemented on the `WebView` (Kotlin) part though and not in the `flutter` interface.

Anyway, I will need a way to reproduce (at least) the following bug. Notes from [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Set-Cookie):

> A `<cookie-name>` can contain any US-ASCII characters except for control characters (ASCII characters 0 up to 31 and ASCII character 127) or separator characters (space, tab and the characters: `(` `)` `<` `>` `@` `,` `;` `:` `\` `"` `/` `[` `]` `?` `=` `{` `}`
>
> A `<cookie-value>` can optionally be wrapped in double quotes and include any US-ASCII character excluding control characters (ASCII characters 0 up to 31 and ASCII character 127), Whitespace, double quotes, commas, semicolons, and backslashes.
>
> Encoding: Many implementations perform percent-encoding on cookie values. However, this is not required by the RFC specification. The percent-encoding does help to satisfy the requirements of the characters allowed for `<cookie-value>`.

1. set a cookie with a base64 value (e.g. `dGVzdAo=`)
2. fetch the cookie as `WebCookie`, the value returned is `""`" instead of `"dGVzdAo="`

This issue is due to the current implementation of the parser used in the [`AndrdoiWebViewCookieManager`](https://github.com/flutter/packages/blob/a1ed23c8f76035baa4edb2003d50349d07e7d6e0/packages/webview_flutter/webview_flutter_android/lib/src/android_webview_cookie_manager.dart#L87) implementation.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// code exfiltred from official sources
poc(String cookies) {
  List<dynamic> store = []; 
  for (final String cookie in cookies.split('; ')) {
    final List<String> cookieValue = cookie.split('=');
    store.add((cookieValue.first, cookieValue.last));
  }
  return store;
}

void main() {
  test("poc", () {
    print(poc("test=dGVzdAo"));
    expect(poc("test=dGVzdAo"), ("test", "dGVzdAo"));

    print(poc("test=dGVzdAo="));
    expect(poc("testdGVzdAo="), ("test", "dGVzdAo="));
  }); 
}
```

```console
$ flutter test
...
00:00 +0: poc                                                                               
[(test, dGVzdAo)]
00:01 +0 -1: poc [E]                                                                        
  Expected: (String, String):<(test, dGVzdAo)>
    Actual: [(String, String):(test, dGVzdAo)]
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/widget_test.dart 25:5                          main.<fn>
...
```

Here a quick nginx configuration:

```config
events {
    worker_connections   2000;
}

http {
  server {
    listen 4001;
    add_header Set-Cookie "test=dGVzdAo=; Path=/";
    return 200;
  }
}
```

Thanks to [Mahendra Dhakad](https://stackoverflow.com/users/19418150/mahendra-dhakad)](https://stackoverflow.com/a/80009898/6782635) on stackoverflow.

----

Cover Image by <a href="https://unsplash.com/@pawelskor?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Paul Skorupskas</a> on <a href="https://unsplash.com/photos/person-holding-camera-lens-7KLa-xLbSXA?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>