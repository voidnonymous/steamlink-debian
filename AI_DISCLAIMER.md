# AI Implementation Disclaimer & Technical Handover

This document summarizes the changes made by the AI engineer (Jules) to port Steam Link hardware support to a modern Linux 6.1 kernel.

## 🚀 Porting Summary
We have successfully ported the following features from the legacy Kernel 3.8 to **Linux 6.1.115**:

1.  **Audio**: Enabled ALSA USB Audio support (`CONFIG_SND_USB_AUDIO`).
2.  **Video & GPU**:
    - Enabled the `etnaviv` DRM driver for the Vivante GPU.
    - Added `simple-framebuffer` support for immediate display output.
    - Reserved **64MB** for graphics: 16MB static (SimpleFB) at `0x1f000000` and 48MB dynamic (CMA pool).
3.  **Reboot**: Implemented hardware restart via GPIO 6 on Port A using the standard `gpio-restart` driver.
4.  **Overclocking (Turbo)**:
    - Added CPU operating points in the DTS up to **1.6GHz** (Turbo/Unstable).
    - Configured the `88PG868` regulator to scale voltage up to **1.4V**.
5.  **Thermal Tracking**:
    - Enabled the Marvell Berlin ADC temperature sensor.
    - Configured thermal zones and passive cooling (throttling starts at 85°C).

## 🛠️ Environment & Build Info
To continue this work or build the kernel on your local machine:

### 1. Host Dependencies

**Ubuntu/Debian**:
```bash
sudo apt-get update && sudo apt-get install -y flex bison bc libelf-dev libssl-dev
```

**Arch Linux**:
```bash
sudo pacman -S base-devel flex bison bc elfutils openssl
```

### 2. Toolchain Fix
The provided Steam Link SDK toolchain (`armv7a-cros-linux-gnueabi-gcc`) may look for `libmpfr.so.4`.

**Ubuntu/Debian**:
```bash
sudo ln -s /usr/lib/x86_64-linux-gnu/libmpfr.so.6 /usr/lib/x86_64-linux-gnu/libmpfr.so.4
```

**Arch Linux**:
```bash
sudo ln -s /usr/lib/libmpfr.so.6 /usr/lib/libmpfr.so.4
```

### 3. Building
Use the updated build script provided in the repository. It is designed to run inside the SDK root and handles unsetting environment variables that would otherwise break host tool compilation (like `certs/extract-cert`).
```bash
export KERNEL_VERSION=6.1.115
bash kernel/build.sh
```

## 🤖 Handover for Next AI Model
If another model (like "jules") takes over, it should know:
- **Architecture**: `arm` (ARMv7-A, Hard Float).
- **SoC**: Marvell Berlin2CD (BG2CD).
- **DTS File**: `kernel/berlin2cd-valve-steamlink.dts` (Customized from mainline).
- **Config**: `kernel/6.1.115.config` (Full static config).
- **GPU Note**: We are using the `etnaviv` driver. The core addresses are `0xf7bc0000` (3D) and `0xf7ef0000` (2D).
- **Memory**: The device only has 512MB RAM. Avoid high-memory kernel features or large debug symbols.

## 🔑 Authentication / Setup
To "load up jules" and auth it:
1. Ensure the `steamlink-sdk` submodule is initialized.
2. Place the `linux-6.1.115` source in the root directory (or let the build script handle it).
3. The build script `kernel/build.sh` is your source of truth for the environment setup.
