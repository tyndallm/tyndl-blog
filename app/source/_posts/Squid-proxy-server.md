---
title: Squid proxy server
date: 2017-02-27 09:06:51
tags: [linux, ubuntu, squid]
---

## Quick guide to setting up an authenticated proxy server

### SSH into your server

``` bash
$ ssh user@yourip
```

### sudo up

``` bash
$ sudo su
```

### Update and install Squid & Apache2-utils

``` bash
$ apt-get update && apt-get install squid apache2-utils -y
```

Squid is the proxy service we will be running. We will use Apache2-utils for adding basic authentication to Squid. After Squid is installed the proxy service will be up and running on the default port 3128 but is set to deny all traffic.

### Allow incoming http requests

In order to allow incoming traffic we need to edit the squid config file

``` bash
$ nano /etc/squid/squid.conf
```

Now we can look for "http_access deny all" and modify it. In nano use ctrl+w to search

``` bash
http_access allow all
```

**Warning**: It's not recommended to leave this configured without any authentication as there are thousands of bots scanning the web for open proxies and anyone would be able to access and use this server as a proxy if we just left it like this.

### Create a username and password for auth

We're going to use Apache's htpasswd utility to add basic authentication. First we need to create a file that will contain our auth credentials.

``` bash
$ touch /etc/squid/passwd
```

Then we're going to create a user with htpasswd

``` bash
$ htpasswd /etc/squid/passwd [username]
```

It will then prompt you to enter a password for that user

### Add auth to squid config

Open the squid config in editor

``` bash
$ nano /etc/squid/squid.conf
```

Now we're going to add the lines that tell squid to require authentication. (I usually just add this to the top of the squid.conf file. Wherever you put it needs to be above the http_access allow all we added earlier) 

```
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
acl squid_users proxy_auth REQUIRED
http_access allow squid_users
```

This adds the user we created in our /etc/squid/passwd to an access control list that requires authentication.

Now lets restart squid so the change takes effect

``` bash
$ service squid restart
```

## At this point the proxy should be good to go

The proxy server should now be properly locked down to outsiders and allowing all http traffic to an authenticated user. To test you can open up your browser and configure it to use the proxy you just created.

When entering the proxy information in the browser the address is going to be the public IP address of your VPS and the port will be 3128.

You can verify that the proxy is working correctly by looking at the access log on the server:

``` bash
tail -f /var/log/squid/access.log
```

In addition if you are setting up a brand new proxy server I recommend combining this guide with the [[enter link to vps hardening here]] to properly lock down the server. If you do, make sure you open port 3128 in UFW otherwise the firewall will block the incoming proxy traffic.

Once I have one of these server configured I will create an image on my hosting provider so that I can instantly spin up as many proxy servers as needed.
