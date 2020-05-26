#!/sbin/sh

if [ ! -f "/system_root/system/lib/libmemtrack_real.so" ]; then
  if [ -f "/system_root/system/lib/libmemtrack.so" ]; then
    mv /system_root/system/lib/libmemtrack.so /system_root/system/lib/libmemtrack_real.so
  fi
fi

if [ -d "/system_root/system/lib64" ]; then
  if [ ! -f "/system_root/system/lib64/libmemtrack_real.so" ]; then
    if [ -f "/system_root/system/lib64/libmemtrack.so" ]; then
      mv /system_root/system/lib64/libmemtrack.so /system_root/system/lib64/libmemtrack_real.so
    fi
  fi
fi
