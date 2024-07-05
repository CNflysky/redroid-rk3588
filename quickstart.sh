#!/bin/bash

check_kernel_version() {
    if ! uname -r | grep -q "5.10.160"; then
        echo "你的内核版本不包含 5.10.160, 放弃吧, 换个内核再试试?"
        exit 1
    fi
}

check_docker() {
    if command -v docker >/dev/null 2>&1; then
        echo "有 Docker, 好!"
    else
        install_docker
    fi
}

check_mali_firmware() {
    if dmesg | grep -q "Kernel DDK version"; then
        echo "看起来你的系统包含 GPU 内核驱动, 注意一下版本是否为 g18p0."
        dmesg | grep "Kernel DDK version"
    else
        echo "看起来你的系统不包含 Mali GPU 内核驱动, 建议换个内核, 或者设备树, 或者都换掉."
        echo "也有可能只是日志被覆盖了, 建议重启试试."
        exit 1
    fi
    if [ -f "/lib/firmware/mali_csffw.bin" ]; then
        echo "看起来 mali 固件在它该呆的地方。"
        export MALI_NOT_HERE=0
    else
        echo "mali 固件不在它该呆的地方。稍等咱给你整一份。"
        export MALI_NOT_HERE=1
    fi
}

check_binderfs() {
    if cat /proc/filesystems | grep -q "binder"; then
        echo "binderfs 已经挂载。"
    else
        echo "binderfs 没有挂载。"
        if [ -f "/etc/armbian-release" ]; then
            echo "是 armbian 呢."
            echo "咱给你挂载 binderfs."
            sudo modprobe binder_linux
            sudo modprobe binder
            sudo modprobe binder_hl
            sudo mount -t binder binder /dev/binderfs
            echo "尝试挂载了一下 binderfs."
            check_binderfs
        else
            echo "不是 armbian 呢. 得靠你自己辣."
            exit 1
        fi
    fi
}

check_mac80211_hwsim() {
    if lsmod | grep -q "mac80211_hwsim"; then
        echo "mac80211_hwsim 已经加载。"
    else
        echo "mac80211_hwsim 没有加载。"
        if [ -f "/etc/armbian-release" ]; then
            echo "是 armbian 呢."
            echo "咱给你整一个 mac80211_hwsim."
            if [ ! -f "/lib/modules/$(uname -r)/kernel/drivers/net/wireless/mac80211_hwsim.ko" ]; then
                echo "本地没有 mac80211_hwsim.ko, 咱给你整一个."
                cd ~/redroid-rk3588
                make
                sudo cp mac80211_hwsim.ko /lib/modules/$(uname -r)/kernel/drivers/net/wireless
                sudo depmod
                echo "mac80211_hwsim" | sudo tee /etc/modules-load.d/redroid.conf
            fi
            sudo modprobe mac80211_hwsim
            if lsmod | grep -q "mac80211_hwsim"; then
                echo "mac80211_hwsim 加载完毕。"
            else
                echo "mac80211_hwsim 加载失败。"
                exit 1
            fi
        else
            echo "不是 armbian 呢. 得靠你自己辣."
            exit 1
        fi
    fi
}

clone_repository() {
    if [ ! -d ~/redroid-rk3588 ]; then
        echo "看起来你还没有 redroid-rk3588 仓库。咱给你 clone 一份。"
        if git clone https://github.com/CNflysky/redroid-rk3588 --depth=1 ~/redroid-rk3588; then
            echo "Clone 成功。"
        else
            echo "网不好吧, clone 失败了。"
            return 1
        fi
    else
        echo "redroid-rk3588 仓库已存在。"
    fi
}

diagnose_container() {
    check_mali_firmware
    install_mali_firmware
    check_binderfs
    check_mac80211_hwsim
    if [ $MALI_NOT_HERE -eq 0 ]; then
        sudo docker restart $container_id
        echo "再试试看?"
        exit 0
    fi
}

install_mali_firmware() {
    if [ $MALI_NOT_HERE -eq 1 ]; then
        sudo docker cp $container_id:/vendor/etc/firmware/mali_csffw.bin /lib/firmware/
    fi
    check_mali_firmware
    if [ $MALI_NOT_HERE -eq 0 ]; then
        echo "mali 固件已经整到 /lib/firmware/ 里了。"
    else
        echo "mali 固件整不进 /lib/firmware/ , 哪里出了问题？"
        exit 1
    fi
}

install_hw80211() {
    if [ -f "/etc/armbian-release" ]; then
        echo "是 armbian 呢."
        cd ~/redroid-rk3588
        make
        sudo cp mac80211_hwsim.ko /lib/modules/$(uname -r)/kernel/drivers/net/wireless
        sudo depmod
        echo "mac80211_hwsim" | sudo tee /etc/modules-load.d/redroid.conf
    else
        echo "不是 armbian 呢. 得靠你自己辣."
        exit 1
    fi
}

start_container() {
    echo "咱给你启动一个容器."
    echo "参数是: $bootargs"
    container_id=$(sudo $bootargs)
    sudo docker stop -t 1 $container_id
    check_mali_firmware
    install_mali_firmware
    install_hw80211
    sudo docker start $container_id
    echo "开好辣, 容器编号是: $container_id"
}

pull_image() {
    echo "看起来你没有这个镜像, 咱给你拉一份. 你要哪个版本?"
    echo '1) Android 12(12.0.0-latest)'
    echo '2) Android 13(13.0.0-latest)'
    while true; do
        read -p "1 还是 2? " version
        case "$version" in
        1)
            version="12.0.0-latest"
            break
            ;;
        2)
            version="13.0.0-latest"
            break
            ;;
        *)
            echo "输入无效，请输入 1 或 2。"
            continue
            ;;
        esac
    done
    sudo docker pull cnflysky/redroid-rk3588:$version
}

install_docker() {
    while true; do
        echo "看起来你没有 Docker."
        read -p "要咱给你装上 Docker 吗?(y/n) " answer
        case "$answer" in
        y | Y | yes)
            sudo apt-get update
            sudo apt-get install -y docker.io
            echo "装好辣!"
            break
            ;;
        n | N | no | q)
            echo "如你所愿."
            exit 1
            ;;
        *)
            echo "无效，请输入 y 或 n."
            ;;
        esac
    done
}

clone_repository
check_docker
echo "咱看看你本地有没有这个镜像..."
echo "有可能让你输入密码, 之类的."
sudo docker images | grep "redroid-rk3588" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    image_count=$(sudo docker images | grep "redroid-rk3588" | wc -l)
    if [ $image_count -ge 2 ]; then
        echo "你本地有两个或更多的 redroid-rk3588 镜像. 咱脚本能力有限, 只能到这了, 告辞."
    else
        full_image_name=$(sudo docker images | grep "redroid-rk3588" | awk '{print $1":"$2}' | head -n 1)
        container_id=$(docker ps -a | grep "$full_image_name" | awk '{print $1}')
        if [ -n "$full_image_name" ]; then
            echo "看起来你有这个镜像, 咱找到的完整镜像名为: $full_image_name"
            sudo docker ps -a | grep "redroid" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                while true; do
                    read -p "咱看到已经有个 redroid 容器了, 是遇到什么问题无法运行吗?(y/n) " answer
                    case "$answer" in
                    y | Y | yes)
                        echo "咱帮你看看哈."
                        diagnose_container
                        ;;
                    n | N | no | q)
                        echo "拿咱寻开心?"
                        exit 1
                        ;;
                    *)
                        echo "无效，请输入 y 或 n."
                        ;;
                    esac
                done
            fi
            start_container
        else
            echo "脚本好像走丢了."
        fi
    fi
else
    pull_image
    start_container
fi

exit 0