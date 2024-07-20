bash-httpd
==========

The worlds first (and hopefully last) micro web server implementation. A web server in all of ~100 lines of bash.

Below is some commentary on what the software is, what you should do with it, and what you shouldn't.

# What is it?
    Bash-httpd is a micro web server written in bash, the GNU bourne shell replacement. 
# Why does it exist?
    It doesn't have any features that aren't in a million other web servers, and is ridiculously slow. But isn't the idea cool? :) 
# What's the current version?
    The sole script in this repository is versioned. 
# Why should I run it instead of Apache or [insert favorite server software here].
    You shouldn't. Let me repeat that -- you should *not* use this code in any sort of production environment. If you want a web server, use something else, ie. Apache. See the next question. 
# Why *shouldn't* I run it?
    Because it's not secure, relatively slow, probably doesn't comply with any of the HTTP specs, and is feature-poor. 
# I want to run it anyway. How do I get it and install it?
```console
foo@bar:~$ git clone https://github.com/lewismc/bash-httpd.git
foo@bar:~$ sudo ln -s /path/to/bash-httpd/bash-httpd-0.03.sh /usr/local/bin/bash-httpd
foo@bar:~$ mkdir www     // put your files in this directory
```
    Then edit the config variables at the beginning of the script to suit your environment. You may need to insert a line for it in /etc/inetd.conf, running as nobody. You probably also want to wrap the port.

    If you're not root, get ahold of Netcat, preferably compile it with -DGAPING_SECURITY_HOLE (because it *is* a gaping security hole), and run:
```console
foo@bar:~$ (while true; do nc -l -p 8080 -e bash-httpd; done)&
```

    or the like. If you don't understand any part of these instructions, you probably shouldn't be running it. If any harm comes to you or your computer because you ran this software, don't blame me: I don't recommend that *anyone* run it.

    You're welcome. :) 
