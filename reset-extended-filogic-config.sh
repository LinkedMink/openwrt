#!/usr/bin/env bash

source custom-utility.sh

CONFIG_BACKUP_SUFFIX="prereset"
CONFIG_DEFAULT_URL="https://downloads.openwrt.org/snapshots/targets/mediatek/filogic/config.buildinfo"

installDependencyIfNotFound wget

logInfo "Configs prior to reset will be moved to path: ./config.$CONFIG_BACKUP_SUFFIX"
if [ -f .config ]; then
  if [ -f ".config.$CONFIG_BACKUP_SUFFIX" ]; then
    rm ".config.$CONFIG_BACKUP_SUFFIX"
  fi
  mv .config ".config.$CONFIG_BACKUP_SUFFIX"
fi

if [ -f .config.old ]; then
  if [ -f ".config.$CONFIG_BACKUP_SUFFIX.old" ]; then
    rm ".config.$CONFIG_BACKUP_SUFFIX.old"
  fi
  mv .config.old ".config.$CONFIG_BACKUP_SUFFIX.old"
fi

wget $CONFIG_DEFAULT_URL -O .config
sed -i '/CONFIG_TARGET_DEVICE/d' .config
sed -i '/CONFIG_TARGET_ALL_PROFILES/d' .config
tee -a .config <<EOF
CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_bananapi_bpi-r3-kmod=y
CONFIG_TARGET_DEVICE_PACKAGES_mediatek_filogic_DEVICE_bananapi_bpi-r3-kmod=""
CONFIG_TARGET_OPTIONS=y
CONFIG_TARGET_OPTIMIZATION="-O3 -pipe -mcpu=cortex-a53 -Wno-error"
CONFIG_TARGET_ALL_PROFILES=n
EOF

make defconfig
