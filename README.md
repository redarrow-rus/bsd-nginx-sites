# bsd-nginx-sites — BSD tool for NGINX 'site-available' creating
Standard nginx package has the monolithic file **nginx.conf**. But when using nginx on Debian / Ubuntu etc., you will have some improvements, f.e. saving site configs into separate files in _etc/nginx/site-available_ directory. Their soft links are in _etc/nginx/site-enabled_ directory, and the main nginx.conf refers to them via directive:

    include /etc/nginx/site-enabled/*.conf

This is handy but it's not a part of the standard nginx package. FreeBSD distro doesn't include these subdirectories and doesn't adapt nginx.conf to use them. Instead, the monolithic file is used. See [this discussion](https://unix.stackexchange.com/questions/362440/in-linux-theres-etc-nginx-sites-available-default-in-freebsd).

**bsd-nginx-sites** is made to fix this issue and make nginx maintenance on FreeBSD more comfortable.

