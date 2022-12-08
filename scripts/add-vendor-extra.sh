#!/usr/bin/env bash

contents="# Override the updater URL.
PRODUCT_PROPERTY_OVERRIDES += \
    lineage.updater.uri="$UPDATER_URL"

# Add F-Droid and it's privilege extension.
PRODUCT_PACKAGES += \
    F-DroidPrivilegedExtension \
    F-Droid

# Remove the lineage signing keys from the recovery build, we only want ours here which get autoamtically
# added during the signing process.
PRODUCT_EXTRA_RECOVERY_KEYS :=
"

mkdir -p /ham-build/android/vendor/extra

echo $contents > /ham-build/android/vendor/extra/product.mk
