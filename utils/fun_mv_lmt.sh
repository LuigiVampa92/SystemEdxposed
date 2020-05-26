#!/sbin/sh

if [ ! -f "/system/lib/libmemtrack_real.so" ]; then
  if [ -f "/system/lib/libmemtrack.so" ]; then
    mv /system/lib/libmemtrack.so /system/lib/libmemtrack_real.so
  fi
fi

if [ -d "/system/lib64" ]; then
  if [ ! -f "/system/lib64/libmemtrack_real.so" ]; then
    if [ -f "/system/lib64/libmemtrack.so" ]; then
      mv /system/lib64/libmemtrack.so /system/lib64/libmemtrack_real.so
    fi
  fi
fi
