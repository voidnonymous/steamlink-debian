#!/usr/bin/env bash

set -e

export ARCH=arm; export LOCALVERSION="-steam"

mkdir -p boot

# Manually set up environment for kernel build
TOP=$(cd `dirname "${BASH_SOURCE[0]}"`/.. && pwd)
export PATH=$TOP/steamlink-sdk/toolchain/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export CROSS_COMPILE=armv7a-cros-linux-gnueabi-

# Ensure we use host tools for host compilation
export HOSTCC=gcc
export HOSTCXX=g++

cd linux-$KERNEL_VERSION
cp ../kernel/6.1.115.config .config
if [ -f ../kernel/berlin2cd-valve-steamlink.dts ]; then
    cp ../kernel/berlin2cd-valve-steamlink.dts arch/arm/boot/dts/
    # Ensure the DTS is listed in the Makefile
    if ! grep -q "berlin2cd-valve-steamlink.dtb" arch/arm/boot/dts/Makefile; then
        sed -i '/berlin2cd-google-chromecast.dtb/a \tberlin2cd-valve-steamlink.dtb \\' arch/arm/boot/dts/Makefile
    fi
fi

# Forcefully disable features that cause build issues in this environment
# or are unnecessary for the port.
scripts/config --disable SYSTEM_TRUSTED_KEYRING
scripts/config --disable SYSTEM_REVOCATION_LIST
scripts/config --disable MODULE_SIG
scripts/config --disable DEBUG_INFO

make olddefconfig
make -j$(nproc) zImage modules dtbs
cp arch/arm/boot/zImage ../boot/
cp arch/arm/boot/dts/berlin2cd-valve-steamlink.dtb ../boot/
mkdir -p /tmp/build-modules
INSTALL_MOD_PATH=/tmp/build-modules make modules_install
