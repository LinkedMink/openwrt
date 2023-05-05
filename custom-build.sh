#!/usr/bin/env bash

source custom-utility.sh

# Option Defaults
LOG_LEVEL_BUILD="1" # 1-99, s, sc
LOG_FILE_BUILD="build.log"
THREADS=$(($(nproc) - $(nproc) / 4))
CLEAN=

installDependencyIfNotFound unbuffer expect

# Parse Args
VALID_ARGS=$(getopt -o l:o:t:c: --long log:,output:,threads:,clean: -- "$@")
if [[ $? -ne 0 ]]; then
  exit 1
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
  -l | --log)
    LOG_LEVEL_BUILD=$2
    shift 2
    ;;
  -o | --output)
    LOG_FILE_BUILD=$2
    shift 2
    ;;
  -t | --threads)
    THREADS=$2
    shift 2
    ;;
  -c | --clean)
    CLEAN=$2
    shift 2
    ;;
  --)
    shift
    break
    ;;
  esac
done

# Pre-Build Clean
# https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem#cleaning_up
if [ "$CLEAN" = kernel ]; then
  logInfo "Pre-build - Clean kernel targets only"
  make target/linux/clean
  make package/boot/uboot-mediatek/clean
  for makeTarget in package/kernel/*; do
    make package/kernel/$makeTarget/clean
  done
elif [ "$CLEAN" = package ]; then
  logInfo "Pre-build - Clean all architecture packages"
  make clean
elif [ "$CLEAN" = target ]; then
  logInfo "Pre-build - Clean all architecture specific targets"
  make targetclean
elif [ "$CLEAN" = build ]; then
  logInfo "Pre-build - Clean all local tools and architecture targets"
  make dirclean
else
  logInfo "Pre-build - Clean not performed kernel|package|target|build"
fi

rm $LOG_FILE

# Build

logInfo "---------- Build START ----------"
logInfo "Running build with params: --log ${C_YELLOW}${LOG_LEVEL_BUILD}${C_RESET} --output ${C_YELLOW}${LOG_FILE_BUILD}${C_RESET} --threads ${C_YELLOW}${THREADS}${C_RESET}"

time unbuffer \
  make -j $THREADS V=$LOG_LEVEL_BUILD |
  tee $LOG_FILE_BUILD

logInfo "---------- Build -END- ----------"
