#!/usr/bin/env bash
# Full Reset: ./lm-build.sh -c build -r -d

source lm-utility.sh

#region Option Defaults

logLevelBuild="1" # 1-99, s, sc
logFileBuild="build.log"
threadCount=$(($(nproc) - $(nproc) / 4))
cleanTargets=
isPredownloaded=false
isConfigReset=false

#endregion
#region Parse Args

VALID_ARGS=$(getopt -o l:o:t:c:dr --long log:,output:,threads:,clean:,download,reset -- "$@")
if [[ $? -ne 0 ]]; then
  exit 1
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
  -l | --log)
    logLevelBuild=$2
    shift 2
    ;;
  -o | --output)
    logFileBuild=$2
    shift 2
    ;;
  -t | --threads)
    threadCount=$2
    shift 2
    ;;
  -c | --clean)
    cleanTargets=$2
    shift 2
    ;;
  -d | --download)
    isPredownloaded=true
    shift
    ;;
  -r | --reset)
    isConfigReset=true
    shift
    ;;
  --)
    shift
    break
    ;;
  esac
done

logDebug <<EOT
Options:
logLevelBuild=$logLevelBuild
logFileBuild=$logFileBuild
threadCount=$threadCount
cleanTargets=$cleanTargets
isPredownloaded=$isPredownloaded
isConfigReset=$isConfigReset
EOT

#endregion
#region Pre-Build Clean and Preparation

installDependencyIfNotFound unbuffer expect

# https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem#cleaning_up
if [ "$cleanTargets" = kernel ]; then
  logInfo "Pre-build - Clean kernel targets only"
  make target/linux/clean
  make package/boot/uboot-mediatek/clean
  for makeTarget in package/kernel/*; do
    make "package/kernel/$makeTarget/clean"
  done
elif [ "$cleanTargets" = package ]; then
  logInfo "Pre-build - Clean all architecture packages"
  make clean
elif [ "$cleanTargets" = target ]; then
  logInfo "Pre-build - Clean all architecture specific targets"
  make targetclean
elif [ "$cleanTargets" = build ]; then
  logInfo "Pre-build - Clean all local tools and architecture targets"
  make dirclean
else
  logInfo "Pre-build - Clean not performed kernel|package|target|build"
fi

if [ "$isConfigReset" = true ]; then
  ./lm-reset-filogic-config.sh
fi

if [ "$isPredownloaded" = true ]; then
  make download
fi

rm -f "$logFileBuild"

#endregion
#region Build

logInfo "---------- Build START ----------"
logInfo "Running build with params: --log ${C_YELLOW}${logLevelBuild}${C_RESET} --output ${C_YELLOW}${logFileBuild}${C_RESET} --threads ${C_YELLOW}${threadCount}${C_RESET}"

# export IGNORE_ERRORS=1
time unbuffer \
  make -j "$threadCount" V="$logLevelBuild" |
  tee "$logFileBuild"

logSuccess "---------- Build -END- ----------"

#endregion
