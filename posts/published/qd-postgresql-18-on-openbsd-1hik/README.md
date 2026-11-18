---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/qd-postgresql-18-on-openbsd-1hik"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Fmlksj98q0oznv2sm9otr.jpg"
created_at: "None"
crossposted_at: "None"
description: "If you need the latest version of PostgreSQL on OpenBSD, the limits for the semaphores must be..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/qd-postgresql-18-on-openbsd-1hik"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "qd-postgresql-18-on-openbsd-1hik"
social_image: "None"
title: "Q&D: PostgreSQL 18 on OpenBSD"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Q&D: PostgreSQL 18 on OpenBSD

If you need the latest version of PostgreSQL on OpenBSD, the [limits for the semaphores must be increased](https://www.mail-archive.com/ports%40openbsd.org/msg137080.html). Indeed, let imagine you want to deploy a fresh postgresql database (assuming the `/var/postgresql/data` directory was not created or purged).

```console
$ doas pkg_add postgresql-server
...

$ cd /var/postgresql

$ doas -u _postgresql initdb -D data
The files belonging to this database system will be owned by user "_postgresql".                                                                              
This user must also own the server process.          

The database cluster will be initialized with locale "C".                     
The default database encoding has accordingly been set to "SQL_ASCII".         
The default text search configuration will be set to "english".               
                                                                              
Data page checksums are enabled.
                                                                              
fixing permissions on existing directory data ... ok
creating subdirectories ... ok                                                
selecting dynamic shared memory implementation ... posix
selecting default "max_connections" ... 20                           
selecting default "shared_buffers" ... 400kB                                  
selecting default time zone ... UTC
creating configuration files ... ok
running bootstrap script ... 2026-09-14 17:44:41.502 UTC [93045] FATAL:  could not create semaphores: No space left on device                                 
2026-09-14 17:44:41.502 UTC [93045] DETAIL:  Failed system call was semget(3810418, 17, 03600).                                                               
2026-09-14 17:44:41.502 UTC [93045] HINT:  This error does *not* mean that you have run out of disk space.  It occurs when either the system limit for the maximum number of semaphore sets (SEMMNI), or the system wide maximum number of semaphores (SEMMNS), would be exceeded.  You need to raise the respective kernel 
parameter.  Alternatively, reduce PostgreSQL's consumption of semaphores by reducing its "max_connections" parameter.                                         
        The PostgreSQL documentation contains more information about configuring your system for PostgreSQL.                                                  
child process exited with exit code 1                                          
initdb: removing contents of data directory "data"
```

An error! To fix it, `kern.seminfo.semmni` and ` kern.seminfo.semmns` need to be modified.

```console
$ doas sysctl kern.seminfo.semmni=256
kern.seminfo.semmni: 10 -> 256

$ doas sysctl kern.seminfo.semmns=2048
kern.seminfo.semmns: 60 -> 2048
```

Now, the database can be initialized without issue.

```sh
$ doas -u _postgresql initdb -D data                    
The files belonging to this database system will be owned by user "_postgresql".                                                                             
This user must also own the server process.                                   

The database cluster will be initialized with locale "C".                     
The default database encoding has accordingly been set to "SQL_ASCII".        
The default text search configuration will be set to "english".               

Data page checksums are enabled.       

fixing permissions on existing directory data ... ok                          
creating subdirectories ... ok         
selecting dynamic shared memory implementation ... posix                      
selecting default "max_connections" ... 100                                   
selecting default "shared_buffers" ... 128MB                                  
selecting default time zone ... UTC    
creating configuration files ... ok    
running bootstrap script ... ok        
performing post-bootstrap initialization ... ok                               
syncing data to disk ... ok            

initdb: warning: enabling "trust" authentication for local connections        
initdb: hint: You can change this by editing pg_hba.conf or using the option -A, or --auth-local and --auth-host, the next time you run initdb.              

Success. You can now start the database server using:                         

    pg_ctl -D data -l logfile start

$ doas rcctl start postgresql
postgresql(ok)
```

It looks way better! The new configuration can now be added into `/etc/sysctl.conf`

```console
$ echo "kern.seminfo.semmni=256" | doas tee -a /etc/sysctl.conf

$ echo "sysctl kern.seminfo.semmns=2048" | doas tee -a /etc/sysctl.conf
```

The server should reboot with the good configuration now. You can configure your postgresql server now.

```console
$ doas -u _postgresql psql postgres
psql (18.6)
Type "help" for help.

postgres=#
```

Happy hacking and have fun!

---

Cover Image by <a href="https://unsplash.com/@d_seddon?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Dan Seddon</a> on <a href="https://unsplash.com/photos/leopard-puffer-fish-TbgoCf4F3MM?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>