#!/usr/bin/env bash
set -e
VENDOR=oneplus
LOS_DEVICE=enchilada
DELETE_IMAGES="system.img vbmeta.img boot.img dtbo.img india.img reserve.img"
PREBUILT_VENDOR=true

mkdir -p /ham-build/firmware
cd /ham-build/firemware

# Create the image folder in the device tree if required.  Stores the final img files to be added to the OTA.
mkdir -p /ham-build/android/device/$VENDOR/$LOS_DEVICE/images

# Create the image_raw folder if required.  Stores the raw img files extracted from OOS.
mkdir -p images_raw

# Clean older images if found
rm -rf /ham-build/android/device/$VENDOR/$LOS_DEVICE/images/*
rm -rf /ham-build/firmware/images_raw/*
rm -ff /ham-build/firmware/vendor.img

# Make sure we're in the firmware directory to start.
cd /ham-build/firmware/

# Extract the payload.bin file from stock.
unzip -o /ham-build/stock_os/current-stock-os.zip payload.bin

# Extract img files.
python /ham-build/android/lineage/scripts/update-payload-extractor/extract.py --output_dir ./images_raw payload.bin

# Change in to the output directory.
cd images_raw

# Get rid of the images we don't need.
for IMAGE in $DELETE_IMAGES; do
   rm $IMAGE
done

# Change to the images directory.
cd /ham-build/android/device/$VENDOR/$LOS_DEVICE/images

# Copy over the raw images from OOS.
cp /ham-build/firmware/images_raw/*.img .

# Remove vendor.img as we'll pull a version with the proper hashtree after the build is run.
if [ "$PREBUILT_VENDOR" == "true" ]; then
   rm vendor.img
fi

# Return to the firmware directory.
cd /ham-build/firmware/

# If we're keeping the vendor IMG, move it to it's home now.
if [ "$PREBUILT_VENDOR" == "true" ]; then
   mv images_raw/vendor.img .
fi

# Cleanup time!
rm payload.bin
rm -rf images_raw
rm -rf /ham-build/stock_os
