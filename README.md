# steamlink-debian

This repository provides a way to run Debian GNU/Linux on a Valve Steam Link device using a USB stick.

Heads up!
This is a repo I made for messing with AI, and trying to get new features. There is a like, 10% chance this will build. Please use the base repo instead unless you want to debug Jules janky code.

```
debian@steamlink:~$ fastfetch
       _,met$$$$$gg.           debian@steamlink
    ,g$$$$$$$$$$$$$$$P.        ----------------
  ,g$$P"         """Y$$.".     OS: Debian GNU/Linux bookworm 12.7 armv7l
 ,$$P'               `$$$.     Host: Valve Steam Link
',$$P       ,ggs.     `$$b:    Kernel: Linux 6.1.115-steam
`d$$'     ,$P"'   .    $$$     Uptime: 9 mins
 $$P      d$'     ,    $$$P    Packages: 191 (dpkg)
 $$:      $.   -    ,d$$'      Shell: bash 5.2.15
 $$;      Y$b._   _,d$P'       Terminal: /dev/pts/0
 Y$$.    `.`"Y$$$$P"'          CPU: Marvell Berlin
 `$$b      "-.__               Memory: 29.66 MiB / 498.16 MiB (6%)
  `Y$$                         Swap: Disabled
   `Y$$.                       Disk (/): 325.80 MiB / 989.67 MiB (33%) - ext3 [External]
     `$$b.                     Local IP (eth0): 192.168.1.7/24
       `Y$$b.                  Locale: C
          `"Y$b._
             `"""
```

## How to use

Download an image of Debian version of your choice from the [Releases](https://github.com/djmuted/steamlink-debian/releases) page and flash it on a 2GB (or bigger) USB stick using [balenaEtcher](https://etcher.balena.io/) or any other USB flasher. SD cards paired with a USB SD Reader work as well.

> :warning: **Warning**: Flashing the image on the USB stick will wipe all data stored on the device!

Plug the USB stick into the Steam Link and power it on. The device will boot from the USB stick and appear on your network soon.

## Default passwords

> :warning: **Recommended**: Consider changing your passwords with `passwd` after first login.

### Default user

User: `debian`
password: `steamlink`

## First boot

For the first boot a LAN connection is required. Once the new kernel starts booting, there will be no HDMI output anymore. Connect to the Steam Link via SSH. Local IP address can be found in your router's DHCP table.

### Change hostname

This the first thing you should do after logging in, some commands might not work without a proper hostname.

```bash
sudo hostnamectl set-hostname steamlink
echo '127.0.0.1 steamlink' | sudo tee -a /etc/hosts
```

### Automatic setup on first boot

On the first boot, the system will automatically:
- Resize the root partition to take the entire space of the USB stick.
- Resize the filesystem.
- Create and enable a 1.5GB swap file.

This process might take a few minutes depending on the speed of your USB stick. You can monitor the progress if you have a serial console connected, or just wait for the SSH service to become available.

### Additional swap options

#### ZRAM (Recommended for performance)

While a 1.5GB swap file is created automatically, ZRAM provides a compressed swap space in RAM, which is much faster than swapping to a USB stick.

Install `zram-tools`:

```bash
sudo apt update
sudo apt install zram-tools
```

Configure it by editing `/etc/default/zramswap`:

```bash
# Set size to 60% of RAM
echo 'PERCENT=60' | sudo tee /etc/default/zramswap
# Use lz4 for better performance
echo 'ALGO=lz4' | sudo tee -a /etc/default/zramswap
```

Restart the service to apply:

```bash
sudo systemctl restart zramswap
```

## What does not work

- NAND driver
- video/audio output
- suspend/resume/halt/reboot
- RTC

## Credits

- [Getting Linux on Valve Steam Link from heap.ovh](https://heap.ovh/getting-linux-on-valve-steam-link.html)
- [Docker Debian bootstrap script from v86 project](https://github.com/copy/v86)
- [regmibijay/steamlink-archlinux GitHub repository](https://github.com/regmibijay/steamlink-archlinux)
