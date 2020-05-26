#!/sbin/sh

if [ -d "/system/etc/init.d" ]; then
  exit 0
else
  exit 1
fi
