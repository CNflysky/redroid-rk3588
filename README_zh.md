# 适用于RK3588的Redroid镜像，包含多种功能

## 支持版本
- `Android 12(12.0.0-latest)`
- `Android 13(13.0.0-latest)`

## 支持功能
- `Gapps`  
- `Magisk(Kitsune 版)` 
- 去除`surfaceflinger`限制，可在app中输入密码（不会黑屏）  
- `虚拟 WiFi`
- 预装`Via`浏览器

## 前提条件
确保你的内核版本为`5.10.160`，`mali ddk`版本为`g18p0`。
```bash
dmesg | grep DDK
```
本镜像需要`mali_csffw.bin`文件才能运行，将其放置于宿主机的`/lib/firmware`下即可。  
你可以在容器的`/vendor/etc/firmware` 目录中找到它。  

如果你想要使用`虚拟WiFi`功能，请确保宿主机上有`mac80211_hwsim`内核模块支持。

## 运行
```bash
# 欲使用Android 13,请修改镜像名。
docker run -d -p 5555:5555 -v ~/redroid-data:/data --name redroid --privileged cnflysky/redroid-rk3588:12.0.0-latest androidboot.redroid_height=1920 androidboot.redroid_width=1080
```
欲使用虚拟WiFi，请于命令最后添加 `androidboot.redroid_virt_wifi=1` 参数。

## 其它
测试环境： `Orange Pi 5 Plus w/16G 内存`, 运行 `Armbian` ，内核版本 `5.10.160` (自定义内核).  

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
