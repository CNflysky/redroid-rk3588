# redroid-rk3588
_Redroid images for Rockchip RK3588 series SoC_  
![Screenshot](https://github.com/user-attachments/assets/6c6d2b7c-d9a3-4e9c-aa51-7fc23aaa571d)

[zh_CN(简体中文)](./README_zh.md)  

## Supported Versions

### LineageOS (user build)
- `LineageOS 20 (lineage-20)`

AOSP builds [here](#deprecated-builds)
## Supported Features 
- `GPU` (Mali-G610) accelerated (SW render not available)
- `Gapps`
- `Magisk (Kitsune fork)`
- `surfaceflinger` patched so can type password in apps without black screen
- `Fake WiFi` (let apps believe WiFi is connected)
- `scrcpy physical keyboard/mouse emulation` support

## Tested Devices

- `Orange Pi 5 Plus w/16G RAM`, OS `Armbian Server` (`Debian 12 "Bookworm"`) with `5.10.160` kernel (Customzied), Docker version 20.10.24(`docker.io`).
- `Orange Pi 5 Plus w/16G RAM`, OS `Ubuntu Rockchip` (`Ubuntu 22.04 "Jammy" Gnome Desktop`) with `5.10.0-1009-rockchip` kernel (Stock), Docker version 27.0.3(`docker-ce`).
- `Orange Pi 5 w/8G RAM`, OS `Armbian Desktop` (`Debian 12 "Bookworm" XFCE Desktop`) with `5.10.160` kernel (Customzied), Docker version 20.10.24(`docker.io`).

## Prerequisites
- Kernel version `5.10`/`6.1` (customized 6.1 [kernel](https://github.com/CNflysky/linux-rockchip) required)
- Mali CSF GPU driver version `g18p0`
- Mali CSF Firmware in `/lib/firmware/`
- `CONFIG_PSI=y`
- `CONFIG_ANDROID_BINDERFS=y` 
- Android specific `DMA-BUF` device support

You can run `envcheck.sh` script to check them.

## Deploy
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
docker run -d -p 5555:5555 -v ~/redroid-data:/data --restart unless-stopped --name redroid --privileged cnflysky/redroid-rk3588:lineage-20 androidboot.redroid_height=1920 androidboot.redroid_width=1080
```

## Arguments

| Argument | Description | Default |
| --- | --- | --- |
| `androidboot.redroid_fps` | set fps, range (1,120) | 60 |
| `androidboot.redroid_magisk` | enable magisk | 0 |
| `androidboot.redroid_fake_wifi` | enable fake WiFi | 0 |
| `androidboot.redroid_fake_wifi_ssid` | set fake WiFi ssid | FakeWiFi |
| `androidboot.redroid_fake_wifi_bssid` | set fake WiFi bssid | 66:55:44:33:22:11 |
| `androidboot.redroid_fake_wifi_mac` | set fake WiFi mac address | 11:22:33:44:55:66 |
| `androidboot.redroid_fake_wifi_speed` | set fake WiFi speed(Mbps) | 866 |
| `androidboot.redroid_adbd_bind_eth0` | bind adb socket to eth0 | 1 |
| `ro.adb.secure` | enable ADB authentication | 1 |
| `androidboot.redroid_create_secure_display` | create secure display by default | 1 |
| `androidboot.redroid_enable_input_subsys` | enable input subsystem | 0 |

(0 = disable, 1 = enable)

## Documentation
[Google Play Certification](https://github.com/CNflysky/redroid-rk3588/wiki/en:-Google-Play-Certification)  
[Enable ADB authentication](https://github.com/CNflysky/redroid-rk3588/wiki/en:-Enable-ADB-authentication)  
[App compatibility list](https://github.com/CNflysky/redroid-rk3588/discussions/8)  
[About Fake WiFi](https://github.com/CNflysky/redroid-rk3588/wiki/en:-About-FakeWiFi)  
[Switch device type](https://github.com/CNflysky/redroid-rk3588/wiki/en:-Switch-device-type)  
[scrcpy physical keyboard/mouse emulation](https://github.com/CNflysky/redroid-rk3588/wiki/en:-scrcpy-physical-keyboard-mouse-emulation)

## Deprecated builds
### AOSP (userdebug build)
**Note: AOSP builds are no longer maintained.**
- `Android 12(12.0.0-latest)`
- `Android 13(13.0.0-latest)`
