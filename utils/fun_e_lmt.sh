#!/sbin/sh

if [ -f "/system/lib/libmemtrack.so" ]; then
  exit 0
else
  exit 1
fi

