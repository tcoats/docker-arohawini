#!/bin/sh
set -e

apk update
apk upgrade

# Install node.js syslog-ng zeromq initsh bashalias cifs-utils
apk add nodejs zeromq syslog-ng cifs-utils
cp -R /install/syslog-ng/* /
cp -R /install/initsh/* /
cp -R /install/bashalias/* /

# Install Runit
testing_repo="http://dl-4.alpinelinux.org/alpine/edge/testing"
echo "$testing_repo" >> /etc/apk/repositories
apk update
apk add runit
grep -v "$testing_repo" /etc/apk/repositories > /etc/apk/repositories.tmp
mv /etc/apk/repositories.tmp /etc/apk/repositories

# Clean up
rm -rf /install
rm -rf /tmp/*
rm -rf /var/cache/apk/*
