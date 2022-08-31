# bsd-nginx-sites — BSD tool for NGINX 'sites-available' creating

Standard nginx package has the monolithic file **nginx.conf**. But when using nginx on Debian / Ubuntu etc., you will have some improvements, f.e. saving site configs into separate files in _/etc/nginx/sites-available_ directory. Their soft links are in _/etc/nginx/sites-enabled_ directory, and the main nginx.conf refers to them via directive:

    include /etc/nginx/sites-enabled/*.conf

This is handy but it's not a part of the standard nginx package. FreeBSD distro doesn't include these subdirectories and doesn't adapt nginx.conf to use them. Instead, the monolithic file is used. See [this discussion](https://unix.stackexchange.com/questions/362440/in-linux-theres-etc-nginx-sites-available-default-in-freebsd).

**bsd-nginx-sites** is made to fix this issue and make nginx maintenance on FreeBSD more comfortable.

## Usage

You need to have nginx installed. Also, you need bash and awk. I didn't test yet if it works on pure shell :)

Just run the script **nginx-sites.sh** as root and the job will get done.

The default working dir is _/usr/local/etc/nginx_.

## How it works

The script makes the following steps:

- Checks if it started as root. Fails if not.
- Checks if the working dir exist. Fails if not.
- Checks if the main nginx.conf exist. Fails if not.
- Checks if the 'sites-enabled' subdirectory exist. Fails if YES.
- Looks for Nginx executable. Fails if not found.
- Checks nginx config. Fails if it fails.
- Creates sites-... subdirectories.
- Analyzes and splits nginx.conf, creates single site files in 'sites-available' subdirectory and new nginx.conf via awk script. This is the core process.
- Backups old nginx.conf.
- Replaces this one with new nginx.conf.
- Creates symbolic links from 'sites-available' files to 'sites-enabled'.
- Checks nginx config again.
