# I have no idea why this is required.
# PRODUCT_BROKEN_VERIFY_USES_LIBRARIES := true

# Seems to be a lot of trouble to get F-Droid Directly
# installed in the ROM. I might be doing something
# wrong but let's see.
# Add F-Droid and it's privilege extension.
PRODUCT_PACKAGES += F-DroidPrivilegedExtension
#    F-Droid

# Remove the lineage signing keys from the recovery build, we only want ours here which get autoamtically
# added during the signing process.
PRODUCT_EXTRA_RECOVERY_KEYS :=

