#!/usr/bin/env bash
#region Definitions

source lm-utility.sh

OPENWRT_GIT_REPO_URL="git://git.openwrt.org/openwrt/openwrt.git"

#endregion
#region Main

logInfo "Install dependencies"

# https://openwrt.org/docs/guide-developer/toolchain/install-buildsystem#debianubuntu
# https://openwrt.org/docs/guide-developer/toolchain/wsl
sudo apt update
sudo apt install \
    build-essential clang flex bison g++ gawk gcc-multilib g++-multilib \
    gettext git libncurses-dev libssl-dev python3-distutils rsync unzip zlib1g-dev \
    file wget

logInfo "Setup build configuration for forked repo"

git remote add upstream $OPENWRT_GIT_REPO_URL

./reset-extended-filogic-config.sh

logInfo "Pre-download sources for build step"

make download

#endregion
