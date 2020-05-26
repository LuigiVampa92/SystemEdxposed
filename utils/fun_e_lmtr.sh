#!/sbin/sh

if [ -f "/system/lib/libmemtrack_real.so" ]; then
  exit 0
else
  exit 1
fi
