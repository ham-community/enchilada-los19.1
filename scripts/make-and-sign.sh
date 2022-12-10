#!/usr/bin/env bash
set -e
VENDOR=oneplus
LOS_DEVICE=enchilada

TODAY=$(date +"%Y%m%d")
OUT=/ham-build/android/out/target/product/$LOS_DEVICE
PKGNAME=lineage-19.1-$TODAY-release-$LOS_DEVICE-signed

export PATH=$PATH:/ham-build/android/out/host/linux-x86:/ham-build/android/out/host/linux-x86/bin:/ham-build/android/build/make/tools/releasetools:/ham-build/android/out/soong/host/linux-x86/bin

# Add the LOS java library paths to the environment.
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/ham-build/android/out/host/linux-x86/lib:/ham-build/android/out/host/linux-x86/lib64

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

breakfast $LOS_DEVICE user

# Package the files
echo "Making target packages for $DEVICE..."
mka target-files-package otatools

echo "Build process complete for $DEVICE!"

echo "Sign target APK's with prebuilt vendor partitions..."

export LOS_INTERMEDIATES_DIR=/ham-build/android/out/target/product/$LOS_DEVICE/obj/PACKAGING/target_files_intermediates

# Make sure our vendor image directory exists.
mkdir -p /ham-build/android/device/$VENDOR/$LOS_DEVICE/images/vendor

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
