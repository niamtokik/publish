---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/weeklyreview202635-1aa4"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Fuz4fm9flc5tppu05h3de.jpg"
created_at: "None"
crossposted_at: "None"
description: "Finally, someone said it loudly on a podcast, the open-source communities are full of f* goblin with..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/weeklyreview202635-1aa4"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "weeklyreview202635-1aa4"
social_image: "None"
title: "WeeklyReview#202635"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# WeeklyReview#202635

Finally, someone said it loudly on a podcast, the [open-source communities are full of f* goblin with a shitty mindset](https://x.com/thestanduppod/status/2091511392717213707?s=20) destroying the hobbyist fun and blocking the real innovation from hackers/engineers by forcing other people to be agree with their political point of view. It's refreshing to watch a short video on this topic, because it was one of the most important reason I did not participate anymore on Open-source projects, especially BSD systems. This guy is doing a great summary: we don't care of your sex, gender, political beliefs or your age. We are hobbyist, hackers, engineers. We are fixing problems by giving solutions. We are NOT involved in politic, and if it's the case, this is not the place to talk about it. In France, during family meeting, we are trying to avoid few topics: religion, politic and most of the controversial news. Why? By To avoid conflict(s) during a time where everyone can be there. It's rare. It's precious. It's called respect. Be respectable, and everything will be fine.

About my posts on this "public note pad". The first articles were focused on learning Dart and Flutter, they were kinda short, and based on documentation, tutorials, tests and examples. The next publications are way more complex, and will involve more knowledge and tests on my side. In fact, one of my project (and future product) was already delayed of one month due to the many - unexpected - things I did during July and August. Anyway, not a promise, just a quick note to explain my current situation.

About dev.to, a quick feedback. I'm now using it for all my technical publication and to be honest, it's not the best place to put your information. In 3 or 4 months, the service was down many time. When editing a long article, sometimes the modifications are not saved on the server side (happened to me many time, and it's... ANNOYING). How a service like that can host so many authors? Where is the reliability? I wanted to avoid doing my own servers, but I think that's what we got for a free service.

# Coding

📝 [**Bringing Primary Constructors to Dart**](https://dart.dev/blog/bringing-primary-constructors-to-dart): after the 3.13 version, it will be now possible to use the `new` keyboard to define named/unnamed constructor as well as factory. Example:

```dart
class A {
  new();
  new create();
}

class B {
  factory () { }
  factory create() { }
}
```

📝 [**Introducing the Desktop Windowing API for Flutter**](https://flutter.dev/blog/desktop-windowing-apis):  Learn about the design behind the new Desktop Windowing API and write your first multi-window Flutter application. 

# System

📝 [**net-tools to iproute cheat sheet**](https://anarc.at/blog/2026-02-18-iproute2/): a nice way to remember the commands between `ip` and the legacy net-tools packages (including `ifconfig`) on Linux. The same should be done between Linux, BSDs and MacOS.

🏗️ [**MemProcFS**](https://github.com/ufrisk/MemProcFS): MemProcFS is an easy and convenient way of viewing physical memory as files in a virtual file system.

🏗️ [**Beyla project**](https://github.com/grafana/beyla): eBPF-based autoinstrumentation of web applications and network metrics. An interesting tool to collect metrics on web server using eBPF (so, linux-only), the [documentation](https://grafana.com/oss/beyla-ebpf/) looks good as well. I was looking for something similar few years ago, to collect [network metrics](https://grafana.com/docs/beyla/latest/network/quickstart/).

🏗️ [**The Goodmans Kernel project**](https://github.com/zer0condition/GoodmansKernel): Run unsigned kernel payloads in a signed kernel driver via wasm3. No JIT/W^x (HVCI/etc., compliant)

🏗️ [**kubectl x project**](https://github.com/platformersdev/kubectl-x): A kubectl plugin that runs commands against every context in your kubeconfig file in parallel.

🏗️ [**ipatool project**](https://github.com/majd/ipatool): Command-line tool that allows searching and downloading app packages (known as ipa files) from the iOS App Store

📝 [**Reverse Engineering: How we bypassed CoreML and talked directly to the hardware**](https://maderix.github.io/articles/inside-the-m4-ane-part-1/): a series of article about Apple M1 CPU ANE graph execution engine, and how to bypass CoreML interface.

📝 [**How to Build Smaller Container Images: Docker Multi-Stage Builds**](https://labs.iximiuz.com/tutorials/docker-multi-stage-builds): A tutorial to build small sized containers with docker multi stage, using node.js as example.

# Network

🌐 [**Who Am I**](https://whoami.moe/): another "what's my ip" service, displaying more information than usual. I like it.

# Security

📝 [**Decrypting and analyzing HTTPS traffic without MITM**](https://blog.silentsignal.eu/2020/05/04/decrypting-and-analyzing-https-traffic-without-mitm/): a way to decrypt HTTPS traffic using PCAP and BURP SUITE.

📝 [**How Easy Is It to Scan a Contactless Payment and Access Card?**](https://www.mobile-hacker.com/2026/08/20/how-easy-is-it-to-scan-a-contactless-payment-and-access-card/): a post about NFC scanning and cloning.

📝 [**Smart Glasses Can Record You – And Detecting Them Isn’t So Simple**](https://www.mobile-hacker.com/2026/06/14/smart-glasses-can-record-you-and-detecting-them-isnt-so-simple/): those glasses can potentially be detected using bluetooth but it depends on the manufacturers (and the spec). When the glasses are connected, they are not broadcasting data anymore.

📝 [**Reversing TP-Link EX220 from A1**](https://xakcop.com/post/ex220/): a quick article about reversing a firewall/router.

🏗️ [**PE-bear project**](https://github.com/hasherezade/pe-bear): a multiplatform reversing tool for PE files. Its objective is to deliver fast and flexible “first view” for malware analysts, stable and capable to handle malformed PE files. see also the [author's blog](https://hshrzd.wordpress.com/pe-bear/).

📝 [**The Linux Kernel Is Approaching 2,000 CVEs Per Release**](https://www.phoronix.com/news/Linux-Kernel-CVEs-Nearly-2000): I don't really think the Linux kernel will be able to stay in the game with its current structure. The only good answer would have been to use a micro-kernel (Linux is a Minix-clone), it's simpler, easier to maintain and in fine, more isolated. What's scary here is the amount of unpatched old-Linux still running everywhere. I don't know what will happen in the future, but the old mantra "Linux is safer than Windows" is going to break.

📝 [**Vulnerability Research on Bitdefender's Antivirus Engine**](https://stackbits.eu/blog/bdcore_part1.html): the first part of a series of article about antivirus analysis and fuzzing. The last sections of this publication are talking about fuzzing BitDefender with [honggfuzz](https://github.com/google/honggfuzz). I'm waiting for the next part!

# Security/Cryptography

📝 [**Time as a Key: Breaking Rhysida Ransomware with the Attacker’s Own Ciphertext**](https://sigreturn.com/papers/time-as-a-key/): the story behind the Rhysida Ransomware. A [X/twitter thread](https://x.com/ech0re/status/2091293244483133873) and a [simplified version of the story](https://sigreturn.com/blog/rhysida-analysis-decryption/) by the author can be read. In short, the IV (initialization vector) and the keys are generated using the `rand` function (derived from `srand` function). Those functions are both linked to the `time` function, and when executed many times or in parallel, this function return the same value. If one knows the seed (the parameter passed to the `srand` function), then one is able to decipher encrypted files. The analysis from the paper, the blog post and the x/twitter thread is amazing. A must read.

🏗️ [**Crypto 101: the book**](https://github.com/crypto101/book): The source code of the Crypto101 book. Nothing to add, just a good reference.

📝 [**Blood MERIDIAN: LLM cryptanalysis of a blockcipher that is isn't a blockcipher**](https://www.bfswa.blog/p/blood-meridian-131): an interesting LLM session using GPT-5.6 Sol to break a "blockcipher" ([MERIDIAN](https://eprint.iacr.org/2026/856)). No test vectors have been shared on the specification, and the LLM found an issue.

📝 [**Compromising Signal's Contact Discovery Enclave**](https://v12.sh/blog/signal): V12 found two critical object-lifetime vulnerabilities that allow the untrusted host server to break the enclave boundary.

📝 [**Privacy Pools: Anatomy of a 53-bit Entropy Collapse**](https://zknox.eth.limo/posts/2026/03/26/privacy-pools-postmortem.html): a type coercion bug reducing the entropy of master keys from 256 bits to 53 bits. interesting post-mortem and analysis.

📝 [**Into the Dark - DarkSword Kernel Exploit Writeup**](https://therealclarity.github.io/blog/clearsword/): a post about iOS DarkSword vulnerability ([CVE-2025-43520](https://nvd.nist.gov/vuln/detail/cve-2025-43520)). It uses an exploitable race condition in the virtual file system to allocate kernel memory. Really interesting, but a bit complex to follow on my side, I don't really know how iOS is working under the hood.

📑 [**Regev’s Attack on Hyperelliptic Cryptosystems**](https://www.mdpi.com/2410-387X/10/5/62): [Hyperelliptic curves](https://en.wikipedia.org/wiki/Hyperelliptic_curve) (yet another thing I don't know) are an alternative to ECC. I simply read the introduction, to know what a "hyperelliptic curve" was. It looks complex, like the elliptic curves.

# Security/BlueTeam

🏗️ [**Sliver project**](https://github.com/BishopFox/sliver): "an open source cross-platform adversary emulation/red team framework, it can be used by organizations of all sizes to perform security testing. Sliver's implants support C2 over Mutual TLS (mTLS), WireGuard, HTTP(S), and DNS and are dynamically compiled with per-binary asymmetric encryption keys."

# Security/RedTeam

📑 [**Tips and Scripts for Reconnaissance and Scanning**](https://sansorg.egnyte.com/dl/j8w7bJpG97kC): an old publication listing methods to scan hosts.

🌐 [**RatCTF**](https://ratctf.com/): yet another capture the flag challenges website.

▶️ [**Hacking hardware security key into an air-gap-jumping worm: the hidden features of a YubiKey**](https://it4sec.substack.com/p/hacking-hardware-security-key-into): using yubikeys as attack vector by using logical usage modification to propagate worms (or take control of devices). The full talk can be seen on [Youtube](https://www.youtube.com/watch?v=rXy1WvPkXIM).

📝 [**Web App Hacking: Six Tools for Bug Hunters**](https://hackers-arise.com/web-app-hacking-six-tools-for-bug-hunters/): a list of tools to find bugs on web application, [gospider](https://github.com/jaeles-project/gospider) (webcrawling/spider), [SecretFinder](https://github.com/m4ll0k/SecretFinder) (discover sensitive information), [jsluice](https://github.com/BishopFox/jsluice) (javascript source code secret extractor), [xnLinkFinder](https://github.com/xnl-h4ck3r/xnLinkFinder) (discovering tool), [Dalfox](https://github.com/hahwul/dalfox) (XSS scanner), [Caido](https://github.com/caido/caido) (web audit tool).

🏗️ [**DFIR-LAB project**](https://github.com/Azr43lKn1ght/DFIR-LABS): a compilation of challenges that aims to provide practice in simple to advanced concepts in the following topics: Digital Forensics, Incident Response, Malware Analysis and Threat Hunting.

🏗️ [**InfraGuard project**](https://github.com/Whispergate/InfraGuard): Red team infrastructure tracker and C2 redirector -- a modern alternative to [RedWarden](https://github.com/mgeeky/RedWarden). InfraGuard sits between the internet and your C2 teamserver, validating every inbound request against your malleable C2 profile and blocking anything that doesn't conform. Scanners, bots, and blue team probes get redirected to a decoy site while legitimate beacon traffic passes through to your teamserver.

🌐 [**KitPloit**](https://kitploit.com/en): Hacking, PenTest, and Cybersecurity Tools for Your Security Arsenal!

📝 [**Open Source Intelligence (OSINT): Using Osiris for Global Intelligence**](https://hackers-arise.com/open-source-intelligence-osint-using-osiris-for-global-intelligence/): an article on the open-source [Osiris](https://github.com/simplifaisoul/osiris.git), a tool, used to collect global information (e.g. cctv, aircraft, critical infrastructure, dangerous zone...). Kinda interesting and can run locally.

# Update/Upgrade

🔄 [**Unifi Security Advisory Bulletin 067**](https://community.ui.com/releases/Security-Advisory-Bulletin-067/fc4a3488-7c43-4628-8bab-f715e96dbfc9): 22 critical security issues to patch, with CVSS score >8. Kudos for the one with a score of 10.

🔄 [**Announcing Dart 3.13, Bringing conciseness and simplicity to Dart codebases, tooling, and platforms.**](https://dart.dev/blog/announcing-dart-3-13): Primary constructors, improvement of the dart formatter and much more.

🔄 [**Elixir v1.19.6 security release**](https://github.com/elixir-lang/elixir/releases/tag/v1.19.6): this release patch the [CVE-2026-75758](https://github.com/elixir-lang/elixir/security/advisories/GHSA-jf5q-v438-665c), allowing an attacker to crash a node by memory exhaustion with the help of an unsanatized char list used in `IO.inspect/1` function. This function is used by the [`Logger`](https://github.com/elixir-lang/elixir/blob/0c8f1feb3af7c6f9e7958463dede1d6cab4be61b/lib/logger/lib/logger.ex) module (see [`translator.ex`](https://github.com/elixir-lang/elixir/blob/0c8f1feb3af7c6f9e7958463dede1d6cab4be61b/lib/logger/lib/logger/translator.ex)) to print Elixir/Erlang data-structure. It would be fun to try exploiting it in some way.

🔄 [**QSB-118: Dom0 arbitrary code execution in qvm-copy-to-vm error reporting**](https://www.qubes-os.org/news/2026/08/29/qsb-118/): in short, a wrongly sanitized string from a compromised qube (domU) can be used to execute arbitrary code in dom0. The sanitizer is not removing the backtick character from the filename, leading to arbitrary code execution via the `system()` function. A dirty bug impacting all QubeOS version.

# Embedded

📝 [**Baochip-1x: A Mostly-Open, 22nm SoC for High Assurance Applications**](https://www.bunniestudios.com/blog/2026/baochip-1x-a-mostly-open-22nm-soc-for-high-assurance-applications/): a security chip made by Bunnie, project created via the [betrusted initiative](https://betrusted.io/).

📝 [**Redesigning my microkernel from the ground up**](https://drewdevault.com/blog/Hermes-from-the-ground-up/): an experimental microkernel inspired by Sel4, called [ares](https://git.sr.ht/~sircmpwn/hermes), which is a full rewrite of [helios](https://sr.ht/~sircmpwn/helios/). This article also talks a bit about [bunnix](https://git.sr.ht/~sircmpwn/bunnix), an Unix-like OS implemented by the same author.

▶️ [**Extracting Firmware from Embedded Devices (SPI NOR Flash)**](https://www.youtube.com/watch?v=nruUuDalNR0): a really great video about extracting firmware, using [NOR Flash](https://en.wikipedia.org/wiki/Flash_memory#Distinction_between_NOR_and_NAND_flash) via [SPI protocol bus](https://en.wikipedia.org/wiki/Serial_Peripheral_Interface) with the help of a logical analyzer ([saleae](https://www.saleae.com/logic)) and [hydrabus](https://hydrabus.com/?v=82a9e4d26595). In short, this is a man in the middle attack by reading the data directly from the microcontroller to the memory.

📟 [**$299 Arduino Ventuno Q SBC combines Qualcomm Dragonwing IQ8 SoC and STM32H5 MCU**](https://www.cnx-software.com/2026/08/25/299-arduino-ventuno-q-sbc-combines-qualcomm-dragonwing-iq8-soc-and-stm32h5-mcu/): Quick introduction to the [Arduino Ventuno Q](https://www.arduino.cc/product-ventuno-q), [Octa-core Kryo Gen 6](https://en.wikipedia.org/wiki/Kryo#Kryo_600_Series), Adreno A623, 16GB LPDDR5, 64GB eMMC flash, M.2 socket for NVMe Gen4 SSD, 2.5GbE RJ45 port.

📟 [**AT LoRa USB Dongle**](https://www.tindie.com/products/nn_6394/at-lora-usb-dongle/): USB device that lets you send and receive LoRa wireless data using simple AT commands. No coding needed. Good for testing and development.

🌐 [**Free RF Tools for Engineers, Radio Amateurs & Students**](https://rfconsult.uk/): A long list of tools to help with calculations, design and so on for RF engineers and radio amateurs.

📝 [**Building A Headless Game Boy Emulator**](https://hackaday.com/2026/08/28/building-a-headless-game-boy-emulator/): great project with an ESP32! the ESP32 here is used as server, offering an access to the emulator on Wifi. Other people can also play as well. 

# Misc

📝 [**The end of IPFS at Shipyard**](https://ipshipyard.com/blog/2026-the-end-of-ipfs-at-shipyard/): P2P distributed storage is hard to maintain, I know this by experience with one of my last mission. The infrastructure cost is huge, even more if no one knows how to deploy really low-cost distributed systems around the world. IPFS is impacted as well by those issues, and when one partner is leaving, it will be hard to continue. I hope IPFS will not shutdown because of that, it's a great technology and it would be really sad to see it disappears.

📟 [**noah5b motherboard**](https://www.broachlink.com/product/noah5b-139.html): I wanted to upgrade my firewall (an old [PC ENGINE APU2](https://pcengines.ch/apu2.htm)) and just learnt [PC Engine will not produce them anymore](https://pcengines.ch/eol.htm). Instead, [Broachlink](broachlink.com) will offer similar [motherboards](https://www.broachlink.com/product/c18.html) called [Noah](https://www.broachlink.com/product/noah5b-139.html). This is looking great, and are not so expensive [^varia-noah5-tpm] 
[^varia-noah5-firewall] [^alibaba-noah6] [^retiaglobal-noah5] (between €300 and €400). [Linux drivers](https://github.com/rackmatrix/noah-driver) are available on Github.

[^varia-noah5-tpm]: [Noah 5 TPM 2.0 Firewall Router Motherboard Intel E3845, 8GB RAM](https://en.varia-store.com/product/broachlink-bl-noah5-tpm-8-423111-mainboard-motherboard/) (€326.80)

[^varia-noah5-firewall]: [Noah 5 Firewall Router Motherboard Intel E3845, 8GB RAM, Fanless](https://en.varia-store.com/product/broachlink-bl-noah5-e3845-v10-8gb-423109-mainboard-motherboard/) (€313.50)

[^alibaba-noah6]: [Broachlink NOAH6 Intel E3845 3RJ45 1SFP Pfsense Firewall Mainboard Embedded Server Motherboard VPN Router Motherboard with SFP](https://www.alibaba.com/product-detail/Broachlink-NOAH6-Intel-E3845-3RJ45-1SFP_1601301805816.html) (€103)

[^retiaglobal-noah5]: [Noah 5 Firewall Router Motherboard Intel E3845, 4 cores 1.91 GHz](https://shop.retiaglobal.com/products/noah-5-firewall-router-motherboard-intel-e3845-4-cores-1-91-ghz) (€180)

📝 [**Crypto ATM operator Bitcoin Depot files for bankruptcy**](https://www.icij.org/investigations/coin-laundry/crypto-atm-operator-bitcoin-depot-files-for-bankruptcy/): the world largest cryptocurrency ATM is filed with bankruptcy due to fraud allegations (hundred millions of dollars annually). $389 millions dollars lost due to scams, involving Bitcoin Depot machines. In 2025, $1.5 million scams transactions had passed through hundred of ATMs.

🏗️ [**GTA 6 Leaks & Cyberleek Investigation Report**](https://github.com/FermataRest/cyberleek-leak-research): a repository containing the complete investigation of the GTA 6 leaks.

📟 [**Openterface KeyMod, Pocket USB multi-tool bridge for tech, professionals and gaming**](https://www.crowdsupply.com/techxartisan/openterface-keymod): interesting concept to transform a smartphone into many different input device.

📝 [**Two Alleged ‘TeamPCP’ Hackers Arrested in Australia**](https://krebsonsecurity.com/2026/08/two-alleged-teampcp-hackers-arrested-in-australia/): arrested due to multiple information leaks from SpyCloud, RaidForums, Nulled, and a gmail address used on many other website. Being anonymous on the web is nearly impossible, even for the scammers and criminals. A [Risky Business podcast](https://risky.biz/RBFEATURES37/) is talking about this story.

🌐 [**privatekeys.info**](https://privatekeys.info/): a "game" to crack bitcoin and ethereum private key. Pick a number between `1` and `pow(2, 256)` and voilà, you are now rich and famous!

🏗️ [**trustmebro project**](https://github.com/DavidCarliez/trustmebro): Bypass llm guardrails by confusing it with fabricated tool output.

----

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/e3n4bz1zpw6tdirwxbju.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/wjiznvdwma4e8khh9f9w.png)

![I don't know how to write handcrafted code anymore](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/ty2pdi61q9a9jxtrvrgy.png)

![Pathetic](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/nkqvk40ukpvsj3bxiv7l.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/l7r0974ncji874wftgpv.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/n0guvlu1xmmk55qouj13.png)

![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/mbrxlxrkdv8ad9mpach1.png)

![I lied, I don't have netflix](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/iyxyrx0f88j0yr89spgd.png)

![Cybersecurity zombie nephew](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/p6nbj41vbl0rrpgzl9tq.png)

----

Legend:

| symbol | usage | example |
|--------|-------|---------|
| ▶️     | video | youtube |
| 🏗️     | project | git repository |
| 📝     | informal publication | blog post |
| 🎥     | live | twitch |
| 🏛️     | definition | wikipedia |
| 🌐     | regular website | -
| 📑     | academic or scientific publication | arxiv |
| 🔄     | software new release, update or ugprade | - |
| 📟     |  device | embedded hardware |
| 🐦     | twitter | message from twitter |
| 📖     | book | book or very long article |
| 💡     | idea | an idea to implement |
| 💭     | thought | for thoughts and opinions | 

----

Cover Image by <a href="https://unsplash.com/@didpics?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Didier VEILLON</a> on <a href="https://unsplash.com/photos/a-field-of-corn-with-the-sun-shining-through-the-leaves-QunE8iVvjmY?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>