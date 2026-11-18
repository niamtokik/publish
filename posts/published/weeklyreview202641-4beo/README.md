---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/weeklyreview202641-4beo"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Fizk6c0pod6wsv7i7tvq4.jpg"
created_at: "None"
crossposted_at: "None"
description: "This week was quite busy in my code. Redarging my main application/product, I started to implement..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/weeklyreview202641-4beo"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "weeklyreview202641-4beo"
social_image: "None"
title: "WeeklyReview#202641"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# WeeklyReview#202641

This week was quite busy in my code. Redarging my main application/product, I started to implement the database schema with [`sqflite`](https://pub.dev/packages/sqflite) in `flutter`. I did also a lot of tests regarding the flexibility of [`sqflite`](https://pub.dev/packages/sqflite), and its potential limits in my use case. To be honest, I don't really like how this library is working but it should do the jobs for now. I also played with the [`flutter_quill`](https://pub.dev/packages/flutter_quill) text editor library (and also [`fleather`](https://pub.dev/packages/fleather)). Not so complex to use, can produce something pretty cool quick. Finally, the [BlocSignal](https://github.com/RandalSchwartz/BlocSignal) pattern used in Flutter seems really attractive, lot of examples are available on their repository and it can be a good alternative of my approach (doing everything from scratch to learn).

----

It was not expected, but it looks like my motivation was focused to do C code for [`mac_randomizer`](https://github.com/niamtokik/mac_randomizer). This is definitively a pet project, but C is still one of my favorite language, even if it can be challenging to do some things (e.g. concurrency), it's still great to do kinda low-level code. The source code tree is now clean, the Makefile is minimalist but should work on any system using GNU Makefile. Most of the functions are now sorted by categories in their own source file. The last action was to start working on a minimalist implementation of a Mealy machine, a specific kind of finite state machine, to parse mac addresses, instead of using an external regexp library. Actually, the implementation is a bit hard, not because of the complexity, but because of the interface and the abstraction. My idea is to have something like that:

```c
// first tokenize the mac address to validate the
// characters used. Luckily, a mac address only has
// 23 allowed characters: [a-fA-F0-9\-\.\:]
//
// char *string is the raw strings containing the
// mac address.
//
// size_t length is the max size of the string, the
// tokenizer must stop when reading a NUL char or when
// it reaches the length limit
//
// the struct token *tokens is an array of token, where
// each token contains the raw valid character, the 
// position of the character and the kind of token (e.g.
// digit, separator).
//
// the tokens should probably be defined inside another
// structure embedded the length of the array. This value
// should be incremented every time a valid character is
// found.
int
tokenizer(char *string, size_t length, struct token *tokens) {
  return fsm_start(string, length, state, tokens);
}

// secondly, the parser will get the tokens and will convert
// them into an internal binary representation of the mac
// address (e.g. uint8_t mac_address[6]).
//
// The arguments of this function are similar to the previous
// one. The final result is then stored in the mac_address
// variable.
int
parser(struct token *tokens, size_t length, uint8_t *mac_address){
  return fsm_start(tokens, length, state, mac_address);
}

// the question know is how to design correctly the fsm_start()
// function. It should have the possibility to deal with different
// kind of input, not only char, but also C data-structure. It
// should also be able to deal with different kind of output. Based
// on these requirements, the definition of the function should look
// like the snippet below.
//
// The input argument can be a problem here, at least for the
// mac address parsing feature. Indeed, a string representing a
// mac address only has a few format, with specific length:
//
//   EUI48-IEEE: xx-xx-xx-xx-xx-xx (max length 17)
//   EUI48-IETF: xx:xx:xx:xx:xx:xx (max length 17)
//   EUI48-CISCO: xxxx.xxxx.xxxx (max length 16)
//   EUI64-IEEE: xx-xx-xx-xx-xx-xx-xx-xx (max length 23)
//   EUI64-IETF: xx:xx:xx:xx:xx:xx:xx:xx (max length 23)
//
// the input string should then have a maximal value of 23
// (+1 with NUL), and a minimal value of 17(+1 with NUL). The
// output can also be limited to sizeof(uint8_t)*6=48bits or
// sizeof(uint8_t)*8=64bits. Using the 64bits version is perhaps
// the best choice because an EUI48 can be converted to an EUI64
// and vice versa. Note: I don't even think it's possible to
// compress this value, it will probably add more complexity
// for no real benefits on the long run.
int
fsm_start(
  void *input,
  size_t input_length,
  void *output,
  struct state *init
){
  // do something here.
}

// the states must also be defined somewhere. states can
// be created dynamically by instantiating different kind
// of object and pushing them together, or creating them
// "statically" in their own data-structure with their
// own callback functions. One of the idea is to create
// something like the code below.
//
// The handler_enter callback is called only when a transition
// occurs between states.
//
// The handler_input callback is executed when an input
// is received.
struct state {
  struct state*(handler_enter)(struct state *s);
  struct state*(handler_input)(void *input, void *output, struct state *s);
};
```

As you can see, it's a good mental exercise to find the right way to implement something like that in C. In fact, a mealy (or moore) FSM are being use with Regexp but also with other complex protocols like TCP. Reimplementing something like that to parse well specified data like a mac address is probably the best choice, and, if correctly done, it could also be used to encode as well.

Anyway, here some implementations from github:

- [**ajrisi/fsm**](https://github.com/ajrisi/fsm);
- [**cferwin/microFSM**](https://github.com/cferwin/microFSM);
- [**At-EC/At-FSM**](https://github.com/At-EC/At-FSM);
- [**TheHumbleTransistor/HTHSM**](https://github.com/TheHumbleTransistor/HTHSM).

More implementation examples can be also found in userland from OpenBSD, FreeBSD and NetBSD projects. Many of those tools can have an implementation of a finite state machine.

- OpenBSD:
  - [`usr.bin/patch/ed.c`](https://github.com/openbsd/src/blob/master/usr.bin/patch/ed.c): it contains a small finite state machine implementation used to parse commands
  - [`games/bs/bs.c`](https://github.com/openbsd/src/blob/master/games/bs/bs.c)
  - [`usr.sbin/npppd/npppd/fsm.c`](https://github.com/openbsd/src/blob/master/usr.sbin/npppd/npppd/fsm.c)
  - [`usr.sbin/pppd/fsm.c`](https://github.com/openbsd/src/blob/master/usr.sbin/pppd/fsm.c)
  - [`lib/libc/gen/unvis.c`](https://github.com/openbsd/src/blob/master/lib/libc/gen/unvis.c)
- FreeBSD:
  - [`crypto/openssl/ssl/statem/statem.c`](https://github.com/freebsd/freebsd-src/blob/main/crypto/openssl/ssl/statem/statem.c)
- NetBSD:
  - [`libexec/telnetd/state.c`](https://github.com/NetBSD/src/blob/trunk/libexec/telnetd/state.c)
  - [`sbin/init/init.c`](https://github.com/NetBSD/src/blob/trunk/sbin/init/init.c)

----

Most of my posts are currently stuck in draft mode due to that, but I like the weekly review format. It is a good summary containing a lot of information in one place. Then, I think most of the coming publications will use this format.

# Coding

📝 [**A deep dive into HEEx compilation from LiveView 1.2**](http://www.phoenixframework.org/blog/heex-compilation-deep-dive-liveview-1-2): A post explaining the foundation of the HEEx template systems present in Phoenix LiveView. I did not know it was tokenized. In fact, this is a very good news... It is becoming closer to the way clojure is dealing with HTML.

📝 [**an application in lisp you grow by talking to it**](https://ghuntley.com/lisp/): LISP is probably one of the greatest language of all time, in this article, the program is created by talking to an LLM during a coding session.

🏗️ [**WeaveC**](https://github.com/weavefoundry/weavec): A C compiler with inferred ownership and borrow checking for Rust-style memory safety.

🌐 [**Tools for your Elixir app**](https://elixir.menu/): A starting point for each kind of application. Recommended tools, why we use them, and when to choose something else.

🏗️ [**cccc**](https://github.com/moznion/cccc): measures Cognitive Complexity (SonarSource / G. Ann Campbell) and Cyclomatic Complexity (McCabe). I used similar tools in the past, like `ccc` and `scc` or `sccc`. Nice to have, even before if you add it in your CI/CD to evaluate the complexity of a commit.

📑 [**Reducing undefined behavior in the C language**](https://lwn.net/Articles/1095811/): undefined behavior in C is a nightmare. Probably one of the most complex part of the language, and it can lead to total disaster. This post is presenting the solution to avoid common mistakes and find a way to create safer C code. Actually, this is from a [talk](https://www.youtube.com/watch?v=dhlYcmX_oBQ&list=PLEVVgAZOU9P8&index=14), and the slides are [available online](https://uecker.codeberg.page/kernel-recipes.pdf).

📝 [**What Every C Programmer Should Know About Undefined Behavior #1/3**](https://blog.llvm.org/2011/05/what-every-c-programmer-should-know.html): the first article of a series about undefined behavior in C.

📝 [**Abstract Syntax Tree, An Example in C**](https://keleshev.com/abstract-syntax-tree-an-example-in-c/): a short publication with nice example to explain how to implement and use an AST.

📝 [**One-pass Compiler**](https://keleshev.com/one-pass-compiler-primer): a nice trick to compile code directly without passed inside different layer.

📖 [**Compiling to Assembly from Scratch**](https://keleshev.com/compiling-to-assembly-from-scratch/#table-of-contents): a book by the author of the two previous posts. neat.

📑 [**CASM: Implementing an Abstract State Machine based Programming Language**](https://dl.gi.de/server/api/core/bitstreams/95165c87-561d-4b35-bed9-6175e1948a5a/content)

# System

📝 [**Headers Up! What's New in httpd and relayd**](https://rsadowski.de/posts/2026/update-relayd-and-httpd/): HTTP header manipulation support and request filtering. I'm still using nginx, but `httpd` is becoming really better every new release.

📝 [**Locking down openat(2) and friends with O_BELOW and F_BELOW**](https://marc.info/?l=openbsd-tech&m=179114222343483&w=2): a mail-exchange describing the (future?) `openat` function to open file with relative path (and more safety).

🏗️ [**scrcpy**](https://github.com/Genymobile/scrcpy): Display and control your Android device.

🏗️ [**floci**](https://github.com/floci-io/floci): gives you AWS-shaped services on your machine without requiring a cloud account, an auth token, or paid feature gates. 

🏗️ [**riscv/learn**](https://github.com/riscv/learn): A community-driven, continuously updated compilation of RISC-V learning resources. Content is organized by topic and experience level to help you discover courses, software, documentation, and articles efficiently.

📖 [**Haskell: The Craft of Functional Programming**](https://simonjohnthompson.github.io/haskellcraft/): revised version.

🏗️ [**DPDK (Data Plane Development Kit)**](https://www.dpdk.org/): an open source framework for fast packet processing on standard hardware. It runs in cloud infrastructure, telecom networks, financial exchanges, particle accelerators, and radio telescopes. Most of your traffic already runs through it. Start by reviewing a patch, no account or setup required. I discovered it was also running not only on Linux... I need to try that.

📝 [**unikernels were hard. key word: were**](https://ghuntley.com/unikernels/): unikernel IS THE WAY TO GO, but I still this a complex technology mixing a lot of features from many different part of any systems. In fact, this is really close to microkernel, and both are, to me, two things that should be merged together.

# Network

🏗️ [**Open vSwitch (OVS)**](https://www.openvswitch.org/): a production quality, multilayer virtual switch, designed to enable massive network automation through programmatic extension, while still supporting standard management interfaces and protocols.

🏗️ [**Open Virtual Network**](https://www.ovn.org/en/): a series of daemons for the Open vSwitch that translate virtual network configurations into OpenFlow.

# Database

🏗️ [**Awesome Database Learning**](https://github.com/pingcap/awesome-database-learning)

🏗️ [**pgvector**](https://github.com/pgvector/pgvector): Open-source vector similarity search for Postgres

# Security

📝 [**Malicious Flutter Package while it have a Clean Code?**](https://forum.itsallwidgets.com/t/malicious-flutter-package-while-it-have-a-clean-code/4960): malware present in `example` directory inside a flutter project. Don't trust blindly all projects.

📝 [**How to fix a bug in a fix**](https://projectzero.google/2026/10/emergency-patching.html)

📝 [**Chrome's Response to Recent ccTLD Registry Hijacks**](https://blog.google/security/chromes-response-to-recent-cctld-registry-hijacks/): Following recent .gh, .sl, and .as ccTLD domain hijacks, Chrome immediately blocked unauthorized HTTPS certificates via CRLSets to protect users automatically. 

[**Telegram Desktop: one-click account takeover via IPC injection**](https://beaksec.github.io/posts/telegram-desktop-one-click-account-takeover/): a post describing the CVE-2026-107181, where one malicious actor can take control of a group by sharing a telegram link and opening it on the telegram desktop application. The problem is from the URI parser, when dealing with semicolons. That's an interesting attack, because many application can be ported on different systems, like Signal or SimpleXChat, and depending of the languages/tools used, some part of the can use different routines.

# Security/Cryptography

📝 [**SequenceHash: multihashing for the rest of us**](https://blog.trailofbits.com/2026/10/02/sequencehash-multihashing-for-the-rest-of-us/)

🌐 [**Hash Smash**](https://www.yukon.org/hashsmash): Find ordinary collision attacks that reach more rounds with less total computation. Select a hash function’s chart, then one of its two round counts.

📑 [**MiniSHAKE**](https://eprint.iacr.org/2026/2363.pdf): an extendable output function based on Keccak, with unlimited size output.

📑 [**TurboSHAKE**](https://keccak.team/files/TurboSHAKE.pdf): an extendable output function based on Keccak, with less rounds to improve performance.

🌐 [**Key Length**](https://keylength.goodkey.co/): The minimum key sizes each source publishes for protecting data until a given year. 

# Embedded

🏗️ [**CPU Performance Engineering**](https://github.com/usamahz/cpu-performance-engineering): A reading path for CPU performance engineering, from one instruction to production inference. Primary sources only, with a runnable benchmark for every section.

📝 [**The FPGA Chronicles: Open Source It**](https://hackaday.com/2026/10/05/the-fpga-chronicles-open-source-it/)

🏗️ [**PasRISCV**](https://github.com/BeRo1985/pasriscv):A RISC-V RV64GCV/RVA23 emulator written in Object Pascal. It simulates processor cores, memory, I/O, and much more.

# Update/Upgrade

🔄 [**hackney 4.8.5**](https://github.com/benoitc/hackney/releases/tag/4.8.5): bug fixes.

🔄 [**Cowboy 2.20**](https://ninenines.eu/articles/cowboy-2.20.0/): security and bug fixes.

🔄 [**LibreSSL 4.2.2 and 4.3.3**](https://undeadly.org/cgi?action=article;sid=20261007052424): security and bug fixes.

# Computer Science

📑 [**Digital Hardware Design DFA, Mealy and Moore Machines**](https://web.iitd.ac.in/~debanjan/ELL318_Lecture7_MealyandMooreMachines_DBRevised.pdf): a lecture on Mealy/Moore machines

📑 [**A Report on Achieving Complete Regular-Expression Matching using Mealy Machines**](https://arxiv.org/pdf/2206.04944): an interesting (but complex) publication about regexp and finite state machine to match exact pattern.

📑 [**Effective Reductions of Mealy Machines**](https://link.springer.com/content/pdf/10.1007/978-3-031-08679-3_8.pdf): reducing mealy machines states and transitions.

# Misc

📝 [**The empty brain**](https://aeon.co/essays/your-brain-does-not-process-information-and-it-is-not-a-computer): an amazing post about brain information processing. The brain is not storing information like a computer (a stream of bits), and in fact, it is not the only organ to "store it". It stores experiences, and experiences are different between every people alive, then, it will be impossible to "copy" experiences between humans. In fact, like the author is explaining in his publication, even if all neurons' states were extracted, copied and connected together, it will have no meaning because it would be outside of the body where the experiences have been learned.

> Because the Information Processing metaphor is not even slightly valid, we will never have to worry about a human mind going amok in cyberspace; alas, we will also never achieve immortality through downloading. [...] **We are organisms, not computers**.

📝 [**Victime d’une fuite de données ? Voici dans quels cas vous pouvez réclamer une indemnisation**](https://frenchbreaches.com/blog/victime-dune-fuite-de-donnees-voici-dans-quels-cas-vous-pouvez-reclamer-une-indemnisation): see also that on the [CNIL website](https://www.cnil.fr/fr/violations-de-donnees-personnelles-cas-indemnite)

📝 [**A strategist who called the Asian financial crisis sees parallels with the AI boom**](https://www.morningstar.com/news/marketwatch/20261008113/a-strategist-who-called-the-asian-financial-crisis-sees-parallels-with-the-ai-boom): another indicator the "AI" boom is not really doing what every one expect. I wanted to read [The Myth Of AI's Miracle: Albert Edwards Spots The Same Fatal Flaw That Sank Asia In 1997](https://www.zerohedge.com/markets/myth-ais-miracle-albert-edwards-spots-same-fatal-flaw-sank-asia-1997), but, well, it is a premium article.

> the productivity payoff from AI remains a forecast, rather than an observation [...] No AI productivity boost in the data yet [...] too many people believed the beguiling narrative and as a consequence, lent these economies cheap, abundant capital which was misallocated.

🐦 [**THE SIGNS THAT THE AI BOOM IS BUILT ON FAKE REVENUE ARE NOW HERE. Here is what is really happening**](https://threadout.app/thread/2108530300494230009-the-signs-that-the-ai-boom-is-built-on-fake-revenue-are-now): a thread about what could happen with the AI financial - SCAM - scheme. Anyway, it smells really bad, even worse than the crypto-currency bubble.

> Every time an AI startup raises money at a higher valuation, the investor raises the value of its stake on its books and counts the increase as income. **No cash comes in. The profit is on paper.** [...] A large part of the sales and profits these companies report depends on money that investors, including the tech giants themselves, keep putting into OpenAI and Anthropic. If that funding slows, the backlog, the sales and the paper profits all weaken together.

# Leaks of the week

🐦 [**Tata Consultancy Services**](https://x.com/DarkWebInformer/status/2106514093717008857?s=20): source code and credentials leaked.

🐦 [**UAE government**](https://x.com/DarkWebInformer/status/2106471572257050887?s=20): 17 millions entries from UAE government-related software licensing database

🐦 [**Get covered**](https://x.com/DarkWebInformer/status/2106465040115159224?s=20): more than 1 million customer records including email, phone numbers, physical address and more.

🐦 [**CAPEB**](https://x.com/DarkWebInformer/status/2106403088835694632?s=20): Around 4 millions records including emails and phone numbers.

🐦 [**Denmark government**](https://x.com/CR1337/status/2107039062469353812?s=20): 8.8 millions people impacted, Danish citizens and emigrates. The leak include  Social security number, Age, Sex, Family relations, Physical address, Protected addresses and Sex change.

----

{% embed https://x.com/circuits24x7/status/2107477791549907153?s=20 %}

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/j33vffo617pk45kgmfyj.png)](https://x.com/Arikalabs/status/2106511599276061021?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/iqkkmgp72avdgzc082c8.png)](https://x.com/SmokeAwayyy/status/2106566046350258515?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/kt8v0k7cqlmk5jat0xe4.png)](https://x.com/AmanVirk1/status/2106610500218061051?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/m85crua37p7iikupzgvu.png)](https://x.com/agounardes/status/2106890198369947659?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/5v3frleiuh1hm5y0dprn.png)](https://x.com/JustDeezGuy/status/2106931338343526541?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/r6d7273w44td79os6osm.png)](https://x.com/wangzhr4/status/2107059715956224145?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/alq86jeq2vib7exkdtvo.png)](https://x.com/ortegaalfredo/status/2107218272416587958?s=20)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/eobxnovnokfwg66u5ycf.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/jncjvli2kxa7earoyz6u.png)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/zidq3pzifmx81fa61hg2.png)](https://x.com/pmddomingos/status/2107598154799738891?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/v3rioly75geie8x1ezfa.png)](https://x.com/louiseivan/status/2107542657874661780?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/jhsijh3sjipigjf96rq5.png)](https://x.com/Ross__Hendricks/status/2108249887435620559?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/6i7a37j7vjeu7r7r8pc5.png)](https://x.com/IceSolst/status/2108543740411584799?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/aikzjwl9l7tkx87ivtge.png)](https://x.com/veorq/status/2108965379829797059?s=20)

----

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/d92cu6t8813va77sv69n.png)

----

Cover Image by <a href="https://unsplash.com/@puregeorgia?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Alfred Schrock</a> on <a href="https://unsplash.com/photos/yellow-leaves-on-black-and-yellow-concrete-road-C7E8WTsvkmY?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>