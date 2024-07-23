# 适用于RK3588的Redroid镜像，包含多种功能
## 交流群
企鹅群：712725497

## 支持安卓版本
- `Android 12(12.0.0-latest)`
- `Android 13(13.0.0-latest)`

## 支持功能
- 预装`Gapps`  
- 预装`Magisk Kitsune版`（部分工作） 
- 预装`Via`浏览器
- 预装`LineageOS 音乐`
- 预装`LineageOS 图库`
- 预装`LineageOS Trebuchet`启动器
- 去除`surfaceflinger`限制，可在App中输入密码（不会因安全限制而黑屏）  
- `虚假 WiFi` （使App认为WiFi已连接）

## 测试环境

- `Orange Pi 5 Plus w/16G RAM` ，运行 `Armbian 服务器版`（`Debian 12 "Bookworm"`） ，内核版本 `5.10.160` （自定义内核），Docker版本`20.10.24`（`docker.io`）。 
- `Orange Pi 5 Plus w/16G RAM` ，运行 `Ubuntu Rockchip`（`Ubuntu 22.04 "Jammy" Gnome 桌面`) ，内核版本 `5.10.0-1009-rockchip` （默认自带内核），Docker版本`27.0.3`（`docker-ce`）。
- `Orange Pi 5 w/8G RAM` ，运行 `Armbian 桌面版`（`Debian 12 "Bookworm" XFCE 桌面`） ，内核版本 `5.10.160` （自定义内核），Docker版本`20.10.24`（`docker.io`）。  

## 系统要求
- 内核版本 `5.10`
- Mali CSF 内核驱动 `g18p0`
- Mali 固件，置于`/lib/firmware/`下
- `CONFIG_PSI=y`
- `CONFIG_ANDROID_BINDERFS=y`  
提示: 你可以运行`envcheck.sh`来检查。


## 运行
### Docker Compose：

#### 克隆项目：

```bash
git clone https://github.com/CNflysky/redroid-rk3588.git --depth 1
cd redroid-rk3588
```

##### 如果你使用docker-ce：
```bash
docker compose up -d
```
##### 如果你使用docker.io：
```bash
sudo apt install docker-compose
docker-compose up -d
```

欲切换版本，请编辑 `docker-compose.yml` 文件，修改 `image` 后的 `tag` ，随后 `docker-compose down && docker-compose up -d` 即可。  
**注意**: 不同版本（`Android 12`/`Android 13`）的`data`目录不能兼容，切换版本前请先备份重要数据或是修改安卓容器内用户数据分区的映射目录。

### 手动运行：
```bash
docker run -d -p 5555:5555 -v ~/redroid-data:/data --restart unless-stopped --name redroid --privileged cnflysky/redroid-rk3588:12.0.0-latest androidboot.redroid_height=1920 androidboot.redroid_width=1080
```

其中，`-v` 参数值 `~/redroid-data:/data` 中冒号前的部分`~/redroid-data` 代表你要在宿主机的哪个位置存放安卓容器内的`用户数据`(也就是`/data`目录)，可以根据自己的需求更改。

## 参数

| 参数 | 描述 | 默认值 |
| --- | --- | --- |
| `androidboot.redroid_fps` | 设置刷新率, 取值范围 (1,120) | 60 |
| `androidboot.redroid_magisk` | 是否启用 Magisk | 0 |
| `androidboot.redroid_fake_wifi` | 是否启用虚假 WiFi | 0 |
| `androidboot.redroid_fake_wifi_ssid` | 设置虚假 WiFi SSID | FakeWiFi |
| `androidboot.redroid_fake_wifi_bssid` | 设置虚假 WiFi BSSID | 66:55:44:33:22:11 |
| `androidboot.redroid_fake_wifi_mac` | 设置虚假 WiFi MAC 地址 | 11:22:33:44:55:66 |
| `androidboot.redroid_fake_wifi_speed` | 设置虚假 WiFi 速度(Mbps) | 866 |
| `androidboot.redroid_adbd_bind_eth0` | 是否绑定ADB Socket到eth0上 | 1 |
| `ro.adb.secure` | 是否启用ADB调试授权认证 | 0 |

（0代表不启用，1代表启用，不添加某参数即代表生效该参数的默认值）

## 文档
[Google Play保护机制认证](https://github.com/CNflysky/redroid-rk3588/wiki/zh:-Google-Play%E4%BF%9D%E6%8A%A4%E6%9C%BA%E5%88%B6%E8%AE%A4%E8%AF%81)  
[启用ADB授权](https://github.com/CNflysky/redroid-rk3588/wiki/zh:-%E5%90%AF%E7%94%A8ADB%E6%8E%88%E6%9D%83)  
[App兼容列表](https://github.com/CNflysky/redroid-rk3588/discussions/8)

## 截图展示

### Android 12
![cap2](https://github.com/CNflysky/redroid-rk3588/assets/48781081/db89bdd0-6193-48c2-83c0-58237a0106bb)
### Android 13
![Screenshot_20240307-072908](https://github.com/CNflysky/redroid-rk3588/assets/48781081/8ebc2954-77c0-4652-916f-b9aeaa5c6878)
### Apps
![Screenshot_20240307-073014](https://github.com/CNflysky/redroid-rk3588/assets/48781081/cff7c070-7060-465c-975a-fba4da3d95c0)
![Screenshot_20240307-073006](https://github.com/CNflysky/redroid-rk3588/assets/48781081/2055090b-aea9-46bc-8564-e000e317b178)
![Screenshot_20240307-072722](https://github.com/CNflysky/redroid-rk3588/assets/48781081/e6edcf4f-a761-47d3-8ce9-1f7d7ca194e8)
![Screenshot_20240307-072928](https://github.com/CNflysky/redroid-rk3588/assets/48781081/ff4fc29a-f3d3-4b8c-99b5-65ab96b28fcd)
