
EDXP_VERSION="0462"

if [ "$#" -ne 2 ]; then
  echo " "
  echo " Usage:"
  echo "   ./build.sh <arch> <selinux>"
  echo " "
  echo "   arch: arm or arm64"
  echo "   selinux: enforcing or permissive"
  echo " "
else
  if [[ $1 == "arm" ]] || [[ $1 == "arm64" ]] ; then
    if [[ $2 == "enforcing" ]] || [[ $2 == "permissive" ]] ; then
        
        if [ -d system/bin ]; then
          rm -rf system/bin
        fi
        mkdir -p system/bin
        if [[ $1 == "arm" ]]; then
          cp -R bin/arm/* system/bin
        else
          cp -R bin/arm64/* system/bin
        fi
          
        if [ -d system/etc ]; then
          rm -rf system/etc
        fi
        mkdir -p system/etc/init.d
        if [ -f utils/fun_c_selinux.sh ]; then
          rm utils/fun_c_selinux.sh
        fi
        touch utils/fun_c_selinux.sh
        echo "#!/sbin/sh" >> utils/fun_c_selinux.sh
        if [[ $2 == "enforcing" ]]; then
          cp selinux/enforcing/07slf system/etc/init.d/07slf
          echo "exit 0" >> utils/fun_c_selinux.sh
        else
          cp selinux/permissive/07slf system/etc/init.d/07slf
          echo "exit 1" >> utils/fun_c_selinux.sh
        fi
 
        ZIP_NAME=zip_system_edxposed_v"$EDXP_VERSION"_$1_$2.zip
        if [ -f $ZIP_NAME ]; then
          rm $ZIP_NAME
        fi
        find . -name ".DS_Store" -delete
        7z a $ZIP_NAME utils/ system/ META-INF/

    else
      echo -e "Error. Invalid selinux value. Only following values are supported: enforcing , permissive"
      exit 1
    fi
  else
    echo -e "Error. Invalid arch value. Only following values are supported: arm , arm64"
    exit 1
  fi
fi
