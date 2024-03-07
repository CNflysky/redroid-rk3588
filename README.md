# Redroid Image For RK3588 with Multiple Features
[Simplified Chinese(简体中文)](./README_zh.md)  

## Supported Versions
- `Android 12(12.0.0-latest)`
- `Android 13(13.0.0-latest)`

## Supported Features
- `Gapps`  
- `Magisk(Kitsune fork)` 
- Hacked `surfaceflinger` so can type password in apps without black screen
- `Virtual WiFi` support
- `Via` Browser installed

## Prerequisites
make sure your kernel version = `5.10.160` and `mali ddk` version = `g18p0`.
```bash
dmesg | grep DDK
```
`mali_csffw.bin` file is required to run this image, place it under host's `/lib/firmware`.  
You can find `mali_csffw.bin` at container's `/vendor/etc/firmware`.  
If you wish use `Virtual Wifi`, you must make sure your host's kernel has `mac80211_hwsim` module support.  

## Run
```bash
# change image name if you wish use Android 13
docker run -d -p 5555:5555 -v ~/redroid-data:/data --name redroid --privileged cnflysky/redroid-rk3588:12.0.0-latest androidboot.redroid_height=1920 androidboot.redroid_width=1080
```
add `androidboot.redroid_virt_wifi=1` argument to enable Virtual WiFi.

## Other
Tested on `Orange Pi 5 Plus w/16G RAM`，running `Armbian` with `5.10.160` kernel (customzied).

