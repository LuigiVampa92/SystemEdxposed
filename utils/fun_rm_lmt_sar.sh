#!/sbin/sh

if [ -f "/system_root/system/lib/libmemtrack_real.so" ]; then
  if [ -f "/system_root/system/lib/libmemtrack.so" ]; then
    rm /system_root/system/lib/libmemtrack.so
    mv /system_root/system/lib/libmemtrack_real.so /system_root/system/lib/libmemtrack.so
  else
    mv /system_root/system/lib/libmemtrack_real.so /system_root/system/lib/libmemtrack.so
  fi
fi

if [ -d "/system_root/system/lib64" ]; then
  if [ -f "/system_root/system/lib64/libmemtrack_real.so" ]; then
    if [ -f "/system_root/system/lib64/libmemtrack.so" ]; then
      rm /system_root/system/lib64/libmemtrack.so
      mv /system_root/system/lib64/libmemtrack_real.so /system_root/system/lib64/libmemtrack.so
    else
      mv /system_root/system/lib64/libmemtrack_real.so /system_root/system/lib64/libmemtrack.so
    fi
  fi
fi
