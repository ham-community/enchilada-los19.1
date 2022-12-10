#!/usr/bin/env bash

mkdir -p /ham-build/android/vendor/extra

echo "# Override the updater URL." >> /ham-build/android/vendor/extra/product.mk
echo 'PRODUCT_PROPERTY_OVERRIDES += \' >> /ham-build/android/vendor/extra/product.mk
echo '    lineage.updater.uri='$UPDATER_URL'' >> /ham-build/android/vendor/extra/product.mk
echo "" >> /ham-build/android/vendor/extra/product.mk
cat /ham-recipe/source/product.mk >> /ham-build/android/vendor/extra/product.mk
