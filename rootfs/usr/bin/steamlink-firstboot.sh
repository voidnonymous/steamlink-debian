#!/bin/bash

set -e
set -o pipefail

LOG_FILE="/var/log/steamlink-firstboot.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "--- Steam Link First Boot Setup Start: $(date) ---"

# Resize partition 1 to 100% of the disk
if [ -b /dev/sda ]; then
    echo "Resizing partition /dev/sda1 to fill the disk..."
    parted --script /dev/sda resizepart 1 100% || echo "Warning: parted returned non-zero, continuing..."
else
    echo "Error: /dev/sda not found. Skipping partition resize."
fi

# Resize the filesystem to fill the partition
echo "Resizing filesystem on /dev/sda1..."
resize2fs /dev/sda1 || echo "Warning: resize2fs failed or partition already resized."

# Create a 1.5GB swapfile
if [ ! -f /swapfile ]; then
    echo "Creating 1.5GB swapfile at /swapfile (this may take a while)..."
    dd if=/dev/zero of=/swapfile bs=1M count=1536 status=progress
    echo "Setting swapfile permissions..."
    chmod 600 /swapfile
    echo "Formatting swapfile..."
    mkswap /swapfile
else
    echo "Swapfile already exists at /swapfile."
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
echo "Disabling steamlink-firstboot.service..."
systemctl disable steamlink-firstboot.service

echo "--- Steam Link First Boot Setup Complete: $(date) ---"
