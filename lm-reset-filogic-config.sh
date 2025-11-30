#!/usr/bin/env bash
#region Definitions

source lm-utility.sh

CONFIG_BACKUP_SUFFIX="prereset"

#endregion
#region Main

logInfo "Configs prior to reset will be moved to path: ./config.$CONFIG_BACKUP_SUFFIX"
if [ -f .config ]; then
  rm -f ".config.$CONFIG_BACKUP_SUFFIX"
  mv .config ".config.$CONFIG_BACKUP_SUFFIX"
fi

if [ -f .config.old ]; then
  rm -f ".config.$CONFIG_BACKUP_SUFFIX.old"
  mv .config.old ".config.$CONFIG_BACKUP_SUFFIX.old"
fi

tee -a .config <<EOF
CONFIG_TARGET_mediatek=y
CONFIG_TARGET_mediatek_filogic=y
# CONFIG_TARGET_MULTI_PROFILE is not set
CONFIG_TARGET_mediatek_filogic_DEVICE_bananapi_bpi-r3-kmod=y

# CONFIG_ALL_NONSHARED is not set
# CONFIG_ALL_KMODS is not set
CONFIG_DEVEL=y
CONFIG_TARGET_PER_DEVICE_ROOTFS=y
CONFIG_AUTOREMOVE=y
CONFIG_BUILDBOT=y
CONFIG_COLLECT_KERNEL_DEBUG=y
CONFIG_IB=y
CONFIG_JSON_CYCLONEDX_SBOM=y
CONFIG_KERNEL_BUILD_DOMAIN="buildhost"
CONFIG_KERNEL_BUILD_USER="builder"
CONFIG_MAKE_TOOLCHAIN=y
CONFIG_REPRODUCIBLE_DEBUG_INFO=y
CONFIG_SDK=y
CONFIG_SDK_LLVM_BPF=y

CONFIG_TARGET_ROOTFS_PARTSIZE=768
CONFIG_TARGET_OPTIONS=y
CONFIG_TARGET_PREINIT_IP="192.168.128.32"
CONFIG_TARGET_PREINIT_NETMASK="255.255.255.0"
CONFIG_TARGET_PREINIT_BROADCAST="192.168.128.255"

CONFIG_BTRFS_PROGS_ZSTD=y

EOF

# CONFIG_ALL_KMODS=y
# CONFIG_ALL_NONSHARED=y

# CONFIG_LIBQMI_COLLECTION_FULL=y
# # CONFIG_PACKAGE_kmod-ipt-rtpengine is not set
# # CONFIG_PACKAGE_kmod-openvswitch is not set
# # CONFIG_PACKAGE_kmod-pf-ring is not set

# CONFIG_TARGET_ROOTFS_PERSIST_VAR=y
# CONFIG_TARGET_OPTIMIZATION="-O3 -pipe -mcpu=cortex-a53 -Wno-error"

logInfo "Generate complete default config: .config"

make defconfig

#endregion
