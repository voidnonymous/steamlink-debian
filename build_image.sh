#!/bin/bash

set -e

KERNEL_VERSION="6.1.115"
KERNEL_BRANCH="v6.x"
DEBIAN_VERSION="bullseye"

echo "Building Steam Link Debian image for kernel $KERNEL_VERSION..."

# 1. Download Kernel
if [ ! -d "linux-$KERNEL_VERSION" ]; then
    echo "Downloading kernel source..."
    wget https://cdn.kernel.org/pub/linux/kernel/$KERNEL_BRANCH/linux-$KERNEL_VERSION.tar.xz
    echo "Extracting kernel source..."
    tar -xf linux-$KERNEL_VERSION.tar.xz
    rm linux-$KERNEL_VERSION.tar.xz
fi

# 2. Copy Config
echo "Copying kernel config..."
cp ./kernel/$KERNEL_VERSION.config ./linux-$KERNEL_VERSION/.config

# 3. Build Kernel
echo "Building kernel (this will take a while)..."
export KERNEL_VERSION
./kernel/build.sh

# 4. Prepare Artifacts
echo "Preparing artifacts..."
ARTIFACTS_DIR="kernel-$KERNEL_VERSION"
mkdir -p "$ARTIFACTS_DIR"
cp linux-$KERNEL_VERSION/arch/arm/boot/zImage "$ARTIFACTS_DIR"/
cp linux-$KERNEL_VERSION/arch/arm/boot/dts/berlin2cd-valve-steamlink.dtb "$ARTIFACTS_DIR"/ || cp linux-$KERNEL_VERSION/arch/arm/boot/dts/marvell/berlin2cd-valve-steamlink.dtb "$ARTIFACTS_DIR"/
cp linux-$KERNEL_VERSION/.config "$ARTIFACTS_DIR"/config-$KERNEL_VERSION-steam
cp -r /tmp/build-modules/lib/modules/$KERNEL_VERSION-steam "$ARTIFACTS_DIR"/
rm -rf "$ARTIFACTS_DIR"/$KERNEL_VERSION-steam/build "$ARTIFACTS_DIR"/$KERNEL_VERSION-steam/source

# 5. Build RootFS Docker Image
echo "Building RootFS Docker image..."
docker buildx build --platform linux/arm/v7 \
    --build-arg KERNEL_VERSION=$KERNEL_VERSION \
    --build-arg DEBIAN_VERSION=$DEBIAN_VERSION \
    --rm -f rootfs/Dockerfile \
    --tag steamlink-debian:latest \
    --output type=docker,dest=steamlink-debian.tar .

# 6. Create RootFS tarball
echo "Creating rootfs.tar..."
docker load -i steamlink-debian.tar
docker create -t -i --name steamlink-debian-rootfs steamlink-debian:latest
docker export steamlink-debian-rootfs -o rootfs.tar
docker rm steamlink-debian-rootfs
rm steamlink-debian.tar

# 7. Create disk image
echo "Creating final disk image..."
sudo ./rootfs/build.sh

echo "Build complete! The flashable image is: steamlink-debian.img.xz"
