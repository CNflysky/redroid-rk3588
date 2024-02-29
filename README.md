# Redroid 12 Image With GPU Enabled
`Gapps` Ready  
`Magisk(Kitsune fork)` Ready  
Hacked `surfaceflinger` so can type password in some apps without black screen  
Run:
```bash
docker run -d -p 5555:5555 -v ~/redroid-data:/data --name redroid --device /dev/mali0 --privileged cnflysky/redroid-rk3588:12.0.0-latest androidboot.redroid_height=1920 androidboot.redroid_width=1080
```
make sure your kernel version = `5.10.160` and `mali ddk` version = `g18p0`.
```bash
dmesg | grep DDK
```
`mali_csffw.bin` file is required to run this image, place it under host's `/lib/firmware`.  
you can find `mali_csffw.bin` in container's `/vendor/etc/firmware` path.

# Redroid 12 启用GPU加速的镜像
`Gapps`已安装  
`Magisk(Kitsune版)`已安装
已对`surfaceflinger`打patch，因此可以正常地在app中输入密码（不会黑屏）  
运行
```bash
docker run -d -p 5555:5555 -v ~/redroid-data:/data --name redroid --device /dev/mali0 --privileged cnflysky/redroid-rk3588:12.0.0-latest androidboot.redroid_height=1920 androidboot.redroid_width=1080
```
确保你的内核版本为5.10.160，mali ddk版本为g18p0。
```bash
dmesg | grep DDK
```
本镜像需要`mali_csffw.bin`文件才能运行，将其放置于宿主机的`/lib/firmware`下即可。  
你可以在容器的`/vendor/etc/firmware` 目录中找到它。
