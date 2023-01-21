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

```sh
# Backgroud Pre-Download
make -j 4 download
ionice -c 3 chrt --idle 0 nice -n19 make -j $(nproc)
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
cp repositories.local.conf \
    ~/bin/openwrt-imagebuilder-mediatek-filogic.Linux-x86_64/repositories.conf
# Compiled kernel and core system
cp repositories.official.conf \
    ~/bin/openwrt-imagebuilder-mediatek-filogic.Linux-x86_64/repositories.conf

cd ~/bin/openwrt-imagebuilder-mediatek-filogic.Linux-x86_64
```

```sh
make image \
    PROFILE="bananapi_bpi-r3" \
    PACKAGES="base-files busybox ca-bundle dnsmasq dropbear e2fsprogs f2fsck firewall4 fstools kmod-crypto-hw-safexcel kmod-gpio-button-hotplug kmod-hwmon-pwmfan kmod-i2c-gpio kmod-leds-gpio kmod-mt7915e kmod-mt7986-firmware kmod-nft-offload kmod-sfp kmod-usb3 libc libgcc libustream-wolfssl logd mkf2fs mtd netifd nftables odhcp6c odhcpd-ipv6only opkg ppp ppp-mod-pppoe procd procd-seccomp procd-ujail uboot-envtools uci uclient-fetch urandom-seed urngd wpad-basic-wolfssl kmod-mt7921e mt7921bt-firmware kmod-bluetooth luci-ssl luci-app-samba4 parted luci-app-statistics collectd-mod-wireless collectd-mod-sensors kmod-crypto-ecb kmod-crypto-xts kmod-crypto-misc kmod-crypto-user cryptsetup f2fs-tools f2fsck kmod-fs-f2fs mkf2fs block-mount kmod-usb-storage kmod-sfp ethtool-full kmod-nvme keepalived luci-app-keepalived conntrackd collectd-mod-thermal wireguard-tools kmod-wireguard luci-proto-wireguard dnscrypt-proxy2 luci-app-uhttpd node node-npm curl"

# Missing luci-app-keepalived
make image \
    PROFILE="bananapi_bpi-r3" \
    PACKAGES="base-files busybox ca-bundle dnsmasq dropbear e2fsprogs f2fsck firewall4 fstools kmod-crypto-hw-safexcel kmod-gpio-button-hotplug kmod-hwmon-pwmfan kmod-i2c-gpio kmod-leds-gpio kmod-mt7915e kmod-mt7986-firmware kmod-nft-offload kmod-sfp kmod-usb3 libc libgcc libustream-wolfssl logd mkf2fs mtd netifd nftables odhcp6c odhcpd-ipv6only opkg ppp ppp-mod-pppoe procd procd-seccomp procd-ujail uboot-envtools uci uclient-fetch urandom-seed urngd wpad-basic-wolfssl kmod-mt7921e mt7921bt-firmware kmod-bluetooth luci-ssl luci-app-samba4 parted luci-app-statistics collectd-mod-wireless collectd-mod-sensors kmod-crypto-ecb kmod-crypto-xts kmod-crypto-misc kmod-crypto-user cryptsetup f2fs-tools f2fsck kmod-fs-f2fs mkf2fs block-mount kmod-usb-storage kmod-sfp ethtool-full kmod-nvme keepalived conntrackd collectd-mod-thermal wireguard-tools kmod-wireguard luci-proto-wireguard dnscrypt-proxy2 luci-app-uhttpd node node-npm curl"
```

## Clean

https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem#cleaning_up

```sh
make clean
```
