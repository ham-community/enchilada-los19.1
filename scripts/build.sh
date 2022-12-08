#!/usr/bin/env bash

VENDOR=oneplus
LOS_DEVICE=enchilada

TODAY=$(date +"%Y%m%d")
OUT=/ham-build/android/out/target/product/$LOS_DEVICE
PKGNAME=LineageOS-19.1-$TODAY-release-$LOS_DEVICE-signed

export PATH=$PATH:/ham-build/android/out/host/linux-x86:/ham-build/android/out/host/linux-x86/bin:/ham-build/android/build/make/tools/releasetools:/ham-build/android/out/soong/host/linux-x86/bin

# Add the LOS java library paths to the environment.
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/ham-build/android/out/host/linux-x86/lib:/ham-build/android/out/host/linux-x86/lib64

cd /ham-build/android


BCFILE=/ham-build/android/device/$VENDOR/$LOS_DEVICE/BoardConfig.mk
BCADDITIONS="
# Enable RADIO files so we can add the firmware IMGs to the OTA.
ADD_RADIO_FILES := true

# Set the AVB key and hash algorithm.
BOARD_AVB_KEY_PATH := /root/.android-certs/releasekey.key
BOARD_AVB_ALGORITHM := SHA256_RSA2048

# Include the rest of the prebuilt partitions.
# The following three images are exclude as lineage recovery doesn't seem to be able to flash them: india.img, reserve.img
AB_OTA_PARTITIONS += abl aop bluetooth cmnlib cmnlib64 devcfg dsp fw_4j1ed fw_4u1ea hyp keymaster LOGO modem oem_stanvbk qupfw storsec tz xbl xbl_config
"

echo $BCADDITIONS >> $BCFILE


BCCFILE=/ham-build/android/device/$VENDOR/sdm845-common/BoardConfigCommon.mk
# We need to remove the flag that disables the partition verification during boot if it hasn't been already
# in the sdm845 common code.
if ! grep "#BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS" $BCCFILE > /dev/null; then
   sed -i 's/^BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 2/#BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 2/' $BCCFILE
   sed -i 's/^BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --set_hashtree_disabled_flag/#BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --set_hashtree_disabled_flag/' $BCCFILE
fi

CFILE=/ham-build/android/device/$VENDOR/sdm845-common/common.mk
# We need to add the OEM lock/unlock feature to developers options if it's not there already.
if ! grep "ro.oem_unlock_supported=1" $CFILE > /dev/null; then
   sed -i 's/^# OnePlus/# OEM Unlock reporting\nPRODUCT_DEFAULT_PROPERTY_OVERRIDES += \\\n    ro.oem_unlock_supported=1\n\n# OnePlus/' $CFILE
fi

ABFILE=/ham-build/android/device/$VENDOR/$LOS_DEVICE/AndroidBoard.mk
# Add the RADIO files to the build system.
if [ ! -f $ABFILE ]; then
   cp /ham-recipe/source/AndroidBoard.mk $ABFILE
fi

IRQFILE=/ham-build/android/device/$VENDOR/sdm845-common/rootdir/etc/init.recovery.qcom.rc
# We need to add a couple of symlinks to the recovery init script so we can flash partitions.
if ! grep "oem_stanvbk_a" $IRQFILE > /dev/null; then
   patch $IRQFILE /ham-recipe/patches/init.recovery.qcom.rc.patch
fi

IQFILE=/ham-build/android/device/$VENDOR/sdm845-common/rootdir/etc/init.qcom.rc
# We need to add a couple of symlinks to the init script so we can flash partitions.
if ! grep "oem_stanvbk_a" $IQFILE > /dev/null; then
   patch $IQFILE /ham-recipe/patches/init.qcom.rc.patch
fi

# Build WOS.
# common_build_wos


cd /ham-build/android

# Setup the build environment
source build/envsetup.sh
croot

# Setup our env variables
RELEASE_TYPE=RELEASE
export RELEASE_TYPE

TARGET_BUILD_VARIANT=user
export TARGET_BUILD_VARIANT

TARGET_PRODUCT=lineage_$LOS_DEVICE
export TARGET_PRODUCT

# Clean the build environment.
make installclean

# Start the build
echo "Running breakfast... "
breakfast $LOS_DEVICE user

# Package the files
echo "Making target packages for $DEVICE..."
mka target-files-package otatools

echo "Build process complete for $DEVICE!"

echo "Sign target APK's with prebuilt vendor partitions..."

export LOS_INTERMEDIATES_DIR=$OUT/target/product/obj/PACKAGING/target_files_intermediates

# Make sure our vendor image directory exists.
if [ ! -d /ham-build/android/device/$VENDOR/$LOS_DEVICE/images/vendor ]; then
   mkdir -p /ham-build/android/device/$VENDOR/$LOS_DEVICE/images/vendor
fi

# Get the signed vendor.img from the out directory.
cp $LOS_INTERMEDIATES_DIR/lineage_$LOS_DEVICE-target_files-eng.root/IMAGES/vendor.img /ham-build/android/device/$VENDOR/$LOS_DEVICE/images/vendor

# Check to make sure we have files to sign...
if [ -f $LOS_INTERMEDIATES_DIR/*-target_files-*.zip ]; then
   # Sign the apks.
   sign_target_files_apks -o -d /root/.android-certs --prebuilts_path /ham-build/android/device/$VENDOR/$LOS_DEVICE/images/vendor $LOS_INTERMEDIATES_DIR/*-target_files-*.zip signed-target_files.zip
else
   echo "    ...error no intermediate files found!"
   exit -1
fi

# Make sure the release directory exists.
mkdir -p /ham-output/

# Create the release file
echo "Create release file: $PKGNAME..."

if [ -f signed-target_files.zip ]; then
   ota_from_target_files -k /root/.android-certs/releasekey --block signed-target_files.zip /ham-output/$PKGNAME.zip
else
   echo "    ...error signed-target_files.zip not found!"
   exit -1
fi

# Make sure the release file exists.
if [ -f /ham-output/$PKGNAME.zip ]; then
   # Create the md5 checksum file for the release.
   echo "Create the md5 checksum..."
   # Move in to the OTA directory so md5sum doesn't add the full path to the filename during output.
   pushd $PWD
   cd /ham-output/
   md5sum $PKGNAME.zip > $PKGNAME.zip.md5sum
   popd
   
   # Grab a copy of the build.prop file.
   echo "Extract the build.prop file..."
   unzip -j signed-target_files.zip SYSTEM/build.prop
   mv build.prop /ham-output/$PKGNAME.zip.prop
   touch -r /ham-output/$PKGNAME.zip.md5sum /ham-output/$PKGNAME.zip.prop

   # Cleanup the signed target files zip.
   # echo "Store signed target files for future incremental updates..."
   # mv signed-target_files.zip ~/releases/signed_files/$LOS_DEVICE/signed-target_files-$LOS_DEVICE-$TODAY.zip
   rm -rf signed-target-files.zip
   
   # Grab a copy of the current recovery file from the signed target files.
   echo "Building recovery zip..."

   # Grab the payload file to extract the img files from.
   echo "Extracting payload.bin..."
   unzip -o -j /ham-output/$PKGNAME.zip payload.bin -d /ham-output/ > /dev/null 2>&1

   # Start by assuming there is a real recovery partition, if not, we'll use the boot.img instead.
   payload-dumper-go -o /ham-output/ -partitions recovery /ham-output/payload.bin > /dev/null 2>&1
   RECOVERYFILE="/ham-output/recovery"
   if [ ! -f $RECOVERYFILE.img ]; then
      echo "Using boot as recovery."
      payload-dumper-go -o /ham-output/ -partitions boot /ham-output/payload.bin > /dev/null 2>&1
      RECOVERYFILE="/ham-output/boot"
   else
      echo "Using recovery as recovery."
   fi
  
   # Delete the payload bin as we no longer need it.
   rm /ham-output/payload.bin

   # Build the new recovery filename for the release.
   RECOVERYNAME="/ham-output/LineageOS-19.1-$TODAY-recovery-$LOS_DEVICE"
   
   # Move and zip the recovery image to the proper release directory.
   mv $RECOVERYFILE.img $RECOVERYNAME.img
   zip -j $RECOVERYNAME.zip $RECOVERYNAME.img
   rm $RECOVERYNAME.img

   # Now add the appropriate pkmd.bin file to the recovery zip for user convenience.
   # zip -j $RECOVERYNAME.zip /root/.android-certs/pkmd.bin
else
   echo "ERROR: Release file (/ham-output/$PKGNAME.zip) not found!"
   exit -1
fi
