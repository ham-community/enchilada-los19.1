#!/usr/bin/env bash

wget -O index.html -q https://f-droid.org/en/packages/org.fdroid.fdroid/

# Get the first url to the f-droid apk.
grep -m 1 "https://f-droid.org/repo/org.fdroid.fdroid_.*.apk" index.html > new_url.txt
sed -i 's/\s*//' new_url.txt
sed -i 's/<a href="//' new_url.txt
sed -i 's/">//' new_url.txt

# Delete the index file as it's no longer needed.
rm index.html

FDROIDURL=$(<new_url.txt)
rm -rf current-f-droid.apk
wget -q -O current-f-droid.apk $FDROIDURL
rm -rf new_url.txt
