#!/sbin/sh

if [ -f "/system/lib64/libmemtrack_real.so" ]; then
  exit 0
else
  exit 1
fi

