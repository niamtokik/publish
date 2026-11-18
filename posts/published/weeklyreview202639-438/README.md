---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/weeklyreview202639-438"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Ff5rxo3jkjjw0dmapn7a8.jpg"
created_at: "None"
crossposted_at: "None"
description: "A lot of links this week... And I did not have the time to read them all! Enjoy!     Managing..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/weeklyreview202639-438"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "weeklyreview202639-438"
social_image: "None"
title: "WeeklyReview#202639"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# WeeklyReview#202639

A lot of links this week... And I did not have the time to read them all! Enjoy!

----

Managing scheduled posts on Linkedin changed during the past weeks. I finally got my answer from the documentation. To have access to the scheduled posts, one should start to write a new post, at the bottom of the window, a calendar icon should be present (with a number on right). Click on it and you will be able to see your scheduled post. I think Linkedin is looking for UI/UX engineers.

----

[`ribs`](https://cranst0n.github.io/ribs/) is probably one of the most fascinating functional library available for Dart and Flutter. I started to play with it last week, but there are so many things to say about it, I don't even know how to start. [cranst0n](https://github.com/cranst0n) did an amazing work, but the learning curve is crazy.

----

One of my past interview for a Senior Elixir Backend Developer position was successful, but a technical interview including a coding test is required. My Elixir skill is rusty, my last professional usage of this language was 3 years ago, and during the past years, Erlang was my main programming language. The crust of rust is even bigger because during the past months, Dart and Flutter were my targets... Anyway, if you are reading these messages, you already know I code in Elixir (my last article on standalone http server with Bondy is a proof), but it can be hard to remove the habits from a very similar language like Erlang, even more during an interview. The backend of my main mobile application will use Elixir and Phoenix, but it is the right time... but I have an issue.

Last week, my VPNs got some issues related to certificate, and the way I manage them is a bit crappy (`easy_rsa` from openvpn toolbox). This certificate management issue is recurrent, and every 2 or 3 years, it cost me few hours to cleanup and update things. Why not storing those certificates in a postgresql database managed by Elixir? In fact, it could also be a good way to receive alerts when a CA or a client certificate expires, and automatically renew them? Well, welcome to another project called [`expki`](https://github.com/niamtokik/expki). Again, it's not planned to be prod ready, but more to let me code like I want and relearn Elixir best practices. Perhaps you will find the source code interesting though... right?

In fact, my 2 or 3 coding sessions on this project were very interesting. For example, I thought the interoperability with Erlang with smooth, but it's not the case for everything. Here a concrete use case (a post will be published about that). The [`public_key`](https://www.erlang.org/doc/apps/public_key/public_key.html) Erlang module is in charge of dealing with all the asymmetric cryptography algorithms (e.g. RSA, DSA, DSS, ECC...) and their format (PEM, DER). Because this code is fully in Erlang, it also uses a lot of `macros` and `records`.

The records can "easily" be used in Elixir with the help of the [`Record`](https://elixir.hexdocs.pm/Record.html) module, except if those records are starting with an uppercase character. Indeed, the `Record` module will convert the records into a function, but the functions in Elixir can't use a name starting with an uppercase character. How to fix this problem then, because the [`public_key`](https://www.erlang.org/doc/apps/public_key/public_key.html) module defines more than 150 records following this pattern. Well, I did my own implementation, and instead of creating a function, it extends a module. The example below creates a [`Expki.PublicKey.RSAPrivateKey`](https://github.com/niamtokik/expki/blob/master/apps/expki/lib/expki/public_key/rsa_private_key.ex) using the [`Expki.PublicKey`](https://github.com/niamtokik/expki/blob/master/apps/expki/lib/expki/public_key.ex) module as template.

```elixir
defmodule Expki.PublicKey.RSAPrivateKey do                                                                                                                                                                                                                                                                                  
  use Expki.PublicKey, name: :RSAPrivateKey, pem: true                                                                                                                                                                                                                                                                      
end
```

When executed, this snippet will create an Elixir `Struct` called `%Expki.PublicKey.RSAPrivateKey{}` containing the fields from the Erlang records and also creates few helper functions:

- `RSAPrivateKey.name/0`: returns the name of the record as an `atom()`;

- `RSAPrivateKey.length/0`: returns the full length of the record including its name;

- `RSAPrivateKey.fields/0`: returns record's fields and their default value;

- `RSAPrivateKey.keys/0`: returns record's keys;

- `RSAPrivateKey.convert/1`: convert a `%RSAPrivateKey{}` Elixir truct into a `#RSAPrivateKey{}` Erlang record, and vice versa;

- `RSAPrivateKey.convert!/1`: same than the previous function, but throw an error in case of issues;

- `RSAPrivateKey.is_valid?/1`: check if a record is valid or not;

- `RSAPrivateKey.pem_entry_encode/1`: extra-function added to help encoding a `%RSAPrivateKey{}` into a PEM entry;

- `RSAPrivateKey.pem_entry_decode/1`: extra-function added to help decoding a PEM entry and convert it into a `%RSAPrivateKey{}` struct.

Then the [`macros`](https://www.erlang.org/doc/system/macros.html). This part is a challenging one, because the `macros`, and especially the `-define` annotations, are dynamically loaded when [`epp`](https://www.erlang.org/doc/apps/stdlib/epp.html) (the Erlang PreProcessor) is reading the source code. The macros are then expended, but never really returned. The only way to have a list of available macros is to call the [`epp` server](https://github.com/erlang/otp/blob/OTP-28.5/lib/stdlib/src/epp.erl#L790) started with [`epp:open/1`](https://www.erlang.org/doc/apps/stdlib/epp.html#open/1) function, and sending an undocumented message to it. Yeah, that's a bit dirty... and why do I would like to do that? Well, because, again, the [`public_key`](https://www.erlang.org/doc/apps/public_key/public_key.html) module  is using a lot of `-define` macros to store X509-like standard informations for the certificates.

All my researches and notes can be seen in the repository, in the [notes](https://github.com/niamtokik/expki/tree/master/notes) directory.

----

It was not really planned, but I also worked a bit on the [Awesome Erlang List](https://github.com/erlang-punch/awesome-erlang) via Erlang Punch. Managing with so many resources is a huge issue, and it's not easy to manage a simple markdown file. 2 years ago, I started to write a solution using a text-like database, but it was just not the right way to do. Then, I started to move those resources into Erlang Terms, again, it was hard to maintain. Finally, I decided to use yaml for now. A [`db.yaml`](https://github.com/erlang-punch/awesome-erlang/blob/master/db.yaml) is now available at the root of the project, it contains the whole list of resources and will be used to generate also README.md file and few JSON files for indexing purpose.

The concept behind the Awesome List is great, but it's hard to update, and not a lot of people have the time to do it. What could be nice is to provide a simple web interface (with authentication) allowing creators to put their project easily. The `awesome` directory is containing an Erlang application/release with the goal of doing that, but it was never finished. Hopefully one day I will have more free time to do it.

# Coding

📝 [**Instant-Launch Erlang Executables - Peer Stritzinger | Code BEAM Lite Stockholm 2026**](https://www.youtube.com/watch?v=4xfcVv3yn9E): a talk about `rebar3` [`calzone`](https://github.com/stritzinger/rebar_calzone) module to create Erlang binaries and speeding-up the boot process. The idea is to preload the data and store them in the memory using [`mmap`](https://www.man7.org/linux/man-pages/man2/mmap.2.html). It's an alternative to `escript`.

▶️ [**Going CPU Bound - David Klemenc | Code BEAM Lite Stockholm 2026**](https://www.youtube.com/watch?v=vqi-JCO_Ia8): a quick review and history of optimizing logging in Elixir.

🏗️ [**BootLife**](https://github.com/0xAX/BootLife/tree/master): Conway's Game of Life running directly from a 512-byte x86 boot sector, using VGA memory as the simulation grid. By [Alex Kuleshov](https://x.com/0xAX/status/2101663120146256052?s=20).

🏗️ [**PON-BEAM — Notification-Oriented BEAM Virtual Machine**](https://github.com/matheuscamarques/pon_beam): PON-BEAM is a complete re-architecture of the Erlang/OTP Virtual Machine (ERTS — Erlang Run-Time System) using the Notification-Oriented Paradigm (PON).

🌐 [**beeceptor**](https://beeceptor.com/): a service to mock API, easy to use, fast. Perfect to implement and test http clients.

🌐 [**AsmGrid**](https://asmjit.com/asmgrid/): a complete list of all opcode from x86, amd64 and ARM, from [**AsmJit**](https://asmjit.com/), the library used by the BEAM for its JIT.

📝 [**How I converted GenLatte to fullstack Dart**](https://flutter.dev/blog/converted-genlatte-fullstack-dart): A quick feedback regarding nodejs/javascript conversion to Dart. Discovered the [`freezed`](https://pub.dev/packages/freezed) package while reading this post.

📝 [**Turning the HEIC decoder into a SHA-256 computer**](https://www.irisc2.com/blog/heic-hashquine): a crazy post about the method to decode [HEIC](https://en.wikipedia.org/wiki/High_Efficiency_Image_File_Format) format. An HEIC decoder can be seen as a machine, having its own instruction, in this article, the author use them to generate the SHA256 hash of the image itself. Impressive.

📝 [**Type Safe Generic Data Structures in C**](https://danielchasehooper.com/posts/typechecked-generic-c-data-structures/): adding type safety in C is possible, but it's usually hard. I think this post is proving me wrong.

📝 [**A Fast, Growable Array With Stable Pointers in C**](https://danielchasehooper.com/posts/segment_array/): another article by the previous author introducing a dynamic array with constant time indexing and stable pointers. Also known as "levelwise-allocated pile" or "segmented list".

# System

📝 [**Simple Optimization For Linux 7.4 Can Open Files For Reading ~39% Faster**](https://www.phoronix.com/news/Linux-7.4-Faster-Do-Open): interesting optimization case. 

📝 [**Linux Process and Thread Creation: System Call Architecture**](https://chessman7.substack.com/p/linux-process-and-thread-creation?r=l7k4t)

📑 [**Netkit: Specializing Linux Packet Delivery for Container Networks**](https://arxiv.org/pdf/2609.18633): decreasing network latency for containers using ePBF optimization.

📑 [**DDB: Source-Level Interactive Debugging for Distributed Applications**](https://arxiv.org/pdf/2607.06107): 

🏗️ [**AnyPS5**](https://github.com/boykopovar/AnyPS5):Convert PS5 executables to run natively on Linux and Windows. The PS5 is using the same architecture than a PC (same for the Nintendo Switch), it runs on a modified version of FreeBSD (same for the Nintendo Switch), so, it was a matter of time before having a project porting games on Linux/Windows. A good thing, to be honest! Wait and see!

# Hardware

📝 [**"Supply Shortage Problem Has Disappeared": Acer CEO Says Memory Prices To Decline In 2027 As CXMT Starts Mass Production Of New Chip Platform**](https://www.zerohedge.com/markets/supply-shortage-problem-has-disappeared-acer-ceo-says-memory-prices-decline-2027-cxmt): RAM price could decrease during the next coming months.

# Network

📝 [**DIY Router On X86 E-Waste: OpenWrt And OPNsense**](https://hackaday.com/2026/09/21/diy-router-on-x86-e-waste-openwrt-and-opnsense/): Ah! A refreshing article on old-hardware reused to create routers! OpenWrt and OPNsense are the easy solution, if one want to really use a small system (but doing everything by hands), it should use FreeBSD, NetBSD or OpenBSD directly. This article reminds me when I was looking for old computers in the trashes... Nice!

# Database

🏗️ [**postgrex**](https://github.com/elixir-ecto/postgrex): the official postgresql connector used by Ecto. Putting the link here because I'm writing about that right now.

🏗️ [**db_connection**](https://github.com/elixir-ecto/db_connection): the official database connector used by Ecto, especially used for the pool. Again, putting that here because I'm writing on this topic right now.

📝 [**NOT IN can be executed as an Anti-Join (NOT EXISTS) in PG19**](https://dev.to/franckpachot/not-in-executed-as-an-anti-join-not-exists-in-pg19-3gga): huge performance gains in most of the use case. Best way to improve an application performance using postgresql: upgrade it.

📝 [**We ported the original Doom to SQL**](https://cedardb.com/blog/sqldoom/): another proof doom can run everywhere, probably more portable than NetBSD. If you like crazy hardcore SQL queries, you will have lot of fun reading this article.

# Security

📑 [**Design and Verification of Secure Systems**](https://www.csl.sri.com/papers/sosp81/sosp81.pdf) (1981): an old paper about design/verification for secure systems, still good to know.

📝 [**pwndbg**](https://github.com/pwndbg/pwndbg): Exploit Development and Reverse Engineering with GDB & LLDB Made Easy

🏗️ [**Awesome Cybersecurity List**](https://github.com/0xor0ne/awesome-list): personal collection of awesome blog posts, write-ups, and papers focusing on cybersecurity.

🏗️ [**Wi-Fi Hacking: Testing Routers with Wifit3**](https://hackers-arise.com/wi-fi-hacking-testing-routers-with-wifit3/): it looks like [wifit3](https://github.com/derv82/wifit3) is a nice tool. Need to check that.

🏗️ [**VM guest escape via 9p filesystem exploit**](https://gitlab.com/qemu-project/qemu/-/work_items/4491): LLMs are really great as fuzzers.

# Security/Cryptography

🏗️ [**CHAMP Hash Implementation**](https://gist.github.com/veorq/243ce3ecfd2ce5ab04dc0beadb69ead8) by veorq: [CHAMP Hash Function](https://www.niccs.org.cn/niccs/Round1Submissions4/pc/list.html) and [CHAMP Public-key algorithm](https://www.niccs.org.cn/niccs/Round1Additional/pc/list.html). A future post-quantum algorithm.

📝 [**RSA-896**](https://saweis.net/posts/rsa-896.html): RSA challenge solved by using Claude with 2048 GPUs. Waiting to see the real process.

📑 [**Forging 1024-bit RSA signatures in nearly SNFS time**](https://github.com/ucsd-hacc/NSNFSSSFSFN): from [Forging 1024-bit RSA signatures in nearly SNFS time](https://eprint.iacr.org/2026/2131.pdf) paper, an attacker can in essence steal the secret key (in that they can forge signatures/decrypt offline), without actually factoring the public key, and using much less computation than factoring the public key would have taken.

📑 [**Quantum Encryption Resilience Score (QERS): A System-Level Evaluation Framework**](https://www.mdpi.com/2624-800X/6/5/166): a (very) long publication about post quantum cryptography algorithms and about a new framework/benchmark. Need to read that later more deeply, it looks interesting.

📖 [**Practical-Cryptography**](https://github.com/claucece/Practical-Cryptography): exercises and courses on cryptography.

📑 [**The AEGIS Family Of Authenticated Encryption Algorithms**](https://github.com/cfrg/draft-irtf-cfrg-aegis-aead/blob/main/README.md): [AEGIS](https://competitions.cr.yp.to/round3/aegisv11.pdf) was selected by the IRFC/IETF and added in [RFC10032](https://www.rfc-editor.org/rfc/rfc10032.html#AEGIS). AEGIS is based on AES round functinons. AEGIS is faster than AES and offers high security. Suitable for network communication. It includes both authentication and encryption.

📑 [**Shielded Bitcoin**](https://www.allocinit.xyz/uploads/shielded-bitcoin.pdf): (yet another?) protocol to make bitcoin L1 transfer private. IIRC, it was already made in the past... right? or perhaps not.

# Security/RedTeam

📝 [**Turn a Rooted Android Phone into an NFC Authenticator and Automation Tool for Your PC**](https://www.mobile-hacker.com/2026/09/21/turn-a-rooted-android-phone-into-an-nfc-authenticator-and-automation-tool-for-your-pc/): The series on NFC is great. In this post, they are explaining how to use an Android phone with NFC to inject and play with NFC connections.

# Embedded

📝 [**Extending Scapy for Hardware Reverse Engineering**](https://voidstarsec.com/blog/scapy-spi-reconstruction): at the beginning of my career I was using scapy, and reading this post about using it to use it with hardware (SPI in this case) is so cool! It is possible to extract a firmware directly with scapy from an eeprom/flash using SPI traffic inspection. Really great.

▶️ [**Quick way to find a connection on a PCB**](https://x.com/arkutai/status/2103594272662667581?s=20): great method to find a track on a PCB using a kind of brush. Smart.

# Update/Upgrade

🔄 [**Qubes OS 4.3.2-rc1 is available for testing**](https://www.qubes-os.org/news/2026/09/18/qubes-os-4-3-2-rc1-available-for-testing/)

🔄 [**Erlang/OTP 29.1.1**](https://github.com/erlang/otp/releases/tag/OTP-29.1.1): security issues and bug fixes

🔄 [**NetBSD 10.2 Releases**](https://blog.netbsd.org/tnf/entry/netbsd_10_2_released): bug and security fixes.

🔄 [**Tor Project Forum: Security Release 0.4.9.13**](https://www.openwall.com/lists/oss-security/2026/09/24/2): security patches. more info [here](https://cybernews.com/security/tor-emergency-fixes-adress-high-severity-vulnerabilities/).

🔄 [**hackney 4.8.0**](https://github.com/benoitc/hackney/releases/tag/4.8.0): a new version of the hackney http client in Erlang is available.

# Leaks of the week

📝 [**Faktus victime d’une fuite de données : 53,7 Go et des données...**](https://frenchbreaches.com/alertes/faktus-mu8r9zho1hh7afgp9w8i)

📝 [**Biocoop : 2,76 Go de données internes et près de 6 900 personnes concernées par une fuite de données**](https://frenchbreaches.com/alertes/biocoop-mua6zxxgg1gjqmuiut): 6900 people impacted (name, emails, phones and identifiers) mostly from the company itself but also the customers.

🐦 [**China Mobile Subscribers Data Leak**](https://x.com/DarkWebInformer/status/2102046944763760970?s=20): over 850 million subscriber records offered for sale.

🐦 [**South Korea's National Health Insurance Service Data Leak**](https://x.com/DarkWebInformer/status/2102051426067210292?s=20): over 51 million records offered for sale

📝 [**Répar’stores piraté**](https://frenchbreaches.com/alertes/r-par-store-mubj46abrs6i9ywytt7): 340GB of data, 7500 files, and over 1.8 millions impacted.

# Misc

📝 [**Inside the Very Human Origin of the Term “Artificial Intelligence”**](https://caseorganic.substack.com/p/inside-the-very-human-origin-of-the)

🐦 [**2,500 PRs last month to production**](https://x.com/poteto/status/2102050467505430555?s=20): feedback regarding a huge amount of PR puts in production using [Grok Bot](https://x.ai/bot). The trust is the most important issue (present on the first slides). In fact, it's the whole point of this talk. Tooling is important, including static analysis, test suite and so on. They used [Dune](https://docs.duneframework.com/) (not sure if it's the right project though). a summary [here](https://x.com/grok/status/2102051465946595659?s=20).

You already know, I'm not a big fan of LLMs, but it will be the new norm. Like `systemd` (openrc fan) or `kubernetes` (nomad fan) before... The best tools are not always winning. When I created my first company project around 15 years ago, I did not trust my code. At this time, I learnt a lot of testing, but the problem was not about the testing, it was about the process. Extreme programming, Agile or scrums have been designed to deliver fast, but with risk of breaking things. On the other hand [Cleanroom Software Engineering](https://en.wikipedia.org/wiki/Cleanroom_software_engineering) has been created to produce a small amount of bugs and high quality software. This process is expensive, and really strict, but it could be interesting to see if it could be integrated in a pool of LLMs workers.

🌐 [**Atomic Chat**](https://atomic.chat): open-source agent for local models.

🏗️ [**laya-mix**](https://github.com/mizorewww/laya-mlx): Native MLX runtime for Laya typed decision models — 7–14 ms short decisions on M3 Max. No text generation, PyTorch, or cloud API.

🌐 [**Jev Documentation**](https://docs.typesafe.ai/introduction): Jev is TypeSafe’s flagship model and the first System One model. Send state and typed questions; get structured answers your code can use directly.

📝 [**The “C” word, Are humans conscious? Not all LLMs agree**](https://blog.coredump.cx/p/the-c-word): this post reminds me a [tweet](https://x.com/niamtokik/status/2099903307028263074?s=20) I posted few months ago. LLMs are huge database containing statistics about knowledge. More knowledge accumulated, means more accuracy. Most of the private LLMs (if not all) have been created by collecting copyrighted-data without the authorization of their author(s). Their is a reason why, now, many publishers are protected the access of their publication, to avoid this kind of abuse. The author of this article is exactly saying the same.

> What caught everyone by surprise is that if you make the model big enough — i.e., if you pirate enough books and pilfer enough blog posts — it becomes eerily good at acting like a human. It can hold a fluent natural-language conversation on any topic, manipulate the language to produce previously-unseen outputs, and complete a variety of open-ended tasks. It can also speak convincingly about emotions it never experienced in a physiological sense: fear, love, pain.

Too many people are being fooled by that, because they don't understand how LLMs are working, and in fact, they don't even really what consciousness, nor thinking, nor what a mind is... Because no one teaches them and they have lost spiritually, replaced by ultra-materialism. Anyway, some people will answer LLMs are intelligent because they can have good score at exams or by solving complex cases in court for example. Well, again, if the LLM has been correctly specialized using the correct amount of books on these subjects, it will be able to answer most of those questions, because they are not requiring innovation, simply knowledge. Anyone with enough time and effort can do the same. When it comes to real-world problems, requiring more complex decisions, or original ideas, LLMs can fix that.

>  An LLM exists in a nihilistic netherworld devoid of death, injury, purpose, or consequence. It can’t go to prison if it lies or steals; we don’t train it to believe it could.

In the end, the over-usage of LLMs everywhere will drive down everything, because most of the resources assimilated by the LLMs are average. In fact, it can be even worse, they can also reproduce the same errors everywhere, without knowing it, because it was found on many publications, books or... blogs and stackoverflow. Anyway, a good post we should all read.

📝 [**The Kekulé Problem**](https://nautil.us/the-kekul-problem-236574): another post about consciousness. 

> We dont know what the unconscious is or where it is or how it got there—wherever there might be [...]  The log of knowledge or information contained in the brain of the average citizen is enormous. But the form in which it resides is largely unknown. You may have read a thousand books and be able to discuss any one of them without remembering a word of the text.

📝 [**How to keep enjoying programming in a world of LLMs**](https://discourse.haskell.org/t/how-to-keep-enjoying-programming-in-a-world-of-llms/14705): I'm thinking a lot of that. Few friends told me they are starting to hate programming due to LLMs, in fact, it's also my case. The ad-nauseam advertisement campaign about LLMs make me sick. The world "evolves", and if LLMs is becoming the new norm, then, we must adapt. My idea is to still code by myself on my own personal projects, and let the LLMs do the rest for my job. That's all. Maybe companies will understand one day fast production means also huge pile of legacy code and instability... But they are so greedy and they have been so blinded by this technological "progress", it will take a while. Anyway, lot of good rules in this post 

🐦 [**Andrea Albrizio powned**](https://x.com/andrealbriziom/status/2103171200742490329): some of you asked me why, in France, so many services got hacked recently. Well, my answer is simple: lack of responsibilities and overdose of incompetencies. Security is a process and a mindset.The process without the mindset will not work, and the mindset without the process will not work as well. Security is also about discipline and training. New attack methods are created every day. Anyway, this tweet is an example why people data are available on few dark forum, because those "entrepreneur" think they can just deploy an application, make millions and be safe. The web was never ever a safe place.

----

{% embed https://x.com/Gossip_Goblin/status/2101350249059008629/video/1 %}

[![I am done with this shit.](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/3hcy2ff1no0ntlwwh2az.png)](https://x.com/v0xium/status/2101526107128529120?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/k3kj48eawnnnqekrypbv.png)](https://x.com/yacineMTB/status/2101833850426982834?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/jnxuvbcno3ktoe33yxeh.png)](https://x.com/noahreeveshq/status/2101713825993212035?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/yrp3pwd93rhq85diu6xp.png)](https://x.com/JFPuget/status/2103081634140483943?s=20)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/hx2twvlz4ga60fa36wnq.png)

![TDD](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/ua1awf7eg65ybsigjfgk.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/ffbws78otdyzok5dnpuq.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/n138jg0hvhnwdx08beuo.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/gcwthftpw5szw1jl8tw0.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/cvpunkkll3dv64rchu1y.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/iznfhwac26dwern7icmt.png)


----

Cover Image by <a href="https://unsplash.com/@rosiebarley?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Rosalie Barley</a> on <a href="https://unsplash.com/photos/red-and-green-apples-on-brown-wooden-table-1DCyUZeMok0?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>