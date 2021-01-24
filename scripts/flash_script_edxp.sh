#MAGISK
############################################
#
# Magisk Flash Script (updater-script)
# by topjohnwu
#
############################################

##############
# Preparation
##############

COMMONDIR=$INSTALLER/common
APK=$COMMONDIR/magisk.apk
CHROMEDIR=$INSTALLER/chromeos
EDXPDIR=$INSTALLER/edxp

# Default permissions
umask 022

OUTFD=$2
ZIP=$3

if [ ! -f $COMMONDIR/util_functions.sh ]; then
  echo "! Unable to extract zip file!"
  exit 1
fi

# Load utility fuctions
. $COMMONDIR/util_functions.sh

setup_flashable

############
# Detection
############

#if echo $MAGISK_VER | grep -q '\.'; then
#  PRETTY_VER=$MAGISK_VER
#else
#  PRETTY_VER="$MAGISK_VER($MAGISK_VER_CODE)"
#fi
#print_title "Magisk $PRETTY_VER Installer"

ui_print " "
ui_print "     SYSTEM EDXPOSED INSTALLER     "
ui_print "         (version 0.4.6.2)         "
ui_print " "


is_mounted /data || mount /data || is_mounted /cache || mount /cache
mount_partitions
check_data

if ls /data/magisk_backup_* 1> /dev/null 2>&1; then
  abort " ! Magisk detected. Cannot proceed. Please install Riru-Core and Riru-Edxposed magisk modules instead ! "
  exit 1
fi

HASINITDSUPPORT=0
if [ -d /system_root/system/etc/init.d ]
then
  HASINITDSUPPORT=1
else
  if [ -d /system/system/etc/init.d ]
  then
    HASINITDSUPPORT=1
  else
    if [ -d /system_root/etc/init.d ]
    then
      HASINITDSUPPORT=1
    else
      if [ -d /system/etc/init.d ]
      then
        HASINITDSUPPORT=1
      fi
    fi
  fi
fi
if [ $HASINITDSUPPORT -eq 1 ]
then
  ui_print "- Init.d support detected"
  ui_print "- SELinux policies will be injected in system partition"
else
  ui_print "- Init.d support is not detected"
  ui_print "- SELinux policies will be injected in boot partition"
fi


if [ $HASINITDSUPPORT -eq 0 ]
then

get_flags
find_boot_image

[ -z $BOOTIMAGE ] && abort "! Unable to detect target image"
ui_print "- Target image: $BOOTIMAGE"

fi

# Detect version and architecture
api_level_arch_detect

[ $API -lt 17 ] && abort "! Magisk only support Android 4.2 and above"

ui_print "- Device platform: $ARCH"

if [ "$ARCH" != "arm" ]
then
  if [ "$ARCH" != "arm64" ]
  then
    abort " ! Incompatible architecture detected. System-EdXposed supports only arm and arm64 platforms ! "
    exit 1
  fi
fi

BINDIR=$INSTALLER/$ARCH32
chmod -R 755 $CHROMEDIR $BINDIR

if [ $HASINITDSUPPORT -eq 0 ]
then

# Check if system root is installed and remove
$BOOTMODE || remove_system_su

fi


##############
# Environment
##############

ui_print "- Constructing environment"

# Copy required files
rm -rf $MAGISKBIN/* 2>/dev/null
mkdir -p $MAGISKBIN 2>/dev/null
cp -af $BINDIR/. $COMMONDIR/. $EDXPDIR/. $CHROMEDIR $BBBIN $MAGISKBIN
chmod -R 755 $MAGISKBIN


# SILENTPOLICY - discovering system dir
SYSTEMDIR=/system
if [ -f /system_root/system/bin/cd ]
then
  SYSTEMDIR=/system_root/system
elif [ -f /system/system/bin/cd ]
then
  SYSTEMDIR=/system/system
elif [ -f /system_root/bin/cd ]
then
  SYSTEMDIR=/system_root
else
  SYSTEMDIR=/system
fi
ui_print "- System path: $SYSTEMDIR"

# SILENTPOLICY - mount system rw
ui_print "- Remounting system partition to rw mode"
blockdev --setrw /dev/block/mapper/system$SLOT 2>/dev/null
mount -o rw,remount /system


if [ $HASINITDSUPPORT -eq 0 ]
then

# addon.d
if [ -d /system/addon.d ]; then
  ui_print "- Adding addon.d survival script"
#  blockdev --setrw /dev/block/mapper/system$SLOT 2>/dev/null
#  mount -o rw,remount /system
  ADDOND=/system/addon.d/99-magisk.sh
  cp -af $COMMONDIR/addon.d.sh $ADDOND
  chmod 755 $ADDOND
fi

fi

$BOOTMODE || recovery_actions

#####################
# Boot/DTBO Patching
#####################

if [ $HASINITDSUPPORT -eq 0 ]
then

install_magisk

fi

# ============================================= #

if [ -f $SYSTEMDIR/lib/libmemtrack_real.so ]
then
  ui_print "- Previous EdXposed install detected"
else
  ui_print "- No previous EdXposed install detected"
fi

# if previous edxp install detected then delete modified libmemtrack and restore original before any further steps
if [ -f $SYSTEMDIR/lib/libmemtrack_real.so ]
then
  ui_print "- Restore original libmemtrack.so"
  if [ -f $SYSTEMDIR/lib/libmemtrack.so ]
  then
    rm $SYSTEMDIR/lib/libmemtrack.so
    mv $SYSTEMDIR/lib/libmemtrack_real.so $SYSTEMDIR/lib/libmemtrack.so
  fi
fi
if [ -d $SYSTEMDIR/lib64 ]
then
  if [ -f $SYSTEMDIR/lib64/libmemtrack_real.so ]
  then
    if [ -f $SYSTEMDIR/lib64/libmemtrack.so ]
    then
      rm $SYSTEMDIR/lib64/libmemtrack.so
      mv $SYSTEMDIR/lib64/libmemtrack_real.so $SYSTEMDIR/lib64/libmemtrack.so
    fi
  fi
fi

# move original libs
ui_print "- Move libmemtrack.so"
if [ -f $SYSTEMDIR/lib/libmemtrack.so ]
then
  mv $SYSTEMDIR/lib/libmemtrack.so $SYSTEMDIR/lib/libmemtrack_real.so
fi
if [ -d $SYSTEMDIR/lib64 ]
then
  if [ -f $SYSTEMDIR/lib64/libmemtrack.so ]
  then
    mv $SYSTEMDIR/lib64/libmemtrack.so $SYSTEMDIR/lib64/libmemtrack_real.so
  fi
fi

ui_print "- Install system libraries"

### copy libmemtrack.so
if [ -f $SYSTEMDIR/lib/libmemtrack.so ]
then
  rm $SYSTEMDIR/lib/libmemtrack.so
fi
cp $MAGISKBIN/libmemtrack.so.arm $SYSTEMDIR/lib/libmemtrack.so || ui_print "- Error delivering libmemtrack.so (arm)"
chmod 0644 $SYSTEMDIR/lib/libmemtrack.so
chown root:root $SYSTEMDIR/lib/libmemtrack.so
chcon u:object_r:system_file:s0 $SYSTEMDIR/lib/libmemtrack.so
rm $MAGISKBIN/libmemtrack.so.arm
if [ -d $SYSTEMDIR/lib64 ]
then
  if [ -f $SYSTEMDIR/lib64/libmemtrack.so ]
  then
    rm $SYSTEMDIR/lib64/libmemtrack.so
  fi
  cp $MAGISKBIN/libmemtrack.so.arm64 $SYSTEMDIR/lib64/libmemtrack.so || ui_print "- Error delivering libmemtrack.so (arm64)"
  chmod 0644 $SYSTEMDIR/lib64/libmemtrack.so
  chown root:root $SYSTEMDIR/lib64/libmemtrack.so
  chcon u:object_r:system_file:s0 $SYSTEMDIR/lib64/libmemtrack.so
fi
rm $MAGISKBIN/libmemtrack.so.arm64

### copy libriru_edxp.so
if [ -f $SYSTEMDIR/lib/libriru_edxp.so ]
then
  rm $SYSTEMDIR/lib/libriru_edxp.so
fi
cp $MAGISKBIN/libriru_edxp.so.arm $SYSTEMDIR/lib/libriru_edxp.so || ui_print "- Error delivering libriru_edxp.so (arm)"
chmod 0644 $SYSTEMDIR/lib/libriru_edxp.so
chown root:root $SYSTEMDIR/lib/libriru_edxp.so
chcon u:object_r:system_file:s0 $SYSTEMDIR/lib/libriru_edxp.so
rm $MAGISKBIN/libriru_edxp.so.arm
if [ -d $SYSTEMDIR/lib64 ]
then
  if [ -f $SYSTEMDIR/lib64/libriru_edxp.so ]
  then
    rm $SYSTEMDIR/lib64/libriru_edxp.so
  fi
  cp $MAGISKBIN/libriru_edxp.so.arm64 $SYSTEMDIR/lib64/libriru_edxp.so || ui_print "- Error delivering libriru_edxp.so (arm64)"
  chmod 0644 $SYSTEMDIR/lib64/libriru_edxp.so
  chown root:root $SYSTEMDIR/lib64/libriru_edxp.so
  chcon u:object_r:system_file:s0 $SYSTEMDIR/lib64/libriru_edxp.so
fi
rm $MAGISKBIN/libriru_edxp.so.arm64

### copy libwhale.edxp.so
if [ -f $SYSTEMDIR/lib/libwhale.edxp.so ]
then
  rm $SYSTEMDIR/lib/libwhale.edxp.so
fi
cp $MAGISKBIN/libwhale.edxp.so.arm $SYSTEMDIR/lib/libwhale.edxp.so || ui_print "- Error delivering libwhale.edxp.so (arm)"
chmod 0644 $SYSTEMDIR/lib/libwhale.edxp.so
chown root:root $SYSTEMDIR/lib/libwhale.edxp.so
chcon u:object_r:system_file:s0 $SYSTEMDIR/lib/libwhale.edxp.so
rm $MAGISKBIN/libwhale.edxp.so.arm
if [ -d $SYSTEMDIR/lib64 ]
then
  if [ -f $SYSTEMDIR/lib64/libwhale.edxp.so ]
  then
    rm $SYSTEMDIR/lib64/libwhale.edxp.so
  fi
  cp $MAGISKBIN/libwhale.edxp.so.arm64 $SYSTEMDIR/lib64/libwhale.edxp.so || ui_print "- Error delivering libwhale.edxp.so (arm64)"
  chmod 0644 $SYSTEMDIR/lib64/libwhale.edxp.so
  chown root:root $SYSTEMDIR/lib64/libwhale.edxp.so
  chcon u:object_r:system_file:s0 $SYSTEMDIR/lib64/libwhale.edxp.so
fi
rm $MAGISKBIN/libwhale.edxp.so.arm64

### copy edxp jars
ui_print "- Install framework jars"
if [ -f $SYSTEMDIR/framework/edconfig.jar ]
then
  rm $SYSTEMDIR/framework/edconfig.jar
fi
cp $MAGISKBIN/edconfig.jar $SYSTEMDIR/framework/edconfig.jar || ui_print "- Error delivering edconfig.jar"
chmod 0644 $SYSTEMDIR/framework/edconfig.jar
chown root:root $SYSTEMDIR/framework/edconfig.jar
chcon u:object_r:system_file:s0 $SYSTEMDIR/framework/edconfig.jar
rm $MAGISKBIN/edconfig.jar

if [ -f $SYSTEMDIR/framework/eddalvikdx.jar ]
then
  rm $SYSTEMDIR/framework/eddalvikdx.jar
fi
cp $MAGISKBIN/eddalvikdx.jar $SYSTEMDIR/framework/eddalvikdx.jar || ui_print "- Error delivering eddalvikdx.jar"
chmod 0644 $SYSTEMDIR/framework/eddalvikdx.jar
chown root:root $SYSTEMDIR/framework/eddalvikdx.jar
chcon u:object_r:system_file:s0 $SYSTEMDIR/framework/eddalvikdx.jar
rm $MAGISKBIN/eddalvikdx.jar

if [ -f $SYSTEMDIR/framework/eddexmaker.jar ]
then
  rm $SYSTEMDIR/framework/eddexmaker.jar
fi
cp $MAGISKBIN/eddexmaker.jar $SYSTEMDIR/framework/eddexmaker.jar || ui_print "- Error delivering eddexmaker.jar"
chmod 0644 $SYSTEMDIR/framework/eddexmaker.jar
chown root:root $SYSTEMDIR/framework/eddexmaker.jar
chcon u:object_r:system_file:s0 $SYSTEMDIR/framework/eddexmaker.jar
rm $MAGISKBIN/eddexmaker.jar

if [ -f $SYSTEMDIR/framework/edxp.jar ]
then
  rm $SYSTEMDIR/framework/edxp.jar
fi
cp $MAGISKBIN/edxp.jar $SYSTEMDIR/framework/edxp.jar || ui_print "- Error delivering edxp.jar"
chmod 0644 $SYSTEMDIR/framework/edxp.jar
chown root:root $SYSTEMDIR/framework/edxp.jar
chcon u:object_r:system_file:s0 $SYSTEMDIR/framework/edxp.jar
rm $MAGISKBIN/edxp.jar

### copy zygote_restart
ui_print "- Install zygote_restart binary"
if [ -f $SYSTEMDIR/bin/zygote_restart ]
then
  rm $SYSTEMDIR/bin/zygote_restart
fi
if [ "$ARCH" == "arm" ]
then
  cp $MAGISKBIN/zygote_restart.arm $SYSTEMDIR/bin/zygote_restart || ui_print "- Error delivering zygote_restart (arm)"
else
  if [ "$ARCH" == "arm64" ]
  then
    cp $MAGISKBIN/zygote_restart.arm64 $SYSTEMDIR/bin/zygote_restart || ui_print "- Error delivering zygote_restart (arm64)"
  else
    abort " ! Incompatible architecture detected. System-EdXposed supports only arm and arm64 platforms ! "
    exit 1
  fi
fi
chmod 0700 $SYSTEMDIR/bin/zygote_restart
chown root:root $SYSTEMDIR/bin/zygote_restart
chcon u:object_r:system_file:s0 $SYSTEMDIR/bin/zygote_restart
rm $MAGISKBIN/zygote_restart.arm
rm $MAGISKBIN/zygote_restart.arm64

# if system supports init.d then copy binary that patches selinux policies and script to call it on boot
if [ $HASINITDSUPPORT -eq 1 ]
then

  ui_print "- Install selinux patcher binary"
  if [ -f $SYSTEMDIR/bin/espf ]
  then
    rm $SYSTEMDIR/bin/espf
  fi
  if [ "$ARCH" == "arm" ]
  then
    cp $MAGISKBIN/espf.arm $SYSTEMDIR/bin/espf || ui_print "- Error delivering espf (arm)"
  else
    if [ "$ARCH" == "arm64" ]
    then
      cp $MAGISKBIN/espf.arm64 $SYSTEMDIR/bin/espf || ui_print "- Error delivering espf (arm64)"
    else
      abort " ! Incompatible architecture detected. System-EdXposed supports only arm and arm64 platforms ! "
      exit 1
    fi
  fi
  chmod 0700 $SYSTEMDIR/bin/espf
  chown root:root $SYSTEMDIR/bin/espf
  chcon u:object_r:system_file:s0 $SYSTEMDIR/bin/espf

  ui_print "- Install selinux patcher script"
  if [ -f $SYSTEMDIR/etc/init.d/07slf ]
  then
    rm $SYSTEMDIR/etc/init.d/07slf
  fi
  cp $MAGISKBIN/initdscript $SYSTEMDIR/etc/init.d/07slf || ui_print "- Error delivering init.d script"
  chmod 0755 $SYSTEMDIR/etc/init.d/07slf
  chown root:root $SYSTEMDIR/etc/init.d/07slf
  chcon u:object_r:system_file:s0 $SYSTEMDIR/etc/init.d/07slf

fi
rm $MAGISKBIN/espf.arm
rm $MAGISKBIN/espf.arm64
rm $MAGISKBIN/initdscript

# ============================================= #

# SILENTPOLICY - remove addon.d script
if [ -f $SYSTEMDIR/addon.d/99-magisk.sh ]
then
  ui_print "- Remove addon.d script"
  rm -f $SYSTEMDIR/addon.d/99-magisk.sh
else
  ui_print "- No addon.d script found"
fi


if [ $HASINITDSUPPORT -eq 0 ]
then

# SILENTPOLICY - move backups to tmp and wipe original
ORIGINALBACKUPSDIR=/tmp/backup_original_partitions
rm -rf $ORIGINALBACKUPSDIR 2>/dev/null
mkdir $ORIGINALBACKUPSDIR 2>/dev/null
cp -R /data/magisk_backup* $ORIGINALBACKUPSDIR
ui_print "- Backups copied to tmpfs"
rm -rf /data/magisk_backup* 2>/dev/null
ui_print "- Original backups wiped"


# SILENTPOLICY - backup secure dir and wipe original
if [ -d /data/adb/magisk ]
then
  ui_print "- Backup secure dir"
  cp -R /data/adb/magisk $ORIGINALBACKUPSDIR/securedir
  ui_print "- Removing traces from secure dir"
  rm -rf /data/adb/magisk
else
  ui_print "- No traces in secure dir"
fi

fi

# Cleanups
$BOOTMODE || recovery_cleanup
rm -rf $TMPDIR

ui_print "- Done"

if [ $HASINITDSUPPORT -eq 0 ]
then

# SILENTPOLICY - backups warning
ui_print " "
ui_print " "
ui_print " ! WARNING !"
ui_print " Installation completed successfully. Do not reboot to system right now. Please do not forget to dump backups via adb and save them:"
ui_print " "
ui_print " $ adb pull $ORIGINALBACKUPSDIR . "
ui_print " "
ui_print " If you forget to do this, you will not be able to automatically uninstall this tool, you will have to manually restore your original device /boot partition"
ui_print " "
ui_print " "

fi

ui_print " "

exit 0
