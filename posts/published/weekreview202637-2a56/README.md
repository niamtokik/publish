---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/weekreview202637-2a56"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2F8czfzk962ipm5u4qxc43.jpg"
created_at: "None"
crossposted_at: "None"
description: "Paying for \"cheap\" virtual machines running my CI/CD pipelines is no fun. You will have the result..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/weekreview202637-2a56"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "weekreview202637-2a56"
social_image: "None"
title: "WeekReview#202637"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# WeekReview#202637

Paying for "cheap" virtual machines running my CI/CD pipelines is no fun. You will have the result quick, but you will not learn how to deploy this kind of infrastructure. As sysadmin, it's always nice to see how the tools used few years ago evolved... So, this week was about creating my own local privacy-first building infrastructure for Gitlab CI/CD. Based on the increasing cost of hosting providers due to the "AI revolution", hosting its own infrastructure can have a lot of benefit (and few drawbacks). What's the idea? 

To avoid information leaks like my own public address, the network will route all outgoing connections to a VPN or/and via a proxy. Each servers will be installed with an hardened version of Alpine Linux, and will have gitlab-runner enabled by default with a container manager (e.g. podman). Those servers are old laptops or cheap bare-metal devices (e.g. Intel NUCs, ARM boards). This infrastructure will also offer local isolated cache servers and a way to store artefacts.

It was not really planned, but it's a nice idea to do that. In fact, I would like to also test this kind of infrastructure with `k3s` to see if a kubernetes cluster can run in its own world, without a direct access to internet. Spoiler alert: it is already deployed on two workers, behind an OpenBSD firewall. It's a matter of time before a series of articles will be published here about that.

This week was kinda busy, working on my application in Dart/Flutter, and most of the links are without comments because they have been barely read... Even more, dev.to is going to make me crazy. When a post is removed from a series, it is not displayed on user's profile. I created an [issue](https://github.com/forem/forem/issues/23829#issuecomment-5630318665) hoping it will be fixed, but I was so angry about that, I started to work on my own post manager called [`publish`](https://github.com/niamtokik/publish) using only pandoc, Makefiles and shell scripting. I don't understand how a website like dev.to can be a "reference" for developers. Anyway, as usual, nothing is better than what you can do by yourself. A word on `publish` project?

1. must be highly portable and run everywhere
2. must be use simple markdown files
3. must publish content in more than one format (e.g. html, pdf, epub, djvu...)
4. must be easy to clone/export
5. must be easy to backup
6. must be easy to migrate
7. must be flexible enough to deal with callbacks in any languages
8. must generate good old files and directories
9. must save its state as local files/directories as well
10. all my publications will be firstly created there and then published on substack, medium and dev.to (and in other places as well if possible).

I'm really tired of migrating my content every 2 or 3 years, but I know think the best way is to keep everything open, and stay with your data locally.

# Coding

🏗️ [**snmpkit**](https://hex.pm/packages/snmpkit): A comprehensive SNMP toolkit for Elixir featuring a unified API, pure Elixir implementation, and powerful device simulation.

📝 [**Register Allocation in the LLVM Backend**](https://www.21verses.xyz/2026/09/04/Register_allocation_LLVM/): an article on LLVM compiler optimization for registers allocation. In short, this is the algorithms used when the `-O` flag is set. It's interesting to see register allocation is not a simple thing. This article focus on CPU though, GPU register allocation is a bit different.

🏗️ [**listen project**](https://pub.dev/packages/listen): A package to notify state changes to interested listeners in pure Dart.

📝 [**Recreating Voodoo Graphics and a Late-1990s Gaming PC on an FPGA**](https://nand2mario.github.io/posts/2026/zsst-voodoo/): another article about the z486 CPU, this time about recreating a graphic card using an FPGA.

🏗️ [**gitlab-ci-local project**](https://github.com/firecow/gitlab-ci-local): Run gitlab pipelines locally as shell executor or docker executor.

🏗️ [**ecto_middleware**](https://github.com/vereis/ecto_middleware): Implements the middleware pattern for your Ecto repos, a Plug-like concept for Ecto.

📝 [**Implementation of GCC's Nested Functions (vs. C++ Lambdas)**](https://uecker.codeberg.page/2026-09-05.html)

📑 [**C*: Unifying Programming and Verification in C**](https://arxiv.org/abs/2504.02246)

🐦 [**A quick overview of atomics in C**](https://x.com/lemire/status/2098020509426294907)

📑 [**Stackful Coroutine Made Fast**](https://photonlibos.github.io/blog-20241014/Stackful_Coroutine_Made_Fast.pdf): from [PhotonLibOS](https://photonlibos.github.io/)

📝 [**Optimizing a Spin-Lock**](https://david.alvarezrosa.com/posts/optimizing-a-spin-lock/)

📝 [**Implementing a Phoenix PubSub Adapter with EventStore**](https://www.erlang-solutions.com/blog/how-to-write-a-phoenix-pubsub-adapter-tutorial-example-based-on-eventstore/): a quick and short introduction to Phoenix [`PubSub`](https://phoenix-pubsub.hexdocs.pm/Phoenix.PubSub.html).

📝 [**Decompilation Book**](https://decompilation.education/): A good introduction to decompilation (and reverse engineering).

# System

📝 [**Asahi Linux Now Officially Supports Apple M3 Macs - With Caveats**](https://www.phoronix.com/news/Asahi-Linux-Official-M3): Linux on Apple M3 CPU will be great. Looking forward to have the same support on BSDs.

📝 [**RabbitMQ vs. Apache Kafka**](https://www.rabbitmq.com/docs/compare/kafka): it reminds me years ago when some of my colleagues were talking about comparing RabbitMQ and Kafka. This article is an up-to-date version of this discussion, with a nice conclusion: RabbitMQ is the better default. In general, both systems are now doing the same, with mostly the same performance. Anyway, a good summary every one working with queueing systems should read. A [study](https://ulearn-it.vercel.app/topics/rabbitmq-vs-kafka/study) is also available.

📝 [**SystemIO conflicts are not firmware bugs**](https://codon.org.uk/~mjg59/blog/p/systemio-conflicts-are-not-firmware-bugs/)

🏗️ [**grafito project**](https://github.com/ralsina/grafito): a simple, self-contained web-based log viewer for journalctl. It provides an intuitive interface to browse and filter system logs directly from your web browser.

🏗️ [**Vinix OS**](https://vinix-os.org/#about): Vinix initially is going to support every Apple Silicon Mac (only M1 Macs for now as of Sep 10 2026).

📝 [**Retrospectively Reverse-Engineering Apple's Neural Engine**](https://eiln.github.io/posts/ane.html)

📝 [**Interview with Ken Thompson, 9-6-89**](https://web.archive.org/web/20201002094756/https://www.princeton.edu/~hos/mike/transcripts/thompson.htm)

# Network

📑 [**De-Anonymization Techniques in the Tor Network Using an Experimental Testbed**](https://www.mdpi.com/2624-800X/6/2/72): A really interesting publications doing a huge work on de-anonymizing tor network users using open-source tools, in an experimental network. In the end, nothing really new. It's well known if the user is not careful during browsing or when downloading something, it can  lead to information leaks. Whonix mostly fix this issue, even more when it is installed in QubeOS. Here the tools they used in this paper:

- [shadow](https://github.com/shadow/shadow): Shadow is a discrete-event network simulator that directly executes real application code, enabling you to simulate distributed systems with thousands of network-connected processes in realistic and scalable private network experiments using your laptop, desktop, or server running Linux;

- [chutney](https://gitlab.torproject.org/tpo/core/chutney): Tool for testing Tor network

- [ExperimenTor](crysp.uwaterloo.ca/software/exptor/): A Testbed for Safe and Realistic Tor Experimentation 

# Database

🏗️ [**PostgreSQL Anonymizer**](https://postgresql-anonymizer.readthedocs.io/en/latest/): The main goal of this extension is to offer anonymization by design. We firmly believe that data masking rules should be written by the people who develop the application because they have the best knowledge of how the data model works. Therefore masking rules must be implemented directly inside the database schema. From [PostgreSQL News](https://www.postgresql.org/about/news/postgresql-anonymizer-32-faster-pseudonymization-3373/).

🏗️ [**`pg_vault_tde` project**](https://github.com/labmiriade/pg_vault_tde): encrypts every tuple with AES-256-GCM at the Table Access Method layer. Data is encrypted before it reaches the storage manager and decrypted after it leaves. Encryption keys are managed by HashiCorp Vault / OpenBao or a local PKCS#12 wallet and cached in shared memory with automatic rotation. Seen from [postgresql news](https://www.postgresql.org/about/news/pg_vault_tde-v171-transparent-data-encryption-for-postgresql-17-and-18-3376/).

# Storage

🏗️ [**Garage project**](https://github.com/deuxfleurs-org/garage): S3-compatible object store for small self-hosted geo-distributed deployments.

# Security

📝 [**Activating Chrome DevTools Protocol in Memory: Bypassing –remote-debugging-port Restrictions**](https://www.pikered.com/en/learn/bypass-remote-debugging-port-restrictions/): shellcode injection on windows using Chrome Developer Tool.

📝 [**I accidentally logged hundreds of thousands of phone calls to military bases**](https://lina.sh/blog/hijacking-e164-arpa): a good story about hijacking `e164.arpa` domains, a project created in the 2000's to associate phone number with DNS.

📝 [**WeWorm, The first zero-click worm to spread through WeChat calls across iOS and Android.**](https://calif.io/research/weworm)

▶️ [**Deanonymizing Monero Transactions in Tor Network**](https://www.youtube.com/watch?v=y8Kagu3r3Z4): an introduction to deanonymizing monero transactions, but it has been fixed in the latest versions (quick). btw, I liked the fake VPN ads but I also liked the truth behind the private VPN companies giving logs to goverments.

▶️ [**The Tor Project Just Gaslit Their Entire User Base**](https://www.youtube.com/watch?v=3wlNemFwbwE): another project lying to their users. Tor browser does not protect against OS fingerprint, that's a shame, but the worst part is... they are saying the opposite in their communication. Don't trust anyone, again.

📝 [**From P-Code to GNN: extract binary code semantics**](https://blog.quarkslab.com/from-p-code-to-gnn-extract-binary-code-semantics.html)

📝 [**Bluetooth Low Energy Security Testing, Consolidated: Introducing Caeruleus**](https://www.praetorian.com/blog/ble-testing-caeruleus/)

# Security/Cryptography

📝 [**Engineer Factors RSA-260, Ending a 35-Year Cryptographic Challenge**](https://pbxscience.com/engineer-factors-rsa-260-ending-a-35-year-cryptographic-challenge/): lot of noise here, but RSA-260 (260 bits RSA keys) have been broken. At least... One of them.

📑 [**Computing 256-bit elliptic curve discrete logarithms in 26 days on a fault-tolerant trapped-ion quantum computer with 20,000 qubits**](https://arxiv.org/abs/2609.05625)

# Security/OSINT

🏗️ [**Instagram OSINT Relationship Analysis project**](https://github.com/0x6rss/instagram-private-graph): Analyze the followers and following accounts that a private (hidden) Instagram account interacts with.

# Security/BlueTeam

📝 [**MikroTik ssh 0day exploitation in the wild**](https://medium.com/@costin.raiu/mikrotik-ssh-0day-exploitation-in-the-wild-20da4587d9b2): a short story about a 0 day exploited on Mikrotik  routers via SSH.

# Security/RedTeam

📝 [**PowerShell for Hackers: Exploitation Essentials**](https://hetmehta.com/posts/powershell-for-hackers/): not a big fan of powershell, but it's a good introduction for penetration testing.

🏗️ [**XSS Labs project**](https://github.com/NazaninNazari/XSS_Labs): Hands-on XSS labs for learning, practicing, and understanding Cross-Site Scripting vulnerabilities.

# Embedded

📝 [**Scheme-it: Schematic Drawing, Flow and Block Diagramming Made Easy**](https://www.digikey.com/en/blog/scheme-it-schematic-drawing?article_name=scheme-it:_schematic_draw): a quick introduction to scheme-it to create and design electronic schema. Those schema can then be imported in KiCAD.

📝 [**Deep Dive Into PCB Manufacturing Techniques: Milling**](https://www.digikey.com/en/maker/blogs/2024/deep-dive-into-pcb-manufacturing-techniques-milling): a short post on PCB milling.

📝 [**ESP32 Audio Project - Part I: Internet Radio with I²S DAC**](https://www.digikey.com/en/maker/projects/esp32-audio-project-part-i-internet-radio-with-is-dac/b8378782c8524ab78bc1335a2ddb57cb)

📝 [**Chameleon Ultra: Guide to RFID Reading, Emulation and Testing**](https://www.mobile-hacker.com/2026/09/07/chameleon-ultra-guide-to-rfid-reading-emulation-and-testing/)

🏗️ [**A standalone, real-time 2x2 MIMO software-defined radio (SDR) platform for advanced wireless research and rapid prototyping**](https://www.crowdsupply.com/htwave/integrive-100): a standalone, real-time 2x2 MIMO software-defined radio (SDR) platform for advanced wireless research and rapid prototyping. With FPGA-accelerated wireless processing, ultra-low phase noise design, and a proven real-time PHY baseline.

# Update/Upgrade

🔄 [**NetBSD 9.5**](https://blog.netbsd.org/tnf/entry/netbsd_9_5_released_and): NetBSD 9.5, the fifth (and final) release from the NetBSD 9 stable branch, end-of-support for all NetBSD-9.x. The full announcement can be found on [the release page](https://netbsd.org/releases/formal-9/NetBSD-9.5.html).

🔄 [**Cowboy 2.19, Cowlib 2.20, Gun 2.6, Ranch 2.3**](https://ninenines.eu/articles/cowboy-2.19.0/): this is an important release for all the cowboy-suite libraries. Cowboy is now only support OTP-27+ and will drop support for all versions of Erlang without security patches. The release on Github: [cowlib-2.20.0](https://github.com/ninenines/cowlib/releases/tag/2.20.0), [ranch-2.3.0](https://github.com/ninenines/ranch/releases/tag/2.3.0),  [cowboy-2.19.0](https://github.com/ninenines/cowboy/releases/tag/2.19.0) and [gun-2.6.0](https://github.com/ninenines/gun/releases/tag/2.6.0).

🔄 [**Nova 0.17.0**](https://github.com/novaframework/nova/releases/tag/v0.17.0): optimization update.

🔄 [**Nova 0.18.0**](https://github.com/novaframework/nova/releases/tag/v0.18.0): another update.

🔄 [**OpenBSD 7.9 syspatch security upgrade**](https://www.openbsd.org/errata79.html): a lot of patches, impacting opensmtpd, nfs, wscons, shmat, libexpat, X and ldapd.

# Providers

🌐 [**Bullionet**](https://bullionet.com):  cheap bare-metal server in France (Paris, Marseilles, Lille). Announced on [X/Twitter](https://x.com/oliviermis/status/2096506930931913060?s=20).

🌐 [**netcup**](https://www.netcup.com): low cost virtual servers, and interesting [deals](https://www.netcup.com/en/deals).

🌐 [**contabo**](https://contabo.com/en-us/): low cost [virtual servers](https://contabo.com/en/vps/), pretty expensive [bare metal](https://contabo.com/en/dedicated-servers/) ones though.

🌐 [**speedypage**](https://my.speedypage.com/store): in pound (uk), quite expensive bare metal servers, but the price for virtual servers looks great.

🌐 [**euronodes**](https://euronodes.com): virtual machines are cheap (<5€), bare-metal servers are expensive. Data centers in Europe (germany, portugal, spain and czech republic).

🌐 [**macserve**](https://macserve.io): is it a joke?

🌐 [**BoxedTux**](https://boxedtux.com/): Deploy a full Linux virtual server in under 90 seconds. Root access, public IP, your choice of distro — no credit card, no vendor lock-in.

🌐 [**BoxyBSD**](https://boxybsd.com/): BoxyBSD offers free VPS instances for exploring FreeBSD, OpenBSD, NetBSD and many other BSD or Solaris based systems. Get hands-on experience, experiment safely, and join a growing community of BSD enthusiasts.

# Misc

🌐 [**Mini ITX Shop**](https://www.mini-itx.com): A good place to find small-sized computers/boards.

🌐 [**Mhz Shop**](https://www.mhzshop.com/): A good place to find wireless hardware and devices.

📝 [**Under-The-Radar Oklahoma Bitcoin Mining Site Condemned After Leaking 3 Million Gallons Of Water**](https://www.zerohedge.com/markets/oklahoma-bitcoin-mining-site-condemned-after-major-water-leak)

🏗️ [**BraveDebloater project**](https://github.com/osfv/BraveDebloater): Safety-first Windows PowerShell debloater for Brave Browser using enterprise policies, dry-run mode, backups, and restore.

📝 [**Build Your Own Private Cellular Network**](https://hackersarise.thinkific.com/courses/private-cellular-network): kinda expensive ($999) but looks interesting.

🏗️ [**Nobora Project**](https://nobaraproject.org/index.html):  A Fedora-based desktop, tuned for gaming, streaming, and content creation — so you can skip the tweaking and start doing. 

📟 [**Sipeed NanoKVM-Go**](https://sipeed.com/nanokvm-go): an updated version of the NanoKVM, perfect for remote control and debugging a system remotely.

🐦 [**go fuck yourself @sama**](https://x.com/BetterCallMedhi/status/2097472336257863722?s=20): a reaction regarding the last "discovery" made by anthropic in the mathematical field. Below the most interesting part to me. Your data, your ideas, or your researches are not safely protected by those companies.

> to this theoretical imposture you add a disgusting ethical and industrial cynicism **taking advantage of private codex sessions and informal preprints from academic researchers to siphon their research leads and then trying to redact or erase the contribution of levent alpöge** under the pretext that he works at rival anthropic is intellectual serfdom openai behaves like a feudal lord of silicon appropriating the cognitive subsistence of independent scholars threatening their careers behind closed doors if they protest and turning community academic labor into a privatized pressrelease [...] real science is not a clout chase on social media or a compute spike spent to rob the clay mathematics institute it is a quest for elegance physical truth and universal rigor to decode reality [...] the most dangerous aspect of this maneuver is not the mathematical exaggeration but the corporate enclosure of scientific discovery by keeping these frontier systems locked behind outcome based pricing licensing barriers & proprietary API walls [...] when mathematical reality itself gets reduced to synthetic token production swallowed by closed infrastructure we transition from open academic inquiry to technological feudalism

🌐 [**Black Hat World Forum**](https://www.blackhatworld.com): discovering this forum recently, about SEO.

----

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/yr73shcyl5p93dw532a1.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/qkpqrpd2ubybfh841qbh.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/qv9uje9pxsdas3l9arik.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/2hn8p9d6hqxpk53uemcd.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/b9s16gf2271jbr5xlwcv.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/rsasu8y5fv77mudx59wm.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/ick855c1986oynwf1vlr.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/g3xzmhqnsubej8xu5mrp.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/6okdt3ihjfkc39zxq4gf.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/qeynfi1f1klzngjkkr8l.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/8sz587hf4wq825xixhbh.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/lqatx5owv1n97ogfz04b.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/ki0ffka192w1liwe9wly.png)


![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/5i5hidm497fhoh6eips3.png)



----

Cover Image by <a href="https://unsplash.com/@artem_kniaz?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Artem Kniaz</a> on <a href="https://unsplash.com/photos/brown-wooden-boat-on-body-of-water-during-daytime-e3K4OOI3DcI?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
