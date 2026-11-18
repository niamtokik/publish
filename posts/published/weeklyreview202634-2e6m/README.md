---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/weeklyreview202634-2e6m"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Fiban8tzm38urmxahwqvq.jpg"
created_at: "None"
crossposted_at: "None"
description: "The last week was mostly dedicated for my own personal organization, and trying to rework on my..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/weeklyreview202634-2e6m"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "weeklyreview202634-2e6m"
social_image: "None"
title: "WeeklyReview#202634"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# WeeklyReview#202634

The last week was mostly dedicated for my own personal organization, and trying to rework on my projects. This week though, some of them advanced a little bit. After few days of thinking, the internal design of `chored` seems to be a bit better than the initial draft. Even if it's still unusable, it's a good project to think about more important topic, like memory management (including garbage collector), algorithms to store efficiently the data and re-read UNIX/POSIX C documentations. We will talk more on the second publication about `chored`.

To stay focus, my home office was a bit updated. Writing code on a modern laptop with graphical interface is having a negative result on productivity (thanks to all social networks and notifications). A new small dedicated computer, with Alpine Linux (without windows manager) has been successfully deployed and is ready to be used. In fact, `chored` will be designed here and also on an OpenBSD server.

Remember the `kanell` project, the pipeline-like module in Dart created few weeks ago. I'm currently working on it, or at least, a part of it. The pipeline is working, but it's not really what I want. I would like to have a way to create composable/traceable finite state machines, powered by something like a pipeline structures, a kind of [flow-based programming](https://en.wikipedia.org/wiki/Flow-based_programming).

# Coding

▶️ [**Simple Instructions, Weird Algorithms**](https://www.youtube.com/watch?v=ryfbBB3pHfI): a great and short introduction to SIMD (Simple Instruction, Multiple Data) by [Core Dumped](https://www.youtube.com/watch?v=ryfbBB3pHfI) on Youtube, one of the first step to understand GPUs.

📝 [**Introducing BlocSignal: Unidirectional Data Flow Meets Reactive Signals**](https://dev.to/gde/introducing-blocsignal-unidirectional-data-flow-meets-reactive-signals-48b2): Randal Schartz published a series of posts talking about Bloc and Signal (or BlocSignal) with Dart/Flutter: [BlocSignal Architecture & Practice Series' Articles](https://dev.to/randalschwartz/series/42973). A must read (and follow).

📑 [**Contract Based Verification of Non-functional Requirements for Embedded Automotive C Code**](https://arxiv.org/abs/2605.21532): Non-functional requirements (e.g. restrictions on control flow and data flow) can't be specified using classical tools like [ASML/Frama-C](https://www.frama-c.com/html/acsl.html) and are usually done by manual code review. [VerNFR Frama-C module](https://github.com/rse-verification/vernfr) was created to solve this problem.

📑 [**FlowLog: Re-thinking Datalog for Fast and Extensible Static Analysis**](https://arxiv.org/abs/2607.23971): [FlowLog](https://github.com/flowlog-rs/FlowLog) (implemented in Rust), is a Datalog compiler used for static analysis. A [tutorial](https://www.flowlog-rs.com/tutorial/intro/) is available.

▶️ [**Stanford University CS107 - Programming Paradigms**](https://www.youtube.com/watch?v=Ps8jOj7diA0&list=PLWkTsO24LpD-YhslKDYnwHAP7OvTXBb-i): the full [programming paradigms courses](https://web.stanford.edu/class/cs107/) from Stanford. Never watched this one, but the content seems quite interesting, even more if you are doing low-level programming or if you need to review the basis.

📑 [**Simple Garbage-Collector-Safety**](https://dl.acm.org/doi/pdf/10.1145/249069.231394): a quite old paper about garbage-collector safety.

📑 [**Precise Garbage Collection for C**](https://dl.acm.org/doi/pdf/10.1145/1542431.1542438): a publication describing the [Magpie](https://github.com/kazzmir/magpie) garbage collector written in OCaml, designed for long living process.

📑 [**A Parallel, Real-Time Garbage Collector**](https://dl.acm.org/doi/pdf/10.1145/378795.378823)

📑 [**A Study of Concurrent Real-Time Garbage Collectors**](https://dl.acm.org/doi/pdf/10.1145/1379022.1375587)

📑 [**The Specification Paradox: Rethinking Requirements Engineering in the Age of AI**](https://arxiv.org/abs/2608.16618)

📑 [**Etna: An evaluation platform for property-based testing**](https://arxiv.org/abs/2603.27002)

📑 [**To WASM or Not to WASM: Evaluation of Browser Fingerprinting Defenses Under WASM based Obfuscation**](https://arxiv.org/abs/2508.21219)

📑 [**Phoenix: A Modular and Versatile Framework for C/C++ Pointer Analysis**](https://arxiv.org/abs/2602.01720)

📝 [**High-Throughput, Formal-Methods-Assisted Fuzzing for LLVM**](https://blog.regehr.org/archives/2148): an interesting way to apply fuzzing by using mutated tests on LLVM. If it works on that, it should work on other application as well, right?

# System

📝 [**EFS & FreeVxFS File-Systems Get Booted While FailFS Merged For Linux 7.3**](https://www.phoronix.com/news/Linux-File-System-Changes-7.3): [failfs](https://docs.kernel.org/next/filesystems/failfs.html) will permit to use the fchroot syscall and then allow unprileged users to use chroot (based on the [git commit message](https://lore.kernel.org/lkml/20260814-vfs-7.3-rc1.failfs-903759d156dd@brauner/)).

📑 [**KernelScript: Cross-Boundary Typed DSL for eBPF Applications**](https://arxiv.org/abs/2607.23900)

📑 [**Concurrency Testing in the Linux Kernel via eBPF**](https://arxiv.org/abs/2504.21394)

📑 [**Xkernel: Principled Performance Tunability of Operating System Kernels**](https://arxiv.org/pdf/2512.12530)

📝 [**Using the OpenBSD ports tree with dedicated users**](https://dataswamp.org/~solene/2020-01-11-privsep.html): a very old post about OpenBSD, ports management and privilege isolation by [Solene](https://dataswamp.org/~solene/). I was working on some OpenBSD ports recently, and forgot how to apply correctly the isolation. I did not find it on the official documentation though.

📑 [**CombiSan: Unifying Software Sanitizers for Comprehensive Fuzzing**](https://www.usenix.org/system/files/usenixsecurity26-marini.pdf): 

📝 [**NetBSD microvm**](https://wiki.netbsd.org/users/imil/microvm/): things are moving on NetBSD, and I discovered this week the NetBSD MicroVM kernel. The final result? less than 10ms to boot it on qemu. As usual, it can also be customized based on your needs. Always amazed to see those improvements in the BSD world.

# Network

📑 [**Presto: A Match-Action TCP Stack for the Terabit Era**](https://arxiv.org/pdf/2504.19058): Presto is a re-implementation of a TCP-stack using [Reconfigurable Match-Action Table (RMT)](https://people.cs.rutgers.edu/~sn624/552-F19/lectures/16-rmt.pdf) pipelines. This implementation is mostly on the hardware side and is focused on low-latency/high-bandwidth network (e.g. DC or perhaps core-network).

> Even with state-of-the-art kernel bypass TCP stacks, applications spend up to 48% of perpacket CPU cycles in the stack [...]  ASIC transports, such as TCP offload engines (TOEs) and remote direct memory access (RDMA), are highly efficient, but inflexible and operationally brittle in the cloud [...] We present Presto, the first TCP stack tailored to the RMT architecture. Presto reimagines TCP as a pipeline of light-weight match-action operations, enabling line-rate processing without buffering and delivering practical TCP at terabit speeds while preserving high throughput, low latency, energy efficiency, flexibility, and interoperability.

📑 [**SoK: Insecurity of Cellular Basebands**](https://www.usenix.org/system/files/woot26-carnot.pdf): cellular baseband attack surface summary. This publication is about the security of the chips/CPU/devices used in mobile network (2G, 3G and so on). AT command can be used to communicate to the baseband (good to know). The surface is huge, but I think the investment to start attacking all of that, at least the most modern equipments limit most exploitation. Furthermore, the complexity of each protocols, especially from 2G and 3G, is also a wall. A layer of opacity due to the closed source software and firmware is also another problem.

📑 [**SoK: Security of Cyber-physical Systems Under Intentional Electromagnetic Interference Attacks**](https://www.usenix.org/system/files/usenixsecurity26-jiang-qinhong.pdf): see also [IEMI Research Database](https://iemi-research-database.github.io/), gathering other publications from this kind of attacks.

# Database

📝 [**SQLite's Durability Settings are a Mess**](https://www.agwa.name/blog/post/sqlite_durability): a short publication on setting SQLite more durable using `journal_mode` and `synchronous` parameters.

📝 [**Rethinking Database Programming**](https://acadia.engineering/blog/rethinking-database-programming): writing database queries and defined schema using Elm. It's a matter of time before they discover Prolog et Datalog...

📝 [**Loongson loong64 packages on apt.postgresql.org**](https://www.postgresql.org/about/news/loongson-loong64-packages-on-aptpostgresqlorg-3351/): while loongson architecture is being removed from OpenBSD, PostgreSQL is now offering packages for this platform.

# Embedded

📝 [**Amaranth HDL (previously nMigen)**](https://github.com/amaranth-lang/amaranth): "_The Amaranth project provides an open-source toolchain for developing hardware based on synchronous digital logic using the Python programming language, as well as evaluation board definitions, a System on Chip toolkit, and more."_ Here the [documentation](https://amaranth-lang.org/docs/amaranth/latest/cover.html) link.

📑 [**Xilinx JTAG Programmer Guide**](http://ebook.pldworld.com/_Semiconductors/Xilinx/Foundation/ISE/3.3i/Documentation/jtag.pdf): an old (<2000) Xilinx manual to program Xilinx FPGA.

📝 [**Extracting firmware from devices using JTAG**](https://sergioprado.blog/2020-02-20-extracting-firmware-from-devices-using-jtag/): a quick but complete post on using JTAG interface to debug and dump a firmware.

📝 [**Nibbler 4 Bit CPU**](https://www.bigmessowires.com/nibbler/): an homebrew 4 bit CPU called Nibbler, created for educational purpose. It could be nice to create an emulator for this CPU, it could be an easy way to understand CPU architecture from scratch.

📝 [**Deep Dive Into PCB Manufacturing Techniques: Milling**](https://www.digikey.com/en/maker/blogs/2024/deep-dive-into-pcb-manufacturing-techniques-milling): a quick introduction to milling with digikey. Always great to read this kind of publication.

📝 [**Learning to Decapsulate Integrated Circuits Using Acid Deposition**](https://jcjc-dev.com/2020/10/20/learning-to-decap-ics/): a nice post showing lot of experiment to decapsulate integrated circuits.

🌐 [**Zero ASIC releases Platypus 12nm eFPGA product**](https://www.zeroasic.com/blog/platypus-z1015-launch): [zeroasic](https://www.zeroasic.com) (previously known as [Adapteva](https://www.adapteva.com), the conceptors of [the Parallella board](https://parallella.org/board/)) released a the Platypus eFPGA product. I discovered the [Logic FPGA tool chain](https://github.com/siliconcompiler/logik) via the news from their website.

# Security

📝 [**Everything is about to “go dark”**](https://blog.cryptographyengineering.com/2026/08/14/everything-is-about-to-go-dark/): Matthew Green fears about too much security due to AI usage, and the risk of agencies losing control over that. Law enforcers and agencies will then ask to add more backdoors. Is it really necessary? Most of the devices and hardware we are currently using are not open-source, they are being crafted in an opaque way, they are embedding unverified/uncontrolled firmware and then, can't be trusted. Furthermore, no one is able to recreate them in their own garage due to the cost of the infrastructure to make them, but also because of the copyright/laws protecting the manufacturers. In such environment, the backdoors are already there, and governments are just asking to use them, not to implement them. More than 10 years ago, Snowden revealed that [hdd firmware were already backdoored](https://en.wikipedia.org/wiki/Tailored_Access_Operations#Alleged_links_to_Stuxnet_and_the_NSA) (and [not only there](https://github.com/iamcryptoki/snowden-archive)). They did not stop, they continued. What's the solution? More open-source, more makerspaces/hackerspaces, more trusted hardware/devices made from small groups and not big companies. In short: more transparency. They can't stop everybody. But don't worry, there is more. Do you remember when [Ken Thompson was thinking about trusted compilers](https://aeb.win.tue.nl/linux/hh/thompson/trust.html)? Well, an LLM is basically the same, you ask for something, you get it, but can you trust it? In our current situation, LLMs are all managed by big companies, already infiltrated by agencies. Then, can you really trust your application generated by your LLM?

📑 [**TrustMee: Self-Verifying Remote Attestation Evidence**](https://arxiv.org/pdf/2602.13148): define the "self-verifying remote attestation evidence" concept. A proof is generated in WASM and checked by a verifier. Even if the WASM VM was created as an isolated sandbox, it could be used against the protocol. Interesting anyway.

# Security/BlueTeam

📝 [**How to Read Linux Audit Logs During an Intrusion**](https://embeddedbits.org/how-to-read-linux-audit-logs-during-an-intrusion/):   a summary of the actions to take on CentOS/RHEL distribution during an intrusion.

📝 [**Cracking the Crackers**](https://reverse.put.as/2025/03/13/cracking-the-crackers/): reverse-engineering of x86_64 and arm64 cracked softwares. It always amazes me to see the level of complexity in this domain.

📑 [**The State of Passkeys: Studying the Adoption and Security of Passkeys on the Web**](https://www.usenix.org/system/files/usenixsecurity26-jannett.pdf): a long study about adopting physical passkeys. The authors are offering interesting service publicly at [passkeys.tools](https://passkeys.tools/). A must read for someone who wants to implement this kind of authentication on his website or application.

# Security/RedTeam

📝 [**The Axios npm supply chain incident: fake dependency, real backdoor**](https://blog.nviso.eu/2026/04/03/the-axios-npm-supply-chain-incident-fake-dependency-real-backdoor/): a short review of the Axios NPM supply chain attack.

📝 [**Build simple fuzzer, part 6**](https://carstein.github.io/fuzzing/2023/10/01/build-simple-fuzzer-part-6.html): A long series to write a fuzzer (in C, rust and python).

- [**Build simple fuzzer, part 1**](https://carstein.github.io/fuzzing/2020/04/18/writing-simple-fuzzer-1.html)
- [**Build simple fuzzer, part 2**](https://carstein.github.io/fuzzing/2020/04/25/writing-simple-fuzzer-2.html)
- [**Build simple fuzzer, part 3**](https://carstein.github.io/fuzzing/2020/05/02/writing-simple-fuzzer-3.html)
- [**Build simple fuzzer, part 4**](https://carstein.github.io/fuzzing/2020/05/21/writing-simple-fuzzer-4.html)
- [**Build simple fuzzer, part 5**](https://carstein.github.io/fuzzing/2021/03/13/build-your-own-fuzzer-5.html)

📑 [**BADControl: Backdoor Attacks Against Control Systems**](https://www.usenix.org/system/files/usenixsecurity26-burbano.pdf): the first backdoor against controller with physical triggers. A car/robot is used as example in this publication to see what can be done with such attacks.

📝 [**Knock Knock! Who's There? - An NSA VM**](https://reverse.put.as/2021/12/17/knock-knock-whos-there/): an interesting way to hide a service, listening on demand based on interface activity with the help of libpcap. It's a bit like the port knocking technique for a firewall, but on the user land side, perhaps more accurate as well, because all packets can be inspected (including their content).

# Security/Cryptography

📝 [**WhatsApp forensics in 2026 and what survives end-to-end encryption**](https://andreafortuna.org/2026/07/14/whatsapp-forensics-2026/): in short, WhatsApp is still secure, but never forgot end-to-end encryption was created to protect the data one the wire to avoid anyone outside of the two part of the line to read its content, but don't protect the end-points. Data can still be found locally on the device, cracked and then extracted. WhatsApp is using [crypt15 puzzle](https://chathoarding.app/blog/crypt15-explained) (previously [crypt12 and crypt14](https://chathoarding.app/blog/crypt12-vs-crypt14-vs-crypt15)) when storing data locally.

📑 [**Exploiting a Video Camera's Rolling Shutter to Recover Secret Keys from Devices Using Video Footage of Their Power LED**](https://www.nassiben.com/video-based-crypta): defines a new cryptanalysis method called "video-based cryptanalysis", used to perform side channel attack to recover an ECDSA key. It has been used against iPhone 13 and Samsung Galaxy S8 while plugged to an USB hub. Another crazy side-channel attack!

📝 [**Testing the Security of Modbus Services**](https://blog.mindedsecurity.com/2024/03/testing-security-of-modbus-services.html): a quick introduction to testing [Modbus](https://modbus.org/specs.php) using the [M-SAK tool](https://github.com/mindedsecurity/msak). I worked a bit with this protocol in the past, but never had time to read all the specs and understand it clearly (thanks to all the abstraction layers used).

📑 [**End-to-End Encrypted Collaborative Documents**](https://www.usenix.org/system/files/usenixsecurity26-knabenhans.pdf): a protocol to use Signal encryption scheme for collaborative documents, called SignalCD.

📑 [**LLMs won't break symmetric crypto**](https://www.bfswa.blog/p/llms-wont-break-symmetric-crypto): in short, using LLM to find vulnerability in cryptography is a good thing but LLMs will not break popular cryptographic schemes. why? (1) high level structure is secure (2) not related to mathematical structures like asymmetric algorithms or hash functions (3) differential cryptanalysis (4) empirical: flaws and issues are found from experiments (5) time/battle tested for many years. A nice quote: "Symmetry cryptography is the strongest part of our security systems".

📑 [**Fully Homomorphic Encryption with Chosen-Ciphertext Security from LWE**](https://eprint.iacr.org/2026/1756.pdf): the level of mathematics is too hard for me, but I think the next buzzword for the next 10 years will probably be homomorphic encryption. Following the news on that will be important. I'm also waiting for the next marketing term to sell it.

📑 [**SafeHub: End-to-end encrypted Git hosting system**](https://eprint.iacr.org/2026/1748.pdf): a way to encrypt transaction in Git. unfortunately, I did not find the repository, not sure if it's open-source, but the full protocol/design is presented in the paper.

# Update/Upgrades

[**Linux Kernel 7.2 Officially Released, This Is What’s New**](https://9to5linux.com/linux-kernel-7-2-officially-released-this-is-whats-new): [Linux Kernel 7.2](https://git.kernel.org/torvalds/h/v7.2) has been released. It improves AMD GPU support, a better GPU scheduler, few CPU improvements... More can be read on [kernelnewbies](https://kernelnewbies.org/Linux_7.2).

[**Rust: Supply chain attack on arrayref**](https://blog.rust-lang.org/2026/08/20/supply-chain-attack-on-arrayref/): a supply chain attack on one important crate. You can be "memory-safe" and avoid lot of bugs, but it seems it's still hard to be safe in the whole ecosystem. The rust team was reactive though, the create was removed after few minutes (100minutes). Kudos to them.

# Mathematics

▶️ [**The Single Most Undervalued Fact of Linear Algebra**](https://www.youtube.com/watch?v=8gNKE5jVqYY): discovering the relation of linear algebra and graph theory through visual explanation. brilliant.

▶️ [**Ancient Babylonians Cracked This Before Modern Math Even Existed**](https://www.youtube.com/watch?v=3O730YTS8Yg): a short video explaining how Babylonians did an approximation of `sqrt(2)` via the [Babylonian algorithm](https://en.wikipedia.org/wiki/Square_root_algorithms#History), and comparing it with the [Newton-Raphson method](https://en.wikipedia.org/wiki/Newton's_method). Another visually brilliant video from [The Palindrome](https://thepalindrome.org/).

# Misc

📑 [**Does Fixing Break Security? An Empirical Study of Security Degradation in Iterative LLM-Driven Infrastructure-as-Code Repair**](https://arxiv.org/abs/2608.13404): From the conclusion: "(1) Regression is real: 13.8% of scenarios regress in standard mode, 3.3% in strict mode [...]  (3) Resource restructuring is the dominant root cause (79.0%), ahead of configuration drift [...] (5) Self-correction is common but unstable: 36.6% of standard-mode regressions self-correct, yet 28.5% of scenarios oscillate. Interesting report, checking a second time the content of the publication (more deeply) is required.

📑 [**Don't Let AI Agents YOLO Your Files: Information and Control in Agent-Native Filesystems**](https://arxiv.org/abs/2604.13536): the first sentence of the abstract is enough: "AI coding agents operate directly on users' filesystems and regularly corrupt data, delete files, and leak secrets. We conduct the first systematic study of agent filesystem misuse, analyzing 290~public reports. Our study reveals two fundamental gaps: users and agents have limited information about filesystem effects and insufficient control over them."

📝 [**Living with impostor syndrome**](https://andreafortuna.org/2026/07/13/impostor-syndrome/): a good post about impostor syndrome. I think we are more or less all impacted by that in the field, perhaps a bit more when one is working in security due to all the things to check every time and not trusting anything. Anyway, my solution? Doing something outside of my field, like reading philosophical books, or doing sport. When it comes to IT, just do small tasks, one by one. Stop asking too much questions, in fine, no one cares.

🌐 [**1-bit computing**](https://en.wikipedia.org/wiki/1-bit_computing): a CPU architecture using only 1 bit, but the opcodes  were 4 or 8 bits.

🌐 [**4-bit computing**](https://en.wikipedia.org/wiki/4-bit_computing): CPU using only 4 bits, used for calculator in the 70s.

📑 [**FreeToken: Efficient Edge-Native MoE Serving with Bandwidth-Adaptive Execution**](https://arxiv.org/pdf/2608.16157): Faster than Ollama locally, released as [open-source project](https://github.com/FlashML-org/FreeToken), seen that on X/Twitter via [@akshay_pachaar](https://x.com/akshay_pachaar/status/2091150763418620133?s=20). 

----

![Apple employee badge](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/azg5f8kkiiaxqiwr9rkk.png)

![Casino vs LLM](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/13v97em3qnu5c1m4iugr.png)

----

Cover Image by <a href="https://unsplash.com/@debrupas?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Pascal Debrunner</a> on <a href="https://unsplash.com/photos/sunflower-field-under-blue-sky-during-daytime-43rqnV_ZfC4?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
