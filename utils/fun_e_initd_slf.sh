#!/sbin/sh

if [ -d "/system/etc/init.d" ]; then
  if [ -f "/system/etc/init.d/07slf" ]; then
    exit 0
  else
    exit 1
  fi
else
  exit 1
fi
