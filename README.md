# LineageOS 19.1 (Enchilada/OnePlus 6)

Ham Recipe for building LineageOS 19.1 for OnePlus 6 (Enchilada) (Signed Builds). With this build
you can relock your Bootloader and still use LineageOS. 

This branch of the ham recipe builds MindTheGapps right into your ROM so you can still use Google Play
Store with your signed build instead of patching it in a hacky way. Also this enables you to lock your
bootloader along with the GAPPS working just fine.

# How to Build

Install [Hetzner Android Make](https://github.com/antony-jr/ham) and Initialize then,

```
 ham get ~@gh/enchilada-los19.1:gapps
```

# Credits

Most of the build scripts and patches are inspired from [Wunderment OS](https://github.com/Wunderment).
