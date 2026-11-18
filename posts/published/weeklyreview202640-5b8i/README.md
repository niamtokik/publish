---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/weeklyreview202640-5b8i"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Fg9qk1xz6g0wqba9ybno8.jpg"
created_at: "None"
crossposted_at: "None"
description: "Another week of doing Erlang/Elixir code on expki project. Again, that's mostly a sandbox to remove..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/weeklyreview202640-5b8i"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "weeklyreview202640-5b8i"
social_image: "None"
title: "WeeklyReview#202640"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# WeeklyReview#202640

Another week of doing Erlang/Elixir code on `expki` project. Again, that's mostly a sandbox to remove my 2 years rust doing only Erlang code and infrastructure stuff. Things are moving though, and I have a way to deal with the `public_key` module from Elixir. It's not perfect yet and can be optimized, but it should do the job. I think you will read that in a post very soon.

----

My way to extract macros and records from Erlang source code has been moved to its own module called [`preprocessing`](https://github.com/niamtokik/preprocessing). It is currently being tested, but it should work correctly. Many things remain to be added though, like the support for dynamic macros and perhaps other attributes from Erlang.

----

Dev.to is buggy. One big article I started to write few days ago was practically destroyed because of cache issue on the browser. When editing the file from the dashboard, an old version was displayed instead of the latest one. Don't save. Don't publish. Close the window, logout from your dev.to account and reconnect.

----

[`publish`](https://github.com/niamtokik/publish) is now able to fetch all the posts from dev.to using the API and curl. I did not have a lot of time working on it this week though. It would be really nice to migrate few  my articles very soon on my own domain.

----

[`mac_randomizer`](https://github.com/niamtokik/mac_randomizer) was a pet project I got year ago, simply an idea at first. I wanted to do a bit of C this week and started to play with that. Not a really serious project though.

# Coding

📖 [**Course book**](https://github.com/cs341-illinois/coursebook): Open Source Introductory Systems Programming Textbook for the University of Illinois

🌐 [**zero-js**](https://zero-js.vercel.app/): compiling code in HTML/CSS directly, without javascript.

📝 [**Optimizing a Lock-Free Ring Buffer**](https://david.alvarezrosa.com/posts/optimizing-a-lock-free-ring-buffer/)

📝 [**Simplify Function Generation in Elixir with Macros**](https://engineering.legendsoflearning.com/posts/generating-functions/): a quick reminder to generate function in Elixir with macros. A good way to do meta-programming.

📝 [**Elixir Anonymous functions**](https://elixir.hexdocs.pm/anonymous-functions.html): official documentation about anonymous/lambda functions in Elixir.

📝 [**Elixir Quote and unquote**](https://elixir.hexdocs.pm/main/quote-and-unquote.html): official documentation about metaprogramming elixir with quote and unquote.

🏗️ [**pulso**](https://github.com/tuist/pulso): A headless, open-source observability backend: unified logs, metrics, and traces access, built-in alerting, and a native Model Context Protocol (MCP) interface, built on Elixir/OTP with a Rust hot path for columnar data.

🏗️ [**erlang_pay**](https://github.com/imboy-pub/erlang_pay):  A pure-Erlang payment gateway library for Alipay (App pay), WeChat Pay v3 (JSAPI/Native) and Stripe (PaymentIntent).

📝 [**How Copy-on-Write Works with Memory-Mapped Files**](https://blog.codingconfessions.com/p/how-copy-on-write-works-with-memory)

📝 [**Disable debuginfo to improve Rust compile times**](https://kobzol.github.io/rust/rustc/2025/05/20/disable-debuginfo-to-improve-rust-compile-times.html)

📝 [**Reverse Engineering Novalogic's Comanche Terrain Maps**](https://pikuma.com/blog/comanche-maps-reverse-engineering): not an expert in game programming, but reverse engineering is an amazing field. This article explains how to reverse the maps from an old game, it's in C, and it's a great one! I liked this quote:

> Programmers in the early 90s didn't reinvent everything. They used the formats and tools the artists already had, like PCX files straight out of a paint program, and saved their cleverness for the parts that really needed it: the renderer.

📝 [**What TLA+ can and can't check**](https://buttondown.com/hillelwayne/archive/what-tla-can-and-cant-check/): TLA+ fascinated me few years ago, and I started to learn it by myself. Unfortunately, I was not really good with it. Languages formal verifications/specifications can be challenging to learn, even more if you don't have any a real usage for them. It's good to read a post on this language, even more to clarify what TLA+ can do or not.

📝 [**Compiler Options Hardening Guide for C and C++**](https://best.openssf.org/Compiler-Hardening-Guides/Compiler-Options-Hardening-Guide-for-C-and-C++.html): an extremely useful guide and reference to correctly set C compiler flags for hardened applications.

# Database

🏗️ [**Dasha**](https://github.com/dbulashev/dasha): PostgreSQL performance dashboard for analyzing database cluster health, identifying problems, and providing optimization recommendations.

# System

🏗️ [**MiniOS**](https://minios.dev/): A full-featured desktop environment with a wide range of applications. Professional tools for creativity and development.

🏗️ [**Vinix**](https://vinix-os.org/): Vinix is an effort to write a modern, fast, and useful operating system in the [V programming language](https://github.com/vlang/v).

📝 [**HardenedBSD August / September 2026 Status Report**](https://hardenedbsd.org/article/shawn-webb/2026-09-27/hardenedbsd-august-september-2026-status-report): mostly small modification and bug/security fixes.

📝 [**OpenBSD-current has moved to version 8.0**](https://undeadly.org/cgi?action=article;sid=20260927120854): openbsd 8.0 will be ready soon.

📝 [**vmm(4)/vmd(8) gain support for multi-processor VMs**](https://undeadly.org/cgi?action=article;sid=20260927115632): OpenBSD vmm/vmd can now have more than one CPU configured, that's a very good news!

📝 [**SmartOS: The illumos Way of Thinking About Servers**](https://it-notes.dragas.net/2026/09/28/smartos-the-illumos-way-of-thinking-about-servers/): sunos, illumos and smartos... A good way to introduce them via this article.

🏗️ [**How To Secure A Linux Server**](https://github.com/imthenachoman/How-To-Secure-A-Linux-Server): An evolving how-to guide for securing a Linux server that, hopefully, also teaches you a little about security and why it matters.

📝 [**Powerboard Tyche unveiled at Pianeta Amiga**](https://www.powerpc-notebook.org/2026/09/powerboard-tyche-unveiled-at-pianeta-amiga/): Never got an Amiga, never installed AmigaOS, but since I learnt DragonFlyBSD kernel was a mix between FreeBSD and AmigaOS, I always wanted to test it. Another crazy thing is... the community is active! The passion for Amiga seems eternal. Crazy.

# Security

📝 [**Auditing in the age of (good enough) AI**](https://blog.trailofbits.com/2026/09/18/auditing-in-the-age-of-good-enough-ai/)

🏗️ [**apk-reverse**](https://github.com/newliver666/apk-reverse): a skill to reverse APK.

📝 [**Proactive Defense: Hardening Code Pipelines and CI/CD Infrastructure**](https://cloud.google.com/blog/topics/threat-intelligence/hardening-code-pipelines-and-ci-cd-infrastructure): a must read to apply modern protection on CI/CD.

> Organizations should mandate a minimum release-age cooldown of seven days before any newly published public package version becomes installable [...] Establishing a strict seven-day buffer provides the open-source ecosystem time to detect and pull poisoned releases before they reach internal builds. [...] All external packages and container images should, wherever possible, route through a centralized internal proxy that caches, inspects, and gates each component.

📝 [**The Developer is the New Perimeter: How Supply Chain Attacks Are Becoming Cloud Breaches**](https://blog.qualys.com/vulnerabilities-threat-research/2026/09/28/developer-new-perimeter-supply-chain-cloud-breaches): the number of supply chain attacks is growing, and this is another article to remind us to always verify the security of our CI/CD.

📝 [**Cops Can Bypass iPhone’s Automatic Reboot to Get Into Locked Phones, Leaked Video Claims**](https://www.404media.co/cops-can-bypass-iphone-automatic-inactivity-reboot-graykey/)

# Security/Cryptography

📑 [**A Survey of Pseudorandom Codes**](https://eprint.iacr.org/2026/2162.pdf): 

📑 [**Fully Anonymous Perfect Secret-Sharing**](https://eprint.iacr.org/2026/2145.pdf)

🏗️ [**Jolt**](https://github.com/atheonxyz/jolt): Just One Lookup Table. Jolt is a zkVM (zero-knowledge virtual machine) for RISC-V, built to be the simplest, fastest, and most extensible general-purpose of its kind. A [book](https://jolt.a16zcrypto.com/) is available.

📑 [**Formally Modeling the Terrapin Attack on SSH**](https://eprint.iacr.org/2026/2158.pdf)

📑 [**DASH: Distributed Asynchronous Schnorr with High Throughput**](https://eprint.iacr.org/2026/2138.pdf)

📑 [**Perpetual Encryption**](https://eprint.iacr.org/2026/2096.pdf)

📑 [**Lightweight Cryptography for Secure UAV Data Integrity Using Ascon-XOF128 and SHAKE128**](https://eprint.iacr.org/2026/2080.pdf)

📑 [**Forging 1024-bit RSA signatures in nearly SNFS time**](https://eprint.iacr.org/2026/2131.pdf)

📑 [**New Applications of RSA**](https://eprint.iacr.org/2026/2167.pdf)

# Security/RedTeam

📝 [**Offensive Security: Pentesting Office Phones with SIPVicious**](https://hackers-arise.com/offensive-security-pentesting-office-phones-with-sipvicious/): a post showing a quick demo of [sipvicious](https://github.com/EnableSecurity/sipvicious) against VoIP local server.

# Embedded

🏗️ [**Sail architecture definition language**](https://github.com/rems-project/sail): Sail is a language for defining the instruction-set architecture (ISA) semantics of processors: the architectural specification of the behaviour of machine instructions. Sail is an engineer-friendly language, much like earlier vendor pseudocode, but more precisely defined and with tooling to support a wide range of use-cases.

📝 [**You Can Make A Microprocessor That’s All Your Own**](https://hackaday.com/2026/09/26/you-can-make-a-microprocessor-thats-all-your-own/)

📝 [**Reverse Engineering the iPod Classic's Undocumented Mikey Chip**](https://terminalbytes.com/reverse-engineering-ipod-classic-mikey-chip/)

# Updates/Upgrades

🔄 [**Hackney 4.8.4**](https://github.com/benoitc/hackney/releases/tag/4.8.1): many updates here, from the 4.8.1 to 4.8.4, fixing many bugs. If you are using a previous version, you should probably update it.

🔄 [**OpenBSD 7.9 Errata**](https://www.openbsd.org/errata79.html): a huge amount of patch (9) to fix security issues on the whole system. `ldapd`, `nsd` (8 CVEs), `unbound` (35 CVEs), `iked` and many other issues found on the kernel.

🔄 [**Qubes OS 4.3.2**](https://www.qubes-os.org/news/2026/10/02/qubes-os-4-3-2-has-been-released/)

# Misc

📝 [**How to Optimize a CUDA Matmul Kernel for cuBLAS-like Performance: a Worklog**](https://siboehm.com/articles/22/CUDA-MMM)

📝 [**Making Deep Learning Go Brrrr From First Principles**](https://horace.io/brrr_intro.html)

📝 [**AI Bros Are Having a Meltdown Because the Associated Press Stylebook Clarifies That AIs Don’t Have Feelings**](https://futurism.com/artificial-intelligence/ai-bros-meltdown-feelings)

📝 [**Someone ‘Torturing’ LLMs in a Robot Prison Has Triggered the Dumbest Debate in AI Yet**](https://www.404media.co/someone-torturing-llms-in-a-robot-prison-has-triggered-the-dumbest-debate-in-ai-yet/): Yeah. Crazy right? LLMs are not conscious. Adding a "feature" to feel pain/pleasure in a program does not make it conscious, it adds just another variable in the state, or another way to interpret inputs. This can be called - at best - "LLM moding".

> AIs are not conscious. **They do not feel, experience, or suffer**. They do not have innate preferences or underlying motivations. **They are sequence completion engines**, internally hollow, **designed to follow instructions**, and accomplish goals set by humans. Unfortunately, there’s a growing chorus of people who argue that AIs could now be, or may soon become, conscious. They argue that AIs may deserve rights and protections similar to those that we provide other conscious beings […] If this is how AI is developed, it will have a disastrous impact on the wellbeing of humanity.

# Leaks of the week

📝 [**Alaxione**](https://frenchbreaches.com/alertes/alaxione-mukgc44jlfsfro727v): more than 8.5 millions patients impacted, data from 2010 to 2026. +5 millions phone numbers leaked, +1.4 millions e-mail, +300k social security number.

📝 [**KEL/Orisha**](https://frenchbreaches.com/alertes/groupe-kel-orisha-mukzqxqoj9x80n11kl): 1.3 million people impacted including +600k e-mail, +600+ phone number, +140k IBAN.

📝 [**PixelLeak: How AI Agents Exposed Developer Screenshots from Leading Tech Companies**](https://www.glow.io/blogs/how-ai-agents-exposed-developer-screenshots-from-leading-tech-companies): Glow labs identified more than 13k screenshots from 300 organizations (including big companies). Impacted more than 900 repositories and 100k employees. It seems it was mostly skill issue there, and the "AI" were not hardened. Interesting leaks though, because if screenshots can leak, probably other data can be leak as well.

📝 [**FFRandonnée**](https://frenchbreaches.com/alertes/f-d-ration-fran-aise-de-la-randonn-e-ffr-mun6o16r4h0ud0vz18i): 1.43 millions impacted people, more than 1 million e-mail and 663k phone numbers, with physical address location.

📝 [**Cookson-CLAL**](https://frenchbreaches.com/alertes/cookson-clal-muomsy4ng1mk25gtxwj): complete credit card information have been leaked. No more information about the number of people impacted though.

📝 [**VosFactures**](https://fuitesinfos.fr/article/2026-10-01-vosfactures): data leaks on one of the companies in charge of the digital invoices in France. No more information right now, but they have a database with more than 500k companies. Less than 1 month after the official launching of the digital invoices for the companies, one of the "big player" seems to have been impacted by a huge data leaks.

----

{% embed https://x.com/md_kasif_uddin/status/2104051150274408672/video/1 %}

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/ffejdeopcd2t5jwybqeg.png)](https://x.com/rawsalerts/status/2103520617144389928?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/bnm2fmb2bkkee6m1lpcj.png)](https://x.com/tomhacks/status/2103630947883057565?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/cnrhaq2zti5ian777c2j.png)](https://x.com/Qivshi1/status/2103856150592545225?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/rpdtfvrind7bng40znp0.png)](https://x.com/evisdrenova/status/2104052883662717347?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/k9kuavflu0wbqsp6m0h2.png)](https://x.com/Quasilocal/status/2104106284274581643?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/eo75p015eedytz6mdw95.png)](https://x.com/banteg/status/2103958454708920387?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/yxro95idimnhrzgi28a5.png)](https://x.com/CorpAbsurdity/status/2103874469311734112?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/9wszicx0lqzlskbg73ey.png)](https://x.com/wangzhr4/status/2104220073120702579?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/kz6o708sgzazvsgcislo.png)](https://x.com/C2IRIS/status/2104231952643428477?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/esmfnpy4ak2azirvl1pp.png)](https://x.com/jaredLunde/status/2104240208032190768?s=20)

[![AI is malware](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/crjf3xn7d4g5pygy54xx.png)](https://x.com/PoetsLab/status/2104065575580262701?s=20)

[![AI is cancer](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/673gqd9zzn3r25e7uuqt.png)](https://x.com/Mikymigs/status/2104232663968293336?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/mi6sy0hbgeufalqnt1sv.png)](https://x.com/jrysana/status/2104441570179404176?s=20)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/ix3hxk2gx2gaecz9z68h.png)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/90tfm9nh2udujf55ixdw.png)](https://x.com/Polymarket/status/2104499605245251664?s=20)

[![Anthropic’s IPO prospectus reveals a staggering $42,000,000,000.00 net loss in 2025.](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/79ly9j5x7y0zywigpiyy.png)](https://x.com/Polymarket/status/2104719103810224299?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/33piosyx330ezrjf26ip.png)](https://x.com/lcamtuf/status/2105023754263028011?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/6youb0tncb6ntvf3htvt.png)](https://x.com/Grady_Booch/status/2105157423615156439?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/ob8dzffrtj6obw1xi1l2.png)](https://x.com/headzoo/status/2105055215024009662?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/bbam41pdpvkhd22qyx29.png)](https://x.com/mrjasonchoi/status/2105959199452844384?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/1dojxjtxqg18xf9odrxb.png)](https://x.com/shcallaway/status/2106142042405453879?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/n27axs11uvyv9yuv4sao.png)](https://x.com/LeoBuilds_/status/2106159384787345556?s=20)

[![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/cgl1iow0zl9k1s12f2up.png)](https://x.com/straceX/status/2106374472966295641?s=20)

----

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/o9x8n2towli4ktcc0q69.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/u3zqo8rxlxq410fd1qs2.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/0zobykuxlon68sh7e01n.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/zqlkuvtnkew6uv9bqhqq.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/2nuwh2lq252nv0wxm761.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/4v5aq2sj8hblf28jkp5e.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/f15z1pw3xu6dg9ozpzg4.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/agsdeq8djouypf1or7up.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/noo5g60q3ot5mfz4sl4s.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/uyb96ae7btd6scke59oo.png)

----

Cover Image by <a href="https://unsplash.com/@kostyadyadyun?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Konstantin Dyadyun</a> on <a href="https://unsplash.com/photos/brown-trees-on-brown-field-during-daytime-50hhiZf9vI0?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>