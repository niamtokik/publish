---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/substack0-authentication-and-content-management-119n"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fxwjwrh7w6jhosbuja3pv.jpg"
created_at: "None"
crossposted_at: "None"
description: "Reverse engineering network protocol is an interesting process, firstly because one can learn a lot..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/substack0-authentication-and-content-management-119n"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "substack0-authentication-and-content-management-119n"
social_image: "None"
title: "Substack/0: Authentication and Content Management"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Substack/0: Authentication and Content Management

[Reverse engineering](https://en.wikipedia.org/wiki/Reverse_engineering) network protocol is an interesting process, firstly because one can learn a lot of things you would probably never thought of, and secondly because it is a deep dive into developers logic. Reverse engineering is challenging, and is usually made of really small victories. Why doing that? Well, why not? In fact, most of those companies are selling our private data, our behaviors and our stats to other private companies, why should also be forced to use their own implementation of their client? That's probably one part of the idea... But it can also be to implement a library to communicate with a private API and give us the possibility to automatize recurrent tasks.

Now, why [Substack](https://substack.com/)? This is still a small social network, inspired by [X/Twitter](http://x.com/) and mixed with a bit of [Wordpress](https://wordpress.com/). It's a kind of micro-blogging platform and even if they are offering a [public API](https://substackapi.dev/quickstart), using the private one is a good way to learn how their web and mobile applications are working. Furthermore, doing reversing engineering on a web stack can lead to interesting result. Indeed, a web application is made in JavaScript, most of the time using [AJAX](https://developer.mozilla.org/en-US/docs/Glossary/AJAX) with stateless HTTP requests. It can be generalized and some tools can be created to help reverse engineering other private API.

Anyway, Reverse Engineering is a goddamn great way to improve all your skills. Let's. Go.

# Preparation

The main tool we will use for this article will be [`curl`](https://curl.se/) and any kind of browser with a [developer mode activated](https://www.chromium.org/chromium-os/developer-library/guides/device/developer-mode/). In the developer window, got to the Network tab and find a way to preserve the logs (e.g. `Preserve log` radio button on Chromium). A social network can produce a lot of noise, you should also filter the requests and display only the `Fetch/XHR` ones.

Having an easy way to document and test the API is also a good thing. If you are not familiar with [OpenAPI](https://www.openapis.org/), it's a good time to check that. If you are lazy, you can also use [Insomnia](https://insomnia.rest/), it's free and open-source. This tool is an alternative to [Postman](https://www.postman.com/downloads/). It will help us to create the specification and easily tests our finding. You can see this tool also as an extension of `curl`, with a GUI.

Automated tools can help you to do more, but the article here is not to show you how to use them, it's to show you how to reverse engineering an interface with cheap tools anyone can use. Yes, it's perhaps slower, but at least, you will learn a lot. You will also try and fail, the best way to learn discipline and tenacity.

# Requirements

If you have your own Substack account, I would recommend to create a new one dedicated for your reverse engineering goal. Perhaps more than one account, because if you want to publish/subscribe to someone else, you will need more than one account. Most of the companies are not allowing us to use our own clients to deal with their private API, and those accounts can be kicked, blocked, banned or simply removed because of that. You can use temporary email services like [yopmail](http://yopmail.com), [10minutemail](https://10minutemail.com/) or any other alternative. You can also create a mail at [Tutanota](https://mail.tutanota.com/) or [Protonmail](https://proton.me/mail) if you want, probably better for long term reverse engineering sessions. For the rest of this post I will use a fresh account from 10minutemail, in case of credential leaks, it will not be a problem. Here more alternative, be careful, some of them will be blocked by the services you want to reverse engineering.

- [10 Minute Email](https://10minutemail.com/)

- [33Mail](https://www.33mail.com/)

- [Email on Deck](https://www.emailondeck.com/)

- [erine.email](https://erine.email/)

- [fake Mail Generator](https://www.fakemailgenerator.com/)

- [Guerilla Mail](https://www.guerrillamail.com/)

- [Inboxes](https://inboxes.com/)

- [Maildrop](https://maildrop.cc/)

- [Mailinator](https://www.mailinator.com/)

- [Mailnesia](https://mailnesia.com/)

- [MintEmail](https://www.mintemail.com/)

- [Mohmal](https://www.mohmal.com/en)

- [Reusable Email](https://reusable.email/)

- [Temp Mail](temp-mail.org)

- [Tempr Email](https://tempr.email/)

- [Tempail](https://tempail.com/en/)

- [Temporary Mail](https://temporarymail.com/)

- [33Mail](https://www.33mail.com/)

Another thing is to use [Tor](https://manpages.debian.org/trixie/tor/tor.1.en.html), [Proxychains](https://manpages.debian.org/trixie/proxychains4/proxychains.1.en.html) (via an [open proxy list)](https://github.com/proxifly/free-proxy-list) or a VPN to avoid sharing your personal IP address. Some service providers can tag your IP address and share it with other companies. It is especially true for the big companies like Google, Facebook or X/Twitter. If you are trying to reverse engineer one of them, use something to hide your true IP address. If you have Tor configured on your dev machine, you can configure it for curl by setting `HTTP_PROXY`, `HTTPS_PROXY` or `ALL_PROXY` [environment variables](https://manpages.debian.org/trixie/curl/curl.1.en.html#ENVIRONMENT):

```console
$ export ALL_PROXY=http://127.0.0.1:9081
```

If you prefer control those proxy via the CLI, pass your proxy address to the [`--proxy`](https://manpages.debian.org/trixie/curl/curl.1.en.html#ENVIRONMENT--proxy) (or `-x`) argument. I don't really have any preferences there though, you can use whatever methods you like.

Last thing, if you are using someone else IP address, you will probably need to deal with captchas. Indeed, Tor nodes are public and some companies are blocking them (in fact, that's a good practice, a company who wants to offer better privacy would probably use onion hidden services). If you got captchas, solving them with `curl` can be a real challenge, but you can easily found some crazy guys on the who who already worked on that, like [Solving CAPTCHA with cURL: A Step-by-Step Guide](https://www.capsolver.com/blog/All/solve-captcha-with-curl) by Lucas Mitchell or the [`curl-scraping`](https://github.com/DenimEvert/curl-scraping) project.

# HTTP Headers

When using substack, you will probably notice in the developer window a lot of requests. Those requests contain HTTP headers. Most of them will be required to mimic the behavior of the Substack web application. Not all are required, it will depend of the context.

- [`Accept`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Accept):  default to `*/*`, to be set with the `--header` curl flag;

- [`Accept-Encoding`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Accept-Encoding): default to `gzip, deflate, br, zstd`, to be set with the `--header` curl flag;

- [`Accept-Language`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Accept-Language): default to `en-US,en;q=0.5`, to be set with the `--header` curl flag;

- [`Cache-Control`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cache-Control): default to `max-age=0`, to be set with the `--header` curl flag;

- [`Content-Type`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Type): default to `application/json`, this header should be set only for `POST` and `DELETE` requests for now;

- [`Cookie`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cookie): this value is configured by curl with the help of the `-b` and `-c` flags;

- [`Priority`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Priority): set by default to `u=1, i`;

- [`Referer`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Referer): set by default to `https://substack.com/`;

- [`sec-ch-ua`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Sec-CH-UA): set with the name and the version of the browser, for example, in my case: `"Brave";v="147", "Not.A/Brand";v="8", "Chromium";v="147"`

- [`sec-ch-ua-mobile`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Sec-CH-UA-Mobile): set by default to `?0`;

- [`sec-ch-ua-platform`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Sec-CH-UA-Platform): set with your platform code name, for example on my case, on one of my Linux box: `"Linux"`;

- [`sec-fetch-dest`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Sec-Fetch-Dest): set by default to `empty`;

- [`sec-fetch-mode`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Sec-Fetch-Mode): set by default to `cors`;

- [`sec-fetch-site`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Sec-Fetch-Site): set by default to `same-origin`;

- [`sec-gpc`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Sec-GPC): set by default to `1`.

We can make our life a bit easier because most of those headers are statics and will probably never changes during across the HTTP requests. Creating environment variables can solve this issue, or even better, use [header files](https://manpages.debian.org/trixie/curl/curl.1.en.html#H,) with the `--headers` argument from `curl`.

```console
$ cat > headers.txt << EOF
Accept: */*
# be sure curl is compatible with gzip,
# deflate, br or zstd. Those encodings are
# the one set on Brave browser by default.
# If you receive a binary object from the
# Substack end-points, it will probably
# because of that.
Accept-Encoding: gzip, deflate, br, zstd
Accept-Language: en-US,en;q=0.5
Cache-Control: max-age=0
# Not all requests are sending data.
#   Content-Type: application/json
# The cookies are managed with -j and -c arguments
#   Cookie: 
Priority: u=1, i;
Referer: https://substack.com/
sec-ch-ua: "Brave";v="147", "Not.A/Brand";v="8", "Chromium";v="147
sec-ch-ua-mobile: ?0
sec-ch-ua-platform: "Linux"
sec-fetch-dest: empty
sec-fetch-mode: cors
sec-fetch-site: same-origin
sec-gpc: 1
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.3
EOF

$ curl -H@headers.txt ${target}
```

I invite you to read the headers specifications from the [Mozilla developer website](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers). It contains a lot of useful information, and will probably be more accurate than me.

# Authentication

Substack is using MFA with OTP code via e-mail. If your account was correctly created previously, you can try to log to the web interface. A JSON is required though, it will contain your email, and few other fields:

 - `email`: your email address as string

 - `redirect`: the redirected path as string

 - `can_create_user`: a boolean? I currently don't know this thing means.

The JSON object can now be sent to `https://substack.com/api/v1/email-login` end-point. Note: you should probably store the cookies you received in `cookie.txt` file.

```console
$ touch cookie.txt

$ export CURL_OPTS="-vLb cookie.txt -c cookie.txt -H@headers.txt"
```

The JSON object to authenticate via e-mail is kind simple, it has 3 fields, `email`, `redirect` and `can_create_user`.

```json
{
  "email": "x@vtmpj.net",
  "redirect": "/",
  "can_create_user": true
}
```

Let save that in `email_login.json` and use it with `curl`.

```console
$ cat > email_login.json << EOF
{
  "email": "x@vtmpj.net",
  "redirect": "/",
  "can_create_user": true
}
EOF

$ curl ${CURL_OPTS} \
  -H 'Content-Type: application/json' \
  -d @email_login.json \
  -X POST \
  https://substack.com/api/v1/email-login 
```

It should return this kind of JSON object, containing `verification_code` and `onboarding_redirect` fields.

```json
{
  "verification_code": "optional",
  "onboarding_redirect": null
}
```

After having executed this command, you should get an e-mail from substack  containing the 6 digits OTP code. If it's the case, you can send this code to the substack API to valid your authentication via OTP. The JSON object here is quite simple as well with 3 fields, where `code` is containing the OTP code received by mail, `email` containing the e-mail used for your `authentication` and `redirection` containing the URL to be redirected after a successful authentication.

```json
{
  "code": "764945",
  "email": "x@vtmpj.net",
  "redirect": "https://substack.com/"
}
```

Let store this object in `email_otp_login_complete.json` file for now.

```console
$ cat > email_otp_login_complete.json << EOF
{
  "code": "764945",
  "email": "x@vtmpj.net",
  "redirect": "https://substack.com/"
}
EOF 

$ curl ${CURL_OPTS} \
  -H 'Content-Type: application/json' \
  -d @email_otp_login_complete.json \
  -X POST \
  https://substack.com/api/v1/email-otp-login/complete
```

After this request, you should now have a valid authenticated cookie containing your session. On my side, the session received was valid for 90 days (~3months).

If your headers are not correctly configured (for example, you forgot to add the application type one), this kind of JSON object will be returned:

```json
{
  "errors": [
    {
      "location": "body",
      "param": "email",
      "msg": "Invalid value"
    },
    {
      "location": "body",
      "param": "code",
      "msg": "Invalid value"
    },
    {
      "location": "body",
      "param": "code",
      "msg": "Invalid value"
    }
  ]
}
```

While waiting for the OTP via e-mail, the application is sending a kind of ping.

```console
$ curl ${CURL_OPTS} \
  https://substack.com/api/v1/am_i_logged_in
```

During the session, I also discover the link sent by Substack in the e-mail to validate the logins stay valid for a long period of time (still not sure of the delay though). In fact, after 2 successful login via e-mail, the requests started to return this message:

```json
{
  "error": "Too many login emails",
  "type": "single"
}
```

If it's the case, it's probably mean the links from your e-mails are still active, and you can use them to fetch a session via `curl`.

```console
$ curl ${CURL_OPTS} \
  'https://email.mg-tx1.substack.com/c/${payload}'
```

The `${payload}` value is a base64uri string, probably encrypted (or random), used on the Substack side to validate the authentication. If this previous command is working, you should then be redirected to the website with a new session stored in the cookies.

Note: it seems Substack is using HTTP/3.

# Creating Content

Posting messages on Substack look straightforward, but it can be challenging due to the JSON object asked by the end-point. Here an example:

```json
{
  "bodyJson": {
    "type": "doc",
    "attrs": {
      "schemaVersion": "v1",
      "title": null
    },
    "content": [
      {
        "type": "paragraph",
        "content": [
          {
            "type": "text",
            "text": "On Friday, it’s Erlang day."
          }
        ]
      }
    ]
  },
  "tabId": "for-you",
  "surface": "feed",
  "replyMinimumRole": "everyone"
}
```

As you can see, Substack's post are following a specific schema. I'm not sure this is an open-source format, but you can find resources on the web for that, like the documentation from [`substack-api`](https://substack-api.readthedocs.io/api-reference/) on readthedocs. Anyway, let reuse that and past it in `message.json` then invoke `curl`.

```console
$ cat > message.json << EOF
{
  "bodyJson": {
    "type": "doc",
    "attrs": {
      "schemaVersion": "v1",
      "title": null
    },
    "content": [
      {
        "type": "paragraph",
        "content": [
          {
            "type": "text",
            "text": "On Friday, it’s Erlang day."
          }
        ]
      }
    ]
  },
  "tabId": "for-you",
  "surface": "feed",
  "replyMinimumRole": "everyone"
}
EOF

$ curl ${CURL_OPTS} \
  -H "Content-Type: application/json" \
  -X POST \
  -d @message.json\
  https://substack.com/api/v1/comment/feed
```

In case of success, you will receive a JSON object containing a lot of information:

```json{
  "user_id": 12345678,
  "body": "My awesome message",
  "body_json": {
    "type": "doc",
    "attrs": {
      "schemaVersion": "v1",
      "title": null
    },
    "content": [
      {
        "type": "paragraph",
        "content": [
          {
            "type": "text",
            "text": "My awesome message"
          }
        ]
      }
    ]
  },
  "post_id": null,
  "publication_id": null,
  "media_clip_id": null,
  "ancestor_path": "",
  "type": "feed",
  "status": "published",
  "reply_minimum_role": "everyone",
  "id": 12345678,
  "deleted": false,
  "date": "2026-06-19T11:00:00.000Z",
  "name": "Aragog",
  "photo_url": "https://substack-post-media.s3.amazonaws.com/public/images/5d26902d-0000-abcd-1234-e82c0d0e9d55_144x144.png",
  "reactions": {
    "❤": 0
  },
  "children": [],
  "userStatus": {
    "bestsellerTier": null,
    "subscriberTier": null,
    "leaderboard": null,
    "vip": false,
    "badge": null,
    "subscriber": null
  },
  "user_bestseller_tier": null,
  "isFirstFeedCommentByUser": false,
  "reaction_count": 0,
  "restacks": 0,
  "restacked": false,
  "children_count": 0,
  "attachments": [],
  "language": null,
  "autotranslate_to": null
}
```

Great, we have published our first post with `curl`. The interesting field for now from this payload:

- `user_id`: the identifier of the substack user, I think we can get it from another end-point, but it can be useful to have it;

- `body`: the body of the message published;

- `body_json`: the body using the Substack JSON format;

- `status`: the status of the post, if `published`, then the post can be seen by everybody;

- `id`: probably the post identifier, we will check that later;

- `date`: the publication UTC date;

- `name`: the name of the Substack user;

The rest is mostly details we don't care for now.

# Getting Content

Many end-points can be used to retrieve posts information, in our case, we want the one to fetch only one comment.

```console
$ curl ${CURL_OPTS} \
  https://substack.com/api/v1/reader/comment/${post_id}
```

The returned JSON object is huge. I will select only few of interesting fields.

```json
{
  "item": {
    "entity_key": "c-123456",
    "type": "comment",
    "context": {},
    "comment": {
      "id": 123456,
      "body": "...",
      "body_json": {},
      "user_id": 521046804,
      "type": "feed",
      "date": "2026-06-19T12:04:29.130Z",
      "reply_minimum_role": "everyone",
      "media_clip_id": null,
      "name": "Aragog",
      "bio": "...",
      "handle": "aragog",
      "reaction_count": 0,
      "reactions": {
        "❤": 0
      },
      "restacks": 0,
      "restacked": false,
      "children_count": 0,
      "attachments": [],
      "user_bestseller_tier": null,
      "userStatus": {},
      "language": "en",
      "autotranslate_to": null
    },
    "parentComments": [],
    "isMuted": false,
    "canReply": true,
    "trackingParameters": {}
  }
}
```

This object contains all information regarding the message we have posted on Substack, including lot of useful statistics.

# Deleting Content

Deleting content is easy, we can reuse the same end-point but using the DELETE HTTP method instead.

```console
$ curl ${CURL_OPTS} \
  -H "Content-Type: application/json" \
  -d '{}' \
  -X DELETE \
  https://substack.com/api/v1/comment/${post_id}
```

In case of success, the end-point returns a 200 HTTP code with an empty JSON object.

# Conclusion

The full reverse engineering of the Substack private API is far from done and more is coming. I think we will have a lot of surprises in the future with this one. This is another reason why testing is so important, and if you can store the results of those tests, it's even better.

In this article, you saw how to use `curl` to call a private API, with the help of the browser to generate the right call. A draft of the [Insomnia scratch pad](https://gist.github.com/niamtokik/4a52f58d4027cad5338d53b9c43c66c2) is available on Gist for now.

I am not the only one working on this kind of projects, few of them are even sharing their code sources:

- [`substack_api`](https://github.com/NHagar/substack_api) by [Nick Hagar](https://github.com/NHagar) on Github, an implementation in Python;

- [`python-substack`](https://github.com/ma2za/python-substack) by [Paolo Mazza](https://github.com/ma2za) on Github, another implementation in Python.

Anyway, this is the first publication of a long series about reverse engineering, and to be honest, I think starting our journey by reversing a public HTTP API is kinda easy. We don't have to deal with proprietary binary format or weird protocol designed in-house.

As usual, Hack well and have fun!

----

Cover Image by <a href="https://unsplash.com/@alain_pham?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Alain Pham</a> on <a href="https://unsplash.com/photos/construction-frame-P_qvsF7Yodw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>