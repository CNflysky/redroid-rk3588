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
- `虚拟 WiFi` （有Bug，已弃用）

## 测试环境

- `Orange Pi 5 Plus w/16G RAM` ，运行 `Armbian 服务器版`（`Debian 12 "Bookworm"`） ，内核版本 `5.10.160` （自定义内核），Docker版本`20.10.24`（`docker.io`）。 
- `Orange Pi 5 Plus w/16G RAM` ，运行 `Ubuntu Rockchip`（`Ubuntu 22.04 "Jammy" Gnome Desktop`) ，内核版本 `5.10.0-1009-rockchip` （默认自带内核），Docker版本`27.0.3`（`docker-ce`）。

## 前提条件

确保你的内核版本为`5.10`，通过以下命令查询`Mali DDK`版本是否为`g18p0`。
```bash
cat /sys/module/bifrost_kbase/version
```
本镜像需要`mali_csffw.bin`固件文件才能运行，一些系统默认自带该固件（例如Ubuntu Rockchip）。请检查宿主机是否存在`/usr/lib/firmware/mali_csffw.bin`，若无或通过以上命令查询到的`Mali DDK`版本不为`g18p0`，请[获取合适版本](https://github.com/CNflysky/redroid-rk3588/blob/main/firmware_g610/mali_csffw.bin)并将其放置（或覆盖）于宿主机的`/usr/lib/firmware/`下，然后重启系统：
```bash
wget https://github.com/CNflysky/redroid-rk3588/blob/main/firmware_g610/mali_csffw.bin
sudo chown root:root mali_csffw.bin
sudo chmod 644 mali_csffw.bin
sudo mv mali_csffw.bin /usr/lib/firmware/mali_csffw.bin
sudo reboot
```

## 运行
### Docker Compose：

#### 首先，克隆此项目到本地：

```bash
git clone https://github.com/CNflysky/redroid-rk3588.git --depth 1
cd redroid-rk3588
```

#### 检查运行环境并运行容器：
```bash
# 该脚本会检查你的运行环境是否正常，（可选）并且执行一些简单的修复措施。
./quickstart.sh
```

#### 跳过检查运行环境直接运行容器：
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

其中，`-v` 参数值 `~/redroid-data:/data` 中冒号前的部分`~/redroid-data` 代表你要在宿主机的哪个位置存放安卓容器内的用户数据分区，可以根据自己的需求更改。

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
| `androidboot.redroid_virt_wifi` | 是否启用虚拟 WiFi (已废弃) | 0 |
| `androidboot.redroid_adbd_bind_eth0` | 是否绑定ADB Socket到eth0上 | 1 |
| `ro.adb.secure` | 是否启用ADB调试授权认证 | 0 |

（0代表不启用，1代表启用，不添加某参数即代表生效该参数的默认值）

## ~~虚拟WiFi（已弃用）~~

**注意**: **不推荐使用该功能。**

 如果你仍然想要使用`虚拟WiFi`功能，你需要：

- 如果你的内核没有 `mac80211_hwsim` 模块支持，你需要编译 `mac80211_hwsim` 内核模块，见下节
- 在宿主机上切换到 `iptables-legacy`（或是加载 `iptable_nat` 模块： `sudo modprobe iptable_nat`）

你可以通过以下方式来构建该模块：
```bash
# 仅Armbian通过测试
# 首先确保已经克隆本项目到本地
sudo apt install linux-headers-legacy-rk35xx
cd mac80211_hwsim
make
sudo cp mac80211_hwsim.ko /lib/modules/`uname -r`/kernel/drivers/net/wireless
sudo depmod
echo "mac80211_hwsim" | sudo tee /etc/modules-load.d/redroid.conf

# 重启你的开发板
sudo reboot
```

## 可选操作

### 通过Google Play保护机制认证

**注意：该操作只能让你能够通过Google Play保护机制认证来正常使用谷歌商店，但并不能通过SafetyNet认证。高安全性应用例如奈飞等，仍然无法出现在商店列表。**

首次启动Redroid后，你会发现无法登录使用谷歌商店，提示未通过Google Play保护机制认证。你可以通过以下方式自助注册以通过认证：

1. 通过 `adb connect` 命令远程连接到Redroid容器的ADB后执行：

```bash
# 切换adb守护进程至root
adb root
# 打开Redroid容器的Shell控制台
adb shell
# 在控制台中执行以下命令获取Google 服务框架 Android ID
sqlite3 /data/user/$(cmd activity get-current-user)/*/*/gservices.db \
    "select * from main where name = \"android_id\";"
```

2. 此时你会得到l类似于 `android_id|4525296753567226663` 的字符串，复制`|`后面的数串保留备用。
2. 打开[此链接](https://www.google.com/android/uncertified)，登录你的谷歌账号，在网页中填写你刚才复制的数串提交即可。
2. 等待至少10分钟（多则一天）后重启容器，再次尝试登录谷歌商店，即可正常使用。

### 开启ADB授权验证以提高安全性（推荐）

为了方便用户连接到Redroid，本容器镜像默认停用了ADB授权验证（即“允许ADB调试吗”授权验证窗口），能连接到宿主机的任意设备都将能访问到Redroid容器。同时由于Redroid需要调用宿主GPU硬件加速，安卓容器在启动时附加了特权模式（--privileged），但这会导致在未授权访问下遭到恶意提权攻击。

**因此，强烈建议你在首次正常启动容器后，立即附加ADB授权验证以提高安全性。尤其是想把容器投放到公网进行随时随地远程访问的用户。**

以下是开启ADB授权验证的方法（需要通过PC进行操作）：

1. **首先确保Redroid容器已能成功运行，并可以通过ADB命令和Scrcpy远程投屏连接到容器。**

2. 在PC上查找用户目录下是否存在 `.android` 文件夹（Win用户可以直接在文件资源管理的地址栏输入 `%USERPROFILE%\.android` 并回车，Linux用户查找是否存在隐藏的 `~/.android` 目录），如果有，直接进行第3步；若没有，请先通过 `adb connect`和`adb shell `命令、Scrcpy远程投屏尝试远程访问一次Redroid容器，此时即可在对应的用户目录中自动生成 `.android` 文件夹。

3. 打开 `.android `文件夹，利用文本编辑器打开 `adbkey.pub `文件，复制文件中的所有内容供下面步骤使用。其内容类似于：

   ```bash
   QAAAAAvP/Jhd+xuFaJk/5KdV9be7nRLyqWwKvW8FTKadafqrqALiyEQ1jcdGUHTcAGix9WB7XfHQXq/l8WeSCzqsim6WTSZdqf4PnLmrklgfRAkV6sDewAPpEJf7N7hZcpCy+CBsGVngP3gqmEf8aRqj78UadafafKRTaBIxLxyGxt6u4SiujeV0/JwrroNKxONmt8+dlW3+y6K8WTkkr4tDcLYM47Ambv8yYP4QVxYPc8b6Zp1usWFY/sJXM62BbPqgIznO7eWj6afafC7tcn9ErcRsvSyU+KKNMspMTzWHKrtZ8loR6IdUME9TJZ8JicDdh1xZ/rbvi8t5Z5pumtEYpxbeuPyBWvwRFbiFYcp00HAht0bcV4i1OUAnB1T6Bwafa4etd3bEnXQUggLjEkRiSS/rYSM0mKzhc9FiowIkQK5wkh1IlP5dZ6eCQsJgH/vArmYFLKZc1I6h7oJixkCm6f1bUNeVSioPBYWiBrjxX3BZsE0jb31A3hXRNo9qNOwqzGL7ND1m1a/LQrQdpYAEAAQA= ASUS@LAPTOP-5TNUYI14
   ```

4. 通过图形化桌面或者SSH登录连接到Redroid所在的宿主机，进入“运行”步骤中你在`-v`参数后所设定的Redroid容器内用户数据分区的映射目录，再依次进入其中 `misc` 目录下的 `adb` 目录。

5. 在该目录下，新建一个名为 `adb_keys` 的无后缀文件，通过文本编辑器编辑，将第三步中复制的内容粘贴进改文件并保存。

6. 修改该文件的属组属主和权限掩码以供容器能正常识别到：

   ```bash
   sudo chmod 640 adb_keys
   sudo chown $USER:$USER adb_keys
   ```

7. 附加 `ro.adb.secure=1` 参数来重建开启了ADB授权认证的容器：

   ```bash
   # 首先删除现有Redroid容器，请根据实际自己给容器的命名来输入命令。删除现有容器不会丢失容器内用户数据分区的映射目录中的持久化数据
   docker container rm redroid
   # 直接在你先前在“运行”步骤中执行的容器启动命令后加入ro.adb.secure=1参数即可重建开启了ADB授权的容器。例如：
   docker run -d -p 5555:5555 -v ~/redroid-data:/data --restart unless-stopped --name redroid --privileged cnflysky/redroid-rk3588:12.0.0-latest androidboot.redroid_height=1920 androidboot.redroid_width=1080 ro.adb.secure=1
   ```

8. 至此，Redroid容器已经开启了ADB授权验证，除了你刚才用于开启操作的这台PC可以连接到容器，其他未经授权的远程设备都将拒绝连接到容器。此时，你应该利用这台PC通过Scrcpy远程投屏连接到Redroid，然后让你未来想要远控的设备都尝试连接到Redroid容器一次，来触发授权验证弹窗，并通过Scrcpy同意这些设备的连接，相当于加入了白名单，后期这些远程设备才有权限访问。**切记不要随意在开发者选项中撤销所有ADB授权，否则任何远程设备都将不能连接到容器，需要重复1-6步骤才能恢复访问。**

### Magisk使用说明

- 通过参数开启支持Magisk的Redroid容器后，首次打开并使用Magisk时会提示附加安装，根据提示确定并等待容器自动重启即可正常使用。

- 模块安装功能基本可以正常使用，但鉴于模块适配机型不同和Redroid容器环境的特殊性，部分模块可能无法正常使用。

- **警告！目前MagiskHide功能无法正常工作，开启后会导致应用程序卡Splash界面。请不要尝试打开此开关，会无法轻易还原到未打开状态。**

## 截图展示

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
