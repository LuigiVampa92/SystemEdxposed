#!/sbin/sh

if [ -d "/system/lib64" ]; then
  exit 0
else
  exit 1
fi
