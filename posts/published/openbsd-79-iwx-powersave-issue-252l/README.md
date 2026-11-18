---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/openbsd-79-iwx-powersave-issue-252l"
comments_count: "4"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fm2z3u32orwgihpl5ulnl.jpg"
created_at: "None"
crossposted_at: "None"
description: "A quick update regarding the last release of OpenBSD 7.9, I upgraded one of my old laptop (Lenovo..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/openbsd-79-iwx-powersave-issue-252l"
public_reactions_count: "1"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "openbsd-79-iwx-powersave-issue-252l"
social_image: "None"
title: "OpenBSD 7.9 feedback: iwx powersave issue"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# OpenBSD 7.9 feedback: iwx powersave issue

A quick update regarding the last release of [OpenBSD 7.9](https://www.openbsd.org/79.html), I upgraded one of my old laptop (Lenovo Thinkpad AMD T14 gen1) and got a problem with the [iwx](https://man.openbsd.org/iwx.4) driver (the one in charge of the wifi). During the startup I got those messages (visible in `dmesg` as well):

```console
$ dmesg | grep iwx0
...
iwx0 at pci3 dev 0 function 0 "Intel Wi-Fi 6 AX200" rev 0x1a, msix
iwx0: hw rev 0x340, fw 77.30b1cbd8.0, address e0:d4:aa:bb:cc:dd
iwx0 at pci3 dev 0 function 0 "Intel Wi-Fi 6 AX200" rev 0x1a, msix
iwx0: could not read firmware iwx-cc-a0-77 (error 2)
iwx0: failed to load init firmware
iwx0: hw rev 0x340, fw 77.30b1cbd8.0, address e0:d4:aa:bb:cc:dd
iwx0 at pci3 dev 0 function 0 "Intel Wi-Fi 6 AX200" rev 0x1a, msix
iwx0: hw rev 0x340, fw 77.30b1cbd8.0, address e0:d4:aa:bb:cc:dd
iwx0: fatal firmware error
iwx0: fatal firmware error
iwx0: fatal firmware error
```

Well, my first action was to check if the firmware can be upgraded using [`fw_update`](https://man.openbsd.org/fw_update).

```console
$ doas fw_update
```

Nope. No new firmware. Let check if the bug is already known by the team and a [`syspatch`](https://man.openbsd.org/syspatch) has been released?

```console
$ doas syspatch
```

Nothing at all, as expected (the [errata page](https://www.openbsd.org/errata79.html) was empty).

Okay, let just quickly check the [release note](https://www.openbsd.org/79.html) again:

> - Enabled 64-bit DMA transfers on aq(4), em(4), rge(4), re(4), iavf(4), ix(4), ixv(4), ixl(4), igc(4), ice(4) and iwx(4).
> - Added support for a 160 MHz window at 5 GHz and enabled it on iwx(4).
> - Enabled iwx(4) on i386.
> - Fixed iwx(4) issues related to roaming and PMF and firmware crypto keys.
> - Set the assoc ID field in iwx(4) firmware commands correctly.
> - Added support for BZ devices with WiFi 6e radio to iwx(4).
> - Made iwx(4) not load incomplete firmware images and report a proper error instead.
> - **Added powersave support to iwx(4) and enable by default**.
> - Added support for 160 MHz channel width to iwx(4).
> - Increased the VHT frame aggregation size limit from 64k to 1024k on iwx(4).
> - Aligned iwx(4) antenna patterns and STBC with iwlwifi.

Ah! The culprit could be the power saving enabled by default! I hope so... Because if it's not the case, I will need to upgrade to `stable` and I would like to avoid that on this laptop. Luckily, disabling the power saving is not complex, the [`-powersave`](https://man.openbsd.org/ifconfig#powersave~2) flag needs to be added on this device, let put that in [`/etc/hostname.iwx0`](https://man.openbsd.org/man5/hostname.if.5).

```console
$ echo "-powersave" | doas tee /etc/hostname.iwx0
```

Now, we can restart the interface.

```console
$ doas /etc/netstart iwx0
```

And... It works! No more error messages. The problem was the power saving. In short, if you are using a Intel Wi-Fi 6 AX200 device, on a Lenovo T14 AMD Gen1, the power saving does not work with the latest OpenBSD 7.9 version.

Unfortunately, the next day it was not working anymore. The firmware was still unhappy for some unknown reason. Let switch to debug mode, just to have an idea of the problem. Part of the `dmesg` has been removed to avoid leaking my personal network information.

```console
$ doas ifconfig iwx0 debug
$ dmesg
iwx0: RUN -> INIT
iwx0: begin active scan
iwx0: INIT -> SCAN
iwx0: end active scan
...
iwx0: missed beacon threshold set to 25 beacons, beacon interval is 120 TU
iwx0: dumping device error log
iwx0: Start Error Log Dump:
iwx0: Status: 0x879, count: 6
iwx0: 0x00000071 | NMI_INTERRUPT_UMAC_FATAL    
iwx0: 008022F3 | trm_hw_status0
iwx0: 00000000 | trm_hw_status1
iwx0: 004F8F22 | branchlink2
iwx0: 00007FC0 | interruptlink1
iwx0: 00007FC0 | interruptlink2
iwx0: 00015050 | data1
iwx0: 00001000 | data2
iwx0: 00000000 | data3
iwx0: 00087FCC | beacon time
iwx0: 00378032 | tsf low
iwx0: 00000000 | tsf hi
iwx0: 00000000 | time gp1
iwx0: 0037DB02 | time gp2
iwx0: 00000001 | uCode revision type
iwx0: 0000004D | uCode version major
iwx0: 30B1CBD8 | uCode version minor
iwx0: 00000340 | hw version
iwx0: 18089000 | board version
iwx0: 0102001C | hcmd
iwx0: 00021000 | isr0
iwx0: 61040000 | isr1
iwx0: 18F00002 | isr2
iwx0: 00C3400D | isr3
iwx0: 00000000 | isr4
iwx0: 0101001C | last cmd Id
iwx0: 00015050 | wait_event
iwx0: 00000288 | l2p_control
iwx0: 00000000 | l2p_duration
iwx0: 000000BF | l2p_mhvalid
iwx0: 000000EF | l2p_addr_match
iwx0: 00000009 | lmpm_pmg_sel
iwx0: 00000000 | timestamp
iwx0: 00003050 | flow_handler
iwx0: Start UMAC Error Log Dump:
iwx0: Status: 0x879, count: 7
iwx0: 0x20101A0D | ADVANCED_SYSASSERT
iwx0: 0x00000000 | umac branchlink1
iwx0: 0x80455D7A | umac branchlink2
iwx0: 0x0106E0A4 | umac interruptlink1
iwx0: 0x00000000 | umac interruptlink2
iwx0: 0x00000005 | umac data1
iwx0: 0x00000001 | umac data2
iwx0: 0x00000001 | umac data3
iwx0: 0x0000004D | umac major
iwx0: 0x30B1CBD8 | umac minor
iwx0: 0x0037DAFC | frame pointer
iwx0: 0xC0886BC4 | stack pointer
iwx0: 0x001C050F | last host cmd
iwx0: 0x00000000 | isr status reg
driver status:
  tx ring  0: qid=0  cur=29  cur_hw=29  queued=1  
  tx ring  1: qid=1  cur=3   cur_hw=3   queued=1  
  tx ring  2: qid=2  cur=0   cur_hw=0   queued=0  
  tx ring  3: qid=3  cur=0   cur_hw=0   queued=0  
  tx ring  4: qid=4  cur=0   cur_hw=0   queued=0  
  tx ring  5: qid=5  cur=0   cur_hw=0   queued=0  
  tx ring  6: qid=6  cur=0   cur_hw=0   queued=0  
  tx ring  7: qid=7  cur=0   cur_hw=0   queued=0  
  tx ring  8: qid=8  cur=0   cur_hw=0   queued=0  
  tx ring  9: qid=9  cur=0   cur_hw=0   queued=0  
  rx ring: cur=51
  802.11 state RUN
iwx0: fatal firmware error
```

Hmm, while investigating, I also see the interface was crashing when it was using the `11a` mode. Let force the driver to use `11n` for example.

```console
$ echo "mode 11n" | doas tee /etc/hostname.iwx0
$ doas sh /etc/netstart iwx0
```

The network is up again! Okay, I really think there is a bug somewhere in the `iwx` driver or with the firmware. I never had a similar issue with that in the past, so, I assume something has been upgraded there during OpenBSD 7.9 migration. Anyway, if the issue persist, I will try to find another solution and investigate a bit more.

----

Cover Image by <a href="https://unsplash.com/@brice_cooper18?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Brice Cooper</a> on <a href="https://unsplash.com/photos/a-rusted-out-bus-sitting-in-the-middle-of-a-forest-57mzM8SGNn8?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>