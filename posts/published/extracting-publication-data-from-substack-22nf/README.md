---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/extracting-publication-data-from-substack-22nf"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fzq49vzuo4mkueyvlxm0n.jpg"
created_at: "None"
crossposted_at: "None"
description: "If you have a substack account, like me, you are probably wondering how the articles are stored and..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/extracting-publication-data-from-substack-22nf"
public_reactions_count: "1"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "extracting-publication-data-from-substack-22nf"
social_image: "None"
title: "Extracting Publication Data from Substack"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Extracting Publication Data from Substack

If you have a substack account, like me, you are probably wondering how the articles are stored and how to fetch them manually, right? Well, it will be a short post trying to explain that.

The end-point to get the JSON object describing the post is `/api/v1/drafts/${post_id}` where `post_id` is an integer (a reference to your post).

```sh
curl https://${account_name}.substack.com/api/v1/drafts/${post_id}
```

The headers used for doing this request:

```http
Accept: */*
Accept-Encoding: gzip, delfate, br, zstd
Accept-Language: en-US
Cookie: ${your_cookie}
Priority: u=1, i
sec-ch-ua: 
sec-ch-ua-mobile: ?0
sec-ch-ua-platform: "Linux"
sec-fetch-dest: 
sec-fetch-mode: cors
sec-fetch-site: same-origin
sec-gpc: 1
User-Agent: ${your_user_agent}
```

If successful, a JSON should be returned containing a huge amount of fields. Your post is stored in `draft_body` as stringified JSON.

```json
{
   ...
   "draft_body": "",
   ...
}
```

The body of your post can be extracted now, it's a JSON object using the SubstackPost Document Model, if you want more information about it, you can check the [DeepWiki page](https://deepwiki.com/marcomoauro/substack-mcp/2.4-substackpost-document-model) on that or [`Substack document format`](https://github.com/can3p/substack-api-notes/blob/master/doc_format.md) from [`can3p/substack-api-notes`](https://github.com/can3p/substack-api-notes).

Anyway, I need to extract few values from that recently, I thought maybe it would help someone one day.

----

Cover Image by <a href="https://unsplash.com/@timwildsmith?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Tim Wildsmith</a> on <a href="https://unsplash.com/photos/brown-wooden-book-shelf-with-books-o2fc-C-Uotw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
      