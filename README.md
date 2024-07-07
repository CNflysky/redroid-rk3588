# Redroid Image For RK3588 with Multiple Features
[Simplified Chinese(简体中文)](./README_zh.md)  

## Supported Versions
- `Android 12(12.0.0-latest)`
- `Android 13(13.0.0-latest)`

## Supported Features
- `Gapps`  
- `Magisk(Kitsune fork)` 
- Hacked `surfaceflinger` so can type password in apps without black screen
- `Fake WiFi` support (let apps believe WiFi is connected)
- `Virtual WiFi` support(buggy, deprecated)
- `Via` Browser installed
- `Lineage Music` installed
- `Lineage Gallery` installed


## Prerequisites
make sure your kernel version = `5.10.160` and `mali ddk` version = `g18p0`.
```bash
dmesg | grep DDK
```
`mali_csffw.bin` file is required, place it under host's `/lib/firmware`:

```bash
sudo docker cp redroid:/vendor/etc/firmware/mali_csffw.bin /lib/firmware/
sudo docker restart redroid
```

## Run
```bash
git clone https://github.com/CNflysky/redroid-rk3588.git --depth 1
cd redroid-rk3588
# if you use docker-ce
docker compose up -d
# or docker.io:
sudo apt install docker-compose -y
docker-compose up -d
```
manual:
```bash
docker run -d -p 5555:5555 -v ~/redroid-data:/data --name redroid --privileged cnflysky/redroid-rk3588:12.0.0-latest androidboot.redroid_height=1920 androidboot.redroid_width=1080
```
## Arguments
| Argument | Description | 
| --- | --- |
| `androidboot.redroid_fps=60` | set fps, range (1,120) |
| `androidboot.redroid_magisk=1` | enable magisk |
| `androidboot.redroid_fake_wifi=1` | enable fake WiFi |
| `androidboot.redroid_fake_wifi_ssid=FakeWiFi` | set fake WiFi ssid |
| `androidboot.redroid_fake_wifi_bssid=66:55:44:33:22:11` | set fake WiFi
bssid |
| `androidboot.redroid_fake_wifi_mac=11:22:33:44:55:66` | set fake WiFi 
mac address |
| `androidboot.redroid_fake_wifi_speed=866` | set fake WiFi speed(Mbps) |
| `androidboot.redroid_virt_wifi=1` | enable virtual WiFi |

# Virtual WiFi
If you wish use `Virtual WiFi`:
- `mac80211_hwsim`, see below
- switch to `iptables-legacy` in your host os
- ...or load `iptable_nat` module: `sudo modprobe iptable_nat`

If your kernel lacks mac80211_hwsim module, you can build it by following steps:  
```bash
# armbian user only！
sudo apt install linux-headers-legacy-rk35xx
cd mac80211_hwsim
make
sudo cp mac80211_hwsim.ko /lib/modules/`uname -r`/kernel/drivers/net/wireless
sudo depmod
echo "mac80211_hwsim" | sudo tee /etc/modules-load.d/redroid.conf

# reboot your board.
```

## Extra Info
Tested on `Orange Pi 5 Plus w/16G RAM`, OS `Armbian server` (`Debian 12 "Bookworm"`) with `5.10.160` kernel (customzied), docker version 20.10.24(`docker.io`).

## Gallery
### Android 12
![Android 12](https://github.com/CNflysky/redroid-rk3588/assets/48781081/1fb19e50-b6d7-414a-838f-93a2069a1c2c)
### Android 13
![Android 13](https://github.com/CNflysky/redroid-rk3588/assets/48781081/06336b3c-3acc-420e-afd3-40af518aa9fc)
### Apps
![Screenshot_20240307-072620](https://github.com/CNflysky/redroid-rk3588/assets/48781081/5cb921b6-ff7f-4d4b-8758-d788d91339b8)
![Screenshot_20240307-072633](https://github.com/CNflysky/redroid-rk3588/assets/48781081/308cd487-5f90-470c-88fd-4ade4973d5a5)
![Screenshot_20240307-072704](https://github.com/CNflysky/redroid-rk3588/assets/48781081/fcbe9ff0-f924-4ef8-a7f7-e4ab0ca3e020)
![Screenshot_20240307-072722](https://github.com/CNflysky/redroid-rk3588/assets/48781081/e6edcf4f-a761-47d3-8ce9-1f7d7ca194e8)
![Screenshot_20240307-072751](https://github.com/CNflysky/redroid-rk3588/assets/48781081/be2d1163-93bf-4590-a474-b5f0fadb2d20)
