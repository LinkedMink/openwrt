#!/usr/bin/env bash
#region Definitions

source lm-utility.sh

BACKUP_SUFFIX="bak"
BIN_FILES=(
    "openwrt-mediatek-filogic-bananapi_bpi-r3-kmod-sdcard.img.gz"
    "openwrt-mediatek-filogic-bananapi_bpi-r3-kmod-squashfs-sysupgrade.itb"
)
OUTPUT_DIR=${1:-"/mnt/d/bin/openwrt"}

#endregion
#region Main

logInfo "Copying to: $OUTPUT_DIR"

for binFile in "${BIN_FILES[@]}"; do
    if [ -f "$OUTPUT_DIR/$binFile" ]; then
        rm -f "$OUTPUT_DIR/$binFile.$BACKUP_SUFFIX"
        mv "$OUTPUT_DIR/$binFile" "$OUTPUT_DIR/$binFile.$BACKUP_SUFFIX"
    fi

    cp "bin/targets/mediatek/filogic/$binFile" "$OUTPUT_DIR/$binFile"
done

#endregion
