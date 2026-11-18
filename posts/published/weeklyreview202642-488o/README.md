---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/weeklyreview202642-488o"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2F18432czuxjoxklpm6cyx.jpg"
created_at: "None"
crossposted_at: "None"
description: "While reading \"No way to prevent this\" say users of only language where this regularly happens, yet..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/weeklyreview202642-488o"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "weeklyreview202642-488o"
social_image: "None"
title: "WeeklyReview#202642"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# WeeklyReview#202642

While reading [_"No way to prevent this" say users of only language where this regularly happens_](https://xeiaso.net/shitposts/no-way-to-prevent-this/memory-safety/CVE-2026-92392/), yet another complaining about C code, I was thinking... During the past 20 years, many solutions have been created, but only a few C developers are using them. More recently, the [fil-c](https://fil-c.org/) was created to make C memory safe, hopefully it will be used in the future. The compilers are way better than 20 years ago, and for example, it is now possible to easily export the AST of any C project with clang/llvm. Even more, many compilers are now offering their own tools like static analyser to check the code. In fact, I was currently using few them to test my own pet project sandbox, and it's amazingly pleasant to code with all the flags and all those tools. So, why should we rewrite everything in rust, go or any other "modern" language if the AST is available, and we have ways to convert existing C/C++ code into a safer binary version?

Let's go back to the article, the [CVE-2026-92392](https://curl.se/docs/CVE-2026-92392.html) is an use after free bug, a classical mistake anyone do at least one time in its developer life. [fil-c](https://fil-c.org/) fixes that, but let's go a bit deeper. C is known to be an interface to low-level language (assembly) and will let you do whatever you want, it means the memory management must be done manually, like any other resources. It's a complex task, and can become a nightmare when dealing with concurrency. Why not using a pattern above that, always in charge to deal with those resources... Oh, wait, it's a kind of garbage collector, right? Or perhaps a kind of state machine, where the state is a resource that can be opened, used or closed. Anyway, adding another layer will increase the complexity of the existing code, but using something like fil-c could really help a lot.

----

A part of my free-time was dedicated to find design inspiration with Flutter. Thanks to [Flutter Awesome](https://flutterawesome.com), a long list of open-source Flutter projects can be checked! Here a quick list with the ones I liked the most 

- [`flutter_social_chat`](https://github.com/alperefesahin/flutter_social_chat): A simple chat compatible with iOS and Android. The design is really cool.

- [`OstrichGram`](https://github.com/OstrichGram/OstrichGram): a desktop (linux/windows) Nostr client.

- [`dash_chat_2.1`](https://github.com/droperr/dash_chat_2.1): an interesting library with many reusable widgets.

- [`Flutter-Music-Player-App-With-BLoc`](https://github.com/Hamad-Anwar/Flutter-Music-Player-App-With-BLoc): I like the clean MVC organization of this application and the fact there is no route defined, only a navigator pushing screen between context.

- [`bloc_flutter_app`](https://github.com/Suzefa/bloc_flutter_app): another example application using the Bloc pattern.

----

I was playing with the Erlang ssh key interface with Elixir (I wrote an article on that in a French magazine on this topic, but with Erlang). Let generate a public/private key.

```console
$ ssh-keygen -f t.key -t ed25519
...
Your identification has been saved in t.key 
Your public key has been saved in t.key.pub 
...

$ file t.key.pub
t.key.pub: OpenSSH ED25519 public key
```

Then, we can use parse and validate it. We are using the [`:ssh_message`]()https://github.com/erlang/otp/blob/master/lib/ssh/src/ssh_message.erl Erlang module (undocumented) and the [`:public_key`](https://www.erlang.org/doc/apps/public_key/public_key.html) Erlang module to convert it from one format to another one.

```elixir
# open the file, it can also from any kind of String.()
# element
File.read!("/t.key.pub")

# Split the key with null char, it should returns a list
# of 4 elements
#   ["ssh-ed25519", pubkey, comment, ""]
|> then(&Regex.split(~r"\s+", &1)) 

# Returns only the pubkey
|> Enum.at(1)

# SSH public key is base64 encoded, decode it.
|> Base.decode64!()

# parse the result with ssh2_pubkey_decode/1 function.
# it returns something like that:
#   {{:ECPoint, ecpoint}, {:namedCurve, {1, 3, 101, 112}}}
|> :ssh_message.ssh2_pubkey_decode()

# this part is to convert it in PEM format (TLS)
# the firs step is to create an entry with the correct
# ASN1 type (e.g :SubjectPublicKeyInfo)
#   {:SubjectPublicKeyInfo, pubkey, :not_encrypted}
|> then(&:public_key.pem_entry_encode(:SubjectPublicKeyInfo, &1))

# the final step is to finalize the PEM encoding
#   "-----BEGIN PUBLIC KEY-----\nbase64\n-----END PUBLIC KEY-----\n\n"
|> then(&:public_key.pem_encode([&1]))
```

----

# Coding

📝 [**Introduction to Compilers and Language Design, Second Edition**](https://dthain.github.io/books/compiler/compilerbook.pdf): what a great book! It covers all compiling steps, from scanning, parsing, code generation and optimization.

📖 [**Write You a Haskell**](https://sdiehl.github.io/write-you-a-haskell/): yet another book in Haskell.

📝 [**Arena Allocators in C**](https://eliasebner.com/blog/guides/arena-allocators-in-c/): implementing memory allocators in C can be challenging, here a nice article on how to write one using [region-based memory management](https://en.wikipedia.org/wiki/Region-based_memory_management) technique or arena allocator

🏗️ [**eyelang**](https://eyereasoner.github.io/eyelang/): An experimental symbolic logic programming language using a practical subset of Prolog syntax and .pl files, with query explanations and executable checks.

📝 [**Concentrated Liability**](https://ash-hq.org/blog/concentrated-liability/): a security audit report on Ash framework using LLMs.

📝 [**Generic Dynamic Arrays in C**](https://eliasebner.com/blog/guides/generic-dynamic-arrays-in-c/): Another great article by Eliase Ebner.

📝 [**Why C Strings Suck And How I Fixed Them**](https://eliasebner.com/blog/guides/fixing-strings-in-c/): A good way to fix C strings. I like it.

📝 [**Some Advice for Software Developers in the Age of Large Language Models**](https://eliasebner.com/blog/thoughts/advice-for-software-developers-with-large-language-models/): This post has many good points regarding LLM, especially the quote below. Indeed, I already saw that in a previous position, someone losing many weeks of developing, switching and switching between LLMs to solve a problem.

> what are you going to do when the LLM reaches its limit [...] and you are left having to solve the issue on your own? Ask a different LLM? And if that fails? Who are you going to turn to?

📝 [**C Socket Programming in Linux: Build a TCP Client & Server (Complete Guide)**](https://eliasebner.com/blog/guides/c-sockets-from-scratch/): this blog has really nice article! A must read for the one who wants to learn more about C programming!

🌐 [**Competitive Programming Hall Of Fame**](https://www.cphof.org/):  a project created to preserve the history of international championships in competitive programming. This website collects the results of final stages for both worldwide and regional contests. By international championship we mean a contest consisting of several stages available for competitors from more than one country.

# System

📝 [**FreeBSD Cope with Signal Fuckup**](https://vermaden.wordpress.com/2026/10/10/freebsd-cope-with-signal-fuckup/): installing signal on FreeBSD using chrooted environment. It would have been better to use a jail there, but it looks okay.

📝 [**We can harden C**](https://cybersect.substack.com/p/we-can-harden-c): why talking about rust or IA, again? If you want to increase the security of you C application, the first step is to enable all warnings and errors, but also all security features offered by your favorite compiler. It will less fun - because the compiler will blame you for every weird stuff you are doing - be the result will be way better. The next step is to ALWAYS code in C with the help of a small test suite framework like [`munit`](https://nemequ.github.io/munit/) or [`minunit`](github.com/siu/minunit/tree/master). Easy to install and easy to use, it will easier to create your tests and design your application. Finally, don't forget to use the modern tools available on [`gcc`](https://gcc.gnu.org/) or [`llvm`](https://llvm.org/), like [static analyzers](https://clang-analyzer.llvm.org/). Not everything will be fixed though, and if you need a really strong application, you should check the security features offered by FreeBSD ([capsicum](https://man.freebsd.org/cgi/man.cgi?query=capsicum)), OpenBSD ([pledge](https://man.openbsd.org/pledge), [unveil](https://man.openbsd.org/unveil)) or Linux. Anyway, C hardening can be challenging, not because of the complexity, but more because of our ignorance about all the tools available.

📝 [**Building OCI Images Without a Daemon or a Dockerfile**](https://www.opensourceprojects.dev/post/buildah): how to build OCI image from scratch, here the repository on [github](https://github.com/podman-container-tools/buildah).

📝 [**Understanding the Linux Kernel: Namespaces**](https://internals-for-interns.com/posts/linux-kernel-namespaces/): yet another article on the namespaces.

📝 [**Your Computer Memory Is A Lie**](https://hackaday.com/2026/10/12/your-computer-memory-is-a-lie/): a post doing a summary of the problems involving memory (in general).

# Database

📑 [**Distributed Datalog at Scale with Worst-Case Optimal Joins**](https://arxiv.org/pdf/2610.12692)

🏗️ [**pglifecycle**](https://github.com/gmr/pglifecycle):  keeps your database schema in a version-controlled project of YAML files — one file per database object, validated against a JSON-Schema contract — and moves schema between the repository and live databases.

# security

📝 [**Big Fish: Exploiting a 37-Year-Old Kernel Bug in OpenBSD**](https://calif.io/research/big-fish): an interesting report about one of the security issues recently published on OpenBSD. This is a nasty issue, present there for more than 3 decades.

🌐 [**zr.ax**](https://zr.ax/): classifies executables and raw firmware, with interactive Hilbert entropy maps, a hex inspector, and batch analysis. via [Kenan Sulayman](https://x.com/in19h/status/2109069625862570330?s=20)

📝 [**Azure's Weakest Link - Five Full Cross-Tenant Compromises**](https://binsec.no/posts/2026/10/one-root-case): oof. a violent and nasty security issue on azure cloud that can extract user secret via a craft URL encoded path.

📑 [**Hardware-Assisted Rootkits: Abusing Performance Counters on the ARM and x86 Architectures**](https://www.usenix.org/conference/woot16/workshop-program/presentation/spisak)

📝 [**Fingerprints are the new cookies**](https://royfish.dev/fingerprints-are-the-new-cookies)

📝 [**Confessions of a Professional Hacker: Can the CIA or other Intelligence Agencies Track My Every Move?**](https://hackers-arise.com/confessions-of-a-professional-hacker-can-the-cia-or-other-intelligence-agencies-track-my-every-move-2/): yes. Any state agencies with enough resources can track anybody without any problem. It's becoming very hard to be protected against that, even without any digital devices, you are becoming a target.

📝 [**A story of wifi secrets, UART lockdowns and a damaged flash memory chip**](https://adepts.of0x.cc/eufy-homestation2-firmware/)

🏗️ [**openwrt-one-sdr**](https://github.com/alphafox02/openwrt-one-sdr): Turns an OpenWrt One router into a wideband, receive-only software-defined receiver. The board's MediaTek MT7981B Wi-Fi SoC (with an MT7976 radio front end) captures raw 14-bit IQ from the 2.4 and 5 GHz bands at 40 Msps, the dual Cortex-A53 streams it over the 2.5 GbE port as VITA 49, and a Linux host shows it as a live spectrum and waterfall in the browser.

# Security/Cryptography

🌐 [**ecdsa.fail**](https://ecdsa.fail/)

# Security/Red-Team

🏗️ [**exploit-watch-archive**](https://github.com/dinosn/exploit-watch-archive): durable, private aggregation of the exploit/PoC source repos tracked by the exploit-watch monitoring task.

# Embedded

📝 [**The FPGA Chronicles: Ready To Probe**](https://hackaday.com/2026/10/13/the-fpga-chronicles-ready-to-probe/)

📝 [**Another Wireless Chip Has A Hidden SDR Revealed**](https://hackaday.com/2026/10/15/another-wireless-chip-has-a-hidden-sdr-revealed/): some ESP32 chips are embedding SDR feature. It looks provising.

# Update/Upgrade

🔄 [**OpnSense**](https://x.com/abraxas_null/status/2110120094810693729?s=20): 7 remote exploits. Some of them looks really dangerous, please update.
- [opnsense-firmware-mirror-sed](https://github.com/abraxas/opnsense-firmware-mirror-sed)
- [opnsense-tunables-loader](https://github.com/abraxas/opnsense-tunables-loader/)
- [opnsense-uidfield-system-uid0](https://github.com/abraxas/opnsense-uidfield-system-uid0)
- [opnsense-ntp-gps-fudge](https://github.com/abraxas/opnsense-ntp-gps-fudge)
- [opnsense-wlan-wpa-line](https://github.com/abraxas/opnsense-wlan-wpa-line)
- [opnsense-captive-lastseen-roam](https://github.com/abraxas/opnsense-captive-lastseen-roam)
- [opnsense-tunables-loader](https://github.com/abraxas/opnsense-tunables-loader)

🔄 [**pfSense**](https://x.com/abraxas_null/status/2110041481365057758?s=20): pfSense seems to have been impacted as well.
- [pfsense-qinq-parent-if](https://github.com/abraxas/pfsense-qinq-parent-if)
- [pfsense-openvpn-wizard-crlf](https://github.com/abraxas/pfsense-openvpn-wizard-crlf)
- [pfsense-limiter-number](https://github.com/abraxas/pfsense-limiter-number)
- [pfsense-carp-vhid](https://github.com/abraxas/pfsense-carp-vhid)
- [pfsense-ipsec-login-banner](https://github.com/abraxas/pfsense-ipsec-login-banner)

🔄 [**Erlang/OTP 29.1.2**](https://github.com/erlang/otp/releases/tag/OTP-29.1.2): bugs and security fixes.

# Leaks of the week

📝 [**Meta**](https://frenchbreaches.com/blog/fuite-de-donnees-chez-meta-1-500-personnes-touchees-apres-un-piratage-sur-github): 1500 people impacted after github repositories hacked.

📝 [**MaQuestionMedicale**](https://frenchbreaches.com/blog/noms-numeros-de-secu-conversations-medicales-ce-que-revele-le-piratage-de-maquestionmedicale): 96000 people impacted, 369k private messages, with name, phone number, and more.

📝 [**Solution30**](https://frenchbreaches.com/alertes/solutions-30-mv5nto6keh511e3t4k7): more than 10millions identifiers impacted, 11 millions phone number, 2 millions e-mail address.

🐦 [**Canva**](https://x.com/H4ckmanac/status/2110981593758056679?s=20): 200 millions database rows including enterprise license, and orders.

🐦 [**Sourcenext Corporation**](https://x.com/H4ckmanac/status/2110686001337127028?s=20): 22.5 millions customer records including name, phone numbers, e-mail addresses, passwords, postal address...

# Misc

📝 [**I don't understand this whole idiotic concept of "don't use AI for X".**](https://lkml.org/lkml/2026/10/13/3242): The problem is not the LLM/AI per se, but where the computation is made. A compiler and most of the software a developer is using are hosted on their own laptop or on a server they are owning. The result is their own binaries, on their own infrastructure. Today, most - if not all - LLMs are being used through big companies (e.g. Google, Microsoft, Apple, Meta, Anthropic and so on), where the definition of "freedom of usage" is globally incompatible with open-source software. Yes this is a tool, but a tool one is using remotely, on servers no one controls. That's crazy someone like Torvalds does not understand that. When local-LLMs will be working correctly, I think it will be huge win for the open-source world, but for now, this is a future trap.

----

{% embed https://x.com/Gossip_Goblin/status/2109301986189324775/video/1 %}

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/cm51wjmpwh1xjnl774e6.png)](https://x.com/gmkurtzer/status/2109302135846555882?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/k9hdlme2qwtlx6g9oryy.png)](https://x.com/johnennis/status/2108958121133510760?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/2fi0gr41j8te8w313r8z.png)](https://x.com/a_musingcat/status/2109447042460479703?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/jmn4f5i9pvzhwjs54iku.png)](https://x.com/msimoni/status/2109349273234231676?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/qpft37pzuzit04n6l5xh.png)](https://x.com/CodeWisdom/status/2109597719983517740?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/guhwd5vzj6pp8hihctkm.png)](https://x.com/mcnabbd/status/2109341118550991034?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/5cxrotftuim3yvz39tpq.png)](https://x.com/jiratickets/status/2109764284972679404?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/ukhmp73oizdp9k2m7ly9.png)](https://x.com/badcop_/status/2110083558215975161?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/g66xdc1ey0hydfq25z8k.png)](https://x.com/aiandcloud/status/2110164468244140205?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/vth8oftp5z5duxn1pd2v.png)](https://x.com/herrmann1001/status/2110199064822489351?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/h3379l2zp16l6g76lc57.png)](https://x.com/chrisbanes/status/2109919479388160087?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/oyuabd16tp6mxxhpr843.png)](https://x.com/CodeWisdom/status/2110340681759658408?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/t8llr2mfohwjfn2om9zg.png)](https://x.com/OfMikeAndMen/status/2110708163112759448?s=20)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/jbk9o6fa0t6vbg21i9t6.png)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/jl7dtwkf5egudk3ja41h.png)](https://x.com/ThePrimeagen/status/2111100293941219644?s=20)

----

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/qhe4j9n231xpb16poodt.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/5hfkiq1mlsecg906pw5d.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/l5s28y84tvf8gerh5x7n.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/4zpk3xzdyhvbpgfa9g8b.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/hi8ft4pot03jaa258d9a.png)

----

Cover Image by <a href="https://unsplash.com/@freestocks?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">freestocks</a> on <a href="https://unsplash.com/photos/pumpkin-between-lighted-candles-kVv8AvoKJ7g?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
