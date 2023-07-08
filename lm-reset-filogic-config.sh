#!/usr/bin/env bash
#region Definitions

source lm-utility.sh

CONFIG_BACKUP_SUFFIX="prereset"
CONFIG_DEFAULT_URL="https://downloads.openwrt.org/snapshots/targets/mediatek/filogic/config.buildinfo"

#endregion
#region Main

installDependencyIfNotFound wget

logInfo "Configs prior to reset will be moved to path: ./config.$CONFIG_BACKUP_SUFFIX"
if [ -f .config ]; then
  rmIfExist ".config.$CONFIG_BACKUP_SUFFIX"
  mv .config ".config.$CONFIG_BACKUP_SUFFIX"
fi

if [ -f .config.old ]; then
  rmIfExist ".config.$CONFIG_BACKUP_SUFFIX.old"
  mv .config.old ".config.$CONFIG_BACKUP_SUFFIX.old"
fi

logInfo "Download base filogic build config: $CONFIG_DEFAULT_URL"

wget $CONFIG_DEFAULT_URL -O .config

logInfo "Modify base filogic build config: .config"

sed -i '/CONFIG_TARGET_DEVICE/d' .config
sed -i '/CONFIG_TARGET_ALL_PROFILES/d' .config
tee -a .config <<EOF
CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_bananapi_bpi-r3-kmod=y
CONFIG_TARGET_DEVICE_PACKAGES_mediatek_filogic_DEVICE_bananapi_bpi-r3-kmod=""
CONFIG_TARGET_OPTIONS=y
CONFIG_TARGET_ALL_PROFILES=n
CONFIG_TARGET_PREINIT_IP="192.168.128.163"
CONFIG_TARGET_PREINIT_NETMASK="255.255.255.0"
CONFIG_TARGET_PREINIT_BROADCAST="192.168.128.255"
EOF

# CONFIG_TARGET_ROOTFS_PERSIST_VAR=y
# CONFIG_TARGET_OPTIMIZATION="-O3 -pipe -mcpu=cortex-a53 -Wno-error"

logInfo "Generate complete default config: .config"

make defconfig

#endregion
