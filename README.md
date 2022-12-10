# LineageOS 19.1 (Enchilada/OnePlus 6)

Ham Recipe for building LineageOS 19.1 for OnePlus 6 (Enchilada) (Signed Builds). With this build
you can relock your Bootloader and still use LineageOS. 

This build only includes LineageOS itself and F-Droid Priv Extension but does not include the F-Droid
APK itself. You can download the APK manually and install which will automatically use the priv extension.
This build does not includ openGAPPS. If you attempt to patch it with the regular method and lock your device
you will brick your device.

To get a build with gapps micro use the tag ```gapps``` with Ham, like this,

```
 ham get ~@gh/enchilada-los19.1:gapps
```

# How to Build

Install [Hetzner Android Make](https://github.com/antony-jr/ham) and Initialize then,

```
 ham get ~@gh/enchilada-los19.1
```

# Credits

Most of the build scripts and patches are inspired from [Wunderment OS](https://github.com/Wunderment).
