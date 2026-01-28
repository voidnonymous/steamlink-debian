#!/bin/bash

set -e

echo "Starting Steam Link first boot setup..."

# Resize partition 1 to 100% of the disk
echo "Resizing partition..."
parted --script /dev/sda resizepart 1 100%

# Resize the filesystem to fill the partition
echo "Resizing filesystem..."
resize2fs /dev/sda1

# Create a 1.5GB swapfile
if [ ! -f /swapfile ]; then
    echo "Creating 1.5GB swapfile (this may take a while)..."
    dd if=/dev/zero of=/swapfile bs=1M count=1536
    chmod 600 /swapfile
    mkswap /swapfile
fi

# Enable swap
echo "Enabling swap..."
swapon /swapfile

# Persist swap in /etc/fstab
if ! grep -q "/swapfile" /etc/fstab; then
    echo "Adding swapfile to /etc/fstab..."
    echo "/swapfile none swap sw 0 0" >> /etc/fstab
fi

# Disable this service so it doesn't run again
echo "Disabling first boot setup service..."
systemctl disable steamlink-firstboot.service

echo "First boot setup complete!"
