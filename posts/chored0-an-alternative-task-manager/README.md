> The answer is out there, Neo, and it's looking for you, and it will find you if you want it to.
> **The Matrix**, Trinity

Dealing with production - and personal - servers is an exhausting task, even with automation tools and scripts. Many projects came to my hands to manage infrastructure, [Ansible](https://docs.ansible.com/projects/ansible/latest/index.html), [SaltStack](https://saltproject.io/), [Capistrano](https://github.com/capistrano/capistrano), [Fabric](https://www.fabfile.org/), [ReX](https://www.rexify.org/), [Nomad](https://developer.hashicorp.com/nomad) or [Kubernetes](https://kubernetes.io/). Most of them are great but they are not the answer I was looking for. A server should act like a finite state machine, reacting to some kind of events. If you are working on Unix/Linux systems, daemons should not be the only way to do concurrent/parallel computations in background. In fact, a daemon in charge of executing different kind of tasks without scheduling, and being able to reuse the layers of secure configured on the system.

Unfortunately, after 20 years of experiences I did not find this pearl. One of the closed to this idea was Nomad (autonomous application), then SaltStack (remote agent) and finally Ansible (simplicity). This publication is the first one of a long series about a pet project called `chored`, an open-source software to deal with dynamic long living process written in pure C and following all OpenBSD best-practices. It can be seen as a `cron` like application on steroïd, with an optional scheduling part.

# Introduction

How to deal with a remote (long living) task? Well, lot of solutions are currently existing, but those not fit some of my own requirements:

- Configuring a service managed by the `init` process like `systemd` service, `runit`, `systemv` script, `rcctl` on OpenBSD or `sysrc` on FreeBSD. If an user does not have enough privilege to create this configuration, [`supervisord`](https://supervisord.org/) can be used.

- On some system, especially on Linux distributions, one can use [`daemon`](https://manpages.debian.org/trixie/daemon/daemon.1.en.html) command.

- Using an application simulating a tty like [`screen`](https://www.gnu.org/software/screen/), [`tmux`](https://github.com/tmux/tmux), [`tmate`](https://github.com/tmate-io/tmate) or [`dtach`](https://github.com/crigler/dtach)

- Using an application starting automatically a job at a specific time like [`at`](https://man.openbsd.org/at) and [`cron`](https://man.openbsd.org/cron)

- Using an existing agent like the one present in SaltStack called `salt-minion`.

Another kind of software can deal with long living task: init managers, including `runit`, `sys-v init`, `supervisord` or `systemd`. `supervisord` is particularly interesting in this case due its versatility; but this is coded in Python. Even if Python is a great C abstraction, it's still a huge pile of dependencies.

If one wants to run a long living task on a remote server, one needs to have an agent or a way to control the task without his help. The first listed programs have been created to start long living shell session, but they are not offering a low level interface with an API to deal with spawned state.

Then, why not creating a small program to deal with long running task, designed for low memory and embedded systems? Following POSIX and Unix principles should not be so hard, and one can easily creates something portable enough to be executed anywhere. Even more, why not creating an interface to `ansible` or other automation tool to deal with long living processes?

# Constraints and Requirements

This project is written for OpenBSD and other BSD systems, but will be ported to Linux after. One of the goal is to offer a really stable and secure solution before doing an official release. Why OpenBSD? Because the OpenBSD source code is pure high quality code.

# Design

When coding in C, Unix philosophy is clear: do one thing and do it well. One can also add the KISS principle (Keep it Stupid, Simple). `chored` should be small and simple, not an easy task. `chored` can be started as a service with an isolated users, or directly by any user of the system.

# Usage

How to use `chored`? I like to start thinking of the interface to control a program first, just to have an idea how to design it and which features will be critical.

- **starting `chored`**. `chored` is the main daemon, it can be started in two different ways; (1) as root with privilege separation, a bit like `sshd` (2) as standard user with the same privileges.

```sh
# start chored as privilege daemon
# it will use /etc/chored.conf and
# try to find the user _chored and the
# group _chored for the privilege
# separation, but it also means it will
# be able to run any kind of program
# from any user/group present on the
# system
doas chored

# start chored as unprivileged user. This
# time it will look in ~/.chored.conf
# to load the configuration. It can eventually
# invoke command from another user only
# via doas or sudo.
chored

# start in debug/foreground mode;
# chored will not run in the backgroud
chored -d
```

- **configuring `chored`**. The configuration must be easy to understand, easy to modify and easy to parse. Using something similar to the OpenBSD `httpd` daemon or `opensmtpd` could do the job.

```sh
# create the privilege chored configuration
cat > /etc/chored.conf << EOF
# set parameter_name my_value
set user _chored;
set group _chored;
set chroot /;

# job job_name {}
job job_name {
  command /usr/game/pom;
  user _chored;
  group _chored;
  chroot /;
  ulimit "";
  umask "";
  pledge stdio;
  unveil /usr/lib:r;
}

EOF
```

- **creating a new job**. A job creation should be easy to do.

```console
# create a new job called job_name
# this job is not started, it is simply
# stored in memory, waiting to be invoked
# the command returns the name of the job
# and its state
$ chore create job_name -- command
job_name ready
$ echo $?
0
```

- **executing a job**. A job can be executed just after the creation or started when an external events happen.

```console
# executing an existing job
# it will return a random UUID
$ chore execute job_name
job_name ${pid} 4fd67c41-fd21-40db-8778-b03d9842f93d
```

- **monitoring a job execution**. When a long living job is running, it can be nice to have few information on it, like its memory or cpu usage, the last logs and so on.

```console
$ cat /var/chored/jobs/job_name.conf
...

$ tail /var/chored/jobs/job_name/4fd67c41-fd21-40db-8778-b03d9842f93d/stdout
...

$ tail /var/chored/jobs/job_name/4fd67c41-fd21-40db-8778-b03d9842f93d/stderr
...

$ echo 1 | tee /var/chored/jobs/job_name/4fd67c41-fd21-40db-8778-b03d9842f93d/stdin
...

$ cat /var/chored/jobs/job_name/4fd67c41-fd21-40db-8778-b03d9842f93d/ret
...
```

- **checking a job**. In most situation, we don't really care about monitoring, a sysadmin just wants to know the state of the process, if it's still running, if it's stopped or crashed.

```console
$ chore status 4fd67c41-fd21-40db-8778-b03d9842f93d
```

- **stopping a job**. A long living job can also be stopped manually, via a signal or from any other methods defined by `chored`.

```console
$ chore stop 4fd67c41-fd21-40db-8778-b03d9842f93d

```

- **killing a job**. If the job is stuck for some reason (e.g. hardware issue, bad designed software), a sysadmin must be able to kill it.

```console
$ chore kill 4fd67c41-fd21-40db-8778-b03d9842f93d
```

- **remove a job**. Finally, a job definition can also be removed from `chored` memory to avoid starting it by mistake.

```console
$ chore remove job_name
```

# Ideas

- job template: when a dynamic job is created it can automatically load a job template configuration containing extra parameters.

```conf
template job_template {
  chroot /home/my_user;
  user my_user;
  group my_group;
  # other custom parameters ...
}
```

- post action: when the job is done, another script/program with the job name, the job UUID and the return code as argument

# Conclusion

This is a pet project, I would like to use it to fix one time for all some part of my missing knowledge in Unix/Posix system design and C programming. The project is called [`chore`](https://github.com/niamtokik/chore) on Github. This is not something ready, yet, but you have now an idea of the goal. No dead-line though, I will take my time! 

Have fun!

----

Cover Image by <a href="https://unsplash.com/@indigowilderness?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Chloe Skinner</a> on <a href="https://unsplash.com/photos/white-and-blue-floral-cloth-4WV3G3RaneY?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
