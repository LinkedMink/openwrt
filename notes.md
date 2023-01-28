# Notes

- https://downloads.openwrt.org/snapshots/targets/mediatek/filogic/
- https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem

## System

https://openwrt.org/docs/guide-developer/toolchain/install-buildsystem#debianubuntu

```sh
sudo apt update
sudo apt install build-essential clang flex g++ gawk gcc-multilib gettext \
    git libncurses5-dev libssl-dev python3-distutils rsync unzip zlib1g-dev \
    file wget

git clone https://git.openwrt.org/openwrt/openwrt.git
cd ./openwrt
git remote add upstream https://git.openwrt.org/openwrt/openwrt.git
git remote remove origin
git remote add origin git@github.com:LinkedMink/openwrt.git
```

## Setup

https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem#using_official_build_config

```sh
wget https://downloads.openwrt.org/snapshots/targets/mediatek/filogic/config.buildinfo -O .config
make menuconfig

./scripts/feeds update -a
./scripts/feeds install -a
```

## Build

https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem#building_images

Test Optimizations:
https://forum.archive.openwrt.org/viewtopic.php?id=30141#p136619

```sh
# Backgroud Pre-Download
make -j 4 download
ionice -c 3 chrt --idle 0 nice -n19 \
    make -j $(nproc)
# Combine Full
make -j $(nproc) download world
# Limit
make -j $(($(nproc) - 1))
```

### Image Builder with PKGs

- https://firmware-selector.openwrt.org/?version=SNAPSHOT&target=mediatek%2Ffilogic&id=bananapi_bpi-r3
- https://openwrt.org/docs/guide-user/additional-software/imagebuilder#usage

```sh
rm -rf ~/bin/openwrt-imagebuilder-mediatek-filogic.Linux-x86_64

tar -xvf bin/targets/mediatek/filogic/openwrt-imagebuilder-mediatek-filogic.Linux-x86_64.tar.xz \
    --directory ~/bin

# Compiled all dependency
cp ../img-builder/repositories.local.conf \
    ~/bin/openwrt-imagebuilder-mediatek-filogic.Linux-x86_64/repositories.conf
# Compiled kernel and core system
cp ../img-builder/repositories.official.conf \
    ~/bin/openwrt-imagebuilder-mediatek-filogic.Linux-x86_64/repositories.conf
```

```sh
# Defaults
export PACKAGES="base-files busybox ca-bundle dnsmasq dropbear e2fsprogs f2fsck firewall4 fstools kmod-crypto-hw-safexcel kmod-gpio-button-hotplug kmod-hwmon-pwmfan kmod-i2c-gpio kmod-leds-gpio kmod-mt7915e kmod-mt7986-firmware kmod-nft-offload kmod-sfp kmod-usb3 libc libgcc libustream-wolfssl logd mkf2fs mtd netifd nftables odhcp6c odhcpd-ipv6only opkg ppp ppp-mod-pppoe procd procd-seccomp procd-ujail uboot-envtools uci uclient-fetch urandom-seed urngd wpad-basic-wolfssl"
# Base Drivers
export PACKAGES="${PACKAGES} kmod-mt7921e mt7921bt-firmware kmod-bluetooth kmod-nvme"
# Filesystem
export PACKAGES="${PACKAGES} f2fs-tools kmod-fs-f2fs kmod-fs-exfat libblkid1 ntfs-3g kmod-usb-storage block-mount parted"
# Filesystem luks
export PACKAGES="${PACKAGES} kmod-crypto-ecb kmod-crypto-xts kmod-crypto-misc kmod-crypto-user cryptsetup"
# Admin and Security
export PACKAGES="${PACKAGES} luci-ssl ethtool-full dnscrypt-proxy2"
echo $PACKAGES

# SNAND Min
cp -r ~/src/img-builder/files ~/bin/openwrt-imagebuilder-mediatek-filogic.Linux-x86_64/
make image PROFILE="bananapi_bpi-r3" FILES="files"
# Modem R11e-LTE6
export PACKAGES="${PACKAGES} kmod-usb-net-rndis kmod-usb-acm usb-modeswitch luci-proto-modemmanager"
# VRRP Failover
export PACKAGES="${PACKAGES} keepalived conntrackd"
# WireGuard VPN
export PACKAGES="${PACKAGES} wireguard-tools kmod-wireguard luci-proto-wireguard"
# Samba
export PACKAGES="${PACKAGES} luci-app-samba4"
# Monitoring/Stats
export PACKAGES="${PACKAGES} luci-app-statistics collectd-mod-wireless collectd-mod-sensors collectd-mod-thermal prometheus-node-exporter-lua"
# Admin and Utils
export PACKAGES="${PACKAGES} luci-app-uhttpd luci-app-acl luci-proto-bonding curl"
# Modem/Radio Extensions
export PACKAGES="${PACKAGES} rtl-sdr gpsd gpsd-clients ntpd ntp-utils"
# NodeJS
export PACKAGES="${PACKAGES} node node-npm"

make image PROFILE="bananapi_bpi-r3" PACKAGES=${PACKAGES}

base-files busybox ca-bundle dnsmasq dropbear e2fsprogs f2fsck firewall4 fstools kmod-crypto-hw-safexcel kmod-gpio-button-hotplug kmod-hwmon-pwmfan kmod-i2c-gpio kmod-leds-gpio kmod-mt7915e kmod-mt7986-firmware kmod-nft-offload kmod-sfp kmod-usb3 libc libgcc libustream-wolfssl logd mkf2fs mtd netifd nftables odhcp6c odhcpd-ipv6only opkg ppp ppp-mod-pppoe procd procd-seccomp procd-ujail uboot-envtools uci uclient-fetch urandom-seed urngd wpad-basic-wolfssl
```

ppp ppp-mod-pppoe
luci-proto-bonding luci-app-wol luci-app-acl rtl-sdr
gpsd gpsd-clients ntpd ntp-utils
https://openwrt.org/docs/guide-user/luci/luci.essentials#luci_on_nginx
https://openwrt.org/docs/guide-user/services/ntp/gps

```sh
# New Method
cp ~/src/img-builder/.profiles.mk ~/bin/openwrt-imagebuilder-mediatek-filogic.Linux-x86_64/

# SNAND Min
cp -r ~/src/img-builder/files ~/bin/openwrt-imagebuilder-mediatek-filogic.Linux-x86_64/
make image PROFILE="bananapi_bpi-r3-min" FILES="files"

# Full
make image PROFILE="bananapi_bpi-r3-custom" FILES="files"
```

## Clean

https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem#cleaning_up

```sh
make clean
```
