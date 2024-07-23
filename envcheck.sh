#!/bin/bash
set -e
export VERSION=0.2

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

color_echo() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

check_kernel_version() {
    if grep -q "5.10" /proc/version > /dev/null 2>&1
    then
	color_echo $GREEN $"Kernel version: `uname -r`"
    else
        color_echo $RED "Kernel version mismatch: `uname -r`"
        export KERNEL_VERSION_MISMATCH=1
    fi
}

check_mali_driver() {
    if [ -f /sys/module/bifrost_kbase/version ]
    then
	if grep -q "g18p0" /sys/module/bifrost_kbase/version > /dev/null 2>&1
	then
		color_echo $GREEN "Mali DDK verison: `cat /sys/module/bifrost_kbase/version`"
	else
		color_echo $RED "Mali DDK version mismatch: `cat /sys/module/bifrost_kbase/version`"
		export MALI_DDK_VER_MISMATCH=1
	fi
    else
	color_echo $RED "Mali kernel driver missing."
	export MALI_KERNEL_DRIVER_MISSING=1
    fi
}

check_mali_firmware(){
	if [ -f /lib/firmware/mali_csffw.bin ]
	then
		mali_fw_git_sha=`strings /lib/firmware/mali_csffw.bin | grep git_sha | cut -d ' ' -f 2`
		if [ $mali_fw_git_sha == ee476db42870778306fa8d559a605a73f13e455c ]
		then
			color_echo $GREEN "Mali CSF Firmware git_sha: $mali_fw_git_sha"	
		else
			color_echo $YELLOW "Mali CSF Firmware git_sha mismatch: $mali_fw_git_sha"
			export MALI_CSF_FW_GIT_SHA_MISMATCH=1
		fi
	else
		color_echo $YELLOW "Mali CSF Firmware missing."
		export MALI_CSF_FW_MISSING=1
	fi
}

check_kernel_config_location() {
	if [ -f /proc/config.gz ] && command -v zgrep >/dev/null 2>&1
	then
		export CONFIG_PATH=/proc/config.gz
	elif [ -f /boot/config-`uname -r` ]
	then
		export CONFIG_PATH=/boot/config-`uname -r`
	fi
	[ -z $CONFIG_PATH ] && color_echo $RED "Kernel config missing" || color_echo $GREEN "Kernel config: $CONFIG_PATH"
}

check_kernel_config(){
	if zgrep -q "CONFIG_ANDROID_BINDERFS=y" $CONFIG_PATH > /dev/null 2>&1
	then
		color_echo $GREEN "CONFIG_ANDROID_BINDERFS=y"
	else
		color_echo $RED "CONFIG_ANDROID_BINDERFS is not enabled in your kernel."
		export BINDERFS_MISSING=1
	fi

	if zgrep -q "CONFIG_PSI=y" $CONFIG_PATH > /dev/null 2>&1
	then
		color_echo $GREEN "CONFIG_PSI=y"
	else
		color_echo $RED "CONFIG_PSI is not enabled in your kernel."
		export PSI_MISSING=1
	fi

	if zgrep -q "CONFIG_ARM64_VA_BITS=39" $CONFIG_PATH > /dev/null 2>&1
	then
 		color_echo $GREEN "CONFIG_ARM64_VA_BITS=39"
	else
 		color_echo $YELLOW "CONFIG_ARM64_VA_BITS does not match recommended value."
		export VA_MISSING=1
	fi
}

check_binderfs() {
    if grep -q binder /proc/filesystems
    then
	    color_echo $GREEN "binderfs enabled."
    else
	    color_echo $RED "binderfs not enabled."
    fi
}

check_env(){
    color_echo $GREEN "========================================"
    color_echo $YELLOW "checking kernel version..."
    check_kernel_version
    color_echo $GREEN "========================================"
    color_echo $YELLOW "checking mali driver version..."
	check_mali_driver
	color_echo $GREEN "========================================"
    color_echo $YELLOW "checking mali firmware version..."
	check_mali_firmware
	color_echo $GREEN "========================================"
    color_echo $YELLOW "checking kernel config location..."
	check_kernel_config_location
	color_echo $GREEN "========================================"
    color_echo $YELLOW "checking kernel config..."
	check_kernel_config
    color_echo $GREEN "========================================"
    color_echo $YELLOW "checking binderfs..."
    check_binderfs
}

print_summary() {
    color_echo $GREEN "========================================"
    color_echo $YELLOW Summary
    [ -n "$KERNEL_VERSION_MISMATCH" ] && color_echo $RED "FATAL: Kernel version mismatch!" && export FATAL=1
    [ -n "$MALI_KERNEL_DRIVER_MISSING" ] && color_echo $RED "FATAL: Mali kernel driver missing" && export FATAL=1
    [ -n "$MALI_DDK_VER_MISMATCH" ] && color_echo $RED "FATAL: Mali DDK version mismatch" && export FATAL=1
    [ -n "$BINDERFS_MISSING" ] && color_echo $RED "FATAL: CONFIG_ANDROID_BINDERFS is not enabled in your kernel" && export FATAL=1
    [ -n "$PSI_MISSING" ] && color_echo $RED "FATAL: CONFIG_PSI is not enabled in your kernel" && export FATAL=1
    [ -n "$VA_MISSING" ] && color_echo $YELLOW "WARN: CONFIG_ARM64_VA_BITS is not 39. Some apps may crash. "
    [ -n "$FATAL" ] && color_echo $RED "FATAL: At least one of those mandatory kernel features are not met. You must install another kernel or compile kernel by yourself." && exit 1 || color_echo $GREEN "All mandatory features are met."
}

main(){
    color_echo $GREEN "========================================"
    color_echo $YELLOW "redroid-rk3588 environment check script, version $VERSION"
	check_env
	print_summary
}

main "$@"

exit 0
