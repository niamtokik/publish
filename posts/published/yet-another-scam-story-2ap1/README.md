---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/yet-another-scam-story-2ap1"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Fl55z9yeh2skfu7eh2qnf.jpg"
created_at: "None"
crossposted_at: "None"
description: "On 4th August 2026, I received a message on Linkedin from someone called Nils Baadness[1] looking for..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/yet-another-scam-story-2ap1"
public_reactions_count: "3"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "yet-another-scam-story-2ap1"
social_image: "None"
title: "Yet Another Scam Story"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Yet Another Scam Story

On 4th August 2026, I received a message on Linkedin from someone called Nils Baadness[1] looking for a senior Erlang developer for a gaming and DeFi project. Here the message:

> Hope you're doing well!
> 
> While you seem to be happy in your current role, I wanted to reach out and see if you'd consider a new opportunity or even a part-time engagement on an exciting project.
> 
> We're building a decentralized Gaming and DeFi platform that leverages blockchain technology to create innovative, secure, and scalable gaming and financial experiences. The role is fully remote, with competitive compensation, equity options, and strong ownership over technical decisions.
> 
> Would you be open to learning more?
> 
> Looking forward to hearing from you.
> 
> Best regards,
> Nils

I already received this kind of messages in the past. It seems to be a real offer, and share simply my standard resume. After few exchanges, a first meeting/interview has been scheduled for the 17th August 2026 at 2pm using Calendly[2].

The day of the call, someone with a strong Indian accent started to talk to me, a bit weird for someone called Jacob Andrew Scott, but anyway, everything is possible. He presents the project (seems legit), and ask me to present me as well with my experiences. After a long monologue on Erlang, he wanted to check my "programming level" by cloning a repository from Github[3] containing few exercises.

That's a bit weird. Even during a quick job interview, it's very rare to have the interviewer asking you to clone a repository and do some kind of tests. Well, it's not the first though, I clone the repository, and discover few python files and a `.vscode` directory. If you don't know me, I'm an old-school developer, write code with `emacs` or `vim`, rarely with a "modern" IDE like vscode.

After having cloned the repository, sir Jacob asked me to share my screen and use or install vscode. The level of frustration from him increased a bit I guess when I explicitly said "I will never use vscode during a code interview, when a `.vscode` directory exists in a repository. Just for fun, I shared my terminal, and started to read the content of this directory. What I found was kinda funny, a PowerShell like script trying to download something. Well, I said a second time, if he wanted me to install vscode and use that, I would simply stop the interview.

The rest of the test was then in my own terminal with vim. The "test" was a success (to be honest, the questions were just stupid) and before the end of the call, he told me I would have an answer in 2 or 3 business days.

Now, what is wrong here? At first glance, nothing, but... when one starts to search for information, things are getting odd. Nils Baadnes is "working" since 2023 at [Eigen Labs](https://www.eigenlabs.org) but did not have any connections to someone working there on Linkedin. Even more, he only has 159 connections and 456 followers. Jacob Andrew Scott is also totally absent from his connections, in fact, no one is named like that on Linkedin.

![Nils Baadnes Linkedin Profile](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/8tbx9s6pyxhx6k2vjpsy.png)

![Nils Baadnes Linkedin Profile (experience)](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/wtpulpb0s3n3fql5jxlo.png)

No jobs offer can be found on the EigenLabs's AshbyHQ website [4]. This is perhaps not a problem though, if the company is looking for a consultant, it's not really a job. 

![Eigen Labs Ashbyhq page](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/fn08ce961taggq7fqyex.png)

Sadly, I removed the cloned repository at the end of the interview (old reflex to remove unnecessary stuff). I came back to it few minutes after the interview to check if I could simply investigate a bit more the content of the `.vscode` directory but surprise! The repository has been removed from github. 

It seems after few days - I was waiting for some extra-message from them - nothing happened...

[1] https://www.linkedin.com/in/nils-baadnes-5a26a2b9/
[2] https://calendly.com/jacob-andrew-scott/30min?month=2026-08
[3] https://github.com/morriswebster-candidate/python
[4] https://jobs.ashbyhq.com/eigen-labs

# Conclusion

Scammers are really becoming annoying. Receiving scams by e-mails or on social networks was not enough, they are now targeting the recruitment process on Linkedin. In fact, it's an interesting problem that can be easily fixed directly on Linkedin. Most of the companies are already registered at Linkedin, then, when an user is saying he is working for one of them, it should be acknowledged in some ways. This is not the case yet.

Anyway, be careful and don't trust anyone. I don't think the exploit/backdoor they were using would work on my laptop (running on OpenBSD), but someone using Windows or Ubuntu would have been impacted. In doubt, here a few list of things to find out if your interviewer is a scammer:

1. Check the Linkekin profile of the interviewer, if he does not have any kind of relationship with people inside the company, this is odd. Usually, a recruiter - even someone outside of the company - knows few people.

2. If a call is planned, and the camera of the interviewer is turned off, it's another big issue. Most of the interviewer like to see the visage of the interviewee and turn on their webcam by respect.

3. If the people in front of you is having a strong Indian accent, it's could be a scam. Most of the call I received from scammers where from India.

4. If someone is asking you to clone a git repository, share your screen and/or install a software, this is obviously a scam. The git repository should contain some kind of payload, executed by a program (e.g. vscode in my case). Don't execute or install anything from them, and NEVER EVER open an untrusted project with a modern IDE, use `vi`, `nano`, `mg` or `ed` (to make him crazy) instead.

5. Don't do like me, don't remove the cloned repository, but start to investigate it. Those kind of behaviors must be shared.

Finally, if you have time, and if you are working in a confidential or risky field, having a laptop running on [QubesOS](https://www.qubes-os.org/) ready for this kind of tasks can be great. During the call, the cloned repository could then be cloned inside a temporary Qubes, and you can let the scammers taking control of this small isolated VM, while you are collecting data on them.

----

Cover Image by <a href="https://unsplash.com/@markuswinkler?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Markus Winkler</a> on <a href="https://unsplash.com/photos/scam-spelled-with-scrabbles-on-a-wooden-table-FjyseC7iV3k?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>