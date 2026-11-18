#/usr/bin/env python3
######################################################################
#
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!                        WARNING                               !!!
# !!!            THIS IS A DRAFT, USE WITH CARE                    !!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# import publications from experted posts from dev.to.
#
# published posts will be created in the published directory, where
# the markdown will contain an header with the metadata. The cover
# image will be stored in the assets directory.
#
# Usage: devto.py [OPTS] devto-articles.json
#
#  --drafts-directory=""
#  --published-directory=""
#
######################################################################
import json
import argparse
import os
import sys
from pathlib import Path
import http.client
from urllib.parse import urlsplit

class Article:

    def __headers(self):
        return "\n".join([
            f'''cached_tag_list: "{self.cached_tag_list}"''',
            f'''cached_user_name: "{self.cached_user_name}"''',
            f'''cached_user_username: "{self.cached_user_username}"''',
            f'''canonical_url: "{self.canonical_url}"''',
            f'''comments_count: "{self.comments_count}"''',
            f'''cover_image: "{self.cover_image}"''',
            f'''created_at: "{self.created_at}"''',
            f'''crossposted_at: "{self.crossposted_at}"''',
            f'''description: "{self.description}"''',
            f'''edited_at: "{self.edited_at}"''',
            f'''feed_source_url: "{self.feed_source_url}"''',
            f'''last_comment_at: "{self.last_comment_at}"''',
            f'''main_image: "{self.main_image}"''',
            f'''main_image_background_hex_color: "{self.main_image_background_hex_color}"''',
            f'''path: "{self.path}"''',
            f'''public_reactions_count: "{self.public_reactions_count}"''',
            f'''published_at: "{self.published_at}"''',
            f'''published: "{self.published}"''',
            f'''published_from_feed: "{self.published_from_feed}"''',
            f'''show_comments: "{self.show_comments}"''',
            f'''slug: "{self.slug}"''',
            f'''social_image: "{self.social_image}"''',
            f'''title: "{self.title}"''',
            f'''video: "{self.video}"''',
            f'''video_closed_caption_track_url: "{self.video_closed_caption_track_url}"''',
            f'''video_code: "{self.video_code}"''',
            f'''video_source_url: "{self.video_source_url}"''',
            f'''video_thumbnail_url: "{self.video_thumbnail_url}"'''
        ])

    def __init__(self, json, opts = {}):
        self.__drafts_dir = opts.get("drafts_directory", "./_devto/drafts")
        self.__published_dir = opts.get("published_directory", "./_devto/published")
        self.__extension = opts.get("extension", ".md")
        self.body_markdown = json.get("body_markdown", None)
        self.cached_tag_list = json.get("cached_tag_list", None)
        self.cached_user_name = json.get("cached_user_name", None)
        self.cached_user_username = json.get("cached_user_username", None)
        self.canonical_url = json.get("canonical_url", None)
        self.comments_count = json.get("comments_count", None)
        self.cover_image = json.get("cover_image", None)
        self.created_at = json.get("created_at", None)
        self.crossposted_at = json.get("crossposted_at", None)
        self.description = json.get("description", None)
        self.edited_at = json.get("edited_at", None)
        self.feed_source_url = json.get("feed_source_url", None)
        self.last_comment_at = json.get("last_comment_at", None)
        self.main_image = json.get("main_image", None)
        self.main_image_background_hex_color = json.get("main_image_background_hex_color", None)
        self.path = json.get("path", None)
        self.processed_html = json.get("processed_html", None)
        self.public_reactions_count = json.get("public_reactions_count", None)
        self.published_at = json.get("publised_at", None)
        self.published = json.get("published", False)
        self.published_from_feed = json.get("published_from_feed", None)
        self.show_comments = json.get("show_comments", None)
        self.slug = json.get("slug", None)
        self.social_image = json.get("social_image", None)
        self.title = json.get("title", None)
        self.video = json.get("video", None)
        self.video_closed_caption_track_url = json.get("video_closed_caption_track_url", None)
        self.video_code = json.get("video_code", None)
        self.video_source_url = json.get("video_source_url", None)
        self.video_thumbnail_url = json.get("video_thumbnail_url", None)

        if (not Path(self.__drafts_dir).exists()):
            os.makedirs(self.__drafts_dir, exist_ok=True)

        if (not Path(self.__published_dir).exists()):
            os.makedirs(self.__published_dir, exist_ok=True)

        self.filename = "README" + self.__extension

    def is_published(self):
        return self.published

    def __dest_dir(self):
        dest_dir = ""
        if (self.is_published()):
            dest_dir = "/".join([
                self.__published_dir,
                self.slug
            ])
            dest_dir
        else:
            dest_dir = "/".join([
                self.__drafts_dir,
                self.slug
            ])

        if (not Path(dest_dir).exists()):
            os.makedirs(dest_dir, exist_ok=True)

        return dest_dir

    def __dest_file(self):
        dest_file = "/".join([
            self.__dest_dir(),
            self.filename
        ])
        return dest_file

    def headers(self):
        return "\n".join([
            f"---",
            self.__headers(),
            f'---'
        ])

    def export(self):
        # print(self.__headers())
        self.__export_file()
        self.__export_image()

    def __export_file(self):
        print(self.__dest_file())
        dest = self.__dest_file()
        print(f"write {dest}")
        with open(dest, 'w') as f:
            f.write(self.headers())
            f.write("\n\n")
            f.write(f"# {self.title}")
            f.write("\n\n")
            f.write(self.body_markdown)

    def __export_image(self):
        if (self.cover_image):
            dest_dir = "/".join([
                self.__dest_dir(),
                "assets"
            ])
            dest_image = "/".join([
                dest_dir,
                "cover_image.jpg"
            ])
            print(dest_image)
            os.makedirs(dest_dir, exist_ok=True)
            with open(dest_image, 'wb') as f:
                image_data = self.__get(self.cover_image)
                f.write(image_data)

    def __get(self, url):
        split = urlsplit(url)
        conn = http.client.HTTPSConnection(split.netloc)
        conn.request("GET", split.path)
        resp = conn.getresponse()
        if (resp.status == 200):
            data = resp.read()
            conn.close()
            return data
        else:
            conn.close()
            return None

def usage():
    print("Usage: devto.py")

def main():
    filepath = "./_build/articles.json"
    if Path(filepath).exists():
        dump(filepath)
    else:
        print(f"{filepath} does not exist")
        return 1

def dump(filepath):
    with open("./_build/articles.json", 'r') as fh:
        data = fh.read()
        parse(data)

def parse(data):
        j = json.loads(data)
        buf = []
        for item in j:
            buf.append(Article(item))

        for item in buf:
            item.export()

if __name__ == "__main__":
    main()
