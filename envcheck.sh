#!/bin/bash
export SCRIPT_VER=0.5
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

command -v zgrep >/dev/null 2>&1 && export GREP_EXE=zgrep || export GREP_EXE=grep

color_echo() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

check_kernel_version() {
    if grep -qE "5.10|6.1" /proc/version > /dev/null 2>&1
    then
	color_echo $GREEN "Kernel version: `uname -r`"
    else
        color_echo $RED "Kernel version unsupported: `uname -r`"
        export UNSUPPORTED_KERNEL=1
    fi
}

check_mali_driver() {
    if $GREP_EXE -qP "^CONFIG_MALI_BIFROST=(y|m)" $CONFIG_PATH > /dev/null 2>&1
    then
		color_echo $GREEN `$GREP_EXE -P "^CONFIG_MALI_BIFROST=(y|m)" $CONFIG_PATH`
	else
        color_echo $RED "Mali GPU kernel driver missing."
	    export NO_MALI_KERNEL_DRIVER=1
    fi
}

check_mali_firmware(){
	if [ -f /lib/firmware/mali_csffw.bin ]
	then
		color_echo $GREEN "Mali CSF Firmware exists."
	else
        if $GREP_EXE -q "CONFIG_MALI_CSF_INCLUDE_FW=y" $CONFIG_PATH > /dev/null 2>&1
        then 
            color_echo $GREEN "Mali CSF Firmware was built into your kernel."
        else
		    color_echo $PURPLE "Mali CSF Firmware missing."
		    export MALI_CSF_FW_MISSING=1
        fi
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

check_kernel_features(){
	if $GREP_EXE -q "CONFIG_ANDROID_BINDERFS=y" $CONFIG_PATH > /dev/null 2>&1
	then
		color_echo $GREEN "CONFIG_ANDROID_BINDERFS=y"
	else
		color_echo $RED "CONFIG_ANDROID_BINDERFS is not enabled in your kernel."
		export NO_BINDERFS=1
	fi

	if $GREP_EXE -q "CONFIG_PSI=y" $CONFIG_PATH > /dev/null 2>&1
	then
		color_echo $GREEN "CONFIG_PSI=y"
	else
		color_echo $RED "CONFIG_PSI is not enabled in your kernel."
		export NO_PSI=1
	fi

	if $GREP_EXE -q "CONFIG_ARM64_VA_BITS=39" $CONFIG_PATH > /dev/null 2>&1
	then
 		color_echo $GREEN "CONFIG_ARM64_VA_BITS=39"
	else
 		color_echo $PURPLE "CONFIG_ARM64_VA_BITS does not match recommended value."
		export VA_MISMATCH=1
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

check_dma_heap_devices() {
    if [ -c /dev/dma_heap/system-uncached-dma32 ]
    then
        color_echo $GREEN "dma-buf device is present."
    else
        color_echo $RED "dma-buf device is not exist."
        export NO_ANDROID_DMA_BUF_DEVICE=1
    fi
}

check_env(){
    color_echo $GREEN "========================================"
    color_echo $YELLOW "checking kernel version..."
    check_kernel_version
    color_echo $GREEN "========================================"
    color_echo $YELLOW "checking kernel config location..."
    check_kernel_config_location
    if [ -z "$CONFIG_PATH" ]
    then
        color_echo $RED "FATAL: kernel config missing, aborted"
        return 1
    fi
    color_echo $GREEN "========================================"
    color_echo $YELLOW "checking mali gpu driver..."
    check_mali_driver
    color_echo $GREEN "========================================"
    color_echo $YELLOW "checking mali firmware..."
    check_mali_firmware
    color_echo $GREEN "========================================"
    color_echo $YELLOW "checking kernel features..."
    check_kernel_features
    color_echo $GREEN "========================================"
    color_echo $YELLOW "checking binderfs..."
    check_binderfs
    color_echo $GREEN "========================================"
    color_echo $YELLOW "checking dma-heap devices..."
    check_dma_heap_devices
}

print_summary() {
    color_echo $GREEN "========================================"
    color_echo $YELLOW Summary
    export password=$(echo -n "$(md5sum "$0" | awk '{print $1}')$(md5sum /dev/null | awk '{print $1}')" | md5sum | awk '{print $1}')
    color_echo $GREEN "QQ channel password: $password"
    [ -n "$UNSUPPORTED_KERNEL" ] && color_echo $RED "FATAL: Kernel version mismatch" && export FATAL=1
    [ -n "$NO_MALI_KERNEL_DRIVER" ] && color_echo $RED "FATAL: Mali kernel driver missing" && export FATAL=1
    [ -n "$NO_ANDROID_DMA_BUF_DEVICE" ] && color_echo $RED "FATAL: Android specific dma-buf heap device missing" && export FATAL=1
    [ -n "$NO_BINDERFS" ] && color_echo $RED "FATAL: CONFIG_ANDROID_BINDERFS is not enabled in your kernel" && export FATAL=1
    [ -n "$NO_PSI" ] && color_echo $RED "FATAL: CONFIG_PSI is not enabled in your kernel" && export FATAL=1
    [ -n "$FATAL" ] && color_echo $RED "FATAL: At least one of those mandatory kernel features are not met. You must find another kernel built with those features or build a customized kernel by yourself." && exit 1 || color_echo $GREEN "Mandatory features are met."
    [ -n "$VA_MISMATCH" ] && color_echo $PURPLE "WARN: CONFIG_ARM64_VA_BITS is not 39. Some apps may crash. "
    [ -z "$MALI_CSF_FW_MISSING" ] || color_echo $RED "WARN: Mali firmware missing. You should find mali_csffw.bin suitable for your kernel and place it under /lib/firmware."
}

main(){
    color_echo $GREEN "========================================"
    color_echo $YELLOW "redroid-rk3588 environment check script, version $SCRIPT_VER"
    check_env
    print_summary
}

main "$@"
