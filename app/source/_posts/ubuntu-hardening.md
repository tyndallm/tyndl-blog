---
title: Securing your VPS
date: 2017-02-21 00:05:12
tags: [linux, ubuntu, devops]
---
Recently I've been setting up a number of simple VPS servers on Amazon AWS and Digital Ocean, and I've wanted to make sure that they have a minimum level of protecion against common attacks and vulnerabilities. This is the guide I've put together to harden a newly created Ubuntu server.

## Quick System Hardening Guide

### SSH in as root

``` bash
$ ssh root@yourip
```

Always make sure that you update the OS to patch any recently fixed vulnerabilities:
``` bash
$ sudo apt-get update && sudo apt-get install
```

Ideally you want to setup your root user access with an ssh key. Different VPS hosts handle this differently and have slightly different sshd_config settings. We want to disable root access as soon as possible but to do that we need to create a new user we can use first.

### Create user

``` bash
$ adduser XXX
```
Next we will grant this user sudo privelages.
``` bash
$ gpasswd -a XXX sudo
```

Next we want to lock down ssh passwordAuthentication but first we need to make sure our new user has an ssh key.

### Upload an ssh key for new user from local machine

``` bash
$ cat ~/.ssh/id_rsa.pub | ssh username@remote_host "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

Once we know we will be able to login with our new user's ssh key we can disable root and password authentication. While we're there we'll also change the default ssh port.

### Open /etc/ssh/sshd_config with an editor

``` bash
$ sudo nano /etc/ssh/sshd_config
```

Then we will make three changes to the file, so you will want to find and modify the following to:
```
Port (Select a new port value between 49152 and 65535)
...
PermitRootLogin no
...
PasswordAuthentication no
```

In order for those changes to take affect we need to restart ssh:

``` bash
$ sudo service ssh restart
```

### Configure UFW
UFW is a simple firewall we can setup to block incoming traffic except for the ports we specifically need open.

Block all incoming traffic:
``` bash
$ sudo ufw default deny incoming
```
Since UFW hasn't been configured yet this will block all incoming traffic. Now we need to make sure we open our new ssh port:

``` bash
sudo ufw aalow "SSH PORT YOU CHOSE"
```

You can now optionally open any additional ports you may need:
``` bash
sudo ufw allow 8080/tcp
```

Once you are satisfied make sure you enable UFW

``` bash
sudo ufw enable
```

If you want to check that the firewall is configured properly:
``` bash
$ sudo ufw status verbose
```

Finally if you want to double check that the ports are in fact closed/opened you can verify with iptables:
``` bash
sudo iptables -L
```

### More to come
Ideally this is also where we would setup fail2ban, a popular tool used to ban ip addresses that incorrectly attempt ssh logins for a period of time. Expect an update with that coming soon.
