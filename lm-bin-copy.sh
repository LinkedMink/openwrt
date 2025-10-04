#!/usr/bin/env bash
#region Definitions

source lm-utility.sh

BACKUP_SUFFIX="bak"
BIN_FILES=(
    "openwrt-mediatek-filogic-bananapi_bpi-r3-kmod-sdcard.img.gz"
    "openwrt-mediatek-filogic-bananapi_bpi-r3-kmod-squashfs-sysupgrade.itb"
)
OUTPUT_DIR=${1:-"/mnt/e/bin/openwrt"}

copyBinFile() {
    local binFile=$1

    if [ -f "$OUTPUT_DIR/$binFile" ]; then
        local backupCount=0
        local fileName="${binFile%%.*}"
        local fileExtension="${binFile#*.}"
        local backupPath="${OUTPUT_DIR}/${fileName}.${backupCount}.${fileExtension}"

        while [ -f "$backupPath" ]
        do
            backupCount=$((backupCount + 1))
            backupPath="${OUTPUT_DIR}/${fileName}.${backupCount}.${fileExtension}"
        done

        mv "$OUTPUT_DIR/$binFile" "$backupPath"
    fi

    cp "bin/targets/mediatek/filogic/$binFile" "$OUTPUT_DIR/$binFile"
}

#endregion
#region Main

logInfo "Copying to: $OUTPUT_DIR"

for binFile in "${BIN_FILES[@]}"; do
    copyBinFile $binFile
done

#endregion
