---
title: "WeeklyReview#202633"
---

# WeeklyReview#202633

Few years ago, I was collecting all the interesting links, publications, books, articles or videos found each weeks. Those posts were never published... And it's a shame. Let fix that by creating my Weekly Review on dev.to. Here the first issue!

The last 4 or 3 weeks were kinda exhausting to me due to the French weather but also because of travelling (not really vacation). This is the reason why the amount of posts decreased. In fact, the motivation is still not there, but it gave me a moment to breath and took a moment to see "new things".

[**Tcl/Tk**](https://www.tcl-lang.org/) seems to be a great language. Being part of all my systems for many years, it never attracted me for some reasons. After watching a talk on SQLite talking about it, especially on the fact it was created to be a "LISP-like language with C syntax". It triggers my curiosity and started to read the documentation. A comparison between [LISP and Tcl is available on their wiki](https://wiki.tcl-lang.org/page/Lisp). Many great features are present in Tcl:

1. [VFS (virtual file system)](https://core.tcl-lang.org/tclvfs/index) support gives the possibility to mount file systems or file directly from the language itself. It can be used with ZIP files for example. This feature is missing on Erlang/OTP and can offer great advantages for dynamic update or portability (especially with [escript](https://www.erlang.org/doc/apps/stdlib/escript.html)).

2. [Tk](https://core.tcl-lang.org/tk/home) seems easier to use than [wxWidget](https://www.erlang.org/doc/apps/wx/wx.html) on Erlang/OTP and more portable. It looks like no one created a [tcllib](https://www.tcl-lang.org/software/tcllib/) or [libtk](https://www.tcl-lang.org/software/tklib/) interface to Erlang. This kind of feature could help to also increase portability.

3. A bit like Erlang, Tcl supports small isolated stackful processes (called [coroutines](https://www.tcl-lang.org/man/tcl8.6/TclCmd/coroutine.htm)). It also uses a share-nothing design for its [thread](https://www.tcl-lang.org/man/tcl9.0/ThreadCmd/thread.html) implementation. It was a surprise to read that. Even more, Tcl is event-driven and using a message system to pass the data!

Why this language, like Erlang, is in the shadow since the 90s? Why is nobody speaking more about that?! If you want to know more about that, and can't wait to read my future publication, I invite your to check [**Develop Cross-Platform CLI and GUI Tools With Tcl/Tk. Powerful, Event-Driven, Open-Source And Future-Proof Toolkit… From the Past?!**](https://cgicoffee.com/blog/2026/04/tcl-tk-develop-cross-platform-cli-gui-tools-tutorial-guide).

Regarding my projects, including my application, it was in stand-by as well during the past weeks. It is planned to be restarted during the next coming days, with more publication on mobile application design and private API reverse engineering. Another big part of my time was also dedicated to update and do a big cleanup of my resume, a good way to have a "quick" view of my long journey in IT.

# Coding

▶️ [**Fil-C: Garbage In, Memory Safety Out! - Filip Pizlo | SSW 2026**](https://www.youtube.com/watch?v=5F-2Y1LPRek): a talk about [Fil-c](https://fil-c.org/) (a way to protect memory in C) with the creator of the project. Really interesting project using many unheard Clang features, can be a good alternative to "modern" programming language like Rust, Go or Zig.

🏗️ [**Assembly Hall of Shame**](https://github.com/xoreaxeaxeax/asm-hall-of-shame): A project checking ASM instruction performance by Christopher Domas. 

📝 [**Elixir's GenStage Demand (a Visual Explainer)**](https://andrealeopardi.com/posts/genstage-demand-visualized/): an article explaining how Elixir [`GenStage`](https://gen-stage.hexdocs.pm/GenStage.html) is working with beautiful animation.

🏗️ [**clpz-sudoku-9x9.pl**](https://github.com/eyereasoner/eyeprolog/blob/main/examples/clpz-sudoku-9x9.pl): AI Escargot solver in Prolog ([eyeProlog](https://github.com/eyereasoner/eyeprolog/)), solving the problem in 0.88 seconds instead of 7.27 seconds. From [@josderoo on X/Twitter](https://x.com/josderoo/status/2087301125301063783?s=20).

📝 [**Master C and C++ with our new Testing Handbook chapter**](https://blog.trailofbits.com/2026/04/09/master-c-and-c-with-our-new-testing-handbook-chapter/): a summary post regarding their [Security Checklist for C/C++ Programs](https://appsec.guide/docs/languages/c-cpp/), containing a long list of things to verify before shipping something in C or C++, like [Bugs](https://appsec.guide/docs/languages/c-cpp/bug-classes/), [Linux Userland common issues](https://appsec.guide/docs/languages/c-cpp/linux-usermode/), [Linux Kernel-land common issues](https://appsec.guide/docs/languages/c-cpp/linux-kernelmode/), [Windows Userland issues](https://appsec.guide/docs/languages/c-cpp/windows-usermode/), [Windows Kernel-land](https://appsec.guide/docs/languages/c-cpp/windows-kernelmode/) and finally on [sandboxing](https://appsec.guide/docs/languages/c-cpp/seccomp/).

# Database

▶️ [**Reliability Lessons From SQLite - Richard Hipp | SSW 2026**](https://www.youtube.com/watch?v=V_qzqY1bb7I): an awesome talk from one of the SQLite creator, about [SQLite](sqlite.org/) history, testing and reliability. A must watch.

📝 [**Modeling State Transitions in Postgres**](https://thoughtbot.com/blog/modeling-state-transitions-in-postgres): nice article about state transition in PostgreSQL. Few years ago, one of my project needed something similar (it's ended by implementing a FSM-like system in postgres).

📝 [**plx : Write PostgreSQL functions in the language you already know.**](https://www.postgresql.org/about/news/plx-write-postgresql-functions-in-the-language-you-already-know-3358/): an interesting way to interact with PostgreSQL database by creating SQL function using another language; the [plx project source code](https://github.com/commandprompt/plx) can be found on Github.

# System

📝 [**Apple Container Internal**](https://u1f383.github.io/container/2026/06/23/Apple-Container-Internal.html): a publication about an Apple container feature I was unaware of, using a QEMU-KVM-like interface. A lot of code samples and details about this feature.

📝 [**Tachyum Open Sources its Prodigy ISA and Platform to Make AI Available to Everybody in the World**](https://www.tachyum.com/media/press-releases/2026/08/12/tachyum-open-sources-its-prodigy-isa-and-platform-to-make-ai-available-to-everybody-in-the-world/): Tachyum announced officialy they will release their Prodigy platform in full open-source (CC BY 4.0). They already have a [Github profile](https://github.com/Tachyum-Open-Source/) containing many open-source projects, including their [SIMD IEEE-754 fused multiply-add unit](https://github.com/Tachyum-Open-Source/fma-rtl) and [Tachyum TDIMM Design Specification](https://github.com/Tachyum-Open-Source/TDIMM-spec) (available as [PDF](https://github.com/Tachyum-Open-Source/TDIMM-spec/releases/download/0.3.0/TDIMM-Design-Specification.pdf)). The idea behind Tachyium Prodigy is to integrate in one processor, General Purpose Computing, Artificial Intelligence, Physical AI and many other features. Based on their website: "Prodigy has up to 21x higher performance and up to 10x better performance per watt than its competition". Curious to see if it's true.

🏗️ [**BORE (Burst-Oriented Response Enhancer) CPU Scheduler**](https://github.com/firelzrd/bore-scheduler): A Linux scheduler designed to deal with high load without disturbing user input. The news come from [Slackware-Based Zenwalk Linux Aims For "True Low Latency Desktop Experience"](https://www.phoronix.com/news/Zenwalk-BORE-Kernel).

🎥 [**Lefinnois on Twitch Live**](https://www.twitch.tv/lefinnois): Denis Bodor aka [lefinnois](https://x.com/lefinnois) started to do some live streaming session on FreeBSD kernel development (in French). Still great to see some BSD content in French!

# Network

📝 [**Off-Grid Communications, Part 1: Break Free from the Grid with Meshtastic**](https://hackers-arise.com/off-grid-communications-part-1-introduction-to-meshtastic-networks/): another off-grid network project called [Meshstatic](https://meshtastic.org/). This network can be used for backup when the main network is down (can be helpful for hiking, camping and so on). It uses ESP32 boards with LoRa modules. Can be interesting to deploy locally to test it, the bandwidth is not really great (max 20 kbps) but it can be another way to communicate.

📝 [**isTRAIN: Detecting if a Train is Blocking a Local Crossing By Listening to Railroad Frequencies**](https://www.rtl-sdr.com/istrain-detecting-if-a-train-is-blocking-a-local-crossing-by-listening-to-railroad-frequencies/): a quick review of an open-source application used to detect when a train is blocked (decoding data from 457.9375 and 452.9375 MHz). Interesting, a domain I did not really know.

📝 [**War Driving for DECT Devices with a HackRF and Android Device**](https://www.rtl-sdr.com/war-driving-for-dect-devices-with-a-hackrf-and-android-device/): a wardriving session review (on youtube) about [DECT](https://en.wikipedia.org/wiki/DECT) devices (a wireless standard using frequencies from 450 MHz up to 5,875 MHz) with the help of the [DeDECTive](https://github.com/SarahRoseLives/DeDECTive) open-source software.

📝 [**Mobile Network Hacking:What is a Mobile Network and How Does it Work?**](https://hackers-arise.com/mobile-network-hackingwhat-is-a-mobile-network-and-how-does-it-work/): quick publication on mobile network. This more like a small summary than a complete cheatsheet, mobile network is really complex, and doing a post on that seems impossible, but it's a good start for someone interested in this topic.

📝 [**Off-Grid Communications, Part 6: Internet-over-LoRa with deadmesh**](https://hackers-arise.com/off-grid-communications-part-6-internet-over-lora-with-deadmesh/): a tutorial to use [deadmesh](https://github.com/gnarzilla/deadmesh.git), a text-first internet bridge for mesh network. It uses LoRa and Meshstatic to communicate.

🏛️ [**IEEE 802.11bb**](https://en.wikipedia.org/wiki/IEEE_802.11bb): every year I check if new improvements are made with the [LiFi](https://en.wikipedia.org/wiki/Li-Fi) technology. Unfortunately, it's pretty rare to have good news. Using the light to transport locally the information seems (to me) way better than using radio signals. I hope one day we will be able to have that everywhere, with open-source compatible hardware.

# Security/BlueTeam

📝 [**Linux Security in 2026: Hardening, Monitoring, and Defense Strategies**](https://embeddedbits.org/linux-security-in-2026-hardening-monitoring-and-defense-strategies/): some good practices everybody should apply.

📝 [**The Detection & Response Chronicles: Covert Operations Through QEMU**](https://blog.nviso.eu/2026/06/04/the-detection-response-chronicles-covert-operations-through-qemu/): I love QEMU, and it's always a pleasure to read how to use it in some context. Here, Qemu is used as tunneling system, especially to cover up long-living attacks using custom network arguments.

📝 [**Most Common Linux Security Mistakes I Keep Seeing (And How to Avoid Them)**](https://embeddedbits.org/most-common-linux-security-mistakes-i-keep-seeing-and-how-to-avoid-them/): another publication about good practices.

📝 [**Artificial Intelligence in Cybersecurity, Part 14: Turning OSquery into an AI-Powered Forensics Engine**](https://hackers-arise.com/artificial-intelligence-in-cybersecurity-part-14-turning-osquery-into-an-ai-powered-forensics-engine/): a way to use [OSQuery](https://www.osquery.io/) with LLMs.

# Security/RedTeam

📝 [**SDR (Signals Intelligence) for Hackers: Building Your Own Bluetooth and Wi-Fi Jammer**](https://hackers-arise.com/sdr-signals-intelligence-for-hackers-building-your-own-bluetooth-and-wi-fi-jammer/): this article present a way to generate noise in 2.4Ghz communication range (and then generate DoS) with the help of the [ESP32-BlueJammer](https://github.com/EmenstaNougat/ESP32-BlueJammer) tool.

📝 [**Pentesting: Taking Over A Corporate Mail – Mailcow**](https://hackers-arise.com/cyberwar-taking-over-a-russian-corporate-mail/): Interesting publication about a pentest review involving mails and credential recovery. Using `tcpdump` to watch the active connection and stole the credentials (from an active server). Classic.

📝 [**Compromising Telecom Systems: Deploying and Detecting the BPFDoor Backdoor**](https://hackers-arise.com/compromising-telecom-systems-deploying-and-detecting-the-bpfdoor-backdoor/): An APT review involving [BPFDoor](https://github.com/pjt3591oo/bpfdoor.git) (a malware/backdoor) waiting for a magic packet to be active.

📝 [**Social Engineering: Attacking Networks with a BadUSB-ETH, Part 1**](https://hackers-arise.com/social-engineering-attacking-networks-with-a-badusb-eth-part-1/): a covert-network attack using BadUSB-ETH and doing some DHCP poisoning.

📝 [**Open Source Intelligence (OSINT): Extracting Information from TikTok**](https://hackers-arise.com/open-source-intelligence-osint-extracting-information-from-tiktok/): a small OSINT publication about collecting data from TikTok.

🏗️ [**Spaghettifying DRAM (skitter-creek-bath-salts)**](https://github.com/xoreaxeaxeax/skitter-creek-bath-salts): Exploit attacking the memory controller by rewiring the DRAM and breaking the memory protection. By doing that, even protected memory region can be exposed and can expose everything in the end. This can be exploited via C code (with the help of paging, cache, threading and [TLB](https://en.wikipedia.org/wiki/Translation_lookaside_buffer)s). See also the announcement on [X/Twitter](https://x.com/xoreaxeaxeax/status/2087902981458895357/video/1). Announced during the Black Hat 2026 by Christopher Domas.

📝 [**Rocket.Chat Cross-Site Scripting leading to Remote Code Execution CVE-2020-15926**](https://blog.redteam.pl/2020/08/rocket-chat-xss-rce-cve-2020-15926.html): an example of XSS exploitation vulnerability with remote code execution.

🌐 [**pwn.college**](https://pwn.college/): another platform to learn hacking from the basics to the expert level based on challenge (as usual). It looks great.

📝 [**CVE-2026-46331: Linux Kernel pedit COW LPE Exploit Explained**](https://hoploninfosec.com/cve-2026-46331-linux-kernel-pedit-cow-privilege-escalation): most of the recent Linux distribution impacted. The security is from May 2026, but the [exploits](https://vulners.com/cve/CVE-2026-46331) are interesting to study, especially [`pedit-cow-exploit`](https://github.com/0xdeadroot/pedit-cow-exploit).

📝 [**Social Engineering: Building Your Own BadUSB**](https://hackers-arise.com/badusb-hid-building-your-own-badusb/): a small tutorial to configure/create/use [BadUSB](https://github.com/soupbone89/BadUSB) for social engineering and local attack purpose.

📝 [**SDR (Signals Intelligence) for Hackers: Building Your Own Fake GPS Satellite**](https://hackers-arise.com/sdr-signals-intelligence-for-hackers-building-your-own-fake-gps-satellite/): a post about GPS spoofing, quickly describing how GPS works and how to manipulate the protocols with the [GPS-SDR-SIM](https://github.com/osqzss/gps-sdr-sim) project.

🏗️ [**LEAKSFORUMS**](https://github.com/FSECDEV/LEAKSFORUMS): a github project listing forum leaks.

# Security/Cryptography

📝 [**Factoring "short-sleeve" RSA keys with polynomials**](https://blog.trailofbits.com/2026/06/12/factoring-short-sleeve-rsa-keys-with-polynomials/): an attack on RSA keys using biased data and weak keys based on a [CompleteFTP](https://enterprisedt.com/products/completeftp/) vulnerability.

📝 [**2026.08.14: NSA and IETF, part 9: An update**](https://blog.cr.yp.to/20260814-update.html): this is a very long story you can find on [cryp.to's blog](blog.cr.yp.to). It started in October 2025 with the first post called [2025.10.04: NSA and IETF: Can an attacker simply purchase standardization of weakened cryptography?](https://blog.cr.yp.to/20251004-weakened.html). The problem described by those publications are the current structure and organization around IEFT, and the high risk of being manipulated by some agency (NSA). This is a long series of article and will probably require a summary someday:

- [2025.10.04: NSA and IETF: Can an attacker simply purchase standardization of weakened cryptography?](https://blog.cr.yp.to/20251004-weakened.html)
- [2025.11.23: NSA and IETF, part 2: Corruption continues.](https://blog.cr.yp.to/20251123-corruption.html)
- [2025.11.23: NSA and IETF, part 3: Dodging the issues at hand.](https://blog.cr.yp.to/20251123-dodging.html)
- [2025.11.23: NSA and IETF, part 4: An example of censored dissent.](https://blog.cr.yp.to/20251123-scope.html)
- [2026.02.19: NSA and IETF, part 5: One battle after another.](https://blog.cr.yp.to/20260219-obaa.html)
- [2026.02.21: NSA and IETF, part 6: The structure of the debate.](https://blog.cr.yp.to/20260221-structure.html)
- [2026.04.05: NSA and IETF, part 7: Counting votes.](https://blog.cr.yp.to/20260405-votes.html)
- [2026.07.06: NSA and IETF, part 8: Fairness.](https://blog.cr.yp.to/20260706-fairness.html)

📑 [**UFOs: A Very Efficient Multivariate Public Key Signature Scheme**](https://eprint.iacr.org/2026/1607): UFOs (Unbalanced Frobenius Oil and Vinegar with Schedule): only read the abstract and the conclusion. Always interesting to read about alternative public-key signature scheme.

📑 [**Verbeth: Secure Messaging with Metadata Minimization over Public Blockchain Logs**](https://eprint.iacr.org/2026/1606): transforming a blockchain (ledger/smart-contract) into private communication channels with end-to-end encryption. Need to dig a bit more about this one.

# Security/Patches

🔄 [**rsync 3.5.0**](https://download.samba.org/pub/rsync/NEWS#3.5.0): 33 security issues patched for rsync, including 16 high level CVEs. Quite an important update to do.

🔄 [**Erlang/OTP 29.0.5**](https://github.com/erlang/otp/releases/tag/OTP-29.0.5): multiple bug fixes (epmd, ssh).

🔄 [**Erlang/OTP 28.5.0.5**](https://github.com/erlang/otp/releases/tag/OTP-28.5.0.5): multiple bug fixes (epmd, ssh).

🔄 [**Erlang/OTP 27.3.4.16**](https://github.com/erlang/otp/releases/tag/OTP-27.3.4.16): multiple bug fixes (epmd, ssh).

🔄 [**OpenBSD 7.9 Errata 008**](https://ftp.openbsd.org/pub/OpenBSD/patches/7.9/common/008_npppd.patch.sig): fixes an heap or stack corruption in [`npppd`](https://man.openbsd.org/npppd).

🔄 [**OpenBSD 7.9 Errata 009**](https://ftp.openbsd.org/pub/OpenBSD/patches/7.9/common/009_iked.patch.sig): fixes [`iked`](https://man.openbsd.org/iked) remote crashes during authentication.

🔄 [**OpenSSH 10.5 released**](https://undeadly.org/cgi?action=article;sid=20260811113606): many bugs and security fixes. Improvement on FIDO support during key generation and authentication.

# Embedded

📝 [**ESP32 Thing Plus (USB-C) Hookup Guide**](https://www.digikey.com/en/maker/projects/esp32-thing-plus-usbc-hookup-guide/c210558437a9446ebfabdd1ceaebab38): Quick guide to start using ESP32 board from SparkFun.

📝 [**f4pga**](https://f4pga.org/): an open-source FPGA toolchain compatible with some Xilinx, Lattice and QuickLock board. Previously called [Symbiflow](https://hackaday.com/2019/11/01/symbiflow-open-source-fpga-toolchain/), it was originally created to become the GCC of FPGA. The source code is available on [Github](https://hackaday.com/2019/11/01/symbiflow-open-source-fpga-toolchain/).

📝 [**z486: A 486-Class Pipelined FPGA CPU with Integrated Floating-Point**](https://nand2mario.github.io/posts/2026/z486/):  In this post, [@nand2mario](https://x.com/nand2mario) is explaining how to create a 486-like CPU called [z486](https://github.com/nand2mario/z486) using FPGA and [SystemVerilog](https://en.wikipedia.org/wiki/SystemVerilog). He also previously worked on [z386](https://github.com/nand2mario/z386) implementation. Those projects are great to study for someone interested to use FPGA and learn more about CPU design/architecture. All the series are absolute bangers and must be read, what I did, but it will require another reading due to the amount of knowledge shared. Here the latest posts from the series:

- [486Tang - 486 on a credit-card-sized FPGA board](https://nand2mario.github.io/posts/2025/486tang_486_on_a_credit_card_size_FPGA_board/)
- [8086 Microcode Browser](https://nand2mario.github.io/posts/2025/8086_microcode_browser/)
- [z8086: Rebuilding the 8086 from Original Microcode](https://nand2mario.github.io/posts/2025/z8086/)
- [80386 Multiplication and Division](https://nand2mario.github.io/posts/2026/80386_multiplication_and_division/)
- [80386 Barrel Shifter](https://nand2mario.github.io/posts/2026/80386_barrel_shifter/)
- [80386 Protection](https://nand2mario.github.io/posts/2026/80386_protection/)
- [80386 Memory Pipeline](https://nand2mario.github.io/posts/2026/80386_memory_pipeline/)
- [z386: An Open-Source 80386 Built Around Original Microcode](https://nand2mario.github.io/posts/2026/z386/)
- [80386 Early Start Memory Access](https://nand2mario.github.io/posts/2026/80386_early_start/)

🏗️ [**schoolMIPS project**](https://github.com/MIPSfpga/schoolMIPS): a MISP CPU core for FPGA board using Verilog. The same project exists for RISC-V called [schoolRISCV](https://github.com/zhelnio/schoolRISCV).

▶️ [**How does a USB keyboard work?**](https://www.youtube.com/watch?v=wdgULBpRoXk): [Ben Eater channel](https://www.youtube.com/@BenEater) is a great place to learn things about electronics. That's a great introduction to the [USB 2.0 protocol](https://www.usb.org/document-library/usb-20-specification) and its complexity, by using something simple: "a keyboard". Anyway, I wanted to work with USB recently (for a small electronic project) and it seems to be a good place to start. In summary, the computer is asking for data by sending a SYNC IN packet, the keyboard answer with the data, and the computer acknowledge with an ACK packet. Each packet is made  of type containing a Packet ID (PID), the data, and a checksum (CRC-16). If nothing changed on the keyboard side when the computer asks for more data, the keyboard can return a NAK packet. An USB transaction is made of (1) a SYNC packet (2) a data packet encoded on 8192bits (3) an ACK packet. A computer poll every 16ms (low-speed) and 1ms (full-speed) to see if some data are available. It seems only 6 keys can be pressed at the same time on an USB keyboard (interesting). RFWirelessWorld is offering a [CRC-16/USB calculator](https://www.rfwireless-world.com/calculators/crc16-calculator-and-formula).

▶️ [**How does USB device discovery work?**](https://www.youtube.com/watch?v=N0O5Uwc3C0o): another video from [Ben Eater channel](https://www.youtube.com/@BenEater) talking about the USB discovery protocol, starting with the question "why only 6 keys strokes can be used at the same time?". When the keyboard is plugged, the computer is starting a SETUP transaction by sending a SETUP packet. I think a longer publication will be required here to explain all of that. Note: the oscilloscope (a [Keysight DSOX4024A](https://www.keysight.com/us/en/support/DSOX4024A/oscilloscope-200-mhz-4-analog-channels.html)) used here is insanely cool, like its price (~$8000).

# Misc

📝 [**The PC OS That Would Have Blown Your Mind Back In 1984**](https://hackaday.com/2026/08/11/the-pc-os-that-would-have-blown-your-mind-back-in-1984/): discover [os8088](https://www.os8088.com/) operating system in this article from HackaDay.

🌐 [**CVE Numbering Authority for the BEAM ecosystem**](https://cna.erlef.org/): Good to know Erlang ecosystem got a way to announce security issues.

📑 [**The second law of infodynamics and its implications for the simulated universe hypothesis**](https://pubs.aip.org/aip/adv/article/13/10/105308/2915332/The-second-law-of-infodynamics-and-its): an hypothesis made in 2022/2023 about a second law of infodynamics, saying the universe is being compressed or "_the second law of infodynamics states that the information entropy of systems containing information states must remain constant or decrease over time, reaching a certain minimum value at equilibrium_". Only for general knowledge, I don't think I will use this kind of theory in my work.

----

[![I'm in ur clocks, measuring your data center temperature.](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/sx4xempy45n7bimofrwt.png)](https://x.com/danielvf/status/2087934391133594025)

[![You don't need a degree to get a job.](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/n68wyiax6vi0idd1c8b7.png)](https://x.com/NEETOCRACY/status/2088055514395771090?s=20)

![You don't have a skeleton inside you...](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/tozh61y70gidjtt5ryty.png)

----

Cover Image by <a href="https://unsplash.com/@niki_emmert?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Nikolett Emmert</a> on <a href="https://unsplash.com/photos/a-field-of-hay-with-bales-of-hay-in-the-foreground-LFY3Lo-V07A?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
