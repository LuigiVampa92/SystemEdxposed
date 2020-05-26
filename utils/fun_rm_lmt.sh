#!/sbin/sh

if [ -f "/system/lib/libmemtrack_real.so" ]; then
  if [ -f "/system/lib/libmemtrack.so" ]; then
    rm /system/lib/libmemtrack.so
    mv /system/lib/libmemtrack_real.so /system/lib/libmemtrack.so
  else
    mv /system/lib/libmemtrack_real.so /system/lib/libmemtrack.so
  fi
fi

if [ -d "/system/lib64" ]; then
  if [ -f "/system/lib64/libmemtrack_real.so" ]; then
    if [ -f "/system/lib64/libmemtrack.so" ]; then
      rm /system/lib64/libmemtrack.so
      mv /system/lib64/libmemtrack_real.so /system/lib64/libmemtrack.so
    else
      mv /system/lib64/libmemtrack_real.so /system/lib64/libmemtrack.so
    fi
  fi
fi
