# Redroid Image For RK3588 with Multiple Features
[Simplified Chinese(简体中文)](./README_zh.md)  

## Supported Versions
### AOSP (userdebug build)
**Note: AOSP builds are no longer maintained.**
- `Android 12(12.0.0-latest)`
- `Android 13(13.0.0-latest)`

### LineageOS (user build)
- `LineageOS 20 (lineage-20)`

## Supported Features
Both `AOSP` build and `LineageOS` build have these features:  
- `GPU` (Mali-G610) accelerated (SW render not available)
- `Gapps`
- `Magisk (Kitsune fork)`
- `Via` Browser
- `LineageOS Trebuchet` launcher
- `LineageOS Music`
- `LineageOS Gallery`
- `surfaceflinger` patched so can type password in apps without black screen
- `Fake WiFi` (let apps believe WiFi is connected)

## Tested Devices

- `Orange Pi 5 Plus w/16G RAM`, OS `Armbian Server` (`Debian 12 "Bookworm"`) with `5.10.160` kernel (Customzied), Docker version 20.10.24(`docker.io`).
- `Orange Pi 5 Plus w/16G RAM`, OS `Ubuntu Rockchip` (`Ubuntu 22.04 "Jammy" Gnome Desktop`) with `5.10.0-1009-rockchip` kernel (Stock), Docker version 27.0.3(`docker-ce`).
- `Orange Pi 5 w/8G RAM`, OS `Armbian Desktop` (`Debian 12 "Bookworm" XFCE Desktop`) with `5.10.160` kernel (Customzied), Docker version 20.10.24(`docker.io`).

## Prerequisites
- Kernel version `5.10`
- Mali CSF GPU driver version `g18p0`
- Mali CSF Firmware in `/lib/firmware/`
- `CONFIG_PSI=y`
- `CONFIG_ANDROID_BINDERFS=y`  
You can run `envcheck.sh` script to check them.

## Run
### Using docker compose: 

#### Clone this repo: 

```bash
git clone https://github.com/CNflysky/redroid-rk3588.git --depth 1
cd redroid-rk3588
```

##### For docker-ce: 

```bash
docker compose up -d
```

##### For docker.io: 

```bash
sudo apt install docker-compose
docker-compose up -d
```

To switch between Android versions, edit the `docker-compose.yml` file, change image `tag` , then recreate service.  
**Note: The /data partitions between different Android versions are not compatible. Before switching to another Android version, please backup critical data or change mapping volume of /data partition.**

### Manual: 

```bash
docker run -d -p 5555:5555 -v ~/redroid-data:/data --restart unless-stopped --name redroid --privileged cnflysky/redroid-rk3588:12.0.0-latest androidboot.redroid_height=1920 androidboot.redroid_width=1080
```

## Arguments

| Argument | Description | Default | Note |
| --- | --- | --- | --- |
| `androidboot.redroid_fps` | set fps, range (1,120) | 60 | |
| `androidboot.redroid_magisk` | enable magisk | 0 | |
| `androidboot.redroid_fake_wifi` | enable fake WiFi | 0 | |
| `androidboot.redroid_fake_wifi_ssid` | set fake WiFi ssid | FakeWiFi | |
| `androidboot.redroid_fake_wifi_bssid` | set fake WiFi bssid | 66:55:44:33:22:11 | |
| `androidboot.redroid_fake_wifi_mac` | set fake WiFi mac address | 11:22:33:44:55:66 | |
| `androidboot.redroid_fake_wifi_speed` | set fake WiFi speed(Mbps) | 866 | |
| `androidboot.redroid_adbd_bind_eth0` | bind adb socket to eth0 | 1 | |
| `ro.adb.secure` | enable ADB authentication | 0 | `LineageOS` default is 1 |
| `androidboot.redroid_create_secure_display` | create secure display | 1 | only available in `LineageOS` |

(0 = disable, 1 = enable)

## Documentation
[Google Play Certification](https://github.com/CNflysky/redroid-rk3588/wiki/en:-Google-Play-Certification)  
[Enable ADB authentication](https://github.com/CNflysky/redroid-rk3588/wiki/en:-Enable-ADB-authentication)  
[App compatibility list](https://github.com/CNflysky/redroid-rk3588/discussions/8)  
[About Fake WiFi](https://github.com/CNflysky/redroid-rk3588/wiki/en:-About-FakeWiFi)  
[Switch device type](https://github.com/CNflysky/redroid-rk3588/wiki/en:-Switch-device-type)

## Screenshots

### Android 12
![Android 12](https://github.com/CNflysky/redroid-rk3588/assets/48781081/1fb19e50-b6d7-414a-838f-93a2069a1c2c)
### Android 13
![Android 13](https://github.com/CNflysky/redroid-rk3588/assets/48781081/06336b3c-3acc-420e-afd3-40af518aa9fc)
### Apps
![Screenshot_20240307-072620](https://github.com/CNflysky/redroid-rk3588/assets/48781081/5cb921b6-ff7f-4d4b-8758-d788d91339b8)
![Screenshot_20240307-072633](https://github.com/CNflysky/redroid-rk3588/assets/48781081/308cd487-5f90-470c-88fd-4ade4973d5a5)
![Screenshot_20240307-072722](https://github.com/CNflysky/redroid-rk3588/assets/48781081/e6edcf4f-a761-47d3-8ce9-1f7d7ca194e8)
![Screenshot_20240307-072751](https://github.com/CNflysky/redroid-rk3588/assets/48781081/be2d1163-93bf-4590-a474-b5f0fadb2d20)
