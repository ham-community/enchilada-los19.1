#!/usr/bin/env bash

sed -i 's/PRODUCT_EXTRA_RECOVERY_KEYS += \\/PRODUCT_EXTRA_RECOVERY_KEYS :=/' /ham-build/android/vendor/lineage/config/common.mk
sed -i 's/    vendor\/lineage\/build\/target\/product\/security\/lineage//' /ham-build/android/vendor/lineage/config/common.mk
