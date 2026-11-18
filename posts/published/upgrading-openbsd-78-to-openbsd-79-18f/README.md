---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/upgrading-openbsd-78-to-openbsd-79-18f"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Flykfyhdalqp1i8eku1pg.jpg"
created_at: "None"
crossposted_at: "None"
description: "The lastest version of OpenBSD has been released this week and announced on the Mailinglist (but also..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/upgrading-openbsd-78-to-openbsd-79-18f"
public_reactions_count: "1"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "upgrading-openbsd-78-to-openbsd-79-18f"
social_image: "None"
title: "Upgrading OpenBSD 7.8 to OpenBSD 7.9"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Upgrading OpenBSD 7.8 to OpenBSD 7.9

The [lastest version of OpenBSD](https://www.openbsd.org/79.html) has been released this week and announced on the [Mailinglist](https://marc.info/?l=openbsd-announce&m=177919671915512&w=2) (but also on [X/Twitter](https://x.com/canadianbryan/status/2056740268171309263) by Brian Steele). As usual, lot of improvement, this publication is just a quick summary.

- Read the [release note](https://www.openbsd.org/79.html) and the upgrade procedure.

- Ensure you have enough place on your partitions.

```sh
df -h
```

- Be prepared to upgrade your database like PostgreSQL. Do a Backup.

- Start with one device to see if everything is fine.

- Upgrade with [`sysupgrade`](https://man.openbsd.org/sysupgrade).

```sh
sysupgrade
```

- After the reboot, upgrade the packages with [`pkg_add`](https://man.openbsd.org/pkg_add)

```sh
pkg_add -uUra
```

- Do a second reboot if necessary

- [Upgrade PostgreSQL](https://www.postgresql.org/docs/current/pgupgrade.html) and other services which have been upgraded.

- Do a third reboot to check if all services are started correctly during boot (reboot proof servers)

And... It should be okay! No big deal for this upgrade on my side, everything worked without issues.
 
----

Cover Image by <a href="https://unsplash.com/@famouswebsites?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">A Perry</a> on <a href="https://unsplash.com/photos/a-bunch-of-strange-looking-objects-hanging-from-a-ceiling-vaU1IW6AHV8?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>