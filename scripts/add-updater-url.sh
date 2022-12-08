#!/usr/bin/env bash

if [[ -z "$UPDATER_URL" ]]; then
   exit 0
fi

cd /ham-build/android/build/tools
# Replace / -> \/ to escape in sed
# You can use {device}
# {type}, {incr} which are all provided by lineageOS.
sed -i 's/echo "# end build properties"/echo "# Set the updater URI"\necho "lineage.updater.uri='$UPDATER_URL'"\n\necho "# end build properties"/' buildinfo.sh
