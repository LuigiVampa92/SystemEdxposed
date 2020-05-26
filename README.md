# System EdXposed

This is a script that builds a TWRP zip file that installs [EdXposed](https://github.com/ElderDrivers/EdXposed) framework (YAHFA) on your device straight to /system partition. 

The main goal is to be able to use EdXposed without flashing Magisk and installing Riru-Core and Riru-EdXposed magisk-modules.

This approach does not require you to root your device at all. It also makes it possible to lock your device bootloader with custom ROM installed on devices that support it (I did so on my OnePlus 5T). 

I personally believe that flashing magisk or root greatly decreases your device security in cases when someone can physically get your device. Root increases attack surface a lot when it comes to getting your personal data from your device. There are a bunch of tools that can collect data from your device and all of them work via adb or as apps and can call su binary. If someone wants to analyze your device with forensic tools nothing can be better for him than a root. 
Xposed, however, does not give such advantages to a physical forensic attacker but provides a number of tools for you to harden your device against privacy leaks and protect your data.

This build also does not rely on any magisk configs embedded in /data partition so you will not have any troubles when you make a factory reset of your device. Wipe your /data partition as much as you wish, EdXposed will do just fine

## Install

Build.sh uses 7zip, so you have to install 7z from apt/brew/whatever before running the build

- Use build.sh to make a zip file.

You have to set required architecture and SELinux mode for the build script. 
Only ARM architecture supported: 32-bit (armeabi-v7a) and 64-bit (arm64v8a).
This script can not make a build for x86/x86_64 though it is not technically impossible.

Example:
./build.sh arm64 enforcing

- Flash the result zip with TWRP
- Reboot to system
- Install EdXposedManager app. You can get it [here](https://github.com/ElderDrivers/EdXposedManager)
- Enjoy EdXposed !

Direct download:

- [zip_system_edxposed_v0462_arm64_enforcing.zip](https://github.com/LuigiVampa92/System_EdXposed_install/releases/download/v0.4.6.2/zip_system_edxposed_v0462_arm64_enforcing.zip)
- [zip_system_edxposed_v0462_arm64_permissive.zip](https://github.com/LuigiVampa92/System_EdXposed_install/releases/download/v0.4.6.2/zip_system_edxposed_v0462_arm64_permissive.zip)
- [zip_system_edxposed_v0462_arm_enforcing.zip](https://github.com/LuigiVampa92/System_EdXposed_install/releases/download/v0.4.6.2/zip_system_edxposed_v0462_arm_enforcing.zip)
- [zip_system_edxposed_v0462_arm_permissive.zip](https://github.com/LuigiVampa92/System_EdXposed_install/releases/download/v0.4.6.2/zip_system_edxposed_v0462_arm_permissive.zip)

## Uninstall

Use [this](https://github.com/LuigiVampa92/System_EdXposed_uninstall) to properly uninstall System EdXposed

Direct download:

- [zip_system_edxposed_uninstall.zip](https://github.com/LuigiVampa92/System_EdXposed_uninstall/releases/download/v1.0/zip_system_edxposed_uninstall.zip)

## Restrictions

Unfortunately, this "system" version of EdXposed can be installed only on ROMs that have init.d support.

EdXposed requires modification of SELinux policies in order to work. This policies must be applied before loading of EdXposed framework or SELinux must be switched to permissive mode before loading of EdXposed framework, otherwise your system will fall into a bootloop.

Riru-EdXposed magisk module applies required policies at boot time. Magisk replaces original init with its own and can do such things. It injects sepolicy patch for EdXposed during boot process and everything works great.

When we want to do the same trick without Magisk we have to patch sepolicy rules strictly before start of any app process which means we cannot make it on something like BOOT_COMPLETE event, only during system boot. The best option of course is to make your own ROM build and simply include necessary sepolicy rules in .te file at build time. Unfortunately I was not able to make a .rc script that will run during system boot because I could not execute binary that was not approved to be executed during init by SELinux policies defined at build time. To be honest, I do not think it is possible at all. For a simple flashable zip the only practical way is to make it in init.d script. The problem that not many ROMs have init.d support. I tested it on LineageOS 16 (Android 9) and everything worked fine, because LineageOS has init.d support, but most stock ROMs don't

## Links:

https://github.com/ElderDrivers/EdXposed

https://github.com/ElderDrivers/EdXposedManager
