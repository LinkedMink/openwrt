#!/usr/bin/env bash

git pull upstream master --no-edit
# cd ./feeds/luci
# git pull upstream master --no-edit
# cd ../../

./scripts/feeds update -a
./scripts/feeds install -a

make defconfig
