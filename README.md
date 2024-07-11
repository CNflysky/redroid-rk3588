# Redroid Image For RK3588 with Multiple Features
Notice: The English version may fall behind the Chinese version, please prioritize reading the Chinese version or wait for updates.

提示：英文版本说明可能落后于中文版本，请优先阅读中文版本或者等待更新。

[Simplified Chinese(简体中文)](./README_zh.md)  

## Supported Versions
- `Android 12(12.0.0-latest)`
- `Android 13(13.0.0-latest)`

## Supported Features
- `Gapps` preinstalled
- `Magisk Kitsune fork` preinstalled (partial working)
- `Via` Browser preinstalled
- `LineageOS Trebuchet` launcher preinstalled
- `LineageOS Music` preinstalled
- `LineageOS Gallery` preinstalled
- `surfaceflinger` patched so can type password in apps without black screen
- `Fake WiFi` support (let apps believe WiFi is connected)
- ~~`Virtual WiFi` support(buggy, deprecated)~~

## Tested Environment

- Tested on `Orange Pi 5 Plus w/16G RAM`, OS `Armbian Server` (`Debian 12 "Bookworm"`) with `5.10.160` kernel (Customzied), Docker version 20.10.24(`docker.io`).
- Tested on `Orange Pi 5 Plus w/16G RAM`, OS `Ubuntu Rockchip` (`Ubuntu 22.04 "Jammy" Gnome Desktop`) with `5.10.0-1009-rockchip` kernel (Stock), Docker version 27.0.3(`docker-ce`).

## Prerequisites

Ensure that your kernel version is `5.10` , and use the following command to check if the `Mali DDK` version is `g18p0` :
```bash
cat /sys/module/bifrost_kbase/version
```
This image requires the `mali_csffw.bin` firmware file to run, and some systems come with this firmware by default (such as [Ubuntu Rockchip](https://joshua-riek.github.io/ubuntu-rockchip-download/)). Please check if the host machine has `/var/lib/firmware/mali_csffw.bin` . If not, or if the `Mali DDK` version found through the above command is not `g18p0` , please [obtain the appropriate version]( https://github.com/CNflysky/redroid-rk3588/blob/main/firmware_g610/mali_csffw.bin) and place (or overwrite) it in the host's `/var/lib/firmware/` folder, then restart the system: 

```bash
wget https://github.com/CNflysky/redroid-rk3588/blob/main/firmware_g610/mali_csffw.bin
sudo chown root:root mali_csffw.bin
sudo chmod 644 mali_csffw.bin
sudo mv mali_csffw.bin /usr/lib/firmware/mali_csffw.bin
sudo reboot
```

## Run Container
### Docker Compose: 

#### Firstly, clone this project locally: 

```bash
git clone https://github.com/CNflysky/redroid-rk3588.git --depth 1
cd redroid-rk3588
```

#### Check the OS prerequisites and run the container: 

```bash
# This script will check if your OS is matching the prerequisites and try to perform some repair measures, then run container (optional)
./quickstart.sh
```

#### Skip checking the OS and run the container directly: 

##### If you are using docker-ce: 

```bash
docker compose up -d
```

##### If you are using docker.io: 

```bash
sudo apt install docker-compose
docker-compose up -d
```

To switch versions, please edit the `docker compose. yml` file, modify the `tag` after `image` , and then execute `docker compose down && docker compose up - d` . 
**Note: The data directory of different versions (Android 12/Android 13) is not compatible. Before switching versions, please backup important data or modify the mapping directory of user data partitions about the container.**

### Docker Run: 

```bash
docker run -d -p 5555:5555 -v ~/redroid-data:/data --restart unless-stopped --name redroid --privileged cnflysky/redroid-rk3588:12.0.0-latest androidboot.redroid_height=1920 androidboot.redroid_width=1080
```

Among them, the ` -v ` parameter value `~/redroid data:/data` before the colon `~/redroid data`  represents where you want to store the user data partition in the Android container on the host, which can be changed according to your own favor.

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
| `androidboot.redroid_virt_wifi` | enable virtual WiFi (deprecated) | 0 |
| `androidboot.redroid_adbd_bind_eth0` | bind adb socket to eth0 | 1 |
| `ro.adb.secure` | enable ADB debugging authorization | 0 |

(0 means not enabled, 1 means enabled, not adding a parameter means the default value of that parameter is effective.)

# ~~Virtual WiFi(deprecated)~~

**Notice: Use of this feature is not recommended. **

If you still wish use `Virtual WiFi`:

- If your kernel does not support the `mac80211_ hwsim` module, you need to compile the `mac80211_ hwsim` kernel module, as shown in the next section. 
- switch to `iptables-legacy` in your host OS (or load `iptable_nat` module: `sudo modprobe iptable_nat`). 

You can build this module in the following ways: 
```bash
# Armbian user only
# Ensure that the project has been cloned locally
sudo apt install linux-headers-legacy-rk35xx
cd mac80211_hwsim
make
sudo cp mac80211_hwsim.ko /lib/modules/`uname -r`/kernel/drivers/net/wireless
sudo depmod
echo "mac80211_hwsim" | sudo tee /etc/modules-load.d/redroid.conf

# Reboot your board.
sudo reboot
```

## Optional

### Google Play Certification

**Notice: This operation can only allow you to use the Google Play Store, but cannot pass the SafetyNet. **

When launching Redroid conrainer the first time you will be notified that the device is not certified for Google Play Protect. You can follow the instructions on screen to self certify your device: 

1. After remotely connecting to the ADB of the Redroid container using the `adb connect` command, then execute: 

```bash
# Switch adb daemon to root
adb root
# Open the shell of the Redroid container
adb shell
# Execute the following command obtain the Google Service Framework Android ID
sqlite3 /data/user/$(cmd activity get-current-user)/*/*/gservices.db \
    "select * from main where name = \"android_id\";"
```

2. Use the string of numbers printed by the command to register the device on your Google Account at this [link](https://www.google.com/android/uncertified). 
2. Wait for at least 10 minutes (up to a day), then restart the container and try logging into the Google Play Store again. 

### Enable ADB authorization to enhance security (recommended)

For the convenience of users connecting to Redroid, ADB authorization (i.e. "Allow ADB Debugging" authorization window) is disabled by default in our container image. Any device that can connect to the host will be able to access the Redroid container. At the same time, due to Redroid's need to use host GPU hardware acceleration, Android containers attach the privileged mode (--privileged) at startup, but this can lead to malicious privilege escalation attacks under unauthorized access. 

**Therefore, it is strongly recommended that you immediately attach ADB authorization after starting the container normally for the first time to improve security. Especially for users who want to place containers on the public network for remote access. **

The following is the method to enable ADB authorization (requires operation through a PC): 

1. **Firstly, ensure that the Redroid container can run successfully and can be remotely connected to the container through ADB commands and Scrcpy screen casting.**

2. Search for the `.android` folder in the user directory on the PC (Windows users can directly enter `%USERPROFILE%\.android` in the address bar of the File Explorer and press enter, while Linux users search for the hidden `~/.android` directory). If so, proceed to step 3 directly; If not, please first attempt to remotely access the Redroid container through the `adb connect` and `adb shell` commands, and the `.android` folder will be automatically generated in the corresponding user directory.

3. Open the `.android` folder, use a text editor to open the `adbkey.pub` file, and copy all the contents of the file for use in the following steps. Its content is similar to:

   ```bash
   QAAAAAvP/Jhd+xuFaJk/5KdV9be7nRLyqWwKvW8FTKadafqrqALiyEQ1jcdGUHTcAGix9WB7XfHQXq/l8WeSCzqsim6WTSZdqf4PnLmrklgfRAkV6sDewAPpEJf7N7hZcpCy+CBsGVngP3gqmEf8aRqj78UadafafKRTaBIxLxyGxt6u4SiujeV0/JwrroNKxONmt8+dlW3+y6K8WTkkr4tDcLYM47Ambv8yYP4QVxYPc8b6Zp1usWFY/sJXM62BbPqgIznO7eWj6afafC7tcn9ErcRsvSyU+KKNMspMTzWHKrtZ8loR6IdUME9TJZ8JicDdh1xZ/rbvi8t5Z5pumtEYpxbeuPyBWvwRFbiFYcp00HAht0bcV4i1OUAnB1T6Bwafa4etd3bEnXQUggLjEkRiSS/rYSM0mKzhc9FiowIkQK5wkh1IlP5dZ6eCQsJgH/vArmYFLKZc1I6h7oJixkCm6f1bUNeVSioPBYWiBrjxX3BZsE0jb31A3hXRNo9qNOwqzGL7ND1m1a/LQrQdpYAEAAQA= ASUS@LAPTOP-5TNUYI14
   ```

4. Connect to the host where Redroid is running through a graphical desktop or SSH login, enter into the mapping directory of the user data partition in the Redroid container that you set after the `-v` parameter in the `Run container` step, and then enter into the `adb` directory under the `misc` directory in sequence.

5. In this directory, create a file without a suffix named `adb_keys`, edit it with a text editor, paste the copied content from step 3 into the file, and save it.

6. Modify the owner and permission mask of the file so that the container can recognize it properly:

   ```bash
   sudo chmod 640 adb_keys
   sudo chown $USER:$USER adb_keys
   ```

7. Add the parameter `ro.adb.secure=1` to recreate the container with ADB authorization enabled: 

   ```bash
   # To delete an existing Redroid container, please enter the command based on the actual name you give the container. Deleting an existing container will not lose persistent data in the mapped directory of the user data partition within the container
   docker container rm redroid
   # Simply add the ro.adb.secure=1 parameter after the container startup command you previously executed in the "Run container" step to recreate the container with ADB authorization enabled. For example:
   docker run -d -p 5555:5555 -v ~/redroid-data:/data --restart unless-stopped --name redroid --privileged cnflysky/redroid-rk3588:12.0.0-latest androidboot.redroid_height=1920 androidboot.redroid_width=1080 ro.adb.secure=1
   ```

8. Now, the Redroid container has enabled ADB authorization. Except for the PC you just used to enable the operation, unauthorized remote devices will be refused access to the container. At this point, you'd better use this PC to remotely connect to Redroid through Scrcpy. Then, you should have all the devices you want to remotely control connect to the Redroid container once to trigger an authorization window pop-up, and agree to the connection of these devices through Scrcpy. Then these devices will have Redroid container access. **Remember that DO NOT try to revoke all ADB authorizations in the developer options, otherwise any device will not be able to connect to the container and steps 1-6 will need to be repeated to restore access.**

### Magisk User Manual

- After enabling the Redroid container that supports Magisk through parameters, when opening and using Magisk for the first time, it will prompt for additional installation. Follow the prompt to confirm and wait for the container to automatically restart.  

- Module installation worked fine, but due to the different adaptation of the module and the special Redroid container environment, some modules may not be able to function properly.

- **Warning! the MagiskHide function is not working properly and enable it will cause the application to freeze at Splash screen. Please do not attempt to enable MagiskHide as it may not easily revert back to initial state.**

## Screenshots

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
