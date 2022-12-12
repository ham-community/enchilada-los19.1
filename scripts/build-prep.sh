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
breakfast $LOS_DEVICE user || true

# breakfast errors for simple reasons and corrects itself,
# we don't want to simply quit for that simple thing, do we?
# So we are going to mind for errors after breakfast is run
set -e

BCFILE=/ham-build/android/device/$VENDOR/$LOS_DEVICE/BoardConfig.mk
cat /ham-recipe/source/BoardConfigAdditions.mk >> $BCFILE

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

# MindTheGapps
echo "# MindTheGapps" >> /ham-build/android/device/$VENDOR/$LOS_DEVICE/device.mk
#echo "\$(call inherit-product, vendor/gapps/arm64/arm64-vendor.mk)" >> /ham-build/android/device/$VENDOR/$LOS_DEVICE/device.mk 
echo "#include vendor/gapps/arm64/arm64-vendor.mk" >> /ham-build/android/device/$VENDOR/$LOS_DEVICE/device.mk 

true
