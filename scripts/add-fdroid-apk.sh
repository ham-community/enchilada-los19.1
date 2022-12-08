#!/usr/bin/env bash

cd /ham-build/android/packages/apps

mkdir F-Droid
cd F-Droid

cp /ham-recipe/source/F-Droid-Android.mk /ham-build/android/packages/apps/F-Droid/Android.mk
cp /ham-build/apks/current-f-droid.apk F-Droid.apk

