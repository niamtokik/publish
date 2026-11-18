---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/weeklyreview202644-2d6o"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2F4idozf93d63qop0huxj6.jpg"
created_at: "None"
crossposted_at: "None"
description: "This week was mostly dedicated to clean up and fix my CI/CD local infrastructure. The first version..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/weeklyreview202644-2d6o"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "weeklyreview202644-2d6o"
social_image: "None"
title: "WeeklyReview#202644"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# WeeklyReview#202644

This week was mostly dedicated to clean up and fix my CI/CD local infrastructure. The first version of this one was undocumented and using Tor as relay to hide my private IP address. Unfortunately, most of the tor exit nodes were blocked by Google, and following the recent news regarding the 333 rogue exit nodes, forwarding this traffic through my own servers is probably a better idea. Both configuration have been configured - even if it's not yet finished but it works.

In the end, it was great to do some old-school sysadmin/netadmin tasks on OpenBSD. This system is still my favorite after all these years. Yes, it is not fast as a Linux-like distribution, it does not have all fancy hardware support from other operating system, but damn... In few hours, one is able to deploy a crazy stable and secure infrastructure.

----

On my Dart/Flutter application side, the database management was - and still is - a problem. `sqflite` and other interface to it are unpleasant to use. One of my target is to use `ribs_sqlite` over `sqlite` or `sqflite`, but designing it this way requires to change some of my first design.

Another thing, the front-end part was my main target because it was my weak point. By doing that, a big part of my time was dedicated to learn more about UI/UX and mobile design. A post is planned to be released - one day - on that.

----

# Coding

🏗️ [**nanofil**](https://github.com/mbrock/filnix/tree/main/nanofil): A C compiler written in Prolog that emits x86-64 assembly in the Fil-C ABI. Its object files link with clang-built Fil-C code, and they keep Fil-C's guarantees

🌐 [**Learn Erlang Step-By-Step**](https://learnerlang.com/): a new initiative to learn Erlang based on a real-world project! I like the concept and how it has been done.

📝 [**A faster way to compute signed 64-bit floor division by constants**](https://www.benjoffe.com/fast-floordiv): a way to optimize floor division when the divisor is known during compile time.

📝 [**Writing a Linux Debugger Part 1: Setup**](https://tartanllama.xyz/posts/writing-a-linux-debugger/setup/): a serie of article on developing its own linux debugger in C++.

# System

🏗️ [**Beszel**](https://github.com/henrygd/beszel): a lightweight server monitoring platform that includes Docker statistics, historical data, and alert functions.

# Database

🏗️ [**pgCluu**](https://github.com/darold/pgcluu):  a Perl program used to perform a full audit of a PostgreSQL Cluster and System performance.

🌐 [**SafeGrd**](https://safegrd.dev/): SafeGrd backs up your databases, files and mail, encrypts and locks each copy, and restores it on a schedule to prove it works. An agent with your production keys can drop the database, but not the backups.

🏗️ [**pgrecon**](https://github.com/Muzzammil242/pgrecon): an open-source Oracle to PostgreSQL migration assessment and schema conversion tool. It inventories an Oracle database from an offline dump and runs a deterministic rule engine over it.

🏗️ [**PostgreSQL Anonymizer**](https://postgresql-anonymizer.readthedocs.io/en/latest/): an extension to mask or replace personally identifiable information (PII) or commercially sensitive data from a Postgres database.

🏗️ [**sqlean**](https://github.com/nalgeon/sqlean): There are a lot of SQLite extensions out there, but they are incomplete, inconsistent and scattered across the internet. Sqlean brings them together, neatly packaged into domain modules, documented, tested, and built for Linux, Windows and macOS.

# Security

🌐 [**Tailworm, we have zero-trust in our infrastructure**](https://tailworm.com/): a report audit of the tailscale project, containing a lot of security issues.

🐦 [**Keystone: Statement Regarding the Security Incident on Our Official Website and Customer Guidance**](https://x.com/KeystoneWallet/status/2114719318722404578)

📑 [**Don’t Look Up: There Are Sensitive Internal Links in the Clear on
GEO Satellites**](https://satcom.sysnet.ucsd.edu/docs/dontlookup_ccs25_fullpaper.pdf)

📝 [**Fuzzers vs. AI: Comparing Fuzzilli and BigSleep on JavaScript Engines**](https://projectzero.google/2026/10/fuzzing-v-AI.html)

🌐 [**tpbreak**](https://tpbreak.afflicted.sh/): TP-Link firmware decryption at scale — 52,609 images. The verification public key is also the decryption key: the AES key/IV fall out of the RSA-PSS salt. No private key required.

🌐 [**SMS of Death**](https://smsofdeath.com/): an unchecked cast on an array can cause a denial of service for a long period of time on Android. It can lead to SQLite database corruption and also impact the phone to boot. It can brick the phone. If I understand correctly, it will not be fixed... Crazy.

📝 [**Alpine Linux GitLab security incident: attempted exploitation of CVE-2026-97229**](https://alpinelinux.org/posts/GitLab-security-incident-CVE-2026-97229.html): a gitlab upgrade where the main fix was not applied because of Ruby. It confirms me Alpine Linux team is great, instead of ignoring this attack, they are redeploying/rebuilding everything. Great project.

📝 [**SPECTER: Leaking Data from Air-Gapped Computers by Toggling USB Power States**](https://www.rtl-sdr.com/specter-leaking-data-from-air-gapped-computers-by-toggling-usb-power-states/)

📝 [**Thermal Noise Communication: Sending Data Without a Carrier Signal, with an RTL-SDR as the Receiver**](https://www.rtl-sdr.com/thermal-noise-communication-sending-data-without-a-carrier-signal-with-an-rtl-sdr-as-the-receiver/)

📝 [**Official Claude Code VS Code Extension Compromised to Install Persistent SSH Backdoor**](https://thehackernews.com/2026/10/official-claude-code-vs-code-extension.html)

📝 [**When intermediate CAs fail, language stacks discover they own the blast radius**](https://freenode.net/article/when-intermediate-cas-fail-language-stacks-discover-they-own-the-blast-radius)

📑 [**Bypassing Secure Boot using Fault Injection**](https://raelize.com/upload/research/2016/2016_BlackHat-EU_Bypassing-Secure-Boot-Using-Fault-Injection_NT-AS.pdf)

# Security/cryptography

📝 [**The case of the 9 bit AES key**](https://v12.sh/blog/the-case-of-the-9bit-aes-key): encrypt your document yourself... PDF encryption from open-source world is just broken. The keys/seeds are not coming from cryptographic random sources, then, it is easy to break.

📝 [**QSYRUPWD, Part 2: Correcting the Rijndael Key Builder**](https://blog.silentsignal.eu/2026/10/29/qsyrupwd-part-2-correcting-the-rijndael-key-builder/)

📝 [**Lean for Cryptanalysts: A Practical Introduction to Formal Proofs**](https://hoseinhadipour.com/blog/lean-for-cryptanalysts/): a lot of people are talking about the [lean language](https://lean-lang.org/functional_programming_in_lean/), it is on my long list of thing to learn. When someone is writing a post about Lean and cryptanalysis, for sure it will be a banger. So, this is a great example of lean usage, and it motives me even more to learn/use it.

# Security/RedTeam

🌐 [**Exploit for php2shell-audit**](https://sploitus.com/exploit?id=D743A147-AC04-558E-AC44-A86A48AABB08): a "working" (yet non-tested on my side) exploit against php2-shell.

🌐 [**Exploit for CVE-2026-111497 (brotli)**](https://sploitus.com/exploit?id=2EF3AE90-EF42-5F24-AA67-C762AC236FE3): a "working" (yet non-tested on my side) exploit on nodejs brotli vulnerability.

📝 [**Bluetooth Low Energy Security Testing, Consolidated: Introducing Caeruleus**](https://www.praetorian.com/blog/ble-testing-caeruleus/): Bluetooth fascinate me since High School, at this time, I unsuccessfully tried to create an audio/video streaming application on Nokia SymbianOS in C++. It was fun, and bluetooth is a really interesting piece of technology. Having a list of tools to identify and attack this protocol is always useful, especially if you are developing Bluetooth application.

# Embedded

📝 [**Digikey Reference Design Library**](https://www.digikey.com/reference-designs/en)

# Update/Upgrade

🔄 [**LibreSSL 4.4.0**](https://undeadly.org/cgi?action=article;sid=20261025115016): including eMudhra security fix.

🔄 [**Sel4 17.0.0**](https://github.com/seL4/seL4/releases/tag/17.0.0):  many bug and security fixes. Documentation was also improved. Few platforms have been removed (Arndale, Odroid-X, HiKey, Inforce IFC6410, exynos5). The [full changelog](https://github.com/seL4/seL4) is available on Github.

🔄 [**Elixir 1.20.5**](https://github.com/elixir-lang/elixir/releases/tag/v1.20.5): Security and bugs fixes release, including 2 CVEs.

🔄 [**Flutter 3.47.9**](https://github.com/flutter/flutter/releases/tag/3.47.9): bugs fixes release.

# Theory

📑 [**Evidence for the representation of non-hierarchical structures in language**](https://www.nature.com/articles/s41562-025-02387-z)

# Leaks of the Week

🐦 [**Sony**](https://x.com/ZeroDayFacts/status/2115770189426106414): more than 2.5 millions customers leaked, including sensitive information like mails and phone number.

📝 [**Solnet**](https://frenchbreaches.com/alertes/solnet-suisse-piratage-fuite-donnees-clients-telecom-mvwjqg7ow72iqngt8te): Switzerland network provider impacted by a data leak impacting more than 5000 customers.

📝 [**Rassemblement National**](https://frenchbreaches.com/blog/rassemblement-national-un-pirate-revendique-les-donnees-de-150-000-adherents): more than 432000 subscribers data leaked from this French political party.

🐦 [**iCloudITS**](https://x.com/DarkWebInformer/status/2116301692476026953): Saudi IT Provider leaked more than 15GB of data from their database.

📝 [**Bangkok Post**](https://darkwebinformer.com/bangkok-post-breach-claim-includes-822-140-member-accounts-and-6-9-gb-infrastructure-dump/): more than 820000 members impacted by a data leak 

📝 [**Grand Orient de France**](https://frenchbreaches.com/blog/francs-macons-le-grand-orient-de-france-vise-par-une-cyberattaque-67-go-de-donnees-revendiques): 6.72GB of data leaked from one of the main French freemasonry. 

🐦 [**French Unknown IT Company**](https://x.com/DarkWebInformer/status/2115459185852731693): if true, an IT company was impacted by a huge data leaks, including their private keys API for Stripe and Vercel.

# Misc

📝 [**Anthropic announces bankruptcy by...?**](https://polymarket.com/event/anthropic-announces-bankruptcy-by)

📝 [**Who’s Aligned to Whom? How AI Agents Shape Experts’ Research Judgment Calls**](https://www-cdn.anthropic.com/519c17a5d23a794e8b6d50a854048d0b61e0d73a.pdf): The conclusion contains all you need to know.

> experts may defer underdetermined decisions to an AI agent, and that this deferral can be hard to identify, even for the experts themselves [...] Judgment also depends on skill, and people who stop making these decisions may lose the ability to make them [...] institutions will need an explicit strategy for developing human skills as models become more capable [...] Institutions may want to protect these skills and human oversight even with extremely capable AI, for safety, resilience, or their own sake.

📝 [**Claude Code burns ~15–20% of your tokens on a 3-word status line. Here's how to turn it off**](https://gist.github.com/flamerix-ai/c3905705cc4205e5de3011fa2e74efce)

📝 [**Manifestos, Fear, and ‘Loser Thinking’: Inside Proton’s AI Reckoning**](www.404media.co/manifestos-fear-and-loser-thinking-inside-protons-ai-reckoning/): What a great leader and innovator... Calling his engineers and technicians loser is really an incredible act. So, time to move to another solution. By the way, tutanota is perhaps not a [good alternative](https://x.com/CryptoCyberia/status/2019062136400474366).

----

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/1wy4cvtng1th9kmx3eri.png)](https://x.com/devXritesh/status/2115783759672865194)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/y1guzcxa1rfl51piq0v7.png)](https://x.com/msimoni/status/2114088887366586517?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/w89a4knjhcpypl99buos.png)](https://x.com/gf_256/status/2114051242817380507?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/jg3k6fda3r6e7le5xxxy.png)](https://x.com/teej_dv/status/2114423896955118015?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/anjyrhmd2wbfw3qjidl0.png)](https://x.com/BadlyLiquidated/status/2115928489413214629)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/48wp2w8hvyq02wy5okzl.png)](https://x.com/Polymarket/status/2115911339587850419)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/ezg796sm80qof3pqcpga.png)](https://x.com/codytrades/status/2116072067061915684)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/44jh9hqjgnk3k8nmm2hp.png)](https://x.com/gaborgurbacs/status/2116195564127715664)


----

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/j1mhof18i07hlhvjjao2.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/d7tuq0cutb32unusginz.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/oocactcmzigo3z5yrcyc.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/hmkrz0ybvftcujxdkr28.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/4rxkf21kf2mnfrhjqgrn.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/z4r4ayct93una6hoktr8.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/xjdfz88ecjj9fds64ccv.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/81g9lhz8kepiy2c8z2jp.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/kglyb1akeg3d599ctymv.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/4t9wv5al5o4grmnm1cla.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/gtteane6irjg9e92pifd.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/2fcdcvx1aoimbt64eam3.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/dp0jgzv0kzfkojvbpg86.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/i27w1d9w9c79xmz8bzd2.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/wj8dca7fow3lp1lnum6f.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/ei3qejlu0orduejegt8f.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/8mcud1zrgem51v0xnff4.png)

----

Cover Image by <a href="https://unsplash.com/@niki_emmert?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Nikolett Emmert</a> on <a href="https://unsplash.com/photos/a-close-up-of-a-leaf-with-drops-of-water-on-it-4WhzY_EfSw8?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>