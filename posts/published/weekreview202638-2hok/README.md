---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/weekreview202638-2hok"
comments_count: "1"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Fc6te98b5282h6ew0sur0.jpg"
created_at: "None"
crossposted_at: "None"
description: "Linkedin is a mess. While I started to write articles on dev.to, I also started to create scheduled..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/weekreview202638-2hok"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "weekreview202638-2hok"
social_image: "None"
title: "WeekReview#202638"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# WeekReview#202638

Linkedin is a mess. While I started to write articles on dev.to, I also started to create scheduled posts on Linkedin. It was working correctly until few days ago, when the "scheduler manager" just disappears. After 2 long hours to search where I could find a similar feature, I just stopped and started to use the "newsletter" feature from them. That's crazy to see how we are dependent of those services, and how they are treating us.

My feeds were quiet this week. Not a lot of interesting link to show.

Reflexion about Dart code design. What is the best way to design a module in Dart? It can be designed in many different ways, for example, the class can embed the methods to publish a post for example or delete it. In this case, the object must be instantiated first and then the methods can be called.

```dart
class Publication {
  int id;

  Publication({required this.id});

  Publication publish() => this;
  Publication delete() => this;
}

void main() {
  var pub = Publication(id: 1);
  pub.publish();
}
```

What about using a more functional way of doing that, by using the classes/objects as data-structures and passing them directly to functions outside of the class definition?

```dart
class Publication {
  int int;
  Publication({ required this.id });
}

Publication publish(Publication pub) => pub;
Publication delete(Publication pub) => pub;

void main() {
  var pub = Publication(id: 1);
  publish(pub);
}
```

Which method is the best? Well, I'm currently thinking to use the second one. The reason is simple, isolating side effect from the object itself, and function composition. Then, the object created can only be used with accessors, with some part of it in read-only or totally hidden. Anyway, I think it's mostly about coding style.

After few days of testing, using a mix of the two methods can be the best way. Another important part is how to name the module and how to organize the exported functions. Erlang, I miss you.

----

[![See a rumor that Mistral got hacked](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/e9gujunvkoqjevlrpi7v.png)](https://x.com/beniduboss/status/2100561129118265715?s=20)

Back in May 2026, I [tweeted](https://x.com/niamtokik/status/2056966992431649188) about the next threat that will come with OpenClaws and other LLMs used to remote control platforms. ~4 months later, [Mistral](https://mistral.ai/) has been hacked and it seems this is a serious issue. Unreleased code, entire code base and so on can now be found on tor. This is only the beginning, the next step is to infiltrate all layers, inject code and take control of the code produced by LLMs. Remember Linus Torvald saying "LLMs are just kind of compilers" few months ago? Well, if you can't trust your compiler, you can't trust what it produces, see ["Reflections on Trusting Trust"](https://people.cs.umass.edu/~emery/classes/cmpsci691st/readings/Sec/Reflections-on-Trusting-Trust.pdf) by Ken Thompson. What the next step after that? Control the servers where those LLMs are executing tasks, and it's only a matter of time. Good luck to all developers and admins who installed this crap on their servers, including laptops, test and dev machines. Oh, and by the way, [Mistral has been integrated in Firefox recently](https://mistral.ai/news/mistral-x-mozilla/), have fun and sleep well!

# Coding

📝 [**Dart Google Summer of Code 2026 results**](https://dart.dev/blog/google-summer-of-code-2026-results): a report for the Dart Google Summer of code. [**`package:ffigen`**](https://github.com/dart-lang/native/tree/main/pkgs/ffigen) looks promising and will help to create interface from c++ to dart. The other interesting project was [debugging improvements for pointers](https://github.com/TheNourhan/Dart-GSoC26).

📝 [**libsodium/Finite field arithmetic**](https://doc.libsodium.org/advanced/point-arithmetic): white searching a good cryptographic library for Dart (yeah, the ones available don't fit my needs), I read the `libsodium` documentation, especially the part on valid points.

📝 [**Pear Docs**](https://docs.pears.com/): yet another p2p system. This time, it has been mostly done in javascript, by [Holepunch](https://github.com/holepunchto/). Some note on the [protocol](https://github.com/Rightbracket/peeroxide/blob/main/libudx/PROTOCOL.md) can be also found on github from [libudx](https://github.com/holepunchto/libudx/).

📝 [**The "Clockwise/Spiral Rule"**](https://c-faq.com/decl/spiral.anderson.html): did not know this method to mentally parse C.

🌐 [**cdecl**](https://cdecl.org/): an online tool to decipher C language notation, also available as [CLI](https://github.com/paul-j-lucas/cdecl).

📝 [**OpenBSD vmm/vmd SMP support**](https://github.com/openbsd/src/commit/d74b165ebc85c9aaf5150f25e6088f52d9fc0f04): nice! We will be able to set the number of CPUs for a VM on OpenBSD, thanks to [Bryan Steele](https://x.com/canadianbryan/status/2101118786497548629?s=20) for the news.

# System

📝 [**Void Linux Maintainer Orphans 100+ Packages Over AI Policy Dispute**](https://www.phoronix.com/news/Void-Linux-AI-Policy-Orphan): the reason why I like [Void Linux](http://www.voidlinux.eu/).

🏗️ [**turbocrypt**](https://github.com/jedisct1/turbocrypt): A fast, easy-to-use, and secure command-line tool for encrypting and decrypting files , git repositories and directory trees.

📝 [**Crash-Safe & Copy-On-Write GEFS As The "Good Enough File-System" For OpenBSD**](https://www.phoronix.com/news/OpenBSD-GEFS-File-System): more than 10 years ago, HAMMER2 from DragonFlyBSD was planned to be ported to OpenBSD, but it never happened. This filesystem could be a good candidate to replace that. The [specifications](https://orib.dev/gefs.pdf) are looking good. The snapshot feature is really what is missing on many filesystems, including UFS.

# Database

🏗️ [**pgassistant project**](https://github.com/beh74/pgassistant-community): A PostgreSQL assistant for developers Understand, optimize, and improve your PostgreSQL database with ease.

# Network

📝 [**Overview of Passive Optical Networks (PONs) Security**](https://blog.quarkslab.com/overview-of-passive-optical-networks-pons-security.html): a deep introduction to optical network security, a lot of information there.

# Mathematics

📝 [**Finite time blowup with smooth forcing term for the incompressible porous medium, Boussinesq, and incompressible Euler equations**](https://terrytao.wordpress.com/2026/09/07/finite-time-blowup-with-smooth-forcing-term-for-the-incompressible-porous-medium-boussinesq-and-incompressible-euler-equations/comment-page-1/#comment-694321)

# Embedded

📝 [**The Great Pi Zero Showdown**](https://bret.dk/pi-zero-showdown/):  if you want to see benchmarks comparing different kind of Pi Zero implementation.

# Security

📝 [**The Hitchhiker's Guide to Online Anonymity (and Privacy)**](https://anonymousplanet.net/guide/)

📝 [**From APK to Source: Complete Android Reverse Engineering Workflow**](https://www.marginaldeer.com/blog/apk-reverse-engineering-workflow/): a succinct post containing the essential procedure to reverse engineer an android package (apk).

📝 [**Android APK Reverse Engineering: From APK to Source**](https://robinx0.github.io/blogs/mobile-security/apk-reverse-engineering/): another post listing the essential procedures to reverse an android package. 

🌐 [**Quarklabs' blog**](https://blog.quarkslab.com/index.html): lot of interesting articles about modern security (and programming).

📝 [**Devil’s advocate? Uncensored Luciferus AI service advertised underground**](https://www.sophos.com/en-us/blog/uncensored-luciferus-ai-service-advertised-underground): underground actors are selling uncensored LLMs. Good to know.

📝 [**The XSS inside your favorite iOS app**](https://v12.sh/blog/webkit): XSS can also be found in mobile application via WebView for Android and MKWebView for iOS. Good to know because one of my project is using WebView, hardening this part could be a good idea.

📝 [**HEIF Heist, One image parser to pwn them all**](https://heif-heist.com/): the story behind [`libheif`](https://github.com/strukturag/libheif) library vulnerability exploitation. Announced by [Harsh Jaiswal (@rootxharsh)](https://x.com/rootxharsh/status/2100801820960620574?s=20) on X/Twitter.

📝 [**Browser Forensics: Analyzing Suspicious Extensions with ExtAnalysis**](https://hackers-arise.com/browser-forensics-analyzing-suspicious-extensions-with-extanalysis/)

# Security/cryptography

📝 [**It's 255:19AM. Do you know what your validation criteria are?**](https://hdevalence.ca/blog/2020-10-04-its-25519am/): when I was looking for an up to date list of invalid or low-order public keys, I found this post. It seems most of the ed25519 on the market are not compatible with the [RFC8032](https://datatracker.ietf.org/doc/html/rfc8032) (Edwards-Curve Digital Signature Algorithm (EdDSA)), mostly due to design issue and also because the RFC came after all implementations. That's actually a huge portability problem and a security issue as well. 

# Security/RedTeam

📝 [**Advanced Techniques for Bypassing Modern Web Application Firewalls**](https://hetmehta.com/posts/Bypassing-Modern-WAF/): a very long list of attacks for bypassing WAF.

📝 [**JSON Interoperability Vulnerabilities: A Deep Dive**](https://hetmehta.com/posts/json-interoperability-vulnerabilities/): we tend to think JSON is secure because of its simplicity, portability and its presence everywhere. This article list different kind of vulnerabilities that can be found on JSON serializers. interesting.

[**Guesttohost:escapingDocker'shypervisor**](https://www.accomplish.ai/blog/escaping-dockers-hypervisor/): docker hypervisor escape on MacOS, due to virtio-fs. ingenious way to get out of a container.

# Update/Upgrade

🔄 [**Phoenix 1.8.14**](https://github.com/phoenixframework/phoenix/releases/tag/v1.8.14): bug fixes

🔄 [**RabbitMQ 4.3.6**](https://github.com/rabbitmq/rabbitmq-server/releases/tag/v4.3.6): bug fixes and enhancements.

🔄 [**Erlang/OTP 29.1**](https://github.com/erlang/otp/releases/tag/OTP-29.1): many bug fixes and security issues. No new features.

🔄 [**OpenSMTPD 7.9.0p0 released**](https://undeadly.org/cgi?action=article;sid=20260916093956): bugs fixes and hardening.

# Embedded

📝 [**Biodegradable PCBs – The Future of Sustainable Electronics**](https://www.venture-mfg.com/what-is-biodegradable-pcbs/): good to know, we can now create biodegradable PCBs. Not sure if it's a good thing for the environment (e.g. heavy metals, polymers), but it's a first step.

# Misc

🌐 [**BOB Conf**](https://bobkonf.de/2027/en/)

📝 [**On-device intelligence for every product**](https://desertant.com/blog/introducing-desert-ant-labs/)

🏛️ [**Tools for Thought**](https://cel.cs.brown.edu/csci-1377-s26/)

📑 [**Theory Is All You Need: AI, Human Cognition, and Causal Reasoning**](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4737265): Here a part of the abstract.

> Scholars argue that artificial intelligence (AI) can generate genuine novelty and new knowledge and, in turn, that AI and computational models of cognition will replace human decision making under uncertainty. We disagree. We argue that AI’s data-based prediction is different from human theory-based causal logic and reasoning. We highlight problems with the decades-old analogy between computers and minds as input–output devices, using large language models as an example. Human cognition is better conceptualized as a form of theory-based causal reasoning rather than AI’s emphasis on information processing and data-based prediction.

📝 [**Iran strikes on Amazon data centers caused permanent loss of customer data**](https://arstechnica.com/gadgets/2026/09/iran-strikes-on-amazon-data-centers-caused-permanent-loss-of-customer-data/): the cloud during war becomes foggy.

📝 [**Intel Appears To End Its Bug Bounty Program**](https://www.phoronix.com/news/Intel-Bug-Bounty-Program-Ends): if it's the case, why? It could be due to the amount of false-positive bugs found with LLMs, it can have a really huge impact on developers team. Curious to know more about the reason.

----

![Not quite my frequency](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/x8bd72e8nbdn9j7gl0os.png)

![Chad third-party scraper](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/hqd9aqsrg5aeysz6u7iz.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/btb4plhke9lwxb2rsx4b.png)

![A matrix timeline](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/2y7newo6ye22wpwk6cc5.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/t48h1f60b2vqqnziferg.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/d13wpdezq9pd2t2gm065.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/9jxlnihosozeidc592m7.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/k4jfp1syvtgltv2tzg04.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/vyhlqk4lvbfiwiwat2cz.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/jl8ibwsytp9v6qv6lrv4.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/dxopwf5dwwotc9stv0gl.png)



----

Cover Image by <a href="https://unsplash.com/@sunira?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Sunira Moses</a> on <a href="https://unsplash.com/photos/orange-and-green-pumpkins-on-blue-plastic-container-XZ83-3HJei0?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>