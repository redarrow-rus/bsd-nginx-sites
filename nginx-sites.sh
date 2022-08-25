#!/usr/bin/env bash

msg_err() {
    [ -z "$1" ] && exit 2
    printf "\033[31;31m**[ERROR] %s\033[m\n" "$1"
    exit 2
}

BASEDIR=/usr/local/etc/nginx
[ "$( whoami)" == "root" ] || msg_err "Need to be root."
[ -d "$BASEDIR" ] || msg_err "Nginx directory not found. Please verify path: $BASEDIR"
[ -f "$BASEDIR/nginx.conf" ] || msg_err "nginx.conf not found. Please verify path: $BASEDIR/nginx.conf"
nginxBin=$( whereis -bq nginx )
[ -z "$nginxBin" ] && msg_err "Cannot find Nginx executable."

$nginxBin -tq 2>/dev/null || msg_err "Nginx config test failed! Please repair your config and start this script again."

echo "Nginx config found: $BASEDIR/nginx.conf"
echo "Nginx binary found: $nginxBin"
echo -n "Creating 'sites-' directories... "

mkdir $BASEDIR/sites-available
mkdir $BASEDIR/sites-enabled

echo "done."
echo -n "Processing nginx config... "

awk -f "$( dirname "$0" )/nginx-sites.awk" -v "TARGET_PATH=${BASEDIR}" "$BASEDIR/nginx.conf" > "$BASEDIR/nginx.conf.new"
echo "done."
echo -n "Backup files..."
mv "$BASEDIR/nginx.conf" "$BASEDIR/nginx.conf.orig"
mv "$BASEDIR/nginx.conf.new" "$BASEDIR/nginx.conf"
echo "done."
echo "Creating symbolic links."
for site in $( ls -1 "$BASEDIR/sites-available" ); do
    ln -s "$BASEDIR/sites-available/$site" "$BASEDIR/sites-enabled"
    echo "- $site"
done
echo

if $nginxBin -tq 2>/dev/null; then
    echo "Congratulations! Your Nginx config is ok!"
    echo "Base settings are $BASEDIR/nginx.conf, sites settings are in $BASEDIR/sites-available, links to them are in $BASEDIR/sites-enabled."
else
    msg_err "Nginx config test failed! Something got wrong, sorry..."
fi
echo "Source Nginx config is here: $BASEDIR/nginx.conf.orig"
