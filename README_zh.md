# 适用于RK3588的Redroid镜像，包含多种功能
## 交流群
企鹅群：712725497

## 支持版本
- `Android 12(12.0.0-latest)`
- `Android 13(13.0.0-latest)`

## 支持功能
- `Gapps`  
- `Magisk(Kitsune 版)` 
- 去除`surfaceflinger`限制，可在app中输入密码（不会黑屏）  
- `虚假 WiFi` (使app认为WiFi已连接)
- `虚拟 WiFi` (有bug，已弃用)
- 预装`Via`浏览器
- 预装`LineageOS 音乐`
- 预装`LineageOS 图库`

## 前提条件
确保你的内核版本为`5.10.160`，`mali ddk`版本为`g18p0`。
```bash
cat /sys/module/bifrost_kbase/version
```
本镜像需要`mali_csffw.bin`文件才能运行，将其放置于宿主机的`/lib/firmware`下:
```bash
sudo docker cp redroid:/vendor/etc/firmware/mali_csffw.bin /lib/firmware/
sudo docker restart redroid
```  

## 运行
```bash
git clone https://github.com/CNflysky/redroid-rk3588.git --depth 1
cd redroid-rk3588
# 该脚本会检查你的运行环境是否正常，(可选)并且执行一些简单的修复措施.
./quickstart.sh

# 或者你也可以自己运行:
# 如果你使用docker-ce:
docker compose up -d
# docker.io: 
sudo apt install docker-compose
docker-compose up -d
```

欲切换版本，请编辑`docker-compose.yml`文件，修改`image`后的`tag`，随后`docker-compose down && docker-compose up -d`即可。  
**注意**: 不同版本(`Android 12`/`Android 13`)的`data`目录不能兼容，切换版本前请先备份重要数据或是修改映射目录。

手动运行：
```bash
docker run -d -p 5555:5555 -v ~/redroid-data:/data --name redroid --privileged cnflysky/redroid-rk3588:12.0.0-latest androidboot.redroid_height=1920 androidboot.redroid_width=1080
```

## 参数
| 参数 | 描述 | 默认值 |
| --- | --- | --- |
| `androidboot.redroid_fps` | 设置刷新率, 取值范围 (1,120) | 60 |
| `androidboot.redroid_magisk` | 启用 Magisk | 0 |
| `androidboot.redroid_fake_wifi` | 启用虚假 WiFi | 0 |
| `androidboot.redroid_fake_wifi_ssid` | 设置虚假 WiFi ssid | FakeWiFi |
| `androidboot.redroid_fake_wifi_bssid` | 设置虚假 WiFi bssid | 66:55:44:33:22:11 |
| `androidboot.redroid_fake_wifi_mac` | 设置虚假 WiFi mac 地址 | 11:22:33:44:55:66 |
| `androidboot.redroid_fake_wifi_speed` | 设置虚假 WiFi 速度(Mbps) | 866 |
| `androidboot.redroid_virt_wifi` | 启用虚拟 WiFi (已废弃) | 0 |
| `androidboot.redroid_adbd_bind_eth0` | 绑定adb socket到eth0上 | 1 |

# 虚拟WiFi
**注意**: 不推荐使用该功能。  
如果你想要使用`虚拟WiFi`功能:
- `mac80211_hwsim`，见下节
- 在宿主机上切换到 `iptables-legacy`
- ...或是加载 `iptable_nat` 模块: `sudo modprobe iptable_nat`

如果你的内核没有mac80211_hwsim模块支持，你可以通过以下方式来构建该模块：
```bash
# 仅armbian用户
sudo apt install linux-headers-legacy-rk35xx
cd mac80211_hwsim
make
sudo cp mac80211_hwsim.ko /lib/modules/`uname -r`/kernel/drivers/net/wireless
sudo depmod
echo "mac80211_hwsim" | sudo tee /etc/modules-load.d/redroid.conf

# 重启你的板子
```

## 额外信息
测试环境： `Orange Pi 5 Plus w/16G RAM`, 运行 `Armbian 服务器版`(`Debian 12 "Bookworm"`) ，内核版本 `5.10.160` (自定义内核)，docker版本`20.10.24`(`docker.io`).  

## 展示
### Android 12
![cap2](https://github.com/CNflysky/redroid-rk3588/assets/48781081/db89bdd0-6193-48c2-83c0-58237a0106bb)
### Android 13
![Screenshot_20240307-072908](https://github.com/CNflysky/redroid-rk3588/assets/48781081/8ebc2954-77c0-4652-916f-b9aeaa5c6878)
### Apps
![Screenshot_20240307-073014](https://github.com/CNflysky/redroid-rk3588/assets/48781081/cff7c070-7060-465c-975a-fba4da3d95c0)
![Screenshot_20240307-073006](https://github.com/CNflysky/redroid-rk3588/assets/48781081/2055090b-aea9-46bc-8564-e000e317b178)
![Screenshot_20240307-072948](https://github.com/CNflysky/redroid-rk3588/assets/48781081/52c49052-b395-4420-832a-c6009d691c97)
![Screenshot_20240307-072722](https://github.com/CNflysky/redroid-rk3588/assets/48781081/e6edcf4f-a761-47d3-8ce9-1f7d7ca194e8)
![Screenshot_20240307-072928](https://github.com/CNflysky/redroid-rk3588/assets/48781081/ff4fc29a-f3d3-4b8c-99b5-65ab96b28fcd)
