#!/usr/bin/env bash
#region Definitions

source lm-utility.sh

OPENWRT_GIT_REPO_URL="git://git.openwrt.org/openwrt/openwrt.git"

#endregion
#region Main

logInfo "Install script utilities"

sudo apt install unbuffer expect

logInfo "Install OpenWRT build system dependencies"

# https://openwrt.org/docs/guide-developer/toolchain/install-buildsystem#debianubuntu
# https://openwrt.org/docs/guide-developer/toolchain/wsl
sudo apt update
sudo apt install \
    build-essential clang flex bison g++ gawk gcc-multilib g++-multilib \
    gettext git libncurses5-dev libssl-dev python3-setuptools rsync swig unzip \
    zlib1g-dev file wget

logInfo "Setup build configuration for forked repo"

# https://github.com/microsoft/WSL/issues/10006#issuecomment-3150737313
timedatectl set-timezone America/Chicago
sudo timedatectl set-ntp false
# wsl.exe --shutdown

git remote add upstream $OPENWRT_GIT_REPO_URL

./lm-reset-filogic-config.sh

logInfo "Pre-download sources for build step"

make download

#endregion
